<h1> NVIDIA Cloud Native Stack Ubuntu Server (x86-64) v6.2 </h1>

This page describes the steps required to use Ansible to install the NVIDIA Cloud Native Stack.

NVIDIA Cloud Native Stack v6.2 includes:
- Ubuntu 20.04.4 LTS
- Containerd 1.6.5
- Kubernetes version 1.23.8
- Helm 3.8.2
- NVIDIA GPU Operator 1.11.0
  - NVIDIA GPU Driver: 515.48.07
  - NVIDIA Container Toolkit: 1.10.0
  - NVIDIA K8S Device Plugin: 0.12.2
  - NVIDIA DCGM-Exporter: 2.4.5-2.6.7
  - NVIDIA DCGM: 2.4.5-1
  - NVIDIA GPU Feature Discovery: 0.6.1
  - NVIDIA K8s MIG Manager: 0.4.1
  - NVIDIA Driver Manager: 0.4.0
  - Node Feature Discovery: 0.10.1
- NVIDIA Network Operator 1.2.0
  - Mellanox MOFED Driver 5.5-1.0.3.2
  - Mellanox NV Peer Memory Driver 1.1-0
  - RDMA Shared Device Plugin 1.2.1
  - SRIOV Device Plugin 3.3
  - Container Networking Plugins 0.8.7
  - Multus 3.8
  - Whereabouts 0.4.2


### The following Ansible Playbooks are available

- [Install NVIDIA Cloud Native Stack](https://github.com/NVIDIA/cloud-native-stack/blob/master/playbooks/cnc-installation.yaml)

- [Validate NVIDIA Cloud Native Stack ](https://github.com/NVIDIA/cloud-native-stack/blob/master/playbooks/cnc-validation.yaml)

- [Uninstall NVIDIA Cloud Native Stack](https://github.com/NVIDIA/cloud-native-stack/blob/master/playbooks/cnc-uninstall.yaml)

## Prerequisites

The following instructions assume the following:

- You have [NVIDIA-Certified Systems](https://docs.nvidia.com/ngc/ngc-deploy-on-premises/nvidia-certified-systems/index.html) with Mellanox CX NICs. 
- You will perform a clean install.

To determine if your system qualifies as an NVIDIA Certified System, review the list of NVIDIA Certified Systems [here](https://docs.nvidia.com/ngc/ngc-deploy-on-premises/nvidia-certified-systems/index.html). 

Please note that NVIDIA Cloud Native Stack is validated only on systems with the default kernel (not HWE).

### Installing the Ubuntu Operating System
These instructions require having Ubuntu Server LTS 20.04.4 on your system. The Ubuntu Server can be downloaded from http://cdimage.ubuntu.com/releases/20.04.4/release/.


For more information on installing Ubuntu server please reference the [Ubuntu Server Installation Guide](https://ubuntu.com/tutorials/tutorial-install-ubuntu-server#1-overview).
 
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

Install the NVIDIA Cloud Native Stack stack by running the below command. "Skipping" in the ansible output refers to the Kubernetes cluster is up and running.
```
$ nano cnc_version.yaml

cnc_version: 6.2
```

```
$ nano cnc_values_6.2.yaml

# GPU Operator Values
gpu_driver_version: "510.47.03"
enable_mig: no
mig_profile: all-disabled
mig_strategy: single
enable_gds: no
enable_secure_boot: no
enable_vgpu: no
vgpu_license_server: ""
## This is most likely GPU Operator Driver Registry
gpu_operator_driver_registry: "nvcr.io/nvidia"
gpu_operator_registry_username: "$oauthtoken"
## This is most likely an NGC API key
gpu_operator_registry_password: ""
## This is most likely an NGC email
gpu_operator_registry_email: ""

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

## Kubernetes apt resources
k8s_apt_key: "https://packages.cloud.google.com/apt/doc/apt-key.gpg"
k8s_apt_repository: "deb https://apt.kubernetes.io/ kubernetes-xenial main"

```

```
bash setup.sh install
```
#### Custom Configuration
By default Cloud Native Stack uses Google kubernetes apt repository, if you want to use any other kubernetes apt repository, please adjust the `k8s_apt_key` and `k8s_apt_repository` parameters from the `cnc_values_6.2.yaml` file

Example:
```

## Kubernetes apt resources
k8s_apt_key: "https://mirrors.aliyun.com/kubernetes/apt/doc/apt-key.gpg"
k8s_apt_repository: "deb https://mirrors.aliyun.com/kubernetes/apt/ kubernetes-xenial main"
```

### Validation

Run the below command to check if the installed versions are match with predefined versions of the NVIDIA Cloud Native Stack. Here' "Ignored" tasks refer to failed and "Changed/Ok" tasks refer to success.

Run the validation playbook after 5 minutes once completing the NVIDIA Cloud Native Stack Installation. Depends on your internet speed, you need to wait more time.

```
bash setup.sh validate
```

### Uninstall

Run the below command to uninstall the NVIDIA Cloud Native Stack. Tasks being "ignored" refers to no kubernetes cluster being available.

```
bash setup.sh uninstall
```

