<h1> EGX DIY Node Stack Ubuntu Server (x86-64) v1.2 </h1>

This page describes the steps required to use Ansible to install the EGX DIY Node Stack.

The final EGX DIY Node Stack will include:

- Ubuntu 18.04.3 LTS
- Ansible 2.9.9
- Docker CE 19.03.1
- Kubernetes version 1.15.3
- Helm 3.1.0
- NVIDIA GPU Operator 1.1.7
  - NV containerized driver: 440.64.00
  - NV container toolkit: 1.0.2
  - NV K8S device plug-in: 1.0.0-beta6
  - Data Center GPU Manager (DCGM): 1.7.2
  
### Release Notes

- Added section: "Installing the Ubuntu Operating System"

### The following Ansible Playbooks are available

- [Install EGX DIY Node Stack](https://github.com/NVIDIA/egx-platform/blob/master/playbooks/egx-installation.yaml)

- [Validate EGX DIY Node Stack ](https://github.com/NVIDIA/egx-platform/blob/master/playbooks/egx-validation.yaml)

- [Uninstall EGX DIY Node Stack](https://github.com/NVIDIA/egx-platform/blob/master/playbooks/egx-uninstall.yaml)


## Prerequisites

- You have a NGC-Ready for Edge Server.
- You have Ubuntu Server 18.04.3 LTS installed.
- You will perform a clean install.
- The server has internet connectivity.

To determine if your system is NGC-Ready for Edge Servers, please review the list of validated systems on the NGC-Ready Systems documentation page: https://docs.nvidia.com/ngc/ngc-ready-systems/index.html

Please note that the EGX Stack is only validated on Intel based NGC-Ready systems with the default kernel (not HWE). Using an AMD EPYC 2nd generation (ROME) NGC-Ready server is not validated yet and will require the HWE kernel and manually disabling nouveau.

### Installing the Ubuntu Operating System
These instructions require having Ubuntu Server LTS 18.04.3 on your NGC-Ready system. The Ubuntu Server can be downloaded from http://cdimage.ubuntu.com/releases/bionic/release/.

Disabling nouveau (not validated and only required with Ubuntu 18.04.3 LTS HWE Kernel): 

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

Run the below commands to add the EGX DIY ansible playbooks.

```
$ git clone https://github.com/NVIDIA/egx-platform.git
$ cd egx-platform/playbooks
```

## Update EGX DIY Stack Version

Update EGX DIY Stack Version as per below, currently supported versions are

- [1.2](https://github.com/NVIDIA/egx-platform/blob/master/playbooks/Ubuntu_Server_v1.2.md)

```
sudo nano egx_version.yaml

egx_version: 1.2

```

### Installation

Install the EGX stack by running the below command. "Skipping" in the ansible output refers to the Kubernetes cluster is up and running.

```
$ sudo bash setup.sh install
```

### Validation

Run the below command to check if the installed versions are match with predefined versions of the EGX DIY Node Stack. Here' "Ignored" tasks refer to failed and "Changed/Ok" tasks refer to success.

Run the validation playbook after 5 minutes once completing the EGX DIY Node Stack Installation. Depends on your internet speed, you need to wait more time. 

```
$ sudo bash setup.sh validate
```

### Uninstall

Run the below command to uninstall the EGX Stack. Taks being "ignored" refers to no kubernetes cluster being available.

```
$ sudo bash setup.sh uninstall
```
