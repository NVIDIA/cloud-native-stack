<h1>NVIDIA Cloud Native Core - v4.0(formely EGX Stack 4.0) Install Guide for Jetson Xavier NX DevKit</h1>

<h2>Introduction</h2>

This document describes how to set up NVIDIA Cloud Native Core Version 4.0 on a Jetson Xavier NX DevKit to deploy AI applications via Helm charts from NGC. 

The final environment will include:

- JetPack 4.5.1
- Kubernetes version 1.21.1
- Helm 3.5.4
- NVIDIA Container Runtime 1.0.1-dev

<h2>Table of Contents</h2>

- [Prerequisites](#Prerequisites)
- [Installing JetPack 4.5.1](#Installing-JetPack-4.5.1)
- [Jetson Xavier NX Storage](#Jetson-Xavier-NX-Storage)
- [Docker Config Update](#Update-Docker-Config)
- [Installing Kubernetes](#Installing-Kubernetes)
- [Installing Helm](#Installing-Helm)
- [Validating the Installation](#Validating-the-Installation)
- [Validate NVIDIA Cloud Native Core with an application from NGC](#Validate-the-NVIDIA-Cloud-Native-Core-with-an-application-from-NGC)

### Release Notes

- Upgraded to JetPack 4.5.1
- Upgraded to Kubernetes 1.21.1
- Upgraded to Helm 3.5.4

### Prerequisites
 
These instructions assume you have a Jetson Xavier or Xavier NX Developer Kit.

- You will perform a clean install.
- The server has internet connectivity.

### Installing JetPack 4.5.1

JetPack (the Jetson SDK) is an on-demand all-in-one package that bundles developer software for the NVIDIA® Jetson platform. Use the SDK Manager installer to flash your Jetson Developer Kit with the latest OS image, install developer tools for both host PC and Developer Kit, and install the libraries and APIs, samples, and documentation needed to jump-start your development environment.

Follow the [instructions](https://docs.nvidia.com/sdk-manager/install-with-sdkm-jetson/index.html) on how to install JetPack 4.5.1.

Download the SDK Manager from [here](https://developer.nvidia.com/nvidia-sdk-manager)

### Jetson Xavier NX Storage
Running NVIDIA Cloud Native Core on Xavier NX production modules (16GB) might not provide sufficient storage capacity with fully loaded JetPack 4.5 to host your specific container images. If you require additional storage, use the Jetson Xavier NX Development Kit during the development phase, as you can insert greater than 16GB via microSD cards and/or remove unused JetPack 4.5 packages. For production deployments, remove packages that are not required from fully loaded JetPack 4.5 and/or extend the storage capacity via NVMe or SSD.


### Update Docker Config

Edit the docker daemon configuration to add the following line and save the file:

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

Now execute the below commands to restart the docker daemon:
```
sudo systemctl daemon-reload && sudo systemctl restart docker
```

#### Validate docker default runtime

Execute the below command to validate docker default runtime as NVIDIA:

```
$ sudo docker info | grep -i runtime
```

Output:
```
Runtimes: nvidia runc
Default Runtime: nvidia
```

### Installing Kubernetes 

Make sure docker is started and enabled before beginning installation:

```
$ sudo systemctl start docker && sudo systemctl enable docker
```

Execute the following commands to install kubelet kubeadm and kubectl:

```
$ sudo apt-get update && sudo apt-get install -y apt-transport-https curl
$ curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
$ sudo mkdir -p  /etc/apt/sources.list.d/
```

Create kubernetes.list:

```
$ cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
```

Now execute the commands below:

```
$ sudo apt-get update
$ sudo apt-get install -y -q kubelet=1.21.1-00 kubectl=1.21.1-00 kubeadm=1.21.1-00
$ sudo apt-mark hold kubelet kubeadm kubectl
```

#### Initializing the Kubernetes cluster to run as master

##### Disable swap
```
$ sudo swapoff -a
```

Execute the following command:

```
$ sudo kubeadm init --pod-network-cidr=10.244.0.0/16
```

The output will show you the commands that you can execute to deploy a pod network to the cluster and commands to join the cluster.

Following the instructions in the output, execute the commands as shown below:

```
$ mkdir -p $HOME/.kube
$ sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
$ sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

With the following command, you can install a pod-network add-on to the control plane node. Flannel is the pod-network add-on here:

```
$ kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
```

You can execute the below commands to ensure all pods are up and running:

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
NAME         STATUS   ROLES                   AGE   VERSION
#yournodes   Ready    control-plane, master   10m   v1.21.1
```

Since we are using a single-node Kubernetes cluster, the cluster will not schedule pods on the control plane node by default. To schedule pods on the control plane node, we have to remove the taint by executing the following command:

```
$ kubectl taint nodes --all node-role.kubernetes.io/master-
```

Refer to [Installing Kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/)
for more information.

### Installing Helm 

Execute the following command to download Helm 3.5.4: 

```
$ sudo wget https://get.helm.sh/helm-v3.5.4-linux-arm64.tar.gz
$ sudo tar -zxvf helm-v3.5.4-linux-arm64.tar.gz
$ sudo mv linux-arm64/helm /usr/local/bin/helm
```

Refer to the Helm 3.5.4 [release notes](https://github.com/helm/helm/releases) and the [Installing Helm guide](https://helm.sh/docs/using_helm/#installing-helm) for more information.

### Adding an additional node to the NVIDIA Cloud Native Core

Kubernetes packages are required on additional nodes.

Prerequisites: 
- [Installing Kubernetes](#Installing-Kubernetes)
- [Disable swap](#Disable-swap)

Once the prerequisites are completed on the additional nodes, execute the below command on the control-plane node and then execute the join command output on an additional node to add the additional node to NVIDIA Cloud Native Core. 

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
NAME             STATUS   ROLES                  AGE   VERSION
#yourhost        Ready    control-plane,master   10m   v1.21.1
#yourhost-worker Ready                           10m   v1.21.1
```

### Validating the Installation


Create a pod YAML file, add the following contents to it, and save it as samples.yaml:

```
$ cat <<EOF | sudo tee cuda-samples.yaml
apiVersion: v1
kind: Pod
metadata:
  name: nvidia-l4t-base
spec:
  restartPolicy: OnFailure
  containers:
  - name: nvidia-l4t-base
    image: "nvcr.io/nvidia/l4t-base:r32.5.0"
    args:
       - /usr/local/cuda/samples/1_Utilities/deviceQuery/deviceQuery
EOF
```
Now compile the CUDA examples to validate from the pod: 

```
$ cd /usr/local/cuda/samples/1_Utilities/deviceQuery
$ sudo make
$ cd ~
```
Execute the below command to create a sample GPU pod:
```
$ sudo kubectl apply -f cuda-samples.yaml
```
Execute the below command to confirm the cuda-samples pod was created:
```
$ kubectl get pods
```
Output:
```
nvidia-l4t-base  0/1 Completed 2m
```

Validate the sample pod logs to support CUDA libraries:

```
kubectl logs nvidia-l4t-base
```
NVIDIA Cloud Native Core works as expected if the get pods command shows the pod status as completed. You can also verify the successful run of the cuda-samples.yaml by confirming that the output shows Result=PASS

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
### Validate the NVIDIA Cloud Native Core with an application from NGC

Another option to validate the NVIDIA Cloud Native Core is by running a demo application hosted on NGC. 

NGC is NVIDIA's GPU Optimized Software Hub. NGC provides a curated set of GPU-optimized software for AI, HPC, and Visualization. The content provided by NVIDIA and third-party ISVs simplifies building, customizing, and integrating GPU-optimized software into workflows, accelerating the time to solutions for users.

Containers, pre-trained models, Helm charts for Kubernetes deployments, and industry-specific AI toolkits with software development kits (SDKs) are hosted on NGC. For more information about deploying an application hosted on NGC, please visit the NGC Private Registry. Refer to this document: [NGC Registry Guide](https://github.com/erikbohnhorst/NVIDIA Cloud Native Core-DIY-Node-Stack/blob/master/install-guides/NGC_Registry_Guide_v1.0.md). Visit the [public NGC documentation](https://docs.nvidia.com/ngc) for more information.

The steps in this section use the publicly available DeepStream - Intelligent Video Analytics (IVA) demo application Helm Chart. The application can validate the full NVIDIA Cloud Native Core and test the connectivity of the NVIDIA Cloud Native Core to remote sensors. DeepStream delivers real-time AI-based video and image understanding, as well as multi-sensor processing on GPUs. For more information, please refer to the [Helm Chart](https://ngc.nvidia.com/catalog/helm-charts/nvidia:video-analytics-demo-l4t)

There are two ways to configure the DeepStream - Intelligent Video Analytics Demo Application on your NVIDIA Cloud Native Core

- Using a camera
- Using the integrated video file (no camera required)

#### Using a camera

##### Prerequisites: 
- RTSP Camera stream

Go through the below steps to install the demo application. 
```
1. helm fetch https://helm.ngc.nvidia.com/nvidia/charts/video-analytics-demo-l4t-0.1.0.tgz --untar

2. cd into the folder video-analytics-demo-l4t and update the file values.yaml

3. Go to the section Cameras in the values.yaml file and add the address of your IP camera. Please read the comments section on how it could be added. Single or multiple cameras could be added as shown below

cameras:
 camera1: rtsp://XXXX
```

Execute the following command to deploy the demo application:
```
helm install video-analytics-demo-l4t --name-template iva
```

Once the helm chart is deployed, access the application with the VLC player. See the instructions below. 

#### Using the integrated video file (no camera)

If you don’t have a camera input, please execute the below commands to use the default video already integrated into the application. 

```
$ helm fetch https://helm.ngc.nvidia.com/nvidia/charts/video-analytics-demo-l4t-0.1.0.tgz

$ helm install video-analytics-demo-l4t-0.1.0 --name-template iva
```

Once the Helm chart is deployed, Access the Application with the VLC player as per the below instructions. 
For more information about the demo application, please refer to https://ngc.nvidia.com/catalog/helm-charts/nvidia:video-analytics-demo

#### Access from VLC

Download VLC Player from https://www.videolan.org/vlc/ on the machine where you intend to view the video stream.

View the video stream in VLC by navigating to Media > Open Network Stream > Entering the following URL

```
rtsp://IPAddress of Node:31113/ds-test
```

You will now see the video output like below with the AI model detecting objects.

![Deepstream_Video](screenshots/Deepstream.png)

`NOTE:` Video stream in VLC will change if you provide an input RTSP camera.
