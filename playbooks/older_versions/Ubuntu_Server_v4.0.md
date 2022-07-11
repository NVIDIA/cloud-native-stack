<h1> Cloud Native Core Ubuntu Server (x86-64) v4.0 </h1>

This page describes the steps required to use Ansible to install the Cloud Native Core.

The final Cloud Native Core will include:

- Ubuntu 20.04.2 LTS
- Containerd 1.4.6
- Kubernetes version 1.21.1
- Helm 3.5.4
- NVIDIA GPU Operator 1.7.0
  - NV containerized driver: 460.73.01
  - NV container toolkit: 1.5.0
  - NV K8S device plug-in: 0.9.0
  - Data Center GPU Manager (DCGM): 2.1.8-2.4.0-rc.2
  - Node Feature Discovery: 0.6.0
  - GPU Feature Discovery: 0.4.1

### Release Notes

- Added support for Multi Node Kubernetes Cluster

### The following Ansible Playbooks are available

- [Install Cloud Native Core](https://github.com/NVIDIA/cloud-native-core/blob/master/playbooks/cnc-installation.yaml)

- [Validate Cloud Native Core ](https://github.com/NVIDIA/cloud-native-core/blob/master/playbooks/cnc-validation.yaml)

- [Uninstall Cloud Native Core](https://github.com/NVIDIA/cloud-native-core/blob/master/playbooks/cnc-uninstall.yaml)

## Prerequisites

- You have a NGC-Ready for Edge Server.
- You will perform a clean install.
- The server has internet connectivity.

To determine if your system is NGC-Ready for Edge Servers, please review the list of validated systems on the NGC-Ready Systems documentation page: https://docs.nvidia.com/ngc/ngc-ready-systems/index.html

Please note that the Cloud Native Core is only validated on Intel based NGC-Ready systems with the default kernel (not HWE). Using an AMD EPYC 2nd generation (ROME) NGC-Ready server is not validated yet and will require the HWE kernel and manually disabling nouveau.

### Installing the Ubuntu Operating System
These instructions require having Ubuntu Server LTS 20.04.2 on your NGC-Ready system. The Ubuntu Server can be downloaded from http://cdimage.ubuntu.com/releases/20.04.2/release/.

Disabling nouveau (not validated and only required with Ubuntu 20.04.2 LTS HWE Kernel): 

```
$ sudo nano /etc/modprobe.d/blacklist-nouveau.conf
```

Insert the following:

```
blacklist nouveau
options nouveau modeset=0
```

Regenerate the kernel initramfs:

```
$ sudo update-initramfs -u
```

And reboot your system:

```
$ sudo reboot
```

For more information on installing Ubuntu server please reference the [Ubuntu Server Installation Guide](https://ubuntu.com/tutorials/tutorial-install-ubuntu-server#1-overview).
 
## Using the Ansible playbooks 
This section describes how to use the ansible playbooks.

### Clone the git repository

Run the below commands to clone the Cloud Native Core ansible playbooks.

```
$ git clone https://github.com/NVIDIA/cloud-native-core.git
$ cd cloud-native-core/playbooks
```

Update the hosts file in playbooks directory with master and worker nodes(if you have) IP's with username and password like below

```
$ sudo nano hosts

[master]
10.110.16.178 ansible_ssh_user=nvidia ansible_ssh_pass=nvidipass ansible_sudo_pass=nvidiapass ansible_ssh_common_args='-o StrictHostKeyChecking=no'
[node]
10.110.16.179 ansible_ssh_user=nvidia ansible_ssh_pass=nvidiapass ansible_sudo_pass=nvidiapass ansible_ssh_common_args='-o StrictHostKeyChecking=no'
```


## Available Cloud Native Core Versions

Update Cloud Native Core Version as per below, currently supported versions are

- [1.2](https://github.com/NVIDIA/cloud-native-core/blob/master/playbooks/Ubuntu_Server_v1.2.md)
- [2.0](https://github.com/NVIDIA/cloud-native-core/blob/master/playbooks/Ubuntu_Server_v2.0.md)
- [3.1](https://github.com/NVIDIA/cloud-native-core/blob/master/playbooks/Ubuntu_Server_v3.1.md)
- [4.0](https://github.com/NVIDIA/cloud-native-core/blob/master/playbooks/Ubuntu_Server_v4.0.md)

```
sudo nano cnc_version.yaml

cnc_version: 4.0

```

### Installation

Install the Cloud Native Core stack by running the below command. "Skipping" in the ansible output refers to the Kubernetes cluster is up and running.

```
$ bash setup.sh install
```

### Validation

Run the below command to check if the installed versions are match with predefined versions of the Cloud Native Core. Here' "Ignored" tasks refer to failed and "Changed/Ok" tasks refer to success.

Run the validation playbook after 5 minutes once completing the Cloud Native Core Installation. Depends on your internet speed, you need to wait more time.

```
$ bash setup.sh validate
```

### Uninstall

Run the below command to uninstall the Cloud Native Core. Taks being "ignored" refers to no kubernetes cluster being available.

```
$ bash setup.sh uninstall
```

