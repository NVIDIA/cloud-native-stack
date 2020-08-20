<h1>EGX Stack - v2.0 Install Guide for Jetson Xavier NX DevKit</h1>

<h2>Introduction</h2>

This document describes how to set up the EGX Stack Version 2.0 on a Jetson Xavier NX DevKit to enable the deployment of AI applications via Helm charts from NGC. 

The final environment will include:

- JetPack 4.4
- Kubernetes version 1.17.5
- Helm/Tiller 3.1.0
- Nvidia Container Runtime 1.0.1-dev

<h2>Table of Contents</h2>

- [Prerequisites](#Prerequisites)
- [Installing JetPack 4.4](#Installing-JetPack-4.4)
- [Jetson Xavier NX Storage](#Jetson-Xavier-NX-Storage)
- [Docker Config Update](#Update-Docker-Config)
- [Installing Kubernetes](#Installing-Kubernetes)
- [Installing Helm](#Installing-Helm)
- [Validating the Installation](#Validating-the-Installation)

### Prerequisites
 
These instructions assume you have a Jetson Xavier or Xavier NX Developer Kit.

- You will perform a clean install.
- The server has internet connectivity.

### Installing JetPack 4.4

JetPack (the Jetson SDK) is an on-demand all-in-one package that bundles developer software for the NVIDIA® Jetson platform. Use the SDK Manager installer to flash your Jetson Developer Kit with the latest OS image, to install developer tools for both host PC and Developer Kit, and to install the libraries and APIs, samples, and documentation needed to jumpstart your development environment.

Follow the link for instructions on how to install JetPack 4.4
https://docs.nvidia.com/sdk-manager/install-with-sdkm-jetson/index.html

Download the SDK Manager here:
https://developer.nvidia.com/nvidia-sdk-manager

### Jetson Xavier NX Storage
Running EGX on Xavier NX production modules (16GB) might not provide sufficient storage capacity with fully loaded JetPack 4.4 to host your specific container images. If you require additional storage, use the Jetson Xavier NX Development Kit during the development phase as you can insert greater than 16GB via microSD cards and/or remove unused JetPack 4.4 packages. For production deployments, remove not required packages from fully loaded JetPack 4.4 and/or extend the storage capacity via NVMe or SSD.


### Update Docker Config

Edit the docker daemon configuration to add the following line and save the file 

```
"default-runtime" : "nvidia"
```

Example: 
```
$ sudo nano /etc/docker/daemon.json
 
{
   "runtimes": {
   	"nvidia": {
       	"path": "nvidia-container-runtime",
           "runtimeArgs": []
   	}
   },
   "default-runtime" : "nvidia"
}
```

Now execute the below commands, to restart the docker daemon.
```
sudo systemctl daemon-reload && sudo systemctl restart docker
```

#### Validate docker default runtime

Please run the below command to validate docker default runtime as Nvidia

```
$ sudo docker info | grep -i runtime
```

Output:
```
Runtimes: nvidia runc
Default Runtime: nvidia
```

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
$ sudo apt-get install -y -q kubelet=1.17.5-00 kubectl=1.17.5-00 kubeadm=1.17.5-00
$ sudo apt-mark hold kubelet kubeadm kubectl
```

#### Initializing the Kubernetes cluster to run as master
Disable swap:
```
$ sudo swapoff -a
```

Execute the following command:

```
$ sudo kubeadm init --pod-network-cidr=10.244.0.0/16
```

The output will show you the commands that you can execute for deploying a pod network to the cluster as well as commands to join the cluster.

Following the instructions in the output, execute the commands as shown below:

```
$ mkdir -p $HOME/.kube
$ sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
$ sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

With the following command you can install a pod-network add-on to the control plane node. We are using calico as the pod-network add-on here:

```
$ kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
```

You can run below commands to ensure all pods are up and running:

```
$ kubectl get pods --all-namespaces
```

Output:

```
NAMESPACE     NAME                                       READY   STATUS    RESTARTS   AGE
kube-system   kube-flannel-ds-arm64-gz28t                1/1     Running   0          2m8s
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
#yournodes   Ready    master   10m   v1.17.5
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
$ sudo wget https://get.helm.sh/helm-v3.1.0-linux-arm64.tar.gz
$ sudo tar -zxvf helm-v3.1.0-linux-arm64.tar.gz
$ sudo mv linux-arm64/helm /usr/local/bin/helm
```

Refer to https://github.com/helm/helm/releases and https://helm.sh/docs/using_helm/#installing-helm  for more information.


### Validating the Installation


Create a pod yaml file, add the following contents to it and save it as samples.yaml:

```
$ sudo nano cuda-samples.yaml
```

Add the below and save it as cuda-samples.yaml:

```
apiVersion: v1
kind: Pod
metadata:
  name: nvidia-l4t-base
spec:
  restartPolicy: OnFailure
  containers:
  - name: nvidia-l4t-base
    image: "nvcr.io/nvidia/l4t-base:r32.4.2"
    args:
       - /usr/local/cuda/samples/1_Utilities/deviceQuery/deviceQuery
```
Now compile the cuda examples to validate from pod. 

```
$ cd /usr/local/cuda/samples/1_Utilities/deviceQuery
$ sudo make
$ cd ~
```
Run the below command to create a sample gpu pod:
```
$ sudo kubectl apply -f cuda-samples.yaml
```
Check if the samples pod was created:
```
$ kubectl get pods
```
Output:
```
nvidia-l4t-base  0/1 Completed 2m
```

Validate the sample pod logs to support cuda libraries.

```
kubectl logs nvidia-l4t-base
```
The EGX Stack works as expected if the get pods command shows the pod status as completed. You can also verify the successfull run of the cuda-samples.yaml by verifyinng that the output shows Result=PASS

Output:

```
/usr/local/cuda/samples/1_Utilities/deviceQuery/deviceQuery Starting...
CUDA Device Query (Runtime API) version (CUDART static linking)
Detected 1 CUDA Capable device(s)
Device 0: "Xavier"
 CUDA Driver Version / Runtime Version      	10.0 / 10.0
  CUDA Capability Major/Minor version number:	7.2
  Total amount of global memory:             	15815 MBytes (16583041024 bytes)
  ( 8) Multiprocessors, ( 64) CUDA Cores/MP: 	512 CUDA Cores
  GPU Max Clock rate:                        	1377 MHz (1.38 GHz)
  Memory Clock rate:                         	1377 Mhz
  Memory Bus Width:                          	256-bit
  L2 Cache Size: 	                            524288 bytes
  Maximum Texture Dimension Size (x,y,z)     	1D=(131072), 2D=(131072, 65536), 3D=(16384, 16384, 16384)
  Maximum Layered 1D Texture Size, (num) layers  1D=(32768), 2048 layers
  Maximum Layered 2D Texture Size, (num) layers  2D=(32768, 32768), 2048 layers
  Total amount of constant memory:           	65536 bytes
  Total amount of shared memory per block:   	49152 bytes
  Total number of registers available per block: 65536
  Warp size:                  	               32
  Maximum number of threads per multiprocessor:  2048
  Maximum number of threads per block:       	1024
  Max dimension size of a thread block (x,y,z): (1024, 1024, 64)
  Max dimension size of a grid size	(x,y,z): (2147483647, 65535, 65535)
  Maximum memory pitch:                      	2147483647 bytes
  Texture alignment:                         	512 bytes
  Concurrent copy and kernel execution:      	Yes with 1 copy engine(s)
  Run time limit on kernels:              	   No
  Integrated GPU sharing Host Memory:        	Yes
  Support host page-locked memory mapping:   	Yes
  Alignment requirement for Surfaces:        	Yes
  Device has ECC support:                    	Disabled
  Device supports Unified Addressing (UVA):  	Yes
  Device supports Compute Preemption:        	Yes
  Supports Cooperative Kernel Launch:        	Yes
  Supports MultiDevice Co-op Kernel Launch:  	Yes
  Device PCI Domain ID / Bus ID / location ID:   0 / 0 / 0
  Compute Mode:
     < Default (multiple host threads can use ::cudaSetDevice() with device simultaneously) >
deviceQuery, CUDA Driver = CUDART, CUDA Driver Version = 10.0, CUDA Runtime Version = 10.0, NumDevs = 1
Result = PASS
```

