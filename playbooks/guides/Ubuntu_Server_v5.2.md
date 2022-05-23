<h1> NVIDIA Cloud Native Core Ubuntu Server (x86-64) v5.1 </h1>

This page describes the steps required to use Ansible to install NVIDIA Cloud Native Core.

NVIDIA Cloud Native Core v5.1 includes:

- Ubuntu 20.04.4 LTS
- Containerd 1.4.9
- Kubernetes version 1.22.5
- Helm 3.8.2
- NVIDIA GPU Operator 1.10.1
  - NVIDIA GPU Driver: 510.47.03
  - NVIDIA Container Toolkit: 1.9.0
  - NVIDIA K8S Device Plugin: 0.11.0
  - NVIDIA DCGM-Exporter: 2.3.4-2.6.4
  - NVIDIA DCGM: 2.3.4.1
  - NVIDIA GPU Feature Discovery: 0.5.0
  - NVIDIA K8s MIG Manager: 0.3.0
  - NVIDIA Driver Manager: 0.3.0
  - Node Feature Discovery: 0.10.1

### The following Ansible Playbooks are available

- [Install NVIDIA Cloud Native Core](https://github.com/NVIDIA/cloud-native-core/blob/master/playbooks/cnc-installation.yaml)

- [Validate NVIDIA Cloud Native Core ](https://github.com/NVIDIA/cloud-native-core/blob/master/playbooks/cnc-validation.yaml)

- [Uninstall NVIDIA Cloud Native Core](https://github.com/NVIDIA/cloud-native-core/blob/master/playbooks/cnc-uninstall.yaml)

### Prerequisites
 
The following instructions assume the following:

- You have [NVIDIA-Certified Systems](https://docs.nvidia.com/ngc/ngc-deploy-on-premises/nvidia-certified-systems/index.html) with Mellanox CX NICs. 
- You will perform a clean install.

To determine if your system qualifies as an NVIDIA Certified System, review the list of NVIDIA Certified Systems [here](https://docs.nvidia.com/ngc/ngc-deploy-on-premises/nvidia-certified-systems/index.html). 

Please note that NVIDIA Cloud Native Core is validated only on systems with the default kernel (not HWE).

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


cnc_version: 5.2

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
## Enable for Cloud Native Core Developers 
cnc_docker: no
## Enable For Cloud Native Core Developers with TRD Driver
cnc_nvidia_driver: no

## Kubernetes apt resources
k8s_apt_key: "https://packages.cloud.google.com/apt/doc/apt-key.gpg"
k8s_apt_repository: "deb https://apt.kubernetes.io/ kubernetes-xenial main"
```

```
bash setup.sh install dgx
```
#### Custom Configuration
By default Cloud Native Core uses Google kubernetes apt repository, if you want to use any other kubernetes apt repository, please adjust the `k8s_apt_key` and `k8s_apt_repository` parameters from the `cnc_values.yaml` file

Example:
```
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

Run the below command to uninstall the NVIDIA Cloud Native Core. Tasks being "ignored" refers to no kubernetes cluster being available.

```
bash setup.sh uninstall
```

