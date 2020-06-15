<h1>EGX Stack v1.2 - Install Guide for Ubuntu Server x86-64</h1>
<h2>Introduction</h2>

This document describes how to set up the EGX Stack v1.2 on a single node to enable the deployment of AI applications via Helm charts from NGC. The final environment will include:

- Ubuntu 18.04.3 LTS
- Docker CE 19.03.1 
- Kubernetes version 1.15.3
- Helm 3.1.0
- NVIDIA GPU Operator 1.1.7
  - NV containerized driver: 440.64.00
  - NV container toolkit: 1.0.2
  - NV K8S device plug-in: 1.0.0-beta6
  - Data Center GPU Manager (DCGM): 1.7.2

<h2>Table of Contents</h2>

- [Release Notes](#Release-Notes)
- [Prerequisites](#Prerequisites)
- [Installing the Ubuntu Operating System](#Installing-the-Ubuntu-Operating-System)
- [Installing Docker-CE](#Installing-Docker-CE)
- [Installing Kubernetes](#Installing-Kubernetes)
- [Installing Helm](#Installing-Helm)
- [Installing the GPU Operator](#Installing-the-GPU-Operator)
- [Validating the Installation](#Validating-the-Installation)

### Release Notes

- Updated Helm to version 3.1.0.
- Information added that T4 and RTX 6000/8000 based NGC-Ready for Edge Servers are supported.

### Prerequisites
 
The following instructions assume the following:

- You have a NGC-Ready for Edge Server.
- You will perform a clean install.

To determine if your system qualifies as a NGC-Ready for Edge Server, review the list of NGC-Ready for Edge Systems at https://docs.nvidia.com/ngc/ngc-ready-systems/index.html. NGC-Ready for Edge Servers based on T4 and RTX 6000/8000 are supported with this EGX Stack version. 

Please note that the EGX Stack is only validated on Intel based NGC-Ready systems with the default kernel (not HWE). Using an AMD EPYC 2nd generation (ROME) NGC-Ready server is not validated yet and will require the HWE kernel and manually disabling nouveau.

### Installing the Ubuntu Operating System
These instructions require installing Ubuntu Server LTS 18.04.3 on your NGC-Ready for Edge system. Ubuntu Server can be downloaded from http://cdimage.ubuntu.com/releases/bionic/release/.

Disabling nouveau (not validated and only required with Ubuntu 18.04.3 LTS HWE Kernel): 

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

For more information on installing Ubuntu server please reference the [Ubuntu Server Installation Guide](https://ubuntu.com/tutorials/tutorial-install-ubuntu-server#1-overview).

### Installing Docker-CE
Set up the repository
Update the apt package index:

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

Verify that you now have the key with the fingerprint 9DC8 5822 9FC7 DD38 854A E2D8 8D81 803C 0EBF CD88, by searching for the last 8 characters of the fingerprint:
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

Install Docker Engine 19.03.1:

```
$ sudo apt-get install -y docker-ce=5:19.03.1~3-0~ubuntu-bionic docker-ce-cli=5:19.03.1~3-0~ubuntu-bionic containerd.io
```

Verify that Docker Engine - Community is installed correctly by running the hello-world image:

```
$ sudo docker run hello-world
```

More information on how to install Docker can be found at https://docs.docker.com/install/linux/docker-ce/ubuntu/. 

### Installing Kubernetes 

Make sure docker has been started and enabled before starting installation:

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

Add the following lines in kubernetes.list and save the file:

```
deb https://apt.kubernetes.io/ kubernetes-xenial main
```

Now execute the below:

```
$ sudo apt-get update
$ sudo apt-get install -y -q kubelet=1.15.3-00 kubectl=1.15.3-00 kubeadm=1.15.3-00
$ sudo apt-mark hold kubelet kubeadm kubectl
```

#### Initializing the Kubernetes cluster to run as master
Disable swap:
```
$ sudo swapoff -a
$ sudo nano /etc/fstab
```

Add a # before all the lines that start with /swap. # is a comment and the result should look something like this:

```
UUID=e879fda9-4306-4b5b-8512-bba726093f1d / ext4 defaults 0 0
UUID=DCD4-535C /boot/efi vfat defaults 0 0
#/swap.img       none    swap    sw      0       0
```

Execute the following command:

```
$ sudo kubeadm init --pod-network-cidr=192.168.0.0/16
```

The output will show you the commands that you can execute to deploy a pod network to the cluster as well as commands to join the cluster.

Following the instructions in the output, execute the commands as shown below:

```
$ mkdir -p $HOME/.kube
$ sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
$ sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

With the following command you install a pod-network add-on to the control plane node. We are using calico as the pod-network add-on here:

```
$ kubectl apply -f https://docs.projectcalico.org/v3.9/manifests/calico.yaml
```

You can run below commands to ensure all pods are up and running:

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
NAME      STATUS   ROLES    AGE   VERSION
#yournodes   Ready    master   10m   v1.15.3
```

Since we are using a single node kubernetes cluster, the cluster will not be able to schedule pods on the control plane node by default. In order to schedule pods on the control plane node we have to remove the taint by executing the following command:

```
$ kubectl taint nodes --all node-role.kubernetes.io/master-
```

Refer to https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/
for more information.

### Installing Helm 

Execute the following command to download Helm 3.1.0: 

```
$ sudo wget https://get.helm.sh/helm-v3.1.0-linux-amd64.tar.gz
$ sudo tar -zxvf helm-v3.1.0-linux-amd64.tar.gz
$ sudo mv linux-amd64/helm /usr/local/bin/helm
```

Refer to https://github.com/helm/helm/releases and https://helm.sh/docs/using_helm/#installing-helm  for more information.

### Installing the GPU Operator
Add the nvidia repo 

```
$ helm repo add nvidia https://nvidia.github.io/gpu-operator
```

Update the helm repo:

```
$ helm repo update
```

To install the GPU Operator for Tesla T4 or RTX6000/8000 GPUs:

```
$ helm install --version 1.1.7 --devel nvidia/gpu-operator --wait --generate-name
```

#### Validate the state of the GPU Operator:

Please note that the installation of the GPU Operator can take a couple minutes. How long you will have to wait will depend on your internet speed.

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
gpu-operator-resources   nvidia-driver-validation                                          0/1     Completed   0          4m57s

```

Please refer to https://github.com/NVIDIA/gpu-operator for more information.

### Validating the Installation
The GPU Operator validates the stack through the nvidia-device-plugin-validation pod and the nvidia-driver-validation pod. If both completed successfully (see output from kubectl get pods --all-namespaces | grep -v kube-system), the EGX Stack works as expected. To manually validate the stack, this section provides two examples of how to validate that the GPU is usable from within a pod.

#### Example 1: nvidia-smi

Execute the follwoing:

```
$ kubectl run nvidia-smi --rm -t -i --restart=Never --image=nvidia/cuda --limits=nvidia.com/gpu=1 -- nvidia-smi
```

Output:

``` 
Thu May 20 23:13:20 2020
+-----------------------------------------------------------------------------+
| NVIDIA-SMI 418.40.04    Driver Version: 418.40.04    CUDA Version: 10.1     |
|-------------------------------+----------------------+----------------------+
| GPU  Name        Persistence-M| Bus-Id        Disp.A | Volatile Uncorr. ECC |
| Fan  Temp  Perf  Pwr:Usage/Cap|         Memory-Usage | GPU-Util  Compute M. |
|===============================+======================+======================|
|   0  Tesla T4            Off  | 00000000:D8:00.0 Off |                    0 |
| N/A   32C    P8     9W /  70W |     10MiB / 15079MiB |      0%      Default |
+-------------------------------+----------------------+----------------------+

+-----------------------------------------------------------------------------+
| Processes:                                                       GPU Memory |
|  GPU       PID   Type   Process name                             Usage      |
|=============================================================================|
|  No running processes found                                                 |
+-----------------------------------------------------------------------------+
pod "nvidia-smi" deleted
```

#### Example 2: CUDA-Vector-Add

Create a pod yaml file:

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

Run the below command to create a sample gpu pod:

```
$ sudo kubectl apply -f cuda-samples.yaml
```

Check if the cuda-samples pod was created:

```
$ kubectl get pods
``` 

The EGX stack works as expected if the get pods command shows the pod status as completed.
