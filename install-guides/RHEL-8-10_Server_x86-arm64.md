# NVIDIA Cloud Native Stack v14.0 - Install Guide for RHEL Server
## Introduction

This document describes how to setup the NVIDIA Cloud Native Stack collection on a single or multiple NVIDIA Certified Systems. NVIDIA Cloud Native Stack can be configured to create a single node Kubernetes cluster or to create/add additional worker nodes to join an existing cluster.

NVIDIA Cloud Native Stack v14.0 includes:
- RHEL 8.10
- Containerd 2.1.3
- Kubernetes version 1.31.2
- Helm 3.17.2
- NVIDIA GPU Operator 25.3.4
  - NVIDIA GPU Driver: 580.82.07
  - NVIDIA Container Toolkit: 1.17.5
  - NVIDIA K8S Device Plugin: 0.17.1
  - NVIDIA DCGM-Exporter: 4.1.1-4.0.4
  - NVIDIA DCGM: 4.1.1-2
  - NVIDIA GPU Feature Discovery: 0.17.2
  - NVIDIA K8s MIG Manager: 0.12.1
  - Node Feature Discovery: 0.17.2
  - NVIDIA KubeVirt GPU Device Plugin: 1.3.1
  - NVIDIA GDS Driver: 2.20.5
  - NVIDIA Kata Manager for Kubernetes: 0.2.3
  - NVIDIA Confidential Computing Manager for Kubernetes: 0.1.1
- NVIDIA Network Operator 25.1.0
  - Node Feature Discovery: 0.15.6
  - Mellanox MOFED/DOCA Driver 25.01-0.6.0.0-0
  - RDMA Shared Device Plugin 1.5.2
  - SRIOV Device Plugin 3.9.0
  - Container Networking Plugins 1.5.0
  - Multus 4.1.0
  - Whereabouts 0.7.0

## Table of Contents

- [Prerequisites](#Prerequisites)
- [Installing the RHEL Operating System](#Installing-the-RHEL-Operating-System)
- [Installing Container Runtime](#Installing-Container-Runtime)
  - [Installing Containerd](#Installing-Containerd)
  - [Installing CRI-O](#Installing-CRI-O)
- [Installing Kubernetes](#Installing-Kubernetes)
- [Installing Helm](#Installing-Helm)
- [Adding an Additional Node to NVIDIA Cloud Native Stack](#Adding-additional-node-to-NVIDIA-Cloud-Native-Stack)
- [Installing NVIDIA Network Operator](#Installing-NVIDIA-Network-Operator)
- [Installing the GPU Operator](#Installing-the-GPU-Operator)
- [Validating the Network Operator with GPUDirect RDMA](#Validating-the-Network-Operator-with-GPUDirect-RDMA)
- [Validating the GPU Operator](#Validating-the-GPU-Operator)
- [Validate NVIDIA Cloud Native Stack with an Application from NGC](#Validate-NVIDIA-Cloud-Native-Stack-with-an-application-from-NGC)
- [Uninstalling the GPU Operator](#Uninstalling-the-GPU-Operator)
- [Uninstalling the Network Operator](#Uninstalling-the-Network-Operator)

### Prerequisites
 
The following instructions assume the following:

- You have [NVIDIA-Certified Systems](https://docs.nvidia.com/ngc/ngc-deploy-on-premises/nvidia-certified-systems/index.html) with Mellanox CX NICs for x86-64 servers 
- You have [NVIDIA Qualified Systems](https://www.nvidia.com/en-us/data-center/data-center-gpus/qualified-system-catalog/?start=0&count=50&pageNumber=1&filters=eyJmaWx0ZXJzIjpbXSwic3ViRmlsdGVycyI6eyJwcm9jZXNzb3JUeXBlIjpbIkFSTS1UaHVuZGVyWDIiLCJBUk0tQWx0cmEiXX0sImNlcnRpZmllZEZpbHRlcnMiOnt9LCJwYXlsb2FkIjpbXX0=) for ARM servers 
  `NOTE:` For ARM systems, NVIDIA Network Operator is not supported yet.
- You will perform a clean install.

To determine if your system qualifies as an NVIDIA Certified System, review the list of NVIDIA Certified Systems [here](https://docs.nvidia.com/ngc/ngc-deploy-on-premises/nvidia-certified-systems/index.html). 

Please note that NVIDIA Cloud Native Stack is validated only on systems with the default kernel (not HWE).


### Installing the RHEL 8.10 Operating System
These instructions require installing RedHat Enterprise Linux 8.10,  can be downloaded [here](https://access.redhat.com/downloads/content/479/ver=/rhel---8/8.10/x86_64/product-software).

Please reference the [RHEL Server Installation Guide](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html-single/performing_a_standard_rhel_8_installation/index).

### Changing the SELinux State 

Open the `/etc/selinux/config` file in a text editor of your choice, for example:

```
sudo vi /etc/selinux/config
```

Configure the `SELINUX=enforcing` option:
```
# This file controls the state of SELinux on the system.
# SELINUX= can take one of these three values:
#       enforcing - SELinux security policy is enforced.
#       permissive - SELinux prints warnings instead of enforcing.
#       disabled - No SELinux policy is loaded.
SELINUX=enforcing
# SELINUXTYPE= can take one of these two values:
#       targeted - Targeted processes are protected,
#       mls - Multi Level Security protection.
SELINUXTYPE=targeted
```

Save the change, and restart the system:

```
sudo reboot
```

After the system rebooted, run the below command to verify the status 

```
sestatus
```

Expected output:

```
SELinux status:                 enabled
SELinuxfs mount:                /sys/fs/selinux
SELinux root directory:         /etc/selinux
Loaded policy name:             targeted
Current mode:                   enforcing
Mode from config file:          enforcing
Policy MLS status:              enabled
Policy deny_unknown status:     allowed
Memory protection checking:     actual (secure)
Max kernel policy version:      31
```

## Installing Container Runtime

You need to install a container runtime into each node in the cluster so that Pods can run there. Currently Cloud Native Stack provides below container runtimes:

- [Installing Containerd](#Installing-Containerd)
- [Installing CRI-O](#Installing-CRI-O)

`NOTE:` Only install one of either `Containerd` or `CRI-O`, not both!

These steps apply to both runtimes.

Install required packages:

```
sudo dnf install -y yum-utils device-mapper-persistent-data lvm2
```

Configure the `overlay` and `br_netfilter` kernel modules required by Kubernetes:

```
cat <<EOF | sudo tee /etc/modules-load.d/kubernetes.conf
overlay
br_netfilter
EOF
```

```
sudo modprobe overlay
```
```
sudo modprobe br_netfilter
```

Setup required sysctl params; these persist across reboots.
```
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF
```

Apply sysctl params without reboot
```
sudo sysctl --system
```
### Installing Containerd(Option 1)

Download the Containerd for `x86-64` system:

```
wget https://github.com/containerd/containerd/releases/download/v2.1.3/containerd-2.1.3-linux-amd64.tar.gz
```

```
sudo tar --no-overwrite-dir -C / -xzf containerd-2.1.3-linux-amd64.tar.gz
```

```
rm -rf containerd-2.1.3-linux-amd64.tar.gz
```


Download the Containerd for `ARM` system:

```
wget https://github.com/containerd/containerd/releases/download/v2.1.3/containerd-2.1.3-linux-arm64.tar.gz
```

```
sudo tar --no-overwrite-dir -C / -xzf containerd-2.1.3-linux-arm64.tar.gz
```

```
rm -rf containerd-2.1.3-linux-arm64.tar.gz
```

Install the Containerd
```
sudo mkdir -p /etc/containerd
```

```
containerd config default | sudo tee /etc/containerd/config.toml
```

```
sudo sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml
```

```
sudo systemctl restart containerd
```

Install Runc

```
wget https://github.com/opencontainers/runc/releases/download/v1.2.6/runc.amd64
install -m 755 runc.amd64 /usr/local/sbin/runc
```

Install CNI Plugins

```
wget https://github.com/containernetworking/plugins/releases/download/v1.6.2/cni-plugins-linux-amd64-v1.6.2.tgz
sudo mkdir -p /opt/cni/bin
sudo tar -C /opt/cni/bin -xzvf cni-plugins-linux-amd64-v1.6.2.tgz
sudo systemctl restart containerd
```

For additional information on installing Containerd, please reference [Install Containerd with Release Tarball](https://github.com/containerd/containerd/blob/master/docs/cri/installation.md).

### Installing CRI-O(Option 2)

Setup the Yum repositry for CRI-O

```
OS=CentOS_8
VERSION=1.31
```
`NOTE:` VERSION (CRI-O version) is same as kubernetes major version 

```
sudo curl -L -o /etc/yum.repos.d/devel:kubic:libcontainers:stable.repo https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/CentOS_8/devel:kubic:libcontainers:stable.repo
```

```
sudo curl -L -o /etc/yum.repos.d/devel:kubic:libcontainers:stable:cri-o:$VERSION.repo https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable:cri-o:$VERSION/CentOS_8/devel:kubic:libcontainers:stable:cri-o:$VERSION.repo
```


Install the CRI-O and dependencies 

```
sudo dnf install cri-o cri-tools
```

Enable and Start the CRI-O service 

```
sudo systemctl enable crio.service && sudo systemctl start crio.service
```

### Installing Kubernetes 

Execute the following to install prerequisites:

```
 sudo yum update && sudo yum install -y net-tools curl ca-certificates
```

Create kubernetes.repo:

```
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.31/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.31/rpm/repodata/repomd.xml.key
exclude=kubelet kubeadm kubectl cri-tools kubernetes-cni
EOF
```

Now execute the below to install kubelet, kubeadm, and kubectl:

```
 sudo dnf install -y kubelet-1.31.2 kubeadm-1.31.2 kubectl-1.31.2
```

Create a kubelet default with your container runtime:
`NOTE:`  The container runtime endpoint will be `unix:/run/containerd/containerd.sock` or `unix:/run/crio/crio.sock` depending on which container runtime you chose in the previous steps.

For `Containerd` system:

```
 cat <<EOF | sudo tee /etc/default/kubelet
KUBELET_EXTRA_ARGS=--cgroup-driver=systemd --runtime-request-timeout=15m --container-runtime-endpoint="unix:/run/containerd/containerd.sock"
EOF
```

For `CRI-O` system:

```
cat <<EOF | sudo tee /etc/default/kubelet
KUBELET_EXTRA_ARGS=--cgroup-driver=systemd --runtime-request-timeout=15m --container-runtime-endpoint="unix:/run/crio/crio.sock"
EOF
```

Reload the system daemon:
```
sudo systemctl daemon-reload
```

Disable swap:
```
sudo swapoff -a
```

```
sudo nano /etc/fstab
```

`NOTE:` Add a # before all the lines that start with /swap. # is a comment, and the result should look something like this:

```
UUID=e879fda9-4306-4b5b-8512-bba726093f1d / ext4 defaults 0 0
UUID=DCD4-535C /boot/efi vfat defaults 0 0
#/swap.img       none    swap    sw      0       0
```

#### Initializing the Kubernetes cluster to run as a control-plane node

Execute the following command for `Containerd` systems:

```
sudo kubeadm init --pod-network-cidr=192.168.32.0/22 --cri-socket=/run/containerd/containerd.sock --kubernetes-version="v1.31.2"
```

Eecute the following command for `CRI-O` systems:

```
sudo kubeadm init --pod-network-cidr=192.168.32.0/22 --cri-socket=unix:/run/crio/crio.sock --kubernetes-version="v1.31.2"
```

Output:
```
Your Kubernetes control-plane has initialized successfully!
 
To start using your cluster, you need to run the following as a regular user:
 
  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config
 
Alternatively, if you are the root user, you can run:
 
  export KUBECONFIG=/etc/kubernetes/admin.conf
 
You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/
 
Then you can join any number of worker nodes by running the following on each as root:
 
kubeadm join <your-host-IP>:6443 --token 489oi5.sm34l9uh7dk4z6cm \
        --discovery-token-ca-cert-hash sha256:17165b6c4a4b95d73a3a2a83749a957a10161ae34d2dfd02cd730597579b4b34
```


Following the instructions in the output, execute the commands as shown below:

```
mkdir -p $HOME/.kube
```

```
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
```

```
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

With the following command, you install a pod-network add-on to the control plane node. We are using calico as the pod-network add-on here:

```
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.2/manifests/calico.yaml
```

Update the Calico Daemonset 

```
kubectl set env daemonset/calico-node -n kube-system IP_AUTODETECTION_METHOD=interface=ens\*,eth\*,enc\*,enp\*
```

You can execute the below commands to ensure that all pods are up and running:

```
kubectl get pods --all-namespaces
```

Output:

```
NAMESPACE     NAME                                       READY   STATUS    RESTARTS   AGE
kube-system   calico-kube-controllers-65b8787765-bjc8h   1/1     Running   0          2m8s
kube-system   calico-node-c2tmk                          1/1     Running   0          2m8s
kube-system   coredns-5c98db65d4-d4kgh                   1/1     Running   0          9m8s
kube-system   coredns-5c98db65d4-h6x8m                   1/1     Running   0          9m8s
kube-system   etcd-#yourhost                             1/1     Running   0          8m25s
kube-system   kube-apiserver-#yourhost                   1/1     Running   0          8m7s
kube-system   kube-controller-manager-#yourhost          1/1     Running   0          8m3s
kube-system   kube-proxy-6sh42                           1/1     Running   0          9m7s
kube-system   kube-scheduler-#yourhost                   1/1     Running   0          8m26s
```

The get nodes command shows that the control-plane node is up and ready:

```
kubectl get nodes
```

Output:

```
NAME             STATUS   ROLES                  AGE   VERSION
#yourhost        Ready    control-plane          10m   v1.31.2
```

Since we are using a single-node Kubernetes cluster, the cluster will not schedule pods on the control plane node by default. To schedule pods on the control plane node, we have to remove the taint by executing the following command:

```
kubectl taint nodes --all node-role.kubernetes.io/control-plane-
```

Refer to [Installing Kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/)
for more information.

### Installing Helm 

Execute the following command to download and install Helm 3.17.2 for `x86-64` system: 

```
wget https://get.helm.sh/helm-v3.17.2-linux-amd64.tar.gz
```

```
tar -zxvf helm-v3.17.2-linux-amd64.tar.gz
 ```
 
 ```
sudo mv linux-amd64/helm /usr/local/bin/helm
 ```

 ```
rm -rf helm-v3.17.2-linux-amd64.tar.gz linux-amd64/
```

Download and install Helm 3.17.2 for `ARM` system: 

```
wget https://get.helm.sh/helm-v3.17.2-linux-arm64.tar.gz
```

```
tar -zxvf helm-v3.17.2-linux-arm64.tar.gz
 ```
 
```
sudo mv linux-arm64/helm /usr/local/bin/helm
```

```
rm -rf helm-v3.17.2-linux-arm64.tar.gz linux-arm64/
```

Refer to the Helm 3.17.2 [release notes](https://github.com/helm/helm/releases) and the [Installing Helm guide](https://helm.sh/docs/using_helm/#installing-helm) for more information.


### Adding an Additional Node to NVIDIA Cloud Native Stack

`NOTE:` If you're not adding additional nodes, please skip this step and proceed to the next step [Installing NVIDIA Network Operator](#Installing-NVIDIA-Network-Operator)

Make sure to install the Containerd and Kubernetes packages on additional nodes.

Prerequisites: 
- [Installing Containerd](#Installing-Containerd)
- [Installing Kubernetes](#Installing-Kubernetes)
- [Disable swap](#Disable-swap)

Once the prerequisites are completed on the additional nodes, execute the below command on the control-plane node and then execute the join command output on an additional node to add the additional node to NVIDIA Cloud Native Stack:

```
sudo kubeadm token create --print-join-command
```

Output:
```
example: 
sudo kubeadm join 10.110.0.34:6443 --token kg2h7r.e45g9uyrbm1c0w3k     --discovery-token-ca-cert-hash sha256:77fd6571644373ea69074dd4af7b077bbf5bd15a3ed720daee98f4b04a8f524e
```
`NOTE`: control-plane node and worker node should not have the same node name. 

The get nodes command shows that the master and worker nodes are up and ready:

```
kubectl get nodes
```

Output:

```
NAME             STATUS   ROLES                  AGE   VERSION
#yourhost        Ready    control-plane          10m   v1.31.2
#yourhost-worker Ready                           10m   v1.31.2
```

### Adding an Additional Node to NVIDIA Cloud Native Stack

`NOTE:` If you're not adding additional nodes, please skip this step and proceed to the next step [Installing NVIDIA Network Operator](#Installing-NVIDIA-Network-Operator)

Make sure to install the Containerd and Kubernetes packages on additional nodes.

Prerequisites: 
- [Installing Containerd](#Installing-Containerd)
- [Installing Kubernetes](#Installing-Kubernetes)
- [Disable swap](#Disable-swap)

Once the prerequisites are completed on the additional nodes, execute the below command on the control-plane node and then execute the join command output on an additional node to add the additional node to NVIDIA Cloud Native Stack:

```
 sudo kubeadm token create --print-join-command
```

Output:
```
example: 
sudo kubeadm join 10.110.0.34:6443 --token kg2h7r.e45g9uyrbm1c0w3k     --discovery-token-ca-cert-hash sha256:77fd6571644373ea69074dd4af7b077bbf5bd15a3ed720daee98f4b04a8f524e
```
`NOTE`: control-plane node and worker node should not have the same node name. 

The get nodes command shows that the master and worker nodes are up and ready:

```
 kubectl get nodes
```

Output:

```
NAME             STATUS   ROLES                  AGE   VERSION
#yourhost        Ready    control-plane          10m   v1.31.2
#yourhost-worker Ready                           10m   v1.31.2
```

### Installing NVIDIA Network Operator

`NOTE:` If Mellanox NICs are not connected to your nodes, please skip this step and proceed to the next step [Installing GPU Operator](#Installing-GPU-Operator)

The below instructions assume that Mellanox NICs are connected to your machines.

Execute the below command to verify Mellanox NICs are enabled on your machines:

```
 lspci | grep -i "Mellanox"
```

Output:
```
0c:00.0 Ethernet controller: Mellanox Technologies MT2892 Family [ConnectX-6 Dx]
0c:00.1 Ethernet controller: Mellanox Technologies MT2892 Family [ConnectX-6 Dx]
```
Execute the below command to determine which Mellanox device is active:

`NOTE:` Use whicever device shows as `Link Detected: yes` in further steps. The below command works only if you add the NICs before installing the Operating System.

```
for device in `sudo lshw -class network -short | grep -i ConnectX | awk '{print $2}' | egrep -v 'Device|path' | sed '/^$/d'`;do echo -n $device; sudo ethtool $device | grep -i "Link detected"; done
```
Output:
```
ens160f0        Link detected: yes
ens160f1        Link detected: no
```

Create the custom network operator values.yaml and update the active Mellanox device from the above command:
```
nano network-operator-values.yaml
deployCR: true
ofedDriver:
  deploy: true
rdmaSharedDevicePlugin:
  deploy: true
  resources:
    - name: rdma_shared_device_a
      vendors: [15b3]
      devices: [ens160f0]
```

For more information about custom network operator values.yaml, please refer [Network Operator](https://docs.mellanox.com/display/COKAN10/Network+Operator#NetworkOperator-Example2:RDMADevicePluginConfiguration)

Add the NVIDIA repo:
```
 helm repo add mellanox https://mellanox.github.io/network-operator
```

Update the Helm repo:
```
 helm repo update
```
Install Network Operator:
```
 kubectl label nodes --all node-role.kubernetes.io/master- --overwrite
 helm install -f --version 25.1.0 ./network-operator-values.yaml -n network-operator --create-namespace --wait network-operator mellanox/network-operator
```
#### Validating the State of the Network Operator

Please note that the installation of the Network Operator can take a couple of minutes. How long the installation will take depends on your internet speed.

```
kubectl get pods --all-namespaces | egrep 'network-operator|nvidia-network-operator-resources'
```

```
NAMESPACE                           NAME                                                              READY   STATUS      RESTARTS   AGE
network-operator                    network-operator-547cb8d999-mn2h9                                 1/1     Running            0          17m
network-operator                    network-operator-node-feature-discovery-master-596fb8b7cb-qrmvv   1/1     Running            0          17m
network-operator                    network-operator-node-feature-discovery-worker-qt5xt              1/1     Running            0          17m
nvidia-network-operator-resources   cni-plugins-ds-dl5vl                                              1/1     Running            0          17m
nvidia-network-operator-resources   kube-multus-ds-w82rv                                              1/1     Running            0          17m
nvidia-network-operator-resources   mofed-ubuntu20.04-ds-xfpzl                                        1/1     Running            0          17m
nvidia-network-operator-resources   rdma-shared-dp-ds-2hgb6                                           1/1     Running            0          17m
nvidia-network-operator-resources   sriov-device-plugin-ch7bz                                         1/1     Running            0          10m
nvidia-network-operator-resources   whereabouts-56ngr                                                 1/1     Running            0          10m
```

Please refer to the [Network Operator page](https://docs.mellanox.com/display/COKAN10/Network+Operator) for more information.

### Installing GPU Operator

Add the NVIDIA repo:

```
 helm repo add nvidia https://helm.ngc.nvidia.com/nvidia
```

Update the Helm repo:

```
 helm repo update
```

Install GPU Operator:

`NOTE:` If you installed Network Operator, please skip the below command and follow the [GPU Operator with RDMA](#GPU-Operator-with-RDMA)

```
 helm install --version 25.3.4 --create-namespace --namespace nvidia-gpu-operator nvidia/gpu-operator --wait --generate-name
```

#### GPU Operator with RDMA 

- Prerequisites:
  - Please install the [Network Operator](#Installing NVIDIA Network Operator) to ensure that the MOFED drivers are installed. 

After Network Operator installation is completed, execute the below command to install the GPU Operator to load nv_peer_mem modules:

```
 helm install --version 25.3.4 --create-namespace --namespace nvidia-gpu-operator nvidia/gpu-operator  --set driver.rdma.enabled=true  --wait --generate-name
```

#### GPU Operator with Host MOFED Driver and RDMA 

If the host is already installed MOFED driver without network operator, execute the below command to install the GPU Operator to load nv_peer_mem module 

```
 helm install --version 25.3.4 --create-namespace --namespace nvidia-gpu-operator nvidia/gpu-operator --set driver.rdma.enabled=true,driver.rdma.useHostMofed=true --wait --generate-name 

```

### GPU Operator with GPU Direct Storage(GDS) 

Execute the below command to enable the GPU Direct Storage Driver on GPU Operator 

```
helm install --version 25.3.4 --create-namespace --namespace nvidia-gpu-operator nvidia/gpu-operator --set gds.enabled=true
```
For more information refer, [GPU Direct Storage](https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/gpu-operator-rdma.html)

#### Validating the State of the GPU Operator:

Please note that the installation of the GPU Operator can take a couple of minutes. How long the installation will take depends on your internet speed.

```
kubectl get pods --all-namespaces | grep -v kube-system
```

```
NAMESPACE                NAME                                                              READY   STATUS      RESTARTS   AGE
default                  gpu-operator-1622656274-node-feature-discovery-master-5cddq96gq   1/1     Running     0          2m39s
default                  gpu-operator-1622656274-node-feature-discovery-worker-wr88v       1/1     Running     0          2m39s
default                  gpu-operator-7db468cfdf-mdrdp                                     1/1     Running     0          2m39s
nvidia-gpu-operator      gpu-feature-discovery-g425f                                       1/1     Running     0          2m20s
nvidia-gpu-operator      nvidia-container-toolkit-daemonset-mcmxj                          1/1     Running     0          2m20s
nvidia-gpu-operator      nvidia-cuda-validator-s6x2p                                       0/1     Completed   0          48s
nvidia-gpu-operator      nvidia-dcgm-exporter-wtxnx                                        1/1     Running     0          2m20s
nvidia-gpu-operator      nvidia-dcgm-jbz94                                                 1/1     Running     0          2m20s
nvidia-gpu-operator      nvidia-device-plugin-daemonset-hzzdt                              1/1     Running     0          2m20s
nvidia-gpu-operator      nvidia-device-plugin-validator-9nkxq                              0/1     Completed   0          17s
nvidia-gpu-operator      nvidia-driver-daemonset-kt8g5                                     1/1     Running     0          2m20s
nvidia-gpu-operator      nvidia-operator-validator-cw4j5                                   1/1     Running     0          2m20s

```

Please refer to the [GPU Operator page](https://ngc.nvidia.com/catalog/helm-charts/nvidia:gpu-operator) on NGC for more information.

For multiple worker nodes, execute the below command to fix the CoreDNS and Node Feature Discovery. 

```
kubectl delete pods $(kubectl get pods -n kube-system | grep core | awk '{print $1}') -n kube-system; kubectl delete pod $(kubectl get pods -o wide -n nvidia-gpu-operator | grep node-feature-discovery | grep -v master | awk '{print $1}') -n nvidia-gpu-operator
```

#### GPU Operator with MIG

`NOTE:` Only A100 and A30 GPUs are supported for GPU Operator with MIG

Multi-Instance GPU (MIG) allows GPUs based on the NVIDIA Ampere architecture (such as NVIDIA A100) to be securely partitioned into separate GPU instances for CUDA applications. For more information about enabling the MIG capability, please refer to [GPU Operator with MIG](https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/gpu-operator-mig.html) 

### Validating the Network Operator with GPUDirect RDMA

Execute the below command to list the Mellanox NIC's with the status:
```
kubectl exec -it $(kubectl get pods -n nvidia-network-operator-resources | grep mofed | awk '{print $1}') -n nvidia-network-operator-resources -- ibdev2netdev
```
Output:
```
mlx5_0 port 1 ==> ens192f0 (Up)
mlx5_1 port 1 ==> ens192f1 (Down)
```

Create network definition for IPAM and replace the `ens192f0` with an active Mellanox device for `master`:
```
$ nano networkdefinition.yaml 
apiVersion: k8s.cni.cncf.io/v1
kind: NetworkAttachmentDefinition
metadata:
  annotations:
    k8s.v1.cni.cncf.io/resourceName: rdma/rdma_shared_device_a
  name: rdma-net-ipam
  namespace: default
spec:
  config: |-
    {
        "cniVersion": "0.3.1",
        "name": "rdma-net-ipam",
        "plugins": [
            {
                "ipam": {
                    "datastore": "kubernetes",
                    "kubernetes": {
                        "kubeconfig": "/etc/cni/net.d/whereabouts.d/whereabouts.kubeconfig"
                    },
                    "log_file": "/tmp/whereabouts.log",
                    "log_level": "debug",
                    "range": "192.168.112.0/24",
                    "type": "whereabouts"
                },
                "type": "macvlan",
                "master": "ens192f0"
            },
            {
                "mtu": 1500,
                "type": "tuning"
            }
        ]
    }
EOF
``` 
`NOTE:` If you do not have VLAN-based networking on the high-performance side, please set "vlan": 0

 
Execute the below command to install network definition on NVIDIA Cloud Native Stack from the control-plane node:
 
 ```
kubectl apply -f networkdefinition.yaml 
 ```
 
Now create the pod YAML with the below content:

``` 
cat <<EOF | tee mellanox-test.yaml
apiVersion: v1
kind: Pod
metadata:
  name: rdma-test-pod-1
  annotations:
    k8s.v1.cni.cncf.io/networks: rdma-net-ipam
    # If a network with static IPAM is used replace network annotation with the below.
    #k8s.v1.cni.cncf.io/networks: '[
    #  { "name": "rmda-net-ipam",
    #    "ips": ["192.168.111.101/24"],
    #    "gateway": ["192.168.111.1"]
    #  }
    #]'
spec:
  restartPolicy: OnFailure
  containers:
  - image: mellanox/rping-test
    name: rdma-test-ctr
    securityContext:
      capabilities:
        add: [ "IPC_LOCK" ]
    resources:
      limits:
        rdma/rdma_shared_device_a: 1
      requests:
        rdma/rdma_shared_device_a: 1
    command:
    - sh
    - -c
    - |
      ls -l /dev/infiniband /sys/class/net
      sleep infinity
---
apiVersion: v1
kind: Pod
metadata:
  name: rdma-test-pod-2
  annotations:
    k8s.v1.cni.cncf.io/networks: rdma-net-ipam
    # If a network with static IPAM is used replace network annotation with the below.
    #k8s.v1.cni.cncf.io/networks: '[
    #  { "name": "rmda-net-ipam",
    #    "ips": ["192.168.111.101/24"],
    #    "gateway": ["192.168.111.1"]
    #  }
    #]'
spec:
  restartPolicy: OnFailure
  containers:
  - image: mellanox/rping-test
    name: rdma-test-ctr
    securityContext:
      capabilities:
        add: [ "IPC_LOCK" ]
    resources:
      limits:
        rdma/rdma_shared_device_a: 1
      requests:
        rdma/rdma_shared_device_a: 1
    command:
    - sh
    - -c
    - |
      ls -l /dev/infiniband /sys/class/net
      sleep infinity
EOF
 ```

Apply the Mellanox test pod to the NVIDIA Cloud Native Stack  for the validation:
```
kubectl apply -f mellanox-test.yaml
```

Once you apply, verify the `rdma-test-pod-1` pod logs. You should see the expected output as shown below:
`NOTE:` How long the pods take to run depends on your internet speed.

Expected Output:
```
kubectl logs rdma-test-pod-1

/dev/infiniband:
total 0
crw------- 1 root root 231,  64 Jun 1 02:26 issm0
crw-rw-rw- 1 root root  10,  54 Jun 1 02:26 rdma_cm
crw------- 1 root root 231,   0 Jun 1 02:26 umad0
crw-rw-rw- 1 root root 231, 192 Jun 1 02:26 uverbs0
 
/sys/class/net:
total 0
lrwxrwxrwx 1 root root 0 Jun 1 02:26 eth0 -> ../../devices/virtual/net/eth0
lrwxrwxrwx 1 root root 0 Jun 1 02:26 lo -> ../../devices/virtual/net/lo
lrwxrwxrwx 1 root root 0 Jun 1 02:26 net1 -> ../../devices/virtual/net/net1
lrwxrwxrwx 1 root root 0 Jun 1 02:26 tunl0 -> ../../devices/virtual/net/tunl0
```

Execute the below command to list the Mellanox NIC's with the status:
```
kubectl exec -it $(kubectl get pods -n nvidia-network-operator-resources | grep mofed | awk '{print $1}') -n nvidia-network-operator-resources -- ibdev2netdev
```
Output:
```
mlx5_0 port 1 ==> ens192f0 (Up)
mlx5_1 port 1 ==> ens192f1 (Down)
```

Update the above Mellanox NIC, for which status is `Up` in the below command:

```
kubectl exec -it rdma-test-pod-1 -- bash

[root@rdma-test-pod-1 /]# ib_write_bw -d mlx5_0 -a -F --report_gbits -q 1
************************************
* Waiting for client to connect... *
************************************
```

In a separate terminal, print the network address of the secondary interface on the `rdma-test-pod-1` pod:

```
$ kubectl exec rdma-test-pod-1 -- ip addr show dev net1
5: net1@if24: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9000 qdisc noqueue state UP group default
    link/ether 62:51:fb:13:88:ce brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 192.168.111.1/24 brd 192.168.111.255 scope global net1
       valid_lft forever preferred_lft forever
```

Execute the below command with the above inet address to verify the nv_peer_memory performance on NVIDIA Cloud Native Stack:
```
$ kubectl exec -it rdma-test-pod-2 -- bash
[root@rdma-test-pod-1 /]# ib_write_bw -d mlx5_0 -a -F --report_gbits -q 1 192.168.111.2
---------------------------------------------------------------------------------------
                    RDMA_Write BW Test
 Dual-port       : OFF		Device         : mlx5_0
 Number of qps   : 1		Transport type : IB
 Connection type : RC		Using SRQ      : OFF
 TX depth        : 128
 CQ Moderation   : 100
 Mtu             : 1024[B]
 Link type       : Ethernet
 GID index       : 4
 Max inline data : 0[B]
 rdma_cm QPs	 : OFF
 Data ex. method : Ethernet
---------------------------------------------------------------------------------------
 local address: LID 0000 QPN 0x0137 PSN 0x3c5d65 RKey 0x00370e VAddr 0x007ff44bf1d000
 GID: 00:00:00:00:00:00:00:00:00:00:255:255:192:168:111:01
 remote address: LID 0000 QPN 0x0136 PSN 0x475031 RKey 0x002c23 VAddr 0x007fd3d83cb000
 GID: 00:00:00:00:00:00:00:00:00:00:255:255:192:168:111:02
---------------------------------------------------------------------------------------
 #bytes     #iterations    BW peak[Gb/sec]    BW average[Gb/sec]   MsgRate[Mpps]
 2          5000           0.080755            0.073090            4.568094
 4          5000             0.16               0.15   		   4.588128
 8          5000             0.31               0.29   		   4.567442
 16         5000             0.66               0.59   		   4.647555
 32         5000             1.35               1.22   		   4.776518
 64         5000             2.50               2.29   		   4.481806
 128        5000             5.34               4.73   		   4.621828
 256        5000             10.53              9.11   		   4.448153
 512        5000             21.03              17.05  		   4.162100
 1024       5000             38.67              34.16  		   4.169397
 2048       5000             47.11              43.50  		   2.655219
 4096       5000             51.29              51.02  		   1.557094
 8192       5000             52.00              51.98  		   0.793178
 16384      5000             52.33              52.32  		   0.399164
 32768      5000             52.47              52.47  		   0.200143
 65536      5000             52.51              52.50  		   0.100143
 131072     5000             52.51              52.51  		   0.050078
 262144     5000             52.49              52.49  		   0.025029
 524288     5000             52.50              52.50  		   0.012517
 1048576    5000             52.51              52.51  		   0.006260
 2097152    5000             52.51              52.51  		   0.003130
 4194304    5000             52.51              52.51  		   0.001565
 8388608    5000             52.52              52.52  		   0.000783
---------------------------------------------------------------------------------------
```

```
[root@rdma-test-pod-1 /]# ib_write_bw -d mlx5_0 -a -F --report_gbits -q 1

************************************
* Waiting for client to connect... *
************************************
---------------------------------------------------------------------------------------
                    RDMA_Write BW Test
 Dual-port       : OFF		Device         : mlx5_0
 Number of qps   : 1		Transport type : IB
 Connection type : RC		Using SRQ      : OFF
 CQ Moderation   : 100
 Mtu             : 1024[B]
 Link type       : Ethernet
 GID index       : 8
 Max inline data : 0[B]
 rdma_cm QPs	 : OFF
 Data ex. method : Ethernet
---------------------------------------------------------------------------------------
 local address: LID 0000 QPN 0x0136 PSN 0x475031 RKey 0x002c23 VAddr 0x007fd3d83cb000
 GID: 00:00:00:00:00:00:00:00:00:00:255:255:192:168:111:02
 remote address: LID 0000 QPN 0x0137 PSN 0x3c5d65 RKey 0x00370e VAddr 0x007ff44bf1d000
 GID: 00:00:00:00:00:00:00:00:00:00:255:255:192:168:111:01
---------------------------------------------------------------------------------------
 #bytes     #iterations    BW peak[Gb/sec]    BW average[Gb/sec]   MsgRate[Mpps]
 8388608    5000             52.52              52.52  		   0.000783
---------------------------------------------------------------------------------------
```
The benchmark achieved approximately 52 Gbps throughput.

Exit from RDMA test pods and then delete the RDMA test pods with the below command:

```
$ kubectl delete pod rdma-test-pod-1 rdma-test-pod-2
```

### Validating the GPU Operator

GPU Operator validates the  through the nvidia-device-plugin-validation pod and the nvidia-driver-validation pod. If both are completed successfully (see output from kubectl get pods --all-namespaces | grep -v kube-system), NVIDIA Cloud Native Stack is working as expected. This section provides two examples of validating that the GPU is usable from within a pod to validate the  manually.

#### Example 1: nvidia-smi

Execute the following:

```
cat <<EOF | tee nvidia-smi.yaml
apiVersion: v1
kind: Pod
metadata:
  name: nvidia-smi
spec:
  restartPolicy: OnFailure
  containers:
    - name: nvidia-smi
      image: "nvidia/cuda:12.4.0-base-centos7"
      args: ["nvidia-smi"]
EOF
```

```
kubectl apply -f nvidia-smi.yaml
```

```
kubectl logs nvidia-smi
```

Output:

``` 
Mon Mar 31 20:39:28 2025
+-----------------------------------------------------------------------------------------+
| NVIDIA-SMI 580.82.07             Driver Version: 580.82.07     CUDA Version: 12.8     |
|-----------------------------------------+------------------------+----------------------+
| GPU  Name                 Persistence-M | Bus-Id          Disp.A | Volatile Uncorr. ECC |
| Fan  Temp   Perf          Pwr:Usage/Cap |           Memory-Usage | GPU-Util  Compute M. |
|                                         |                        |               MIG M. |
|=========================================+========================+======================|
|   0  NVIDIA A100-SXM4-80GB          On  |   00000000:03:00.0 Off |                    0 |
| N/A   29C    P0             50W /  275W |       1MiB /  81920MiB |      0%      Default |
|                                         |                        |             Disabled |
+-----------------------------------------+------------------------+----------------------+

+-----------------------------------------------------------------------------------------+
| Processes:                                                                              |
|  GPU   GI   CI              PID   Type   Process name                        GPU Memory |
|        ID   ID                                                               Usage      |
|=========================================================================================|
|  No running processes found                                                             |
+-----------------------------------------------------------------------------------------+
```


#### Example 2: CUDA-Vector-Add

`NOTE:` CUDA Vector Validation is not available for ARM systems yet.

Create a pod YAML file:

```
cat <<EOF | tee cuda-samples.yaml
apiVersion: v1
kind: Pod
metadata:
  name: cuda-vector-add
spec:
  restartPolicy: OnFailure
  containers:
    - name: cuda-vector-add
      image: "k8s.gcr.io/cuda-vector-add:v0.1"
EOF
```

Execute the below command to create a sample GPU pod:

```
kubectl apply -f cuda-samples.yaml
```

Confirm the cuda-samples pod was created:

```
kubectl get pods
``` 

NVIDIA Cloud Native Stack works as expected if the get pods command shows the pod status as completed.

### Validate NVIDIA Cloud Native Stack with an Application from NGC
Another option to validate NVIDIA Cloud Native Stack is by running a demo application hosted on NGC.

NGC is NVIDIA's GPU-optimized software hub. NGC provides a curated set of GPU-optimized software for AI, HPC, and visualization. The content provided by NVIDIA and third-party ISVs simplify building, customizing, and integrating GPU-optimized software into workflows, accelerating the time to solutions for users.

Containers, pre-trained models, Helm charts for Kubernetes deployments, and industry-specific AI toolkits with software development kits (SDKs) are hosted on NGC. For more information about how to deploy an application that is hosted on NGC or the NGC Private Registry, please refer to this [NGC Registry Guide](https://github.com/NVIDIA/cloud-native-stack/blob/master/install-guides/NGC_Registry_Guide_v1.0.md). Visit the [public NGC documentation](https://docs.nvidia.com/ngc) for more information.

The steps in this section use the publicly available DeepStream - Intelligent Video Analytics (IVA) demo application Helm Chart. The application can validate the full NVIDIA Cloud Native Stack and test the connectivity of NVIDIA Cloud Native Stack to remote sensors. DeepStream delivers real-time AI-based video and image understanding and multi-sensor processing on GPUs. For more information, please refer to the [Helm Chart](https://ngc.nvidia.com/catalog/helm-charts/nvidia:video-analytics-demo).

There are two ways to configure the DeepStream - Intelligent Video Analytics Demo Application on your NVIDIA Cloud Native Stack

- Using a camera
- Using the integrated video file (no camera required)

#### Using a camera

##### Prerequisites: 
- RTSP Camera stream

Go through the below steps to install the demo application:
```
1. helm fetch https://helm.ngc.nvidia.com/nvidia/charts/video-analytics-demo-0.1.9.tgz --untar

2. cd into the folder video-analytics-demo and update the file values.yaml

3. Go to the section Cameras in the values.yaml file and add the address of your IP camera. Read the comments section on how it can be added. Single or multiple cameras can be added as shown below

cameras:
 camera1: rtsp://XXXX
```

Execute the following command to deploy the demo application:
```
helm install video-analytics-demo --name-template iva
```

Once the Helm chart is deployed, access the application with the VLC player. See the instructions below. 

#### Using the integrated video file (no camera)

If you dont have a camera input, please execute the below commands to use the default video already integrated into the application:

```
helm fetch https://helm.ngc.nvidia.com/nvidia/charts/video-analytics-demo-0.1.9.tgz

helm install video-analytics-demo-0.1.9.tgz --name-template iva
```

Once the helm chart is deployed, access the application with the VLC player as per the below instructions. 
For more information about the demo application, please refer to the [application NGC page](https://ngc.nvidia.com/catalog/helm-charts/nvidia:video-analytics-demo)

#### Access from WebUI

Use the below WebUI URL to access the video analytic demo application from the browser:
```
http://IPAddress of Node:31115/
```

#### Access from VLC

Download VLC Player from https://www.videolan.org/vlc/ on the machine where you intend to view the video stream.

View the video stream in VLC by navigating to Media > Open Network Stream > Entering the following URL:

```
rtsp://IPAddress of Node:31113/ds-test
```

You should see the video output like below with the AI model detecting objects.

![Deepstream_Video](screenshots/Deepstream.png)

`NOTE:` Video stream in VLC will change if you provide an input RTSP camera.


### Uninstalling the GPU Operator 

Execute the below commands to uninstall the GPU Operator:

```
$ helm ls
NAME                    NAMESPACE                      REVISION        UPDATED                                 STATUS          CHART                   APP VERSION
gpu-operator-1606173805 nvidia-gpu-operator            1               2025-03-31 20:23:28.063421701 +0000 UTC deployed        gpu-operator-25.3.4      v23.3.2 

$ helm del gpu-operator-1606173805 -n nvidia-gpu-operator

```

### Uninstalling the Network Operator

Execute the below commands to uninstall the Network Operator:

```
$ helm ls -n network-operator
NAME            	NAMESPACE       	REVISION	UPDATED                                	STATUS  	CHART                 	APP VERSION
network-operator	network-operator	1       	2025-03-31 17:09:04.665593336 +0000 UTC	deployed	network-operator-25.1.0	v25.1.0

$ helm del network-operator -n network-operator
```
