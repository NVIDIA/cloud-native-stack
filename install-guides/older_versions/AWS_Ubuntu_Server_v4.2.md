<h1>NVIDIA Cloud Native Core v4.2(formely EGX Stack 4.2) for AWS - Install Guide for Ubuntu Server x86-64</h1>
<h2>Introduction</h2>
This document describes setting up NVIDIA NVIDIA Cloud Native Core v4.12 on one or multiple GPU accelerated AWS instances to deploy AI applications via Helm charts from NVIDIA NGC. NVIDIA Cloud Native Core v4.2 will include:

- Ubuntu 20.04.2 LTS
- Containerd 1.5.8
- Kubernetes version 1.21.7
- Helm 3.7.0
- NVIDIA GPU Operator 1.9.0
  - NV containerized driver: 470.82.01
  - NV container toolkit: 1.7.2
  - NV K8S device plug-in: 0.10.0
  - Data Center GPU Manager (DCGM): 2.3.1-2.6.0
  - Node Feature Discovery: 0.8.2
  - GPU Feature Discovery: 0.4.1
  - K8s MIG Manager: 0.2.0
  - NVIDIA DGCM: 2.3.1
  - NVIDIA Driver Manager: 0.2.0

<h2>Table of Contents</h2>

- [Release Notes](#Release-Notes)
- [Prerequisites](#Prerequisites)
- [AWS G4 Instance Setup](#AWS-G4-Instance-SetUp)
- [Installing Containerd](#Installing-Containerd)
- [Installing Kubernetes](#Installing-Kubernetes)
- [Installing Helm](#Installing-Helm)
- [Adding an additional node to the NVIDIA Cloud Native Core](#Adding-additional-node-to-the-NVIDIA-Cloud-Native-Core)
- [Installing GPU Operator](#Installing-the-GPU-Operator)
- [Installing NVIDIA Network Operator](#Installing-NVIDIA-Network-Operator)
- [Validating the Installation](#Validating-the-Installation)
- [Saving your instance](#Saving-your-instance)

### Release Notes

- Upgraded to Containerd 1.5.8
- Upgraded to Helm 3.7.0
- Upgraded to GPU Operator 1.9.0

## Prerequisites
 
The following instructions assume that you have an AWS account. If you do not have an AWS account, please refer to the [Setup AWS account](https://aws.amazon.com/premiumsupport/knowledge-center/create-and-activate-aws-account/) webpage.  

Please note that NVIDIA Cloud Native Core is validated only on AWS G4 systems with the default kernel (not HWE).

## AWS G4 Instance Setup
AWS G4 EC2 instances provide the latest generation NVIDIA T4 GPUs. Please follow the below steps to set up an NVIDIA Cloud Native Core G4 instance via the AWS console web UI. 
First, log in to the AWS console, go to the EC2 management page, and launch a new instance by clicking the launch instance button.

![AWS_Launch_Instance](screenshots/AWS_Launch_instance.png)

Step 1: Select the Ubuntu Server 20.04 LTS image with 64-bit (x86), available in the QuickStart area.

![AWS_Choose_AMI](screenshots/AWS_Choose_AMI.png)

Step 2: Choose a G4 instance and select any G4 instance type. (e.g., g4dn.xlarge, g4dn.2xlarge etc.). For additional information, please refer to [AWS G4 Instances](https://aws.amazon.com/blogs/aws/now-available-ec2-instances-g4-with-nvidia-t4-tensor-core-gpus/)

![AWS_Choose_Instance_Type](screenshots/AWS_Choose_Instance_type1.png)

Step 3: In this step, you will provide additional instance configuration details, as shown below.

![AWS_Configure_Instance_details](screenshots/AWS_Configure_Instance_details.png)

`NOTE:` This guide uses a default network configuration to showcase a working setup. Your setup may require a different configuration. Ensure that you configure the network to align with your requirements so that NVIDIA Cloud Native Core can connect to your sensor (RTSP camera). 
- Network: Use your default network or custom network configuration.
- Subnet: Use the default subnet or custom subnet.

Step 4: Modify the storage to at least 25GB for NVIDIA Cloud Native Core to work with the sample Intelligent Video Analytics Demo application. Increase the storage to accommodate your requirements if you are using a different application.

![AWS_Add_Storage](screenshots/AWS_Add_Storage.png)

Step 5: A good practice is to add tags to your instance so that you can quickly identify the purpose and details of each instance.

- For example, key as Name and its value as NVIDIA Cloud Native Core_Location_N.

![AWS_Add_Tags](screenshots/AWS_Add_Tags.png)

Step 6: For the security group settings, it is recommended that you create a security group with the rules below.

- Type: SSH
- For testing with the DeepStream - Intelligent Video Analytics Demo application, create a custom TCP rule that opens ports 30000-32767.

`NOTE:` Make sure to add all the ports that your custom application uses.

![AWS_Configure_Security_Group](screenshots/AWS_Configure_Security_Group.png)

Step 7: Review the instance configuration and click "Launch Instances," the key pair will pop up. Select the option “Choose an Existing Key Pair” if you already have a key pair. If not, select the option “Create a New Key Pair.”

![AWS_Review_Instance_Config](screenshots/AWS_Review_Instance_Config.png)

Please wait at least 5 minutes to see the G4 node status checks pass. 

### AWS G4 Instance Access

Execute the below command to SSH into your AWS Instance. Replace `yourkeypair.pem` and `<public-ip>` with your AWS Key Pair and your EC2 Public IP.

```
ssh -i yourkeypair.pem ubuntu@ec2-<public-ip>.us-west-1.compute.amazonaws.com
```

`NOTE:` You can get the EC2 Public IP from your AWS EC2 Management Console. 

## Installing Containerd

Set up the repository and update the apt package index:

```
$ sudo apt-get update
```

Install packages to allow apt to use a repository over HTTPS:

```
$ sudo apt-get install -y apt-transport-https ca-certificates gnupg-agent libseccomp2 autotools-dev debhelper software-properties-common
```

Configure the Prerequisites for Containerd

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
Download the Containerd tarball

```
$ wget https://github.com/containerd/containerd/releases/download/v1.5.8/cri-containerd-cni-1.5.8-linux-amd64.tar.gz
$ sudo tar --no-overwrite-dir -C / -xzf cri-containerd-cni-1.5.8-linux-amd64.tar.gz
$ rm -rf cri-containerd-cni-1.5.8-linux-amd64.tar.gz
```

Install the Containerd
```
$ sudo mkdir -p /etc/containerd

$ containerd config default | sudo tee /etc/containerd/config.toml

$ sudo systemctl restart containerd
```

For additional information on installing Containerd, please reference [Install Containerd with Release Tarball](https://github.com/containerd/containerd/blob/master/docs/cri/installation.md).

## Installing Kubernetes 

Make sure Containerd has been started and enabled before beginning installation:

```
$ sudo systemctl start containerd && sudo systemctl enable containerd
```

Execute the following to install kubelet kubeadm and kubectl:

```
$ curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
$ sudo mkdir -p  /etc/apt/sources.list.d/
```

Create Kubernetes.list:

```
$ cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
```

Now execute the commands below:

```
$ sudo apt-get update
$ sudo apt-get install -y -q kubelet=1.21.7-00 kubectl=1.21.7-00 kubeadm=1.21.7-00
$ sudo apt-mark hold kubelet kubeadm kubectl
```

### Initializing the Kubernetes cluster to run as master

#### Disable swap
```
$ sudo swapoff -a
$ sudo nano /etc/fstab
```

Add a # before all the lines that start with /swap. # is a comment, and the result should look similar to this:

```
UUID=e879fda9-4306-4b5b-8512-bba726093f1d / ext4 defaults 0 0
UUID=DCD4-535C /boot/efi vfat defaults 0 0
#/swap.img       none    swap    sw      0       0
```

Execute the following command:

```
$ sudo kubeadm init --pod-network-cidr=192.168.0.0/16 --cri-socket=/run/containerd/containerd.sock
```

The output will show you the commands that, when executed, deploy a pod network to the cluster and commands to join the cluster.

Following the instructions in the output, execute the commands as shown below:

```
$ mkdir -p $HOME/.kube
$ sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
$ sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

With the following command, you install a pod-network add-on to the control plane node. Calico is used as the pod-network add-on here:

```
$ kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
```

You can execute the below commands to ensure that all pods are up and running:

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
kube-system   etcd-#hostname                             1/1     Running   0          8m25s
kube-system   kube-apiserver-#hostname                   1/1     Running   0          8m7s
kube-system   kube-controller-manager-#hostname          1/1     Running   0          8m3s
kube-system   kube-proxy-6sh42                           1/1     Running   0          9m7s
kube-system   kube-scheduler-#hostname                   1/1     Running   0          8m26s
```

The get nodes command shows that the control-plane node is up and ready:

```
$ kubectl get nodes
```

Output:

```
NAME             STATUS   ROLES                  AGE   VERSION
#yourhost        Ready    control-plane,master   10m   v1.21.7
```

Since we are using a single-node Kubernetes cluster, the cluster will not schedule pods on the control plane node by default. To schedule pods on the control plane node, we have to remove the taint by executing the following command:

```
$ kubectl taint nodes --all node-role.kubernetes.io/master-
```

For additional information, refer to [kubeadm installation guide](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/)

## Installing Helm 

Execute the following command to download Helm 3.7.0: 

```
$ sudo wget https://get.helm.sh/helm-v3.7.0-linux-amd64.tar.gz
$ sudo tar -zxvf helm-v3.7.0-linux-amd64.tar.gz
$ sudo mv linux-amd64/helm /usr/local/bin/helm
```

For additional information about Helm, refer to the Helm 3.7.0 [release notes](https://github.com/helm/helm/releases) and the [Installing Helm guide](https://helm.sh/docs/using_helm/#installing-helm) for more information. 

### Adding additional node to NVIDIA Cloud Native Core

Please Launch the new AWS G4 instance and install the Containerd and Kubernetes packages on an additional node.

Prerequisites: 
- [AWS G4 Instance Setup](#AWS-G4-Instance-Setup)
- [Installing Containerd](#Installing-Containerd)
- [Installing Kubernetes](#Installing-Kubernetes)
- [Disable Swap](#Disable-swap)

Once the prerequisites are completed on the additional nodes, execute the below command on the control-plane node and then execute the join command output on an additional node to add the additional node to NVIDIA Cloud Native Core 

```
$ kubeadm token create --print-join-command
```

Output:
```
example: 
sudo kubeadm join 10.110.0.34:6443 --token kg2h7r.e45g9uyrbm1c0w3k     --discovery-token-ca-cert-hash sha256:77fd6571644373ea69074dd4af7b077bbf5bd15a3ed720daee98f4b04a8f524e
```
`NOTE`: control-plane node and worker node should not have the same node name. 

The get nodes command shows that the master and worker nodes are up and ready:

```
$ kubectl get nodes
```

Output:

```
NAME             STATUS   ROLES                  AGE   VERSION
#yourhost        Ready    control-plane,master   10m   v1.21.7
#yourhost-worker Ready                           10m   v1.21.7
```

## Installing GPU Operator
Add the NVIDIA helm repo 

```
$ helm repo add nvidia https://helm.ngc.nvidia.com/nvidia
```

Update the helm repo:

```
$ helm repo update
```

To install GPU Operator for AWS G4 instance with Tesla T4:

```
$ helm install --version 1.9.0 --create-namespace --namespace gpu-operator-resources --devel nvidia/gpu-operator  --set operator.defaultRuntime=containerd --wait --generate-name
```

### Validate the state of GPU Operator:

Please note that the installation of GPU Operator can take a couple of minutes. How long the installation will take depends on your internet speed.

```
kubectl get pods --all-namespaces | grep -v kube-system
```

```
NAMESPACE                NAME                                                             READY   STATUS      RESTARTS   AGE

gpu-operator-resources   gpu-operator-1590097431-node-feature-discovery-master-76578jwwt   1/1     Running     0          5m2s
gpu-operator-resources   gpu-operator-1590097431-node-feature-discovery-worker-pv5nf       1/1     Running     0          5m2s
gpu-operator-resources   gpu-operator-74c97448d9-n75g8                                     1/1     Running     1          5m2s
gpu-operator-resources   gpu-feature-discovery-6986n                                       1/1     Running     0          5m2s
gpu-operator-resources   nvidia-container-toolkit-daemonset-pwhfr                          1/1     Running     0          4m58s
gpu-operator-resources   nvidia-cuda-validator-8mgr2                                       0/1     Completed   0          5m3s
gpu-operator-resources   nvidia-dcgm-exporter-bdzrz                                        1/1     Running     0          4m57s
gpu-operator-resources   nvidia-device-plugin-daemonset-zmjhn                              1/1     Running     0          4m57s
gpu-operator-resources   nvidia-device-plugin-validator-spjv7                              0/1     Completed   0          4m57s
gpu-operator-resources   nvidia-driver-daemonset-7b66v                                     1/1     Running     0          4m57s
gpu-operator-resources   nvidia-operator-validator-phndq                                   1/1     Running     0          4m57s

```

Please refer to [GPU Operator page](https://ngc.nvidia.com/catalog/helm-charts/nvidia:gpu-operator) on NGC for more information.



## Validating the Installation

GPU Operator validates the stack through the nvidia-device-plugin-validation pod and the nvidia-driver-validation pod. If both complete successfully (see output from kubectl get pods --all-namespaces | grep -v kube-system), the NVIDIA Cloud Native Core is working as expected. 
There are two ways to validate NVIDIA Cloud Native Core manually: 
1. Validate NVIDIA Cloud Native Core with nvidia-smi and cuda sample
2. Validate NVIDIA Cloud Native Core with an Application

### Validate NVIDIA Cloud Native Core with nvidia-smi and cuda sample
This section provides two examples of how to validate that the GPU is usable from within a pod.

#### Example 1: nvidia-smi

Execute the following:

```
$ kubectl run nvidia-smi --rm -t -i --restart=Never --image=nvidia/cuda:11.4.0-base --limits=nvidia.com/gpu=1 -- nvidia-smi
```

Output:

``` 
Fri Dec  3 17:17:10 2021
+-----------------------------------------------------------------------------+
| NVIDIA-SMI 470.82.01    Driver Version: 470.82.01    CUDA Version: 11.4     |
|-------------------------------+----------------------+----------------------+
| GPU  Name        Persistence-M| Bus-Id        Disp.A | Volatile Uncorr. ECC |
| Fan  Temp  Perf  Pwr:Usage/Cap|         Memory-Usage | GPU-Util  Compute M. |
|                               |                      |               MIG M. |
|===============================+======================+======================|
|   0  Tesla T4            On   | 00000000:14:00.0 Off |                  Off |
| N/A   47C    P8    16W /  70W |      0MiB / 16127MiB |      0%      Default |
|                               |                      |                  N/A |
+-------------------------------+----------------------+----------------------+

+-----------------------------------------------------------------------------+
| Processes:                                                                  |
|  GPU   GI   CI        PID   Type   Process name                  GPU Memory |
|        ID   ID                                                   Usage      |
|=============================================================================|
|  No running processes found                                                 |
+-----------------------------------------------------------------------------+
pod "nvidia-smi" deleted
```

#### Example 2: CUDA-Vector-Add

Create a pod YAML file:

```
$ cat <<EOF | tee cuda-samples.yaml
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
$ sudo kubectl apply -f cuda-samples.yaml
```

Execute the below command to confirm the cuda-samples pod was created:

```
$ kubectl get pods
``` 

NVIDIA Cloud Native Core stack works as expected if the get pods command shows the pod status as completed.

### Validate NVIDIA Cloud Native Core with an application from NGC
Another option to validate NVIDIA Cloud Native Core is by running a demo application hosted on NGC.

NGC is NVIDIA's GPU Optimized Software Hub. NGC provides a curated set of GPU-optimized software for AI, HPC, and Visualization. The content provided by NVIDIA and third-party ISVs simplify building, customizing, and integrating GPU-optimized software into workflows, accelerating the time to solutions for users.

Containers, pre-trained models, Helm charts for Kubernetes deployments, and industry-specific AI toolkit with software development kits (SDKs) hosted on NGC. For more information about how to deploy an application that hosted on NGC, the NGC Private Registry, please refer to this [NGC Registry Guide](https://github.com/erikbohnhorst/NVIDIA Cloud Native Core-DIY-Node-Stack/blob/master/install-guides/NGC_Registry_Guide_v1.0.md). Visit the [public NGC documentation](https://docs.nvidia.com/ngc) for more information

The steps in this section use the publicly available DeepStream - Intelligent Video Analytics (IVA) demo application Helm chart. The application can validate the full NVIDIA Cloud Native Core and test the connectivity of NVIDIA Cloud Native Core to remote sensors. DeepStream delivers real-time AI-based video and image understanding, as well as multi-sensor processing on GPUs. For additional information, please refer to the [Helm Chart](https://ngc.nvidia.com/catalog/helm-charts/nvidia:video-analytics-demo)

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

3. Go to the section Cameras in the values.yaml file and add the address of your IP camera. Please read the comments section on how it is added. Single or multiple cameras can be added, as shown below.

cameras:
 camera1: rtsp://XXXX
```

Execute the following command to deploy the demo application:
```
helm install video-analytics-demo --name-template iva
```

Once the helm chart is deployed, access the application with the VLC player. See the instructions below. 

#### Using the integrated video file (no camera)

If you do not have a camera input, please execute the below commands to use the default video integrated with the application. 

```
$ helm fetch https://helm.ngc.nvidia.com/nvidia/charts/video-analytics-demo-0.1.6.tgz

$ helm install video-analytics-demo-0.1.6,tgz --name-template iva
```

Once the helm chart is deployed, access the Application with VLC player with the instructions below. 
For additional information about the Demo application, please refer to https://ngc.nvidia.com/catalog/helm-charts/nvidia:video-analytics-demo

#### Access from WebUI

Use the below WebUI URL to access the video analytics demo application from the browser.
```
http://IPAddress of Node:31115/WebRTCApp/play.html?name=videoanalytics
```

#### Access from VLC

Download VLC Player from https://www.videolan.org/vlc/ on the machine where you intend to view the video stream.

View the video stream in VLC by navigating to Media > Open Network Stream > Entering the following URL.

```
rtsp://IPAddress of Node:31113/ds-test
```

You will now see the video output like below with the AI model detecting objects.

![Deepstream_Video](screenshots/Deepstream.png)

`NOTE:` Video stream in VLC will change if you provide an input RTSP camera.

## Saving your instance

You can save the current state of your EC2 instance as an Amazon AMI. Follow the steps to [Create an AMI](https://docs.aws.amazon.com/toolkit-for-visual-studio/latest/user-guide/tkv-create-ami-from-instance.html) 

## Cleanup

To remove your AWS instance, log in to the AWS console, go to the EC2 management page, select your EC2 instance, and select Instance State >> then click  Terminate.
