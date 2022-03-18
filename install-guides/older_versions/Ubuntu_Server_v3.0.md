<h1>NVIDIA Cloud Native Core v3.0 (formely EGX Stack 3.0) - Install Guide for Ubuntu Server x86-64</h1>
<h2>Introduction</h2>

This document describes how to set up the NVIDIA Cloud Native Core v3.0 on a single node to enable the deployment of AI applications via Helm charts from NGC. The final environment will include:

- Ubuntu 20.04.1 LTS
- Docker CE 19.03.12 
- Kubernetes version 1.18.8
- Helm 3.3.3
- NVIDIA GPU Operator 1.2.0
  - NV containerized driver: 450.80.02
  - NV container toolkit: 1.3.0
  - NV K8S device plug-in: 0.7.0
  - Data Center GPU Manager (DCGM): 2.1.0-rc.2
  - Node Feature Discovery: 0.6.0

<h2>Table of Contents</h2>

- [Prerequisites](#Prerequisites)
- [Installing the Ubuntu Operating System](#Installing-the-Ubuntu-Operating-System)
- [Installing Docker-CE](#Installing-Docker-CE)
- [Installing Kubernetes](#Installing-Kubernetes)
- [Installing Helm](#Installing-Helm)
- [Installing the GPU Operator](#Installing-the-GPU-Operator)
- [Validating the Installation](#Validating-the-Installation)
- [NGC - NVIDIA's GPU-Optimized Software Hub](#NVIDIAs-GPU-Optimized-Software-Hub)

### Release Notes

- Upgraded to Ubuntu Server 20.04.1 LTS
- Upgraded to Docker-CE 19.03.12
- Upgradet to Kubernetes 1.18.8
- Upgraded to Helm 3.3.3
- Upgraded to GPU Operator 1.2.0
- Added Support for A100

### Prerequisites
 
The following instructions assume the following:

- You have a NGC-Ready for Edge Server.
- You will perform a clean install.

To determine if your system qualifies as a NGC-Ready for Edge Server, review the list of NGC-Ready for Edge Systems at https://docs.nvidia.com/ngc/ngc-ready-systems/index.html. NGC-Ready for Edge Servers based on T4, RTX 6000/8000 and A100 are supported with this NVIDIA Cloud Native Core version. 

Please note that the NVIDIA Cloud Native Core is only validated on Intel based NGC-Ready systems with the default kernel (not HWE). Using an AMD EPYC 2nd generation (ROME) NGC-Ready server is not validated yet and will require the HWE kernel and manually disabling nouveau.

### Installing the Ubuntu Operating System
These instructions require installing Ubuntu Server LTS 20.04.1 on your NGC-Ready for Edge system. Ubuntu Server can be downloaded from http://cdimage.ubuntu.com/releases/20.04.1/release/.

Disabling nouveau (not validated and only required with Ubuntu 20.04.1 LTS HWE Kernel): 

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
Set up the repository.

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

Install Docker Engine 19.03.12:

```
$ sudo apt-get install -y docker-ce=5:19.03.12~3-0~ubuntu-focal docker-ce-cli=5:19.03.12~3-0~ubuntu-focal containerd.io
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
$ sudo apt-get install -y -q kubelet=1.18.8-00 kubectl=1.18.8-00 kubeadm=1.18.8-00
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
$ kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
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
#yourhost   Ready    master   10m   v1.18.8
```

Since we are using a single node kubernetes cluster, the cluster will not be able to schedule pods on the control plane node by default. In order to schedule pods on the control plane node we have to remove the taint by executing the following command:

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

Refer to https://github.com/helm/helm/releases and https://helm.sh/docs/using_helm/#installing-helm  for more information.

### Installing the GPU Operator
Add the nvidia repo 

```
$ helm repo add nvidia https://helm.ngc.nvidia.com/nvidia
```

Update the helm repo:

```
$ helm repo update
```

To install the GPU Operator for Tesla T4, RTX 6000/8000 or A100:

```
$ helm install --version 1.2.0 --devel nvidia/gpu-operator --wait --generate-name
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

Please refer to https://ngc.nvidia.com/catalog/helm-charts/nvidia:gpu-operator for more information.

### Validating the Installation
The GPU Operator validates the stack through the nvidia-device-plugin-validation pod and the nvidia-driver-validation pod. If both completed successfully (see output from kubectl get pods --all-namespaces | grep -v kube-system), the NVIDIA Cloud Native Core works as expected. To manually validate the stack, this section provides two examples of how to validate that the GPU is usable from within a pod.

#### Example 1: nvidia-smi

Execute the following:

```
$ kubectl run nvidia-smi --rm -t -i --restart=Never --image=nvidia/cuda --limits=nvidia.com/gpu=1 -- nvidia-smi
```

Output:

``` 
Thu Oct 22 18:35:02 2020
+-----------------------------------------------------------------------------+
| NVIDIA-SMI 450.80.02    Driver Version: 450.80.02    CUDA Version: 11.1     |
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

The NVIDIA Cloud Native Core stack works as expected if the get pods command shows the pod status as completed.

### Validate the NVIDIA Cloud Native Core with an application from NGC

Another option to validate the NVIDIA Cloud Native Core is by running a demo application that is hosted on NGC. NGC is NVIDIA's hub for GPU-optimized software. The steps in this section use the publicly available DeepStream - Intelligent Video Analytics (IVA) demo application Helm Chart. The Application can be used to validate the full NVIDIA Cloud Native Core and test the connectivity of the NVIDIA Cloud Native Core to remote sensors. DeepStream delivers real-time AI based video and image understanding and multi-sensor processing on GPUs. For more information, please refer to the [Helm Chart](https://ngc.nvidia.com/catalog/helm-charts/nvidia:video-analytics-demo)

There are two ways to configure the DeepStream - Intelligent Video Analytics Demo Application on your NVIDIA Cloud Native Core

- Using a camera
- Using the integrated video file (no camera required)

#### Using a camera

##### Prerequisites: 
- RTSP Camera stream

Go through the below steps to install the demo application. 
```
1. helm fetch https://helm.ngc.nvidia.com/nvidia/charts/video-analytics-demo-0.1.5.tgz --untar

2. cd into the folder video-analytics-demo and update the file values.yaml

3. Go to the section Cameras in the values.yaml file and add the address of your IP camera. Read the comments section on how it can be added. Single or multiple cameras can be added as shown below

cameras:
 camera1: rtsp://XXXX
```

Run the following command to deploy the demo application:
```
helm install video-analytics-demo --name-template iva
```

Once the helm chart is deployed, access the application with the VLC player. See the instructions below. 

#### Using the integrated video file (no camera)

If you don’t have a camera input, please run the below commands to use the default video which is already integrated in the application. 

```
$ helm fetch https://helm.ngc.nvidia.com/nvidia/charts/video-analytics-demo-0.1.5.tgz

$ helm install video-analytics-demo-0.1.5 --name-template iva
```

Once the helm chart is deployed, Access the Application with VLC player as per below instructions. 
For more information about Demo application, please refer https://ngc.nvidia.com/catalog/helm-charts/nvidia:video-analytics-demo

#### Access from WebUI

Use the below WebUI URL to access video analytics demo application from browser
```
http://IPAddress of Node:31115/WebRTCApp/play.html?name=videoanalytics
```

#### Access from VLC

Download VLC Player from: https://www.videolan.org/vlc/ on the machine where you intend to view the video stream.

View the video stream in VLC by navigating to Media > Open Network Stream > Entering the following URL

```
rtsp://IPAddress of Node:31113/ds-test
```

You will now see the video output like below with the AI model detecting objects.

![Deepstream_Video](screenshots/Deepstream.png)

`NOTE:` Video stream in VLC will change if you provide an input RTSP camera.

### NVIDIA's GPU Optimized Software Hub

NGC is NVIDIA's GPU Optimized Software Hub. NGC provides a curated set of GPU-optimized software for AI, HPC and Visualization.

The content provided by NVIDIA and third party ISVs simplify building, customizing and the integration of GPU-optimized software into workflows, accelerating the time to solutions for users.

Containers, pre-trained models, Helm charts for Kubernetes deployments and industry specific AI toolkits with software development kits (SDKs) are hosted on NGC. For more information about how to deploy an application that is hosted on NGC, the NGC Private Registry, please refer to this [NGC Registry Guide](https://github.com/erikbohnhorst/NVIDIA Cloud Native Core-DIY-Node-Stack/blob/master/install-guides/NGC_Registry_Guide_v1.0.md). Visit the [public NGC documentation](https://docs.nvidia.com/ngc) for more information

