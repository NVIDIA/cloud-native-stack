<h1>EGX Stack v3.1 - Install Guide for Ubuntu Server x86-64</h1>
<h2>Introduction</h2>

This document describes how to set up EGX Stack v3.1 on a single or multi-node Kubernetes Cluster to deploy AI applications via Helm charts from NGC. EGX Stack 3.1 also includes instructions on how to set up the NVIDIA Networking Stack within EGX Stack. The final environment will include:

- Ubuntu 20.04.2 LTS
- Docker CE 19.03.13 
- Kubernetes version 1.18.14
- Helm 3.3.3
- NVIDIA GPU Operator 1.6.2
  - NV containerized driver: 460.32.03
  - NV container toolkit: 1.4.7
  - NV K8S device plug-in: 0.8.2
  - Data Center GPU Manager (DCGM): 2.2.0
  - Node Feature Discovery: 0.6.0
  - GPU Feature Discovery: 0.4.1
- Mellanox MOFED Driver 5.3-1.0.0.1
- Mellanox NV_Peer_Memory 1.1 

<h2>Table of Contents</h2>

- [Release Notes](#Release-Notes)
- [Prerequisites](#Prerequisites)
- [Installing the Ubuntu Operating System](#Installing-the-Ubuntu-Operating-System)
- [Installing Docker-CE](#Installing-Docker-CE)
- [Installing Kubernetes](#Installing-Kubernetes)
- [Installing Helm](#Installing-Helm)
- [Adding additional node to EGX Stack](#Adding-additional-node-to-EGX-Stack)
- [Installing GPU Operator](#Installing-GPU-Operator)
- [Installing Mellanox MOFED on EGX Stack](#Installing-Mellanox-MOFED-on-EGX-Stack)
- [Installing nv_peer_mem on EGX Stack](#Installing-nv_peer_mem-on-EGX-Stack)
- [Validating the Mellanox on EGX Stack](#Validating-the-Mellanox-on-EGX-Stack)
- [Validating the Installation](#Validating-the-Installation)
- [NGC - NVIDIA's GPU-Optimized Software Hub](#NVIDIAs-GPU-Optimized-Software-Hub)
- [Uninstalling the GPU Operator](#Uninstalling-the-GPU-Operator)

### Release Notes

- Upgraded to Ubuntu Server 20.04.2 LTS
- Upgraded to Docker-CE 19.03.13
- Upgraded to Kubernetes 1.18.14
- Upgraded to Helm 3.3.3
- Upgraded to GPU Operator 1.6.2
- Added support for A100
- Added support for Multi-Node Kubernetes Cluster
- Added support for Mellanox MOFED, nv_peer_mem with GPU Operator

### Prerequisites
 
The following instructions assume the following:

- You have NVIDIA-Certified Systems or NGC-Ready Servers with Mellanox CX NICs. 
- You will perform a clean install.

To determine if your system qualifies as an NVIDIA Certified System or an NGC-Ready Server, review the list of NVIDIA Certified Systems at https://docs.nvidia.com/ngc/ngc-deploy-on-premises/nvidia-certified-systems/index.html and NGC-Ready for Edge Systems at https://docs.nvidia.com/ngc/ngc-ready-systems/index.html. 

Please note that EGX Stack is only validated on Intel-based systems with the default kernel (not HWE). Using an AMD EPYC 2nd generation (ROME) server is not validated yet and will require the HWE kernel and manually disabling nouveau.

### Installing the Ubuntu Operating System
These instructions require installing Ubuntu Server LTS 20.04.2. Ubuntu Server can be downloaded from http://cdimage.ubuntu.com/releases/20.04.1/release/.

Please reference the [Ubuntu Server Installation Guide](https://ubuntu.com/tutorials/tutorial-install-ubuntu-server#1-overview).

#### Disabling nouveau 

`NOTE:` It's only required with Ubuntu 20.04.2 LTS HWE Kernel 

```
$ sudo nano /etc/modprobe.d/blacklist-nouveau.conf
```

Insert the following:

```
blacklist nouveau
options nouveau modeset=0
```

Regenerate the kernel initramfs:

```
$ sudo update-initramfs -u
```

And reboot your system:

```
$ sudo reboot
```

### Installing Docker-CE

Set up the repository and update the apt package index:

```
$ sudo apt-get update
```

Install packages to allow apt to use a repository over HTTPS:

```
$ sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common
```

Add Docker’s official GPG key:

```
$ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
```

Verify that you now have the key with the fingerprint 9DC8 5822 9FC7 DD38 854A E2D8 8D81 803C 0EBF CD88 by searching for the last 8 characters of the fingerprint:
```
$ sudo apt-key fingerprint 0EBFCD88
    
pub   rsa4096 2017-02-22 [SCEA]
      9DC8 5822 9FC7 DD38 854A  E2D8 8D81 803C 0EBF CD88
uid           [ unknown] Docker Release (CE deb) <docker@docker.com>
sub   rsa4096 2017-02-22 [S]
``` 

Use the following command to set up the stable repository:

```
$ sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
```

Install Docker Engine - Community
Update the apt package index:

```
$ sudo apt-get update
```

Install Docker Engine 19.03.13:

```
$ sudo apt-get install -y docker-ce=5:19.03.13~3-0~ubuntu-focal docker-ce-cli=5:19.03.13~3-0~ubuntu-focal containerd.io
```

Verify that Docker Engine - Community is installed correctly by running the hello-world image:

```
$ sudo docker run hello-world
```

More information on how to install Docker can be found at https://docs.docker.com/install/linux/docker-ce/ubuntu/. 

### Installing Kubernetes 

Make sure docker has been started and enabled before beginning installation:

```
$ sudo systemctl start docker && sudo systemctl enable docker
```

Execute the following to install kubelet kubeadm and kubectl:

```
$ sudo apt-get update && sudo apt-get install -y apt-transport-https curl
$ curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
$ sudo mkdir -p  /etc/apt/sources.list.d/
```

Create kubernetes.list

```
$ sudo nano /etc/apt/sources.list.d/kubernetes.list
```

Add the following lines in the kubernetes.list and save the file:

```
deb https://apt.kubernetes.io/ kubernetes-xenial main
```

Now execute the below:

```
$ sudo apt-get update
$ sudo apt-get install -y -q kubelet=1.18.14-00 kubectl=1.18.14-00 kubeadm=1.18.14-00
$ sudo apt-mark hold kubelet kubeadm kubectl
```

#### Initializing the Kubernetes cluster to run as master
Disable swap:
```
$ sudo swapoff -a
$ sudo nano /etc/fstab
```

Add a # before all the lines that start with /swap. # is a comment, and the result should look something like this:

```
UUID=e879fda9-4306-4b5b-8512-bba726093f1d / ext4 defaults 0 0
UUID=DCD4-535C /boot/efi vfat defaults 0 0
#/swap.img       none    swap    sw      0       0
```

Execute the following command:

```
$ sudo kubeadm init --pod-network-cidr=192.168.0.0/16
```

The output will show you the commands that you can execute to deploy a pod network to the cluster and commands to join the cluster.

Following the instructions in the output, execute the commands as shown below:

```
$ mkdir -p $HOME/.kube
$ sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
$ sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

With the following command, you install a pod-network add-on to the control plane node. We are using calico as the pod-network add-on here:

```
$ kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
```

You can execute the below commands to ensure that all pods are up and running

```
$ kubectl get pods --all-namespaces
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

The get nodes command shows that the master node is up and ready:

```
$ kubectl get nodes
```

Output:

```
NAME             STATUS   ROLES    AGE   VERSION
#yourhost        Ready    master   10m   v1.18.14
```

Since we are using a single-node Kubernetes cluster, the cluster will not schedule pods on the control plane node by default. To schedule pods on the control plane node, we have to remove the taint by executing the following command:

```
$ kubectl taint nodes --all node-role.kubernetes.io/master-
```

Refer to https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/
for more information.

### Installing Helm 

Execute the following command to download Helm 3.3.3: 

```
$ sudo wget https://get.helm.sh/helm-v3.3.3-linux-amd64.tar.gz
$ sudo tar -zxvf helm-v3.3.3-linux-amd64.tar.gz
$ sudo mv linux-amd64/helm /usr/local/bin/helm
```

Refer to https://github.com/helm/helm/releases and https://helm.sh/docs/using_helm/#installing-helm for more information.


### Adding additional node to EGX Stack

Please make sure to install the docker and Kubernetes packages on an additional node.

Prerequisites: 
- [Installing Docker-CE](#Installing-Docker-CE)
- [Installing Kubernetes](#Installing-Kubernetes)

Now execute the below command on the master node and then execute the join command output on an additional node to add the additional node to EGX Stack. 

```
$ kubeadm token create --print-join-command
```

Output:
```
example: 
kubeadm join 10.110.0.34:6443 --token kg2h7r.e45g9uyrbm1c0w3k     --discovery-token-ca-cert-hash sha256:77fd6571644373ea69074dd4af7b077bbf5bd15a3ed720daee98f4b04a8f524e
```

The get nodes command shows that the master and worker nodes are up and ready:

```
$ kubectl get nodes
```

Output:

```
NAME             STATUS   ROLES    AGE   VERSION
#yourhost        Ready    master   10m   v1.18.14
#yourhost-worker Ready             10m   v1.18.14
```

### Installing GPU Operator

Add the NVIDIA repo:

```
$ helm repo add nvidia https://helm.ngc.nvidia.com/nvidia
```

Update the Helm repo:

```
$ helm repo update
```

Install the GPU Operator:

```
$ helm install --version 1.6.2 --devel nvidia/gpu-operator --wait --generate-name
```

#### Validate the state of the GPU Operator:

Please note that the installation of the GPU Operator can take a couple of minutes. How long you will have to wait will depend on your internet speed.

```
kubectl get pods --all-namespaces | grep -v kube-system
```

```
NAMESPACE                NAME                                                             READY   STATUS      RESTARTS   AGE

default                  gpu-operator-1590097431-node-feature-discovery-master-76578jwwt   1/1     Running     0          5m2s
default                  gpu-operator-1590097431-node-feature-discovery-worker-pv5nf       1/1     Running     0          5m2s
default                  gpu-operator-74c97448d9-n75g8                                     1/1     Running     1          5m2s
gpu-operator-resources   nvidia-container-toolkit-daemonset-pwhfr                          1/1     Running     0          4m58s
gpu-operator-resources   nvidia-dcgm-exporter-bdzrz                                        1/1     Running     0          4m57s
gpu-operator-resources   nvidia-device-plugin-daemonset-zmjhn                              1/1     Running     0          4m57s
gpu-operator-resources   nvidia-device-plugin-validation                                   0/1     Completed   0          4m57s
gpu-operator-resources   nvidia-driver-daemonset-7b66v                                     1/1     Running     0          4m57s

```

Please refer to https://ngc.nvidia.com/catalog/helm-charts/nvidia:gpu-operator for more information.

### Installing Mellanox MOFED on EGX Stack

Below instructions that assume that Mellanox NICs are connected to your machines.

Execute the below command to verify Mellanox NIC's are enabled on your machines

```
$ lspci | grep -i "Mellanox"
```

Output:
```
0c:00.0 Ethernet controller: Mellanox Technologies MT2892 Family [ConnectX-6 Dx]
0c:00.1 Ethernet controller: Mellanox Technologies MT2892 Family [ConnectX-6 Dx]
```

Execute the below commands to install MOFED Drivers on every EGX node

```
$ wget -qO - https://www.mellanox.com/downloads/ofed/RPM-GPG-KEY-Mellanox | sudo apt-key add -
$ wget https://linux.mellanox.com/public/repo/mlnx_ofed/5.3-1.0.0.1/ubuntu20.04/mellanox_mlnx_ofed.list
$ sudo mv mellanox_mlnx_ofed.list /etc/apt/sources.list.d/
$ sudo apt update && sudo apt-get install mlnx-ofed-all -y
```

Once MOFED drivers are installed successfully, please reboot the systems.

```	
$ sudo reboot
```

Now execute the below command to install MULTUS CNI Plugin on EGX Stack from the master node

```
$ kubectl apply -f https://raw.githubusercontent.com/intel/multus-cni/master/images/multus-daemonset.yml
```
Multus CNI enables attaching multiple network interfaces to pods in Kubernetes. for more information about Multus, please refer to https://github.com/intel/multus-cni

Follow the below steps to install Kubernetes RDMA shared plug-in to enable Mellanox NIC's on EGX Stack. 

1. Execute the below command on EGX nodes to list the Mellanox NIC's with the status
```
$ sudo ibdev2netdev
```
Output:
```
mlx5_0 port 1 ==> ens192f0 (Up)
mlx5_1 port 1 ==> ens192f1 (Down)
```
2. Now, create the RDMA shared plug-in configmap with the below command on the master node
```
sudo nano k8s-rdma-shared-dev-plugin-config-map.yaml
```

Update Mellanox devices which you previously listed with `ibdev2netdev` in configmap as per below 

```	
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

```
3. Install the Kubernetes RDMA shared device plug-in on EGX Stack from the master node
```
$ kubectl apply -f k8s-rdma-shared-dev-plugin-config-map.yaml
$ kubectl apply -f https://raw.githubusercontent.com/Mellanox/k8s-rdma-shared-dev-plugin/master/images/k8s-rdma-shared-dev-plugin-ds.yaml
```
for more information about RDMA shared plug-in, please refer to https://github.com/Mellanox/k8s-rdma-shared-dev-plugin

Now execute the below commands to copy the container network plug-ins on every EGX node.

```
$ wget https://github.com/containernetworking/plugins/releases/download/v0.8.7/cni-plugins-linux-amd64-v0.8.7.tgz
$ tar xvfz cni-plugins-linux-amd64-v0.8.7.tgz
$ sudo cp macvlan tuning /opt/cni/bin/
```

Now install the whereabouts CNI on EGX Stack with the below steps from the master node

```
$ wget https://raw.githubusercontent.com/openshift/whereabouts-cni/master/doc/daemonset-install.yaml
$ sed -ie 's/latest/v0.3/g' daemonset-install.yaml
$ kubectl apply -f daemonset-install.yaml
$ kubectl apply -f https://raw.githubusercontent.com/openshift/whereabouts-cni/master/doc/whereabouts.cni.cncf.io_ippools.yaml
$ kubectl apply -f https://raw.githubusercontent.com/openshift/whereabouts-cni/master/doc/whereabouts.cni.cncf.io_overlappingrangeipreservations.yaml
```
Whereabout is An IP Address Management (IPAM) CNI plug-in that assigns IP addresses cluster-wide. for more information, please refer to https://github.com/openshift/whereabouts-cni

### Installing nv_peer_mem on EGX Stack 

`NOTE:` Install the [GPU Operator](#Installing-the-GPU-Operator) before installing nv_peer_memory on every node, as nv_peer_memory needs NVIDIA Drivers. 

Execute the below steps on every EGX node.

First, clone the nv_peer_mem source from GitHub and build the nv_peer_mem module with the below steps.

```
$ git clone https://github.com/Mellanox/nv_peer_memory.git

$ cd nv_peer_memory 

$ sudo nano create_nv.symvers.sh
```

replace the line `nvidia_mod=$(/sbin/modinfo -F filename -k "$KVER" $mod 2>/dev/null)"` with 

`nvidia_mod="/run/nvidia/driver/usr/src/nvidia-460.32.03/kernel/nvidia.ko"` in the file `create_nv.symvers.sh`


Now build the nv_peer_mem module with the below commands

```
./build_module.sh

$ cd /tmp
$ tar xzf /tmp/nvidia-peer-memory_1.1.orig.tar.gz
$ cd nvidia-peer-memory-1.1
$ sudo apt install autotools-dev debhelper -y
$ sudo dpkg-buildpackage -us -uc
$ sudo dpkg -i <path to generated deb files>

(e.g. sudo dpkg -i ../nvidia-peer-memory_1.1-0_all.deb
      sudo dpkg -i ../nvidia-peer-memory-dkms_1.1-0_all.deb)
```


### Validating the Mellanox on EGX Stack 

Create Network definition for IPAM on EGX Stack
```
sudo nano networkdefination.yaml 
```

Add the below content to the network definition YAML and apply it to EGX Stack on the master node
```
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
                "vlan": 111
            },
            {
                "mtu": 1500,
                "type": "tuning"
            }
        ]
    }
``` 

`NOTE:` If you do not have VLAN based networking on the high-performance side, please set "vlan": 0
 
 Execute the below command to install network definition on EGX Stack from the master node
 
 ```
 $ kubectl apply -f networkdefination.yaml 
 ```
 
Now create the pod YAML with the below content.

``` 
$ sudo nano mellanox-test.yaml

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
 ```

Apply the Mellanox test pod to the EGX stack for the validation
```
$ kubectl apply -f mellanox-test.yaml
```

Once you apply, verify the `rdma-test-pod-1` pod logs. You should see the expected output 

Expected Output:
```
$ kubectl logs rdma-test-pod-1

/dev/infiniband:
total 0
crw------- 1 root root 231,  64 Nov 19 02:26 issm0
crw-rw-rw- 1 root root  10,  54 Nov 19 02:26 rdma_cm
crw------- 1 root root 231,   0 Nov 19 02:26 umad0
crw-rw-rw- 1 root root 231, 192 Nov 19 02:26 uverbs0
 
/sys/class/net:
total 0
lrwxrwxrwx 1 root root 0 Nov 19 02:26 eth0 -> ../../devices/virtual/net/eth0
lrwxrwxrwx 1 root root 0 Nov 19 02:26 lo -> ../../devices/virtual/net/lo
lrwxrwxrwx 1 root root 0 Nov 19 02:26 net1 -> ../../devices/virtual/net/net1
lrwxrwxrwx 1 root root 0 Nov 19 02:26 tunl0 -> ../../devices/virtual/net/tunl0
```

#### Validate nv_peer_mem on EGX Stack 

First, verify that nv_peer_mem modules are loaded on every EGX node with the below command: 

```
$ lsmod | grep nv_peer_mem
```

Output:
```
nv_peer_mem            16384  0
ib_core               323584  11 rdma_cm,ib_ipoib,mlx4_ib,nv_peer_mem,iw_cm,ib_umad,rdma_ucm,ib_uverbs,mlx5_ib,ib_cm,ib_ucm
nvidia              20385792  117 nvidia_uvm,nv_peer_mem,nvidia_modeset
```

Execute the below command to list the Mellanox NIC's with the status
```
$ sudo ibdev2netdev
```
Output:
```
mlx5_0 port 1 ==> ens192f0 (Up)
mlx5_1 port 1 ==> ens192f1 (Down)
```

Update the above Mellanox NIC, which status is `Up` in the below command 

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

Execute the below command with the above inet address to verify the nv_peer_memory performance on EGX Stack. 
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
 GID index       : 2
 Max inline data : 0[B]
 rdma_cm QPs     : OFF
 Data ex. method : Ethernet
---------------------------------------------------------------------------------------
 local address: LID 0000 QPN 0x0107 PSN 0x41d4ae RKey 0x007e4d VAddr 0x007f3dea182000
 GID: 00:00:00:00:00:00:00:00:00:00:255:255:10:110:16:182
 remote address: LID 0000 QPN 0x0109 PSN 0xb00f6c RKey 0x00827d VAddr 0x007f55e740b000
 GID: 00:00:00:00:00:00:00:00:00:00:255:255:10:110:16:103
---------------------------------------------------------------------------------------
 #bytes     #iterations    BW peak[Gb/sec]    BW average[Gb/sec]   MsgRate[Mpps]
 2          5000           0.073998            0.072574            4.535869
 4          5000             0.15               0.15               4.616910
 8          5000             0.30               0.30               4.641355
 16         5000             0.59               0.59               4.610558
 32         5000             1.19               1.19               4.640746
 64         5000             2.38               2.36               4.613819
 128        5000             4.95               4.94               4.826261
 256        5000             9.89               9.81               4.789082
 512        5000             18.94              18.89              4.610968
 1024       5000             39.36              39.00              4.760667
 2048       5000             68.65              68.30              4.168437
 4096       5000             85.92              85.62              2.612937
 8192       5000             87.79              87.77              1.339222
 16384      5000             87.73              87.69              0.669041
 32768      5000             87.76              87.76              0.334766
 65536      5000             88.08              88.08              0.167992
 131072     5000             88.07              88.06              0.083983
 262144     5000             83.87              83.78              0.039948
 524288     5000             83.72              83.67              0.019949
 1048576    5000             83.79              83.78              0.009987
 2097152    5000             83.72              83.71              0.004989
 4194304    5000             83.73              83.73              0.002495
 8388608    5000             83.78              83.75              0.001248
```
The benchmark achieved approximately 83 Gbps throughput.

Exit from RDMA test pods and then Delete the RDMA test pods with the below command.

```
$ kubectl delete pod rdma-test-pod-1 rdma-test-pod-2
```

### Validating the Installation

GPU Operator validates the stack through the nvidia-device-plugin-validation pod and the nvidia-driver-validation pod. If both are completed successfully (see output from kubectl get pods --all-namespaces | grep -v kube-system), the EGX Stack works as expected. This section provides two examples of validating that the GPU is usable from within a pod to validate the stack manually.

#### Example 1: nvidia-smi

Execute the following:

```
$ kubectl run nvidia-smi --rm -t -i --restart=Never --image=nvidia/cuda:11.2.1-base --limits=nvidia.com/gpu=1 -- nvidia-smi
```

Output:

``` 
Tue Apr 9 22:35:02 2021
+-----------------------------------------------------------------------------+
| NVIDIA-SMI 460.32.03    Driver Version: 460.32.03    CUDA Version: 11.2     |
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
$ sudo nano cuda-samples.yaml
```

Add the below and save it as cuda-samples.yaml:

```
apiVersion: v1
kind: Pod
metadata:
  name: cuda-vector-add
spec:
  restartPolicy: OnFailure
  containers:
    - name: cuda-vector-add
      image: "k8s.gcr.io/cuda-vector-add:v0.1"
```

Execute the below command to create a sample GPU pod:

```
$ kubectl apply -f cuda-samples.yaml
```

Check if the cuda-samples pod was created:

```
$ kubectl get pods
``` 

EGX Stack works as expected if the get pods command shows the pod status as completed.

### Validate the EGX Stack with an application from NGC
Another option to validate EGX Stack is by running a demo application hosted on NGC.

NGC is NVIDIA's GPU Optimized Software Hub. NGC provides a curated set of GPU-optimized software for AI, HPC, and Visualization. The content provided by NVIDIA and third-party ISVs simplify building, customizing, and integrating GPU-optimized software into workflows, accelerating the time to solutions for users.

Containers, pre-trained models, Helm charts for Kubernetes deployments, and industry-specific AI toolkit with software development kits (SDKs) hosted on NGC. For more information about how to deploy an application that hosted on NGC, the NGC Private Registry, please refer to this [NGC Registry Guide](https://github.com/NVIDIA/egx-platform/blob/master/install-guides/NGC_Registry_Guide_v1.0.md). Visit the [public NGC documentation](https://docs.nvidia.com/ngc) for more information

The steps in this section use the publicly available DeepStream - Intelligent Video Analytics (IVA) demo application Helm Chart. The application can validate the full EGX Stack and test the connectivity of the EGX Stack to remote sensors. DeepStream delivers real-time AI-based video and image understanding and multi-sensor processing on GPUs. For more information, please refer to the [Helm Chart](https://ngc.nvidia.com/catalog/helm-charts/nvidia:video-analytics-demo)

There are two ways to configure the DeepStream - Intelligent Video Analytics Demo Application on your EGX DIY Stack

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

Execute the following command to deploy the demo application:
```
helm install video-analytics-demo --name-template iva
```

Once the helm chart is deployed, access the application with the VLC player. See the instructions below. 

#### Using the integrated video file (no camera)

If you don’t have a camera input, please execute the below commands to use the default video already integrated into the application. 

```
$ helm fetch https://helm.ngc.nvidia.com/nvidia/charts/video-analytics-demo-0.1.6.tgz

$ helm install video-analytics-demo-0.1.6.tgz --name-template iva
```

`NOTE:` if you're deploying on A100 GPU, please pass image tag as `--set image.tag=5.0-20.08-devel-a100` to the above command 

Once the helm chart is deployed, Access the Application with the VLC player as per the below instructions. 
For more information about the demo application, please refer to https://ngc.nvidia.com/catalog/helm-charts/nvidia:video-analytics-demo

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

You will now see the video output like below with the AI model detecting objects.

![Deepstream_Video](screenshots/Deepstream.png)

`NOTE:` Video stream in VLC will change if you provide an input RTSP camera.


#### Uninstalling the GPU Operator 

Execute the below commands to uninstall the GPU Operator 

```
$ helm ls
NAME                    NAMESPACE       REVISION        UPDATED                                 STATUS          CHART                   APP VERSION
gpu-operator-1606173805 default         1               2021-04-09 20:23:28.063421701 +0000 UTC deployed        gpu-operator-1.6.2      1.6.2 

$ helm del gpu-operator-1606173805
```
