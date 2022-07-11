<h1> NVIDIA Cloud Native Core Ubuntu Server (x86-64) for Developers with vGPU Driver </h1>

This page describes the steps required to use Ansible to install the NVIDIA Cloud Native Core for Developers

NVIDIA Cloud Native Core for Developers includes:
- Ubuntu 20.04.4 LTS
- Containerd 1.6.2
- Kubernetes version 1.23.5
- Helm 3.8.1
- NVIDIA vGPU Driver: 510.47.03
- NVIDIA Container Toolkit: 1.9.0
- NVIDIA GPU Operator 1.10.1
  - NVIDIA K8S Device Plugin: 0.11.0
  - NVIDIA DCGM-Exporter: 2.3.4-2.6.4
  - NVIDIA DCGM: 2.3.4.1
  - NVIDIA GPU Feature Discovery: 0.5.0
  - NVIDIA K8s MIG Manager: 0.3.0
  - NVIDIA Driver Manager: 0.3.0
  - Node Feature Discovery: 0.10.1


### The following Ansible Playbooks are available

- [Install NVIDIA Cloud Native Core](https://github.com/NVIDIA/cloud-native-core/blob/master/playbooks/cnc-docker.yaml)

- [Uninstall NVIDIA Cloud Native Core](https://github.com/NVIDIA/cloud-native-core/blob/master/playbooks/cnc-uninstall.yaml)

## Prerequisites

The following instructions assume the following:

- You have VM with vGPU Profile 
- You will perform a clean install.
- Access to Enterprise Catalog 

To determine if your system qualifies as an NVIDIA Certified System, review the list of NVIDIA Certified Systems [here](https://docs.nvidia.com/ngc/ngc-deploy-on-premises/nvidia-certified-systems/index.html). 

Please note that NVIDIA Cloud Native Core is validated only on systems with the default kernel (not HWE).

### Installing the Ubuntu Operating System
These instructions require having Ubuntu Server LTS 20.04.4 on your system. The Ubuntu Server can be downloaded from http://cdimage.ubuntu.com/releases/20.04.4/release/.


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
```

### Installation

Install the NVIDIA Cloud Native Core stack by running the below command. "Skipping" in the ansible output refers to the Kubernetes cluster is up and running.

`NOTE:` Update `ngc_apy_key` value in `cnc_values.yaml` below and make sure copy the `client_configuration_token_*.tok` file to `cloud-native-core/playbooks` directory. 

```
$ nano cnc_values.yaml

cnc_version: 6.1

# GPU Operator Values
gpu_driver_version: "510.47.03"
enable_mig: no
mig_profile: all-disabled
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

# Cloud Native Core for Developers Values
## Enable for Cloud Native Core Developers and DGX System
cnc_docker: yes
## Enable For Cloud Native Core Developers with TRD Driver
cnc_nvidia_driver: no
## Enable for Cloud Native Core for Developers with vGPU driver
cnc_nvidia_vgpu: yes
## Provide NGC API key to download the vGPU driver and license token
ngc_api_key: ""

## Kubernetes apt resources
k8s_apt_key: "https://packages.cloud.google.com/apt/doc/apt-key.gpg"
k8s_apt_repository: "deb https://apt.kubernetes.io/ kubernetes-xenial main"
```

`NOTE:` The host may reboot through the install. if it does, wait for the host to finish the reboot and run the installer again. 
```
bash setup.sh install
```

#### Custom Configuration
By default Cloud Native Core uses Google kubernetes apt repository, if you want to use any other kubernetes apt repository, please adjust the `k8s_apt_key` and `k8s_apt_repository` parameters from the `cnc_values.yaml` file

Example:
```
cnc_version: 6.1

# GPU Operator Values
gpu_driver_version: "510.47.03"
enable_mig: no
mig_profile: all-disabled
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

# Cloud Native Core for Developers Values
## Enable for Cloud Native Core Developers and DGX System
cnc_docker: no
## Enable For Cloud Native Core Developers with TRD Driver
cnc_nvidia_driver: no
## Enable for Cloud Native Core for Developers with vGPU driver
cnc_nvidia_vgpu: no
## Provide NGC API key to download the vGPU driver and license token
ngc_api_key: ""

## Kubernetes apt resources
k8s_apt_key: "https://packages.cloud.google.com/apt/doc/apt-key.gpg"
k8s_apt_repository: "deb https://apt.kubernetes.io/ kubernetes-xenial main"

```

### Uninstall

Run the below command to uninstall the NVIDIA Cloud Native Core. Taks being "ignored" refers to no kubernetes cluster being available.

```
bash setup.sh uninstall
```

