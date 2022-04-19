<h1> NVIDIA Cloud Native Core Ubuntu Server (x86-64) v6.0 </h1>

This page describes the steps required to use Ansible to install the NVIDIA Cloud Native Core.

NVIDIA Cloud Native Core v6.0 includes:
- Ubuntu 20.04.3 LTS
- Containerd 1.6.0
- Kubernetes version 1.23.2
- Helm 3.8.0
- NVIDIA GPU Operator 1.9.1
  - NVIDIA GPU Driver: 510.47.03
  - NVIDIA Container Toolkit: 1.7.2
  - NVIDIA K8S Device Plugin: 0.10.0
  - NVIDIA DCGM-Exporter: 2.3.1-2.6.1
  - NVIDIA GPU Feature Discovery: 0.4.1
  - NVIDIA K8s MIG Manager: 0.2.0
  - NVIDIA Driver Manager: 0.2.0
  - Node Feature Discovery: 0.8.2
- NVIDIA Network Operator 1.1.0
  - Mellanox MOFED Driver 5.5-1.0.3.2
  - Mellanox NV Peer Memory Driver 1.1-0
  - RDMA Shared Device Plugin 1.2.1
  - SRIOV Device Plugin 3.3
  - Container Networking Plugins 0.8.7
  - Multus 3.8
  - Whereabouts 0.4.2


### The following Ansible Playbooks are available

- [Install NVIDIA Cloud Native Core](https://github.com/NVIDIA/cloud-native-core/blob/master/playbooks/cnc-installation.yaml)

- [Validate NVIDIA Cloud Native Core ](https://github.com/NVIDIA/cloud-native-core/blob/master/playbooks/cnc-validation.yaml)

- [Uninstall NVIDIA Cloud Native Core](https://github.com/NVIDIA/cloud-native-core/blob/master/playbooks/cnc-uninstall.yaml)

## Prerequisites

The following instructions assume the following:

- You have [NVIDIA-Certified Systems](https://docs.nvidia.com/ngc/ngc-deploy-on-premises/nvidia-certified-systems/index.html) with Mellanox CX NICs. 
- You will perform a clean install.

To determine if your system qualifies as an NVIDIA Certified System, review the list of NVIDIA Certified Systems [here](https://docs.nvidia.com/ngc/ngc-deploy-on-premises/nvidia-certified-systems/index.html). 

Please note that NVIDIA Cloud Native Core is validated only on systems with the default kernel (not HWE).

### Installing the Ubuntu Operating System
These instructions require having Ubuntu Server LTS 20.04.3 on your system. The Ubuntu Server can be downloaded from http://cdimage.ubuntu.com/releases/20.04.3/release/.


For more information on installing Ubuntu server please reference the [Ubuntu Server Installation Guide](https://ubuntu.com/tutorials/tutorial-install-ubuntu-server#1-overview).
 
## Using the Ansible playbooks 
This section describes how to use the ansible playbooks.

### Clone the git repository

Run the below commands to clone the NVIDIA Cloud Native Core ansible playbooks.

```
git clone https://github.com/NVIDIA/cloud-native-core.git
cd cloud-native-core/playbooks
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

Install the NVIDIA Cloud Native Core stack by running the below command. "Skipping" in the ansible output refers to the Kubernetes cluster is up and running.
```
$ nano cnc_values.yaml

cnc_version: 6.0
## NVIDIA Driver Version (https://www.nvidia.com/Download/index.aspx?lang=en-us)
## enable 51.0.47.03 for cnc_version: 6.0
gpu_driver_version: "510.47.03"
## If the Network Operator is yes then make sure enable_rdma as well yes
enable_network_operator: no
## Enable RDMA yes for NVIDIA Certification
enable_rdma: no
## enable MIG with GPU Operator 
enable_mig: no
## MIG Profile for GPU Operator 
mig_profile: all-disabled
## Enable vGPU for GPU Operator 
enable_vgpu: no
## vGPU License Server
vgpu_license_server: ""
## GPU Operator Driver Registry
gpu_operator_driver_registry: "nvcr.io/nvidia"
## This should remain as $oauthtoken if using an NGC API key
gpu_operator_registry_username: "$oauthtoken"
## NGC API key
gpu_operator_registry_password: ""
## NGC email
gpu_operator_registry_email: ""
## Kubernetes apt resources
k8s_apt_key: "https://packages.cloud.google.com/apt/doc/apt-key.gpg"
k8s_apt_repository: "deb https://apt.kubernetes.io/ kubernetes-xenial main"

```

```
bash setup.sh install
```
#### Custom Configuration
By default Cloud Native Core uses Google kubernetes apt repository, if you want to use any other kubernetes apt repository, please adjust the `k8s_apt_key` and `k8s_apt_repository` parameters from the `cnc_values.yaml` file

Example:
```
cnc_version: 6.0
## NVIDIA Driver Version (https://www.nvidia.com/Download/index.aspx?lang=en-us)
## enable 51.0.47.03 for cnc_version: 6.0
gpu_driver_version: "510.47.03"
## If the Network Operator is yes then make sure enable_rdma as well yes
enable_network_operator: no
## Enable RDMA yes for NVIDIA Certification
enable_rdma: no
## Enable MIG with GPU Operator 
enable_mig: no
## MIG Profile for GPU Operator 
mig_profile: all-disabled
## Enable vGPU for GPU Operator 
enable_vgpu: no
## vGPU License Server
vgpu_license_server: ""
## GPU Operator Driver Registry
gpu_operator_driver_registry: "nvcr.io/nvidia"
## This should remain as $oauthtoken if using an NGC API key
gpu_operator_registry_username: "$oauthtoken"
##  NGC API key
gpu_operator_registry_password: ""
## NGC email
gpu_operator_registry_email: ""
## Kubernetes apt resources
k8s_apt_key: "https://mirrors.aliyun.com/kubernetes/apt/doc/apt-key.gpg"
k8s_apt_repository: "deb https://mirrors.aliyun.com/kubernetes/apt/ kubernetes-xenial main"
```

### Validation

Run the below command to check if the installed versions are match with predefined versions of the NVIDIA Cloud Native Core. Here' "Ignored" tasks refer to failed and "Changed/Ok" tasks refer to success.

Run the validation playbook after 5 minutes once completing the NVIDIA Cloud Native Core Installation. Depends on your internet speed, you need to wait more time.

```
bash setup.sh validate
```

### Uninstall

Run the below command to uninstall the NVIDIA Cloud Native Core. Taks being "ignored" refers to no kubernetes cluster being available.

```
bash setup.sh uninstall
```

