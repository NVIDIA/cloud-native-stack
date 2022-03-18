<h1>NVIDIA Cloud Native Core v4.0 (formely EGX Stack 4.0) - Install Guide for Ubuntu Server x86-64</h1>
<h2>Introduction</h2>

This document describes how to set up NVIDIA NVIDIA Cloud Native Core v4.0 on a single or multi-node Kubernetes Cluster to deploy AI applications via Helm charts from NVIDIA NGC. This document also includes instructions on how to set up the NVIDIA Networking Stack within NVIDIA Cloud Native Core. The final environment for NVIDIA Cloud Native Core v4.0 will include:

- Ubuntu 20.04.2 LTS
- Containerd 1.4.6
- Kubernetes version 1.21.1
- Helm 3.5.4
- NVIDIA GPU Operator 1.7.0
  - NV containerized driver: 460.73.01
  - NV container toolkit: 1.5.0
  - NV K8S device plug-in: 0.9.0
  - Data Center GPU Manager (DCGM): 2.1.8-2.4.0-rc.2
  - Node Feature Discovery: 0.6.0
  - GPU Feature Discovery: 0.4.1
- Mellanox MOFED Driver 5.3-1.0.0.1
- Mellanox NV_Peer_Memory 1.1 

<h2>Table of Contents</h2>

- [Release Notes](#Release-Notes)
- [Prerequisites](#Prerequisites)
- [Installing the Ubuntu Operating System](#Installing-the-Ubuntu-Operating-System)
- [Installing Containerd](#Installing-Containerd)
- [Installing Kubernetes](#Installing-Kubernetes)
- [Installing Helm](#Installing-Helm)
- [Adding an additional node to NVIDIA Cloud Native Core](#Adding-additional-node-to-NVIDIA-Cloud-Native-Core)
- [Installing the GPU Operator](#Installing-the-GPU-Operator)
- [GPU Operator with MIG](#GPU-Operator-with-MIG)
- [GPU Operator with vGPU](#GPU-Operator-with-vGPU)
- [Installing Mellanox MOFED on NVIDIA Cloud Native Core](#Installing-Mellanox-MOFED-on-NVIDIA-Cloud-Native-Core)
- [Installing nv_peer_mem on NVIDIA Cloud Native Core](#Installing-nv_peer_mem-on-NVIDIA-Cloud-Native-Core)
- [Validating GPUDirect RDMA on NVIDIA Cloud Native Core](#Validating-GPUDirect-RDMA-on-NVIDIA-Cloud-Native-Core)
- [Validating the Installation](#Validating-the-Installation)
- [NGC - NVIDIA's GPU-Optimized Software Hub](#NVIDIAs-GPU-Optimized-Software-Hub)
- [Uninstalling GPU Operator](#Uninstalling-the-GPU-Operator)
- [Uninstalling the nv_peer_mem ](#Uninstalling-the-nv_peer_mem)
- [Uninstalling the Mellanox MOFED](#Uninstalling-the-the-Mellanox-MOFED)

### Release Notes

- Replaced Docker CE with Containerd 1.4.6
- Upgraded to Kubernetes 1.21.1
- Upgraded to Helm 3.5.4
- Upgraded to GPU Operator 1.7.0
-  Added support for MIG with NVIDIA A30 and A100

### Prerequisites
 
The following instructions assume the following:

- You have [NVIDIA-Certified Systems](https://docs.nvidia.com/ngc/ngc-deploy-on-premises/nvidia-certified-systems/index.html) or [NGC-Ready Servers](https://docs.nvidia.com/ngc/ngc-ready-systems/index.html) with Mellanox CX NICs. 
- You will perform a clean install.

To determine if your system qualifies as an NVIDIA Certified System or an NGC-Ready Server, review the list of NVIDIA Certified Systems [here](https://docs.nvidia.com/ngc/ngc-deploy-on-premises/nvidia-certified-systems/index.html) and NGC-Ready for Edge Systems [here](https://docs.nvidia.com/ngc/ngc-ready-systems/index.html). 

Please note that NVIDIA Cloud Native Core is only validated on Intel-based systems with the default kernel (not HWE). Using an AMD EPYC 2nd generation (ROME) server is not validated yet and will require the HWE kernel and manually disabling nouveau.

### Installing the Ubuntu Operating System
These instructions require installing Ubuntu Server LTS 20.04.2. Ubuntu Server can be downloaded [here](http://cdimage.ubuntu.com/releases/20.04.2/release/).

Please reference the [Ubuntu Server Installation Guide](https://ubuntu.com/tutorials/tutorial-install-ubuntu-server#1-overview).

#### Disabling nouveau 

Run the below command to verify if `nouveau` is loaded.
```
 lsmod | grep nouveau
```
Output: 
```
nouveau              1949696  0
mxm_wmi                16384  1 nouveau
video                  49152  1 nouveau
i2c_algo_bit           16384  2 mgag200,nouveau
ttm                   106496  2 drm_vram_helper,nouveau
drm_kms_helper        184320  4 mgag200,nouveau
drm                   491520  6 drm_kms_helper,drm_vram_helper,mgag200,ttm,nouveau
wmi                    32768  5 wmi_bmof,dell_smbios,dell_wmi_descriptor,mxm_wmi,nouveau
```
If you see the above output, follow the below steps to disable nouveau

```
 cat <<EOF | sudo tee /etc/modprobe.d/blacklist-nouveau.conf
blacklist nouveau
options nouveau modeset=0
EOF
```

Regenerate the kernel initramfs:

```
 sudo update-initramfs -u
```

And reboot your system:

```
 sudo reboot
```

### Installing Containerd

Set up the repository and update the apt package index:

```
 sudo apt-get update
```

Install packages to allow apt to use a repository over HTTPS:

```
 sudo apt-get install -y apt-transport-https gnupg-agent libseccomp2 autotools-dev debhelper software-properties-common
```

Configure the prerequisites for Containerd

```
 cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF
```

```
 sudo modprobe overlay
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

Download the containerd tarball

```
 wget https://github.com/containerd/containerd/releases/download/v1.4.6/cri-containerd-cni-1.4.6-linux-amd64.tar.gz
 sudo tar --no-overwrite-dir -C / -xzf cri-containerd-cni-1.4.6-linux-amd64.tar.gz
 rm -rf cri-containerd-cni-1.4.6-linux-amd64.tar.gz
```

Install containerd
```
 sudo mkdir -p /etc/containerd
 containerd config default | sudo tee /etc/containerd/config.toml
 sudo systemctl restart containerd
```

For additional information on how to install containerd, please reference [Install Containerd with Release Tarball](https://github.com/containerd/containerd/blob/master/docs/cri/installation.md). 

### Installing Kubernetes 

Make sure containerd has been started and enabled before beginning installation:

```
 sudo systemctl start containerd && sudo systemctl enable containerd
```

Execute the following to add apt keys:

```
 sudo apt-get update && sudo apt-get install -y apt-transport-https curl
 curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
 sudo mkdir -p  /etc/apt/sources.list.d/
```

Create kubernetes.list

```
 cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
```

Now execute the below to install kubelet, kubeadm and kubectl:

```
 sudo apt-get update
 sudo apt-get install -y -q kubelet=1.21.1-00 kubectl=1.21.1-00 kubeadm=1.21.1-00
 sudo apt-mark hold kubelet kubeadm kubectl
```

Create a kubelet default with containerd
```
 cat <<EOF | sudo tee /etc/default/kubelet
KUBELET_EXTRA_ARGS=--cgroup-driver=systemd --container-runtime=remote --runtime-request-timeout=15m --container-runtime-endpoint="unix:/run/containerd/containerd.sock"
EOF
```

Reload the system daemon
```
 sudo systemctl daemon-reload
```

##### Disable swap
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

Execute the following command:

```
 sudo kubeadm init --pod-network-cidr=192.168.0.0/16 --cri-socket=/run/containerd/containerd.sock
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
 sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
 sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

With the following command, you install a pod-network add-on to the control plane node. We are using calico as the pod-network add-on here:

```
 kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
```

You can execute the below commands to ensure that all pods are up and running

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
#yourhost        Ready    control-plane,master   10m   v1.21.1
```

Since we are using a single-node Kubernetes cluster, the cluster will not schedule pods on the control plane node by default. To schedule pods on the control plane node, we have to remove the taint by executing the following command:

```
 kubectl taint nodes --all node-role.kubernetes.io/master-
```

Refer to [Installing Kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/)
for more information.

### Installing Helm 

Execute the following command to download and install Helm 3.5.4: 

```
 wget https://get.helm.sh/helm-v3.5.4-linux-amd64.tar.gz
 tar -zxvf helm-v3.5.4-linux-amd64.tar.gz
 sudo mv linux-amd64/helm /usr/local/bin/helm
 rm -rf helm-v3.5.4-linux-amd64.tar.gz linux-amd64/
```

Refer to the Helm 3.5.4 [release notes](https://github.com/helm/helm/releases) and the [Installing Helm guide](https://helm.sh/docs/using_helm/#installing-helm) for more information.


### Adding an additional node to NVIDIA Cloud Native Core

Please make sure to install the containerd and Kubernetes packages on additional nodes.

Prerequisites: 
- [Installing Containerd](#Installing-Containerd)
- [Installing Kubernetes](#Installing-Kubernetes)
- [Disable swap](#Disable-swap)

Once the prerequisites are completed on the additional nodes, execute the below command on the control-plane node and then execute the join command output on an additional node to add the additional node to NVIDIA Cloud Native Core. 

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
#yourhost        Ready    control-plane,master   10m   v1.21.1
#yourhost-worker Ready                           10m   v1.21.1
```

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

```
 helm install --version 1.7.0 --devel nvidia/gpu-operator --set operator.defaultRuntime=containerd --wait --generate-name
```

#### Validate the state of the GPU Operator:

Please note that the installation of the GPU Operator can take a couple of minutes. How long the installation will take depends on your internet speed.

```
kubectl get pods --all-namespaces | grep -v kube-system
```

```
NAMESPACE                NAME                                                              READY   STATUS      RESTARTS   AGE
default                  gpu-operator-1622656274-node-feature-discovery-master-5cddq96gq   1/1     Running     0          2m39s
default                  gpu-operator-1622656274-node-feature-discovery-worker-wr88v       1/1     Running     0          2m39s
default                  gpu-operator-7db468cfdf-mdrdp                                     1/1     Running     0          2m39s
gpu-operator-resources   gpu-feature-discovery-g425f                                       1/1     Running     0          2m20s
gpu-operator-resources   nvidia-container-toolkit-daemonset-mcmxj                          1/1     Running     0          2m20s
gpu-operator-resources   nvidia-cuda-validator-s6x2p                                       0/1     Completed   0          48s
gpu-operator-resources   nvidia-dcgm-exporter-wtxnx                                        1/1     Running     0          2m20s
gpu-operator-resources   nvidia-device-plugin-daemonset-hzzdt                              1/1     Running     0          2m20s
gpu-operator-resources   nvidia-device-plugin-validator-9nkxq                              0/1     Completed   0          17s
gpu-operator-resources   nvidia-driver-daemonset-kt8g5                                     1/1     Running     0          2m20s
gpu-operator-resources   nvidia-operator-validator-cw4j5                                   1/1     Running     0          2m20s

```

Please refer to the [GPU Operator page](https://ngc.nvidia.com/catalog/helm-charts/nvidia:gpu-operator) on NGC for more information.

### GPU Operator with MIG

`NOTE:` Only A100 and A30 GPUs are supported for GPU Operator with MIG

Multi-Instance GPU (MIG) allows GPUs based on the NVIDIA Ampere architecture (such as NVIDIA A100) to be securely partitioned into separate GPU instances for CUDA applications. For more information about enabling the MIG capability, please refer to [GPU Operator with MIG](https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/gpu-operator-mig.html) 


### Installing Mellanox MOFED on NVIDIA Cloud Native Core

The below instructions assume that Mellanox NICs are connected to your machines.

Execute the below command to verify Mellanox NICs are enabled on your machines

```
 lspci | grep -i "Mellanox"
```

Output:
```
0c:00.0 Ethernet controller: Mellanox Technologies MT2892 Family [ConnectX-6 Dx]
0c:00.1 Ethernet controller: Mellanox Technologies MT2892 Family [ConnectX-6 Dx]
```

Execute the below commands to install MOFED drivers on every NVIDIA Cloud Native Core node

```
 wget -qO - https://www.mellanox.com/downloads/ofed/RPM-GPG-KEY-Mellanox | sudo apt-key add -
 wget https://linux.mellanox.com/public/repo/mlnx_ofed/latest/ubuntu20.04/mellanox_mlnx_ofed.list
 sudo mv mellanox_mlnx_ofed.list /etc/apt/sources.list.d/
 sudo apt update && sudo apt-get install mlnx-ofed-all -y
```

Once MOFED drivers are installed successfully, please reboot the systems.

```	
 sudo reboot
```

Now execute the below command to install MULTUS CNI plugin on NVIDIA Cloud Native Core from the control-plane node

```
 kubectl apply -f https://raw.githubusercontent.com/intel/multus-cni/master/images/multus-daemonset.yml
```
Multus CNI enables attaching multiple network interfaces to pods in Kubernetes. Learn more about [Multus](https://github.com/intel/multus-cni)

Next, follow the below steps to install Kubernetes RDMA shared plug-in to enable Mellanox NIC's on NVIDIA Cloud Native Core. 

1. Execute the below command on NVIDIA Cloud Native Core nodes to list the Mellanox NIC's with the status
```
 sudo ibdev2netdev
```
Output:
```
mlx5_0 port 1 ==> ens192f0 (Up)
mlx5_1 port 1 ==> ens192f1 (Down)
```

`NOTE:` If you see all Mellanox NIC's status as Down, make sure to change the status of at least one NIC as Up. 

2. Now, create the RDMA shared plug-in configmap with the below command on the control-plane node
```
cat << EOF | tee k8s-rdma-shared-dev-plugin-config-map.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: rdma-devices
  namespace: kube-system
data:
  config.json: |
    {
        "configList": [{
             "resourceName": "hca_shared_devices_a",
             "rdmaHcaMax": 100,
             "devices": ["ens192f0"]
           }
        ]
    }
EOF
```
Run the below command to replace the active Mellanox NIC. 

```
sed -ie "s/ens192f0/$(sudo ibdev2netdev | grep -i up | awk -F">" '{print $2}' | sed "s/(Up)//g;s/ //g")/g" k8s-rdma-shared-dev-plugin-config-map.yaml
```
3. Install the Kubernetes RDMA shared device plug-in on NVIDIA Cloud Native Core from the control-plane node
```
 kubectl apply -f k8s-rdma-shared-dev-plugin-config-map.yaml
 kubectl apply -f https://raw.githubusercontent.com/Mellanox/k8s-rdma-shared-dev-plugin/master/images/k8s-rdma-shared-dev-plugin-ds.yaml
```
Learn more about [RDMA shared plug-in](https://github.com/Mellanox/k8s-rdma-shared-dev-plugin).

Now execute the below commands to copy the container network plug-ins on every NVIDIA Cloud Native Core node.

```
 wget -q https://github.com/containernetworking/plugins/releases/download/v0.8.7/cni-plugins-linux-amd64-v0.8.7.tgz
 mkdir cni-plugins && tar -C ./cni-plugins -xzvf cni-plugins-linux-amd64-v0.8.7.tgz
 sudo cp cni-plugins/macvlan cni-plugins/tuning /opt/cni/bin/
```

Now install the Whereabouts CNI on NVIDIA Cloud Native Core with the below steps from the control-plane node

```
 wget -q https://raw.githubusercontent.com/openshift/whereabouts-cni/master/doc/daemonset-install.yaml
 sed -ie 's/latest/v0.3/g' daemonset-install.yaml
 kubectl apply -f daemonset-install.yaml
 kubectl apply -f https://raw.githubusercontent.com/openshift/whereabouts-cni/master/doc/whereabouts.cni.cncf.io_ippools.yaml
 kubectl apply -f https://raw.githubusercontent.com/openshift/whereabouts-cni/master/doc/whereabouts.cni.cncf.io_overlappingrangeipreservations.yaml
```
Whereabouts is an IP Address Management (IPAM) CNI plug-in that assigns IP addresses cluster-wide. Learn more about [Whereabouts CNI](https://github.com/openshift/whereabouts-cni).

### Installing nv_peer_mem on NVIDIA Cloud Native Core 

`NOTE:` Install [GPU Operator](#Installing-the-GPU-Operator) before installing nv_peer_memory, as nv_peer_memory needs NVIDIA Drivers. 

Execute the below steps on every NVIDIA Cloud Native Core node.

Run the below command to check that the GPU Operator is running on your node(s). 
```
 sudo chroot /run/nvidia/driver nvidia-smi
```

Output: 
```
Thu Jun 17 22:41:28 2021
+-----------------------------------------------------------------------------+
| NVIDIA-SMI 460.73.01    Driver Version: 460.73.01    CUDA Version: 11.2     |
|-------------------------------+----------------------+----------------------+
| GPU  Name        Persistence-M| Bus-Id        Disp.A | Volatile Uncorr. ECC |
| Fan  Temp  Perf  Pwr:Usage/Cap|         Memory-Usage | GPU-Util  Compute M. |
|                               |                      |               MIG M. |
|===============================+======================+======================|
|   0  A100-PCIE-40GB      On   | 00000000:E2:00.0 Off |                    0 |
| N/A   32C    P0    36W / 250W |      0MiB / 40536MiB |      0%      Default |
|                               |                      |             Disabled |
+-------------------------------+----------------------+----------------------+

+-----------------------------------------------------------------------------+
| Processes:                                                                  |
|  GPU   GI   CI        PID   Type   Process name                  GPU Memory |
|        ID   ID                                                   Usage      |
|=============================================================================|
|  No running processes found                                                 |
+-----------------------------------------------------------------------------+
```

Now clone the nv_peer_mem source from GitHub and build the nv_peer_mem module with the below steps.

```
 git clone https://github.com/Mellanox/nv_peer_memory.git

 cd nv_peer_memory 

 sed -ie "s/nvidia_mod=\$.*/nvidia_mod=\"\/run\/nvidia\/driver\/usr\/src\/nvidia-460\.73\.01\/kernel\/nvidia.ko\"/g" create_nv.symvers.sh
```

Now build the nv_peer_mem module with the below commands

```
$ ./build_module.sh

$ cd /tmp
$ tar xzf /tmp/nvidia-peer-memory_1.1.orig.tar.gz
$ cd nvidia-peer-memory-1.1
$ sudo dpkg-buildpackage -us -uc
$ sudo dpkg -i ../nvidia-peer-memory_1.1-0_all.deb
$ sudo dpkg -i ../nvidia-peer-memory-dkms_1.1-0_all.deb
$ cd -
```


### Validating GPUDirect RDMA on NVIDIA Cloud Native Core 

Create network definition for IPAM
```
cat <<EOF | tee networkdefinition.yaml 
apiVersion: k8s.cni.cncf.io/v1
kind: NetworkAttachmentDefinition
metadata:
  annotations:
    k8s.v1.cni.cncf.io/resourceName: rdma/hca_shared_devices_a
  name: rdma-test
  namespace: default
spec:
  config: |-
    {
        "cniVersion": "0.3.1",
        "name": "rdma-test",
        "plugins": [
            {
                "ipam": {
                    "datastore": "kubernetes",
                    "kubernetes": {
                        "kubeconfig": "/etc/cni/net.d/whereabouts.d/whereabouts.kubeconfig"
                    },
                    "log_file": "/tmp/whereabouts.log",
                    "log_level": "debug",
                    "range": "192.168.111.0/24",
                    "type": "whereabouts"
                },
                "type": "macvlan",
                "master": "ens192f0",
                "vlan": 111
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

Run the below command to replace the `master` value with the active Mellanox NIC. 

```
sed -ie "s/ens192f0/$(sudo ibdev2netdev | grep -i up | awk -F">" '{print $2}' | sed "s/(Up)//g;s/ //g")/g" networkdefinition.yaml
```
 
 Execute the below command to install network definition on NVIDIA Cloud Native Core from the control-plane node
 
 ```
  kubectl apply -f networkdefinition.yaml 
 ```
 
Now create the pod YAML with the below content.

``` 
cat <<EOF | tee mellanox-test.yaml
apiVersion: v1
kind: Pod
metadata:
  name: rdma-test-pod-1
  annotations:
    k8s.v1.cni.cncf.io/networks: rdma-test
    # If a network with static IPAM is used replace network annotation with the below.
    #k8s.v1.cni.cncf.io/networks: '[
    #  { "name": "rmda-net",
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
        rdma/hca_shared_devices_a: 1
      requests:
        rdma/hca_shared_devices_a: 1
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
    k8s.v1.cni.cncf.io/networks: rdma-test
    # If a network with static IPAM is used replace network annotation with the below.
    #k8s.v1.cni.cncf.io/networks: '[
    #  { "name": "rmda-net",
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
        rdma/hca_shared_devices_a: 1
      requests:
        rdma/hca_shared_devices_a: 1
    command:
    - sh
    - -c
    - |
      ls -l /dev/infiniband /sys/class/net
      sleep infinity
EOF
 ```

Apply the Mellanox test pod to NVIDIA Cloud Native Core stack for the validation
```
 kubectl apply -f mellanox-test.yaml
```

Once you apply, verify the `rdma-test-pod-1` pod logs. You should see the expected output as shown below.

Expected Output:
```
$ kubectl logs rdma-test-pod-1

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

#### Validate nv_peer_mem on NVIDIA Cloud Native Core 

First, verify that nv_peer_mem modules are loaded on every NVIDIA Cloud Native Core node with the below command: 

```
 lsmod | grep nv_peer_mem
```

Output:
```
nv_peer_mem            16384  0
ib_core               323584  11 rdma_cm,ib_ipoib,mlx4_ib,nv_peer_mem,iw_cm,ib_umad,rdma_ucm,ib_uverbs,mlx5_ib,ib_cm,ib_ucm
nvidia              20385792  117 nvidia_uvm,nv_peer_mem,nvidia_modeset
```

Execute the below command to list the Mellanox NIC's with the status
```
 sudo ibdev2netdev
```
Output:
```
mlx5_0 port 1 ==> ens192f0 (Up)
mlx5_1 port 1 ==> ens192f1 (Down)
```

Update the above Mellanox NIC, for which status is `Up` in the below command 

```
$ kubectl exec -it rdma-test-pod-1 -- bash

[root@rdma-test-pod-1 /]# ib_write_bw -d mlx5_0 -a -F --report_gbits -q 1
************************************
* Waiting for client to connect... *
************************************
```

In a separate terminal, print the network address of the secondary interface on the `rdma-test-pod-1` pod.

```
$ kubectl exec rdma-test-pod-1 -- ip addr show dev net1
5: net1@if24: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9000 qdisc noqueue state UP group default
    link/ether 62:51:fb:13:88:ce brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 192.168.111.1/24 brd 192.168.111.255 scope global net1
       valid_lft forever preferred_lft forever
```

Execute the below command with the above inet address to verify the nv_peer_memory performance on NVIDIA Cloud Native Core. 
```
$ kubectl exec -it rdma-test-pod-2 -- bash
[root@rdma-test-pod-1 /]# ib_write_bw -d mlx5_0 -a -F --report_gbits -q 1 192.168.111.1
---------------------------------------------------------------------------------------
                    RDMA_Write BW Test
 Dual-port       : OFF          Device         : mlx5_0
 Number of qps   : 1            Transport type : IB
 Connection type : RC           Using SRQ      : OFF
 TX depth        : 128
 CQ Moderation   : 100
 Mtu             : 1024[B]
 Link type       : Ethernet
 GID index       : 10
 Max inline data : 0[B]
 rdma_cm QPs     : OFF
 Data ex. method : Ethernet
---------------------------------------------------------------------------------------
 local address: LID 0000 QPN 0x0109 PSN 0xad9c34 RKey 0x00413c VAddr 0x007f93aab9e000
 GID: 00:00:00:00:00:00:00:00:00:00:255:255:192:168:111:04
 remote address: LID 0000 QPN 0x010a PSN 0xd5981f RKey 0x004b4f VAddr 0x007fe88ecdd000
 GID: 00:00:00:00:00:00:00:00:00:00:255:255:192:168:111:03
---------------------------------------------------------------------------------------
 #bytes     #iterations    BW peak[Gb/sec]    BW average[Gb/sec]   MsgRate[Mpps]
 2          5000           0.101672            0.083211            5.200694
 4          5000             0.21               0.18               5.523125
 8          5000             0.42               0.39               6.120008
 16         5000             0.85               0.78               6.105113
 32         5000             1.94               1.91               7.455015
 64         5000             3.88               3.36               6.562323
 128        5000             6.33               5.90               5.765118
 256        5000             15.72              15.15              7.397497
 512        5000             28.58              26.63              6.501946
 1024       5000             54.24              48.99              5.979717
 2048       5000             82.28              75.34              4.598318
 4096       5000             90.89              88.17              2.690844
 8192       5000             92.78              92.14              1.405963
 16384      5000             93.63              93.59              0.714006
 32768      5000             94.00              93.99              0.358542
 65536      5000             94.31              94.29              0.179852
 131072     5000             94.44              94.44              0.090068
 262144     5000             94.04              94.04              0.044843
 524288     5000             93.26              93.25              0.022233
 1048576    5000             93.27              93.25              0.011116
 2097152    5000             93.13              93.13              0.005551
 4194304    5000             93.11              93.08              0.002774
 8388608    5000             93.30              93.29              0.001390
---------------------------------------------------------------------------------------
```
The benchmark achieved approximately 93 Gbps throughput.

Exit from RDMA test pods and then delete the RDMA test pods with the below command.

```
 kubectl delete pod rdma-test-pod-1 rdma-test-pod-2
```

### Validating the Installation

GPU Operator validates the stack through the nvidia-device-plugin-validation pod and the nvidia-driver-validation pod. If both are completed successfully (see output from kubectl get pods --all-namespaces | grep -v kube-system), NVIDIA Cloud Native Core is working as expected. This section provides two examples of validating that the GPU is usable from within a pod to validate the stack manually.

#### Example 1: nvidia-smi

Execute the following:

```
 kubectl run nvidia-smi --rm -t -i --restart=Never --image=nvidia/cuda:11.2.2-base --limits=nvidia.com/gpu=1 -- nvidia-smi
```

Output:

``` 
Tue Jun 17 22:35:02 2021
+-----------------------------------------------------------------------------+
| NVIDIA-SMI 460.73.01    Driver Version: 460.73.01    CUDA Version: 11.2     |
|-------------------------------+----------------------+----------------------+
| GPU  Name        Persistence-M| Bus-Id        Disp.A | Volatile Uncorr. ECC |
| Fan  Temp  Perf  Pwr:Usage/Cap|         Memory-Usage | GPU-Util  Compute M. |
|                               |                      |               MIG M. |
|===============================+======================+======================|
|   0  A100-PCIE-40GB      On   | 00000000:3B:00.0 Off |                    0 |
| N/A   29C    P0    33W / 250W |    741MiB / 40537MiB |      0%      Default |
|                               |                      |             Disabled |
+-------------------------------+----------------------+----------------------+

+-----------------------------------------------------------------------------+
| Processes:                                                                  |
|  GPU   GI   CI        PID   Type   Process name                  GPU Memory |
|        ID   ID                                                   Usage      |
|=============================================================================|
+-----------------------------------------------------------------------------+
pod "nvidia-smi" deleted
```

#### Example 2: CUDA-Vector-Add

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

NVIDIA Cloud Native Core works as expected if the get pods command shows the pod status as completed.

### Validate NVIDIA Cloud Native Core with an application from NGC
Another option to validate NVIDIA Cloud Native Core is by running a demo application hosted on NGC.

NGC is NVIDIA's GPU optimized software hub. NGC provides a curated set of GPU-optimized software for AI, HPC, and visualization. The content provided by NVIDIA and third-party ISVs simplify building, customizing, and integrating GPU-optimized software into workflows, accelerating the time to solutions for users.

Containers, pre-trained models, Helm charts for Kubernetes deployments, and industry-specific AI toolkits with software development kits (SDKs) are hosted on NGC. For more information about how to deploy an application that is hosted on NGC, or the NGC Private Registry, please refer to this [NGC Registry Guide](https://github.com/NVIDIA/cloud-native-core/blob/master/install-guides/NGC_Registry_Guide_v1.0.md). Visit the [public NGC documentation](https://docs.nvidia.com/ngc) for more information.

The steps in this section use the publicly available DeepStream - Intelligent Video Analytics (IVA) demo application Helm Chart. The application can validate the full NVIDIA Cloud Native Core and test the connectivity of NVIDIA Cloud Native Core to remote sensors. DeepStream delivers real-time AI-based video and image understanding and multi-sensor processing on GPUs. For more information, please refer to the [Helm Chart](https://ngc.nvidia.com/catalog/helm-charts/nvidia:video-analytics-demo).

There are two ways to configure the DeepStream - Intelligent Video Analytics Demo Application on your NVIDIA Cloud Native Core

- Using a camera
- Using the integrated video file (no camera required)

#### Using a camera

##### Prerequisites: 
- RTSP Camera stream

Go through the below steps to install the demo application. 
```
1. helm fetch https://helm.ngc.nvidia.com/nvidia/charts/video-analytics-demo-0.1.6.tgz --untar

2. cd into the folder video-analytics-demo and update the file values.yaml

3. Go to the section Cameras in the values.yaml file and add the address of your IP camera. Read the comments section on how it can be added. Single or multiple cameras can be added as shown below

cameras:
 camera1: rtsp://XXXX
```

Execute the following command to deploy the demo application
```
helm install video-analytics-demo --name-template iva
```

Once the Helm chart is deployed, access the application with the VLC player. See the instructions below. 

#### Using the integrated video file (no camera)

If you don't have a camera input, please execute the below commands to use the default video already integrated into the application. 

```
helm fetch https://helm.ngc.nvidia.com/nvidia/charts/video-analytics-demo-0.1.6.tgz

helm install video-analytics-demo-0.1.6.tgz --name-template iva
```

`NOTE:` If you're deploying on an A100 GPU, please pass image tag as `--set image.tag=5.0-20.08-devel-a100` to the above command 

Once the helm chart is deployed, access the application with the VLC player as per the below instructions. 
For more information about the demo application, please refer to the [application NGC page](https://ngc.nvidia.com/catalog/helm-charts/nvidia:video-analytics-demo)

#### Access from WebUI

Use the below WebUI URL to access the video analytic demo application from the browser:
```
http://IPAddress of Node:31115/WebRTCApp/play.html?name=videoanalytics
```

#### Access from VLC

Download VLC Player from https://www.videolan.org/vlc/ on the machine where you intend to view the video stream.

View the video stream in VLC by navigating to Media > Open Network Stream > Entering the following URL

```
rtsp://IPAddress of Node:31113/ds-test
```

You should see the video output like below with the AI model detecting objects.

![Deepstream_Video](screenshots/Deepstream.png)

`NOTE:` Video stream in VLC will change if you provide an input RTSP camera.


#### Uninstalling the GPU Operator 

Execute the below commands to uninstall the GPU Operator 

```
$ helm ls
NAME                    NAMESPACE       REVISION        UPDATED                                 STATUS          CHART                   APP VERSION
gpu-operator-1606173805 default         1               2021-06-17 20:23:28.063421701 +0000 UTC deployed        gpu-operator-1.7.0      1.7.0 

$ helm del gpu-operator-1606173805
```

#### Uninstalling the nv_peer_mem 

Execute the below commands to uninstall the nv_peer_mem

```
sudo dpkg -r --force-all nvidia-peer-memory-dkms
sudo dpkg -r --force-all nvidia-peer-memory
```

#### Uninstalling the Mellanox MOFED

Execute the below commands to uninstall the Mellanox MOFED

```
sudo apt purge mlnx-ofed-all -y
```

