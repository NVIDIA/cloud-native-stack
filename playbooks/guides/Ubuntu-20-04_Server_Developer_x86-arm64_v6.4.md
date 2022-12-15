<h1> NVIDIA Cloud Native Stack Ubuntu Server for Developers </h1>

NVIDIA Cloud Native Stack for Developers is focused to provide the Docker based experince. This page describes the steps required to use Ansible to install the NVIDIA Cloud Native Stack for Developers

NVIDIA Cloud Native Stack for Developers includes:
- Ubuntu 20.04 LTS
- Containerd 1.6.10
- Kubernetes version 1.23.12
- Helm 3.10.2
- NVIDIA GPU Driver: 525.60.13
- NVIDIA Container Toolkit: 1.11.0
- NVIDIA GPU Operator 22.09
  - NVIDIA K8S Device Plugin: 0.13.0
  - NVIDIA DCGM-Exporter: 3.1.3-3.1.2
  - NVIDIA DCGM: 3.1.3-1
  - NVIDIA GPU Feature Discovery: 0.7.0
  - NVIDIA K8s MIG Manager: 0.5.0
  - NVIDIA Driver Manager: 0.5.1
  - Node Feature Discovery: 0.10.1


### The following Ansible Playbooks are available

- [Install NVIDIA Cloud Native Stack](https://github.com/NVIDIA/cloud-native-stack/blob/master/playbooks/cnc-docker.yaml)

- [Uninstall NVIDIA Cloud Native Stack](https://github.com/NVIDIA/cloud-native-stack/blob/master/playbooks/cnc-uninstall.yaml)

## Prerequisites

The following instructions assume the following:

- You have [NVIDIA-Certified Systems](https://docs.nvidia.com/ngc/ngc-deploy-on-premises/nvidia-certified-systems/index.html) with Mellanox CX NICs for x86-64 servers 
- You have [NVIDIA Qualified Systems](https://www.nvidia.com/en-us/data-center/data-center-gpus/qualified-system-catalog/?start=0&count=50&pageNumber=1&filters=eyJmaWx0ZXJzIjpbXSwic3ViRmlsdGVycyI6eyJwcm9jZXNzb3JUeXBlIjpbIkFSTS1UaHVuZGVyWDIiLCJBUk0tQWx0cmEiXX0sImNlcnRpZmllZEZpbHRlcnMiOnt9LCJwYXlsb2FkIjpbXX0=) for arm64 servers 
  `NOTE:` For ARM systems, NVIDIA Network Operator is not supported yet. 
- You will perform a clean install.

To determine if your system qualifies as an NVIDIA Certified System, review the list of NVIDIA Certified Systems [here](https://docs.nvidia.com/ngc/ngc-deploy-on-premises/nvidia-certified-systems/index.html). 

Please note that NVIDIA Cloud Native Stack is validated only on systems with the default kernel (not HWE).

### Installing the Ubuntu Operating System
These instructions require having Ubuntu Server LTS 20.04 on your system. The Ubuntu Server can be downloaded from http://cdimage.ubuntu.com/releases/20.04/release/.


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

cnc_version: 6.4

```

```
$ nano cnc_values_6.4.yaml
cnc_version: 6.4

# GPU Operator Values
enable_gpu_operator: yes
gpu_driver_version: "525.60.13"
enable_mig: no
mig_profile: all-disabled
mig_strategy: single
enable_gds: no
enable_secure_boot: no
enable_vgpu: no
vgpu_license_server: ""

## NGC Values
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

cnc_validation: no

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
cnc_docker: yes
## Enable For Cloud Native Stack Developers with TRD Driver
cnc_nvidia_driver: yes

## Kubernetes apt resources
k8s_apt_key: "https://packages.cloud.google.com/apt/doc/apt-key.gpg"
k8s_apt_repository: "deb https://apt.kubernetes.io/ kubernetes-xenial main"
k8s_registry: "k8s.gcr.io"
```

`NOTE:` The host may reboot through the install. if it does, wait for the host to finish the reboot and run the installer again. 
```
bash setup.sh install
```

#### Custom Configuration
By default Cloud Native Stack uses Google kubernetes apt repository, if you want to use any other kubernetes apt repository, please adjust the `k8s_apt_key` and `k8s_apt_repository` parameters from the `cnc_values_6.4.yaml` file

Example:
```
## Kubernetes apt resources
k8s_apt_key: "https://mirrors.aliyun.com/kubernetes/apt/doc/apt-key.gpg"
k8s_apt_repository: "deb https://mirrors.aliyun.com/kubernetes/apt/ kubernetes-xenial main"
```

### Uninstall

Run the below command to uninstall the NVIDIA Cloud Native Stack. Tasks being "ignored" refers to no kubernetes cluster being available.

```
bash setup.sh uninstall
```

