<h1> NVIDIA Cloud Native Stack - v9.1 Install Guide for Jetson AGX Xavier or Jetson Xavier NX DevKit or Jetson Orin</h1>

<h2>Introduction</h2>

This document describes how to setup the NVIDIA Cloud Native Stack collection on a single or multiple Jetson AGX Xavier or Jetson Xavier NX DevKits or Jetson Orin. NVIDIA Cloud Native Stack can be configured to create a single node Kubernetes cluster or to create/add additional worker nodes to join an existing cluster.

The final environment will include:

- JetPack 5.1
- Kubernetes version 1.27.0
- Helm 3.11.2
- Containerd 1.7.0


<h2>Table of Contents</h2>

- [Prerequisites](#Prerequisites)
- [Installing JetPack 5.0](#Installing-JetPack-5.0)
- [Jetson Xavier NX Storage](#Jetson-Xavier-NX-Storage)
- [Upgrading Nvidia Container Runtime](#Upgrading-Nvidia-Container-Runtime)
- [Installing Containerd](#Installing-Containerd)
- [Installing Kubernetes](#Installing-Kubernetes)
- [Installing Helm](#Installing-Helm)
- [Adding an Additional Node to NVIDIA Cloud Native Stack](#Adding-additional-node-to-NVIDIA-Cloud-Native-Stack)
- [Validating the Installation](#Validating-the-Installation)
- [Validate NVIDIA Cloud Native Stack with an Application from NGC](#Validate-NVIDIA-Cloud-Native-Stack-with-an-application-from-NGC)


### Prerequisites
 
These instructions assume you have a Jetson Xavier or Xavier NX Developer Kit or Jetson Orin.

- You will perform a clean install.
- The server has internet connectivity.

### Installing JetPack 5.1

JetPack (the Jetson SDK) is an on-demand all-in-one package that bundles developer software for the NVIDIA® Jetson platform. There are two ways to install the JetPack 

1. Use the SDK Manager installer to flash your Jetson Developer Kit with the latest OS image, install developer tools for both host PC and Developer Kit, and install the libraries and APIs, samples, and documentation needed to jump-start your development environment.

Follow the [instructions](https://docs.nvidia.com/sdk-manager/install-with-sdkm-jetson/index.html) on how to install JetPack 4.6There are two ways to install the JetPack 

Download the SDK Manager from [here](https://developer.nvidia.com/nvidia-sdk-manager)

2. Use the SD Card Image method to download the JetPack and load the OS image to external drive. For more information, please refer [flash using SD Card method](https://developer.nvidia.com/embedded/learn/get-started-jetson-xavier-nx-devkit#prepare)

### Jetson Xavier NX Storage
Running NVIDIA Cloud Native Stack on Xavier NX production modules (16GB) might not provide sufficient storage capacity with fully loaded JetPack 4.5 to host your specific container images. If you require additional storage, use the Jetson Xavier NX Development Kit during the development phase, as you can insert greater than 16GB via microSD cards and/or remove unused JetPack 4.6 packages. For production deployments, remove packages that are not required from fully loaded JetPack 4.6 and/or extend the storage capacity via NVMe or SSD.

### Upgrading Nvidia Container Runtime


Execute the following commands to upgrade nvidia container runtime

Install packages to allow apt to use a repository over HTTPS:

```
 sudo apt-get install -y curl apt-transport-https gnupg-agent libseccomp2 autotools-dev debhelper software-properties-common
```

Execute the following to add apt keys:

```
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -   
```

Create nvidia-docker.list:

```
distribution=$(. /etc/os-release;echo $ID$VERSION_ID) &&  curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
```

Now execute the commands below:

```
sudo apt-get update && sudo apt install nvidia-container-runtime=3.13.0
```

## Installing Container Runtime

You need to install a container runtime into each node in the cluster so that Pods can run there. Currently Cloud Native Stack provides below container runtimes

- [Installing Containerd](#Installing-Containerd)
- [Installing CRI-O](#Installing-CRI-O)

`NOTE:` Only install one of either `Containerd` or `CRI-O`, not both!

These steps apply to both runtimes.

Set up the repository and update the apt package index:

```
sudo apt-get update
```

Install packages to allow apt to use a repository over HTTPS:

```
sudo apt-get install -y apt-transport-https ca-certificates gnupg-agent libseccomp2 autotools-dev debhelper software-properties-common
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

Download the Containerd tarball:

```
 wget https://github.com/containerd/containerd/releases/download/v1.7.0/cri-containerd-cni-1.7.0-linux-arm64.tar.gz
 sudo tar --no-overwrite-dir -C / -xzf cri-containerd-cni-1.7.0-linux-arm64.tar.gz
 rm -rf cri-containerd-cni-1.7.0-linux-arm64.tar.gz
```

Install Containerd:
```
 sudo mkdir -p /etc/containerd

 sudo wget -q https://raw.githubusercontent.com/NVIDIA/cloud-native-stack/master/playbooks/config.toml -P /etc/containerd/

 sudo systemctl enable containerd && sudo systemctl restart containerd
```

For additional information on installing Containerd, please reference [Install Containerd with Release Tarball](https://github.com/containerd/containerd/blob/master/docs/cri/installation.md). 

### Installing CRI-O(Option 2)

Setup the Apt repositry for CRI-O

```
OS=xUbuntu_22.04
VERSION=1.26
```
`NOTE:` VERSION (CRI-O version) is same as kubernetes major version 

```
echo "deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/ /" | sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list
```

```
curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/Release.key | sudo apt-key add -
```

```
echo "deb http://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$VERSION/$OS/ /" | sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable:cri-o:$VERSION.list
```

```
curl -L https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable:cri-o:$VERSION/$OS/Release.key | sudo apt-key add -
```

Install the CRI-O and dependencies 

```
sudo apt update && sudo apt install cri-o cri-o-runc cri-tools -y
```

Enable and Start the CRI-O service 

```
sudo systemctl enable crio.service && sudo systemctl start crio.service
```

### Installing Kubernetes 

Make sure container runtime has been started and enabled before beginning installation:

```
 sudo systemctl start containerd && sudo systemctl enable containerd
```

Execute the following to add apt keys:

```
 sudo apt-get update && sudo apt-get install -y apt-transport-https curl
 curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
 sudo mkdir -p  /etc/apt/sources.list.d/
```

Create kubernetes.list:

```
 cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
```

Now execute the below to install kubelet, kubeadm, and kubectl:

```
 sudo apt-get update
 sudo apt-get install -y -q kubelet=1.27.0-00 kubectl=1.27.0-00 kubeadm=1.27.0-00
 sudo apt-mark hold kubelet kubeadm kubectl
```

Create a kubelet default with your container runtime:
`NOTE:`  The container runtime endpoint will be `unix:/run/containerd/containerd.sock` or `unix:/run/crio/crio.sock` depending on which container runtime you chose in the previous steps.

For `Containerd` system:

```
 cat <<EOF | sudo tee /etc/default/kubelet
KUBELET_EXTRA_ARGS=--cgroup-driver=systemd --container-runtime=remote --runtime-request-timeout=15m --container-runtime-endpoint="unix:/run/containerd/containerd.sock"
EOF
```

For `CRI-O` system:

```
cat <<EOF | sudo tee /etc/default/kubelet
KUBELET_EXTRA_ARGS=--cgroup-driver=systemd --container-runtime=remote --runtime-request-timeout=15m --container-runtime-endpoint="unix:/run/crio/crio.sock"
EOF
```

Reload the system daemon:
```
 sudo systemctl daemon-reload
```

Disable swap:
```
 sudo swapoff -a
 sudo nano /etc/fstab
```

`NOTE:` Add a # before all the lines that start with /swap. # is a comment, and the result should look something like this:

```
UUID=e879fda9-4306-4b5b-8512-bba726093f1d / ext4 defaults 0 0
UUID=DCD4-535C /boot/efi vfat defaults 0 0
#/swap.img       none    swap    sw      0       0
```

#### Initializing the Kubernetes cluster to run as a control-plane node

Execute the following command  for `Containerd` systems:

```
 sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --cri-socket=/run/containerd/containerd.sock --kubernetes-version="v1.27.0"
```

Execute the following command for `CRI-O` systems::

```
 sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --cri-socket=unix:/run/crio/crio.sock --kubernetes-version="v1.27.0"
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

With the following command, you install a pod-network add-on to the control plane node. We are using antrea as the pod-network add-on here:

```
 kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/v0.20.0/Documentation/kube-flannel.yml
```

You can execute the below commands to ensure that all pods are up and running:

```
 kubectl get pods --all-namespaces
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

The get nodes command shows that the control-plane node is up and ready:

```
 kubectl get nodes
```

Output:

```
NAME             STATUS   ROLES                  AGE   VERSION
#yourhost        Ready    control-plane          10m   v1.27.0
```

Since we are using a single-node Kubernetes cluster, the cluster will not schedule pods on the control plane node by default. To schedule pods on the control plane node, we have to remove the taint by executing the following command:

```
 kubectl taint nodes --all node-role.kubernetes.io/master-
```

Refer to [Installing Kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/)
for more information.

### Installing Helm 

Execute the following command to download and install Helm 3.11.2: 

```
 wget https://get.helm.sh/helm-v3.11.2-linux-arm64.tar.gz
 tar -zxvf helm-v3.11.2-linux-arm64.tar.gz
 sudo mv linux-arm64/helm /usr/local/bin/helm
 rm -rf helm-v3.11.2-linux-arm64.tar.gz linux-arm64/
```

Refer to the Helm 3.11.2 [release notes](https://github.com/helm/helm/releases) and the [Installing Helm guide](https://helm.sh/docs/using_helm/#installing-helm) for more information.


### Adding an Additional Node to NVIDIA Cloud Native Stack


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
#yourhost        Ready    control-plane,master   10m   v1.27.0
#yourhost-worker Ready                           10m   v1.27.0
```

### Validating the Installation


Create a pod YAML file, add the following contents to it, and save it as samples.yaml:

```
cat <<EOF | sudo tee cuda-samples.yaml
apiVersion: v1
kind: Pod
metadata:
  name: nvidia-l4t-base
spec:
  restartPolicy: OnFailure
  containers:
  - name: nvidia-l4t-base
    image: "nvcr.io/nvidia/l4t-base:r32.6.1"
    args:
       - /usr/local/cuda/samples/1_Utilities/deviceQuery/deviceQuery
EOF
```
Now compile the CUDA examples to validate from the pod: 

```
cd /usr/local/cuda/samples/1_Utilities/deviceQuery
sudo make
cd ~
```
Execute the below command to create a sample GPU pod:
```
sudo kubectl apply -f cuda-samples.yaml
```
Execute the below command to confirm the cuda-samples pod was created:
```
kubectl get pods
```
Output:
```
nvidia-l4t-base  0/1 Completed 2m
```

Validate the sample pod logs to support CUDA libraries:

```
kubectl logs nvidia-l4t-base
```
NVIDIA Cloud Native Stack works as expected if the get pods command shows the pod status as completed. You can also verify the successful run of the cuda-samples.yaml by confirming that the output shows Result=PASS

Output:

```
/usr/local/cuda/samples/1_Utilities/deviceQuery/deviceQuery Starting...
CUDA Device Query (Runtime API) version (CUDART static linking)
Detected 1 CUDA Capable device(s)
Device 0: "Xavier"
 CUDA Driver Version / Runtime Version        10.2 / 10.2
  CUDA Capability Major/Minor version number: 7.2
  Total amount of global memory:              15815 MBytes (16583041024 bytes)
  ( 8) Multiprocessors, ( 64) CUDA Cores/MP:  512 CUDA Cores
  GPU Max Clock rate:                         1377 MHz (1.38 GHz)
  Memory Clock rate:                          1377 Mhz
  Memory Bus Width:                           256-bit
  L2 Cache Size:                              524288 bytes
  Maximum Texture Dimension Size (x,y,z)      1D=(131072), 2D=(131072, 65536), 3D=(16384, 16384, 16384)
  Maximum Layered 1D Texture Size, (num) layers  1D=(32768), 2048 layers
  Maximum Layered 2D Texture Size, (num) layers  2D=(32768, 32768), 2048 layers
  Total amount of constant memory:            65536 bytes
  Total amount of shared memory per block:    49152 bytes
  Total number of registers available per block: 65536
  Warp size:                                   32
  Maximum number of threads per multiprocessor:  2048
  Maximum number of threads per block:        1024
  Max dimension size of a thread block (x,y,z): (1024, 1024, 64)
  Max dimension size of a grid size (x,y,z): (2147483647, 65535, 65535)
  Maximum memory pitch:                       2147483647 bytes
  Texture alignment:                          512 bytes
  Concurrent copy and kernel execution:       Yes with 1 copy engine(s)
  Run time limit on kernels:                   No
  Integrated GPU sharing Host Memory:         Yes
  Support host page-locked memory mapping:    Yes
  Alignment requirement for Surfaces:         Yes
  Device has ECC support:                     Disabled
  Device supports Unified Addressing (UVA):   Yes
  Device supports Compute Preemption:         Yes
  Supports Cooperative Kernel Launch:         Yes
  Supports MultiDevice Co-op Kernel Launch:   Yes
  Device PCI Domain ID / Bus ID / location ID:   0 / 0 / 0
  Compute Mode:
     < Default (multiple host threads can use ::cudaSetDevice() with device simultaneously) >
deviceQuery, CUDA Driver = CUDART, CUDA Driver Version = 10.2, CUDA Runtime Version = 10.2, NumDevs = 1
Result = PASS
```
NVIDIA Cloud Native Stack works as expected if the get pods command shows the pod status as completed.

### Validate NVIDIA Cloud Native Stack with an Application from NGC
Another option to validate NVIDIA Cloud Native Stack is by running a demo application hosted on NGC.

NGC is NVIDIA's GPU-optimized software hub. NGC provides a curated set of GPU-optimized software for AI, HPC, and visualization. The content provided by NVIDIA and third-party ISVs simplify building, customizing, and integrating GPU-optimized software into workflows, accelerating the time to solutions for users.

Containers, pre-trained models, Helm charts for Kubernetes deployments, and industry-specific AI toolkits with software development kits (SDKs) are hosted on NGC. For more information about how to deploy an application that is hosted on NGC or the NGC Private Registry, please refer to this [NGC Registry Guide](https://github.com/NVIDIA/cloud-native-stack/blob/master/install-guides/NGC_Registry_Guide_v1.0.md). Visit the [public NGC documentation](https://docs.nvidia.com/ngc) for more information.

The steps in this section use the publicly available DeepStream - Intelligent Video Analytics (IVA) demo application Helm Chart. The application can validate the full NVIDIA Cloud Native Stack and test the connectivity of NVIDIA Cloud Native Stack to remote sensors. DeepStream delivers real-time AI-based video and image understanding and multi-sensor processing on GPUs. For more information, please refer to the [Helm Chart](https://ngc.nvidia.com/catalog/helm-charts/nvidia:video-analytics-demo-l4t).

There are two ways to configure the DeepStream - Intelligent Video Analytics Demo Application on your NVIDIA Cloud Native Stack

- Using a camera
- Using the integrated video file (no camera required)

#### Using a camera

##### Prerequisites: 
- RTSP Camera stream

Go through the below steps to install the demo application:
```
1. helm fetch https://helm.ngc.nvidia.com/nvidia/charts/video-analytics-demo-l4t-0.1.3.tgz --untar

2. cd into the folder video-analytics-demo-l4t and update the file values.yaml

3. Go to the section Cameras in the values.yaml file and add the address of your IP camera. Read the comments section on how it can be added. Single or multiple cameras can be added as shown below

cameras:
 camera1: rtsp://XXXX
```

Execute the following command to deploy the demo application:
```
helm install video-analytics-demo-l4t --name-template iva
```

Once the Helm chart is deployed, access the application with the VLC player. See the instructions below. 

#### Using the integrated video file (no camera)

If you dont have a camera input, please execute the below commands to use the default video already integrated into the application:

```
helm fetch https://helm.ngc.nvidia.com/nvidia/charts/video-analytics-demo-l4t-0.1.3.tgz

helm install video-analytics-demo-l4t-0.1.3.tgz --name-template iva
```

Once the helm chart is deployed, access the application with the VLC player as per the below instructions. 
For more information about the demo application, please refer to the [application NGC page](https://ngc.nvidia.com/catalog/helm-charts/nvidia:video-analytics-demo-l4t)

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

