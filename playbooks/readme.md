# Ansible Playbooks for NVIDIA Cloud Native Stack

This page describes the steps required to use Ansible to install the NVIDIA Cloud Native Stack.

### The following Ansible Playbooks are available

- [Install NVIDIA Cloud Native Stack](https://github.com/NVIDIA/cloud-native-stack/blob/master/playbooks/cnc-installation.yaml)

- [Upgrade NVIDIA Cloud Native Stack ](https://github.com/NVIDIA/cloud-native-stack/blob/master/playbooks/cnc-upgrade.yaml)

- [Validate NVIDIA Cloud Native Stack ](https://github.com/NVIDIA/cloud-native-stack/blob/master/playbooks/cnc-validation.yaml)

- [Uninstall NVIDIA Cloud Native Stack](https://github.com/NVIDIA/cloud-native-stack/blob/master/playbooks/cnc-uninstall.yaml)

## Prerequisites

- system has direct internet access
- system should have an Operating system either Ubuntu 20.04 and above or RHEL 8.7
- system has adequate internet bandWidth
- DNS server is working fine on the System
- system can access Google repo(for k8s installation)
- system has only 1 network interface configured with internet access. The IP is static and doesn't change
- UEFI secure boot is disabled
- Root file system should has at least 40GB capacity
- system has 4CPU and 8GB Memory
- At least one NVIDIA GPU attached to the system

## Systems support 
The following systems are support for Cloud Native Stack:

- You have [NVIDIA-Certified Systems](https://docs.nvidia.com/ngc/ngc-deploy-on-premises/nvidia-certified-systems/index.html) with Mellanox CX NICs for x86-64 servers 
- You have [NVIDIA Qualified Systems](https://www.nvidia.com/en-us/data-center/data-center-gpus/qualified-system-catalog/?start=0&count=50&pageNumber=1&filters=eyJmaWx0ZXJzIjpbXSwic3ViRmlsdGVycyI6eyJwcm9jZXNzb3JUeXBlIjpbIkFSTS1UaHVuZGVyWDIiLCJBUk0tQWx0cmEiXX0sImNlcnRpZmllZEZpbHRlcnMiOnt9LCJwYXlsb2FkIjpbXX0=) for arm64 servers 
  `NOTE:` For ARM systems, NVIDIA Network Operator is not supported yet. 
- You have [NVIDIA Jetson Systems](https://www.nvidia.com/en-us/autonomous-machines/embedded-systems/)

To determine if your system qualifies as an NVIDIA Certified System, review the list of NVIDIA Certified Systems [here](https://docs.nvidia.com/ngc/ngc-deploy-on-premises/nvidia-certified-systems/index.html). 

Please note that NVIDIA Cloud Native Stack is validated only on systems with the default kernel (not HWE).

### Installing the Ubuntu Operating System
These instructions require Ubuntu server please reference the [Ubuntu Server Installation Guide](https://ubuntu.com/tutorials/tutorial-install-ubuntu-server#1-overview).

### Installing JetPack for Jetson 

JetPack (the Jetson SDK) is an on-demand all-in-one package that bundles developer software for the NVIDIA® Jetson platform. There are two ways to install the JetPack 

1. Use the SDK Manager installer to flash your Jetson Developer Kit with the latest OS image, install developer tools for both host PC and Developer Kit, and install the libraries and APIs, samples, and documentation needed to jump-start your development environment.

Follow the [instructions](https://docs.nvidia.com/sdk-manager/install-with-sdkm-jetson/index.html) on how to install JetPack 5.0There are two ways to install the JetPack 

Download the SDK Manager from [here](https://developer.nvidia.com/nvidia-sdk-manager)

2. Use the SD Card Image method to download the JetPack and load the OS image to external drive. For more information, please refer [flash using SD Card method](https://developer.nvidia.com/embedded/learn/get-started-jetson-xavier-nx-devkit#prepare)

## Using the Ansible playbooks 
This section describes how to use the ansible playbooks.

### Clone the git repository

Run the below commands to clone the NVIDIA Cloud Native Stack ansible playbooks.

```
git clone https://github.com/NVIDIA/cloud-native-stack.git
cd cloud-native-stack/playbooks
```

Update the hosts file in playbooks directory with master and worker nodes(if you have) IP's with username and password like below

```
nano hosts

[master]
10.110.16.178 ansible_ssh_user=nvidia ansible_ssh_pass=nvidipass ansible_sudo_pass=nvidiapass ansible_ssh_common_args='-o StrictHostKeyChecking=no'
[node]
10.110.16.179 ansible_ssh_user=nvidia ansible_ssh_pass=nvidiapass ansible_sudo_pass=nvidiapass ansible_ssh_common_args='-o StrictHostKeyChecking=no'
```

### Installation
Cloud Native Stack Supports below versions.

Available versions are:

- 10.0
- 9.0
- 9.1
- 8.3
- 8.2
- 8.1
- 7.4
- 7.3
- 7.2
- 7.1
- 7.0
- 6.4

Edit the `cnc_version.yaml` and update the version you want to install

```
nano cnc_version.yaml
```

If you want to cusomize any predefined components versions or any other custom paramenters, modify the respective CNS version values file like below and trigger the installation. 

Example:
```
$ nano cnc_values_8.0.yaml

cnc_version: 8.0

## Components Versions
# Container Runtime options are containerd, cri-o
container_runtime: "containerd"
containerd_version: "1.6.8"
crio_version: "1.25.3"
k8s_version: "1.25.2"
calico_version: "3.24.1"
flannel_version: "0.19.2"
helm_version: "3.10.0"
gpu_operator_version: "22.9.0"
network_operator_version: "1.3.0"

# GPU Operator Values
enable_gpu_operator: yes
gpu_driver_version: "520.61.07"
enable_mig: no
mig_profile: all-disabled
mig_strategy: single
enable_gds: no
enable_secure_boot: no
enable_vgpu: no
vgpu_license_server: ""
# URL of Helm repo to be added. If using NGC get this from the fetch command in the console
helm_repository: https://helm.ngc.nvidia.com/nvidia
# Name of the helm chart to be deployed
gpu_operator_helm_chart: nvidia/gpu-operator
## If using a private/protected registry. NGC API Key. Leave blank for public registries
gpu_operator_registry_password: ""
## This is most likely an NGC email
gpu_operator_registry_email: ""
## This is most likely GPU Operator Driver Registry
gpu_operator_driver_registry: "nvcr.io/nvidia"
gpu_operator_registry_username: "$oauthtoken"

# Network Operator Values
## If the Network Operator is yes then make sure enable_rdma as well yes
enable_network_operator: no
## Enable RDMA yes for NVIDIA Certification
enable_rdma: no

# Prxoy Configuration
proxy: no
http_proxy: ""
https_proxy: ""

# Cloud Native Stack for Developers Values
## Enable for Cloud Native Stack Developers
cnc_docker: no
## Enable For Cloud Native Stack Developers with TRD Driver
cnc_nvidia_driver: no

## Kubernetes resources
k8s_apt_key: "https://packages.cloud.google.com/apt/doc/apt-key.gpg"
k8s_apt_repository: " https://apt.kubernetes.io/ kubernetes-xenial main"
k8s_apt_ring: "/etc/apt/keyrings/kubernetes-archive-keyring.gpg"
k8s_registry: "registry.k8s.io"

## Cloud Native Stack Validation
cnc_validation: no

```

Install the NVIDIA Cloud Native Stack stack by running the below command. "Skipping" in the ansible output refers to the Kubernetes cluster is up and running.
```
bash setup.sh install
```
#### Custom Configuration
By default Cloud Native Stack uses Google kubernetes apt repository, if you want to use any other kubernetes apt repository, please adjust the `k8s_apt_key` and `k8s_apt_repository` in `cnc_values_<version>.yaml`.

Example:
```

## Kubernetes apt resources
k8s_apt_key: "https://mirrors.aliyun.com/kubernetes/apt/doc/apt-key.gpg"
k8s_apt_repository: "deb https://mirrors.aliyun.com/kubernetes/apt/ kubernetes-xenial main"
k8s_registry: "registry.aliyuncs.com/google_containers"
```

### Validation

Run the below command to check if the installed versions are match with predefined versions of the NVIDIA Cloud Native Stack. Here' "Ignored" tasks refer to failed and "Changed/Ok" tasks refer to success.

Run the validation playbook after 5 minutes once completing the NVIDIA Cloud Native Stack Installation. Depends on your internet speed, you need to wait more time.

```
bash setup.sh validate
```
### Upgrade 

Cloud Native Stack can be support life cycle management with upgrade option. you can upgrade the current running stack version to next available version. 

Upgrade option is available from one minor version to next minor version of CNS.

Example: Cloud Native Stack 8.0 can upgrade to 8.1 but 8.x can not upgrade to 9.x

### Uninstall

Run the below command to uninstall the NVIDIA Cloud Native Stack. Tasks being "ignored" refers to no kubernetes cluster being available.

```
bash setup.sh uninstall
```

`NOTE`
A list of older NVIDIA Cloud Native Stack versions (formerly known as Cloud Native Core) can be found [here](https://github.com/NVIDIA/cloud-native-stack/blob/master/playbooks/older_versions/readme.md)

<h2> Ansible Playbook Descriptions </h2>

- [Install NVIDIA Cloud Native Stack](#Install-NVIDIA-Cloud-Native-Stack)
- [Validate NVIDIA Cloud Native Stack](#Validate-NVIDIA-Cloud-Native-Stack)
- [Upgrade NVIDIA Cloud Native Stack](#Upgrade-NVIDIA-Cloud-Native-Stack)
- [Uninstall NVIDIA Cloud Native Stack](#Uninstall-NVIDIA-Cloud-Native-Stack)

### Install NVIDIA Cloud Native Stack 

The Ansible NVIDIA Cloud Native Stack installation playbook will do the following:

- Validate if Kubernetes is already installed
- Setup the Kubernetes repository
- Install Kubernetes components 
  - Option to provide the specific kubernetes version
- Install required packages for Docker and Kubernetes
- Setup the Docker Repository
- Install the Docker engine 
  - Option to provide the specific docker version
- Enable and restart Docker and Kubelet
- Disable the Swap for Kubernetes installation
- Initialize the Kubernetes cluster 
  - Option to provide pod network CIDR range
- Copy kubeconfig to home to run kubectl commands
- Install the required networking plugin based on CIDR range
- Taint the control plane node to run all pods on single node
- Check if Helm installed
- Install Helm, if not already installed
- Install the NVIDIA GPU Operator
- Install the NVIDIA Network Operator 

### Validate NVIDIA Cloud Native Stack 

The Ansible NVIDIA Cloud Native Stack validation playbook will do the following:

- Validate if Kubernetes cluster is up
- Check if node is up and running
- Check if all pods are in running state
- Validate that Helm installed
- Validate the GPU Operator pods state
- Report Operating System, Docker, Kubernetes, Helm, GPU Operator versions
- Validate nvidia-smi and cuda liberaries on kubernetes

### Upgrade NVIDIA Cloud Native Stack

The Ansible NVIDIA Cloud Native Stack upgrade playbook will do the following:

- Validate the Cloud Native stack is running
- Update the Cloud Native Stack Version 
- Upgrade the Container runtime and kubernetes components
- Upgrade the Kubernetes cluster to new version
- Upgrade the networking plugin to new version
- Upgrade the GPU Operator to next available version

### Uninstall NVIDIA Cloud Native Stack 

The Ansible NVIDIA Cloud Native Stack uninstall playbook will do the following:

- Reset the Kubernetes cluster
- Remove the Helm package
- Uninstall the Docker and Kubernetes Packages

### Getting Help

Please [open an issue on the GitHub project](https://github.com/NVIDIA/cloud-native-stack/issues) for any questions. Your feedback is appreciated.


