# This version is Deprecated, Please refer [Ubuntu Server 1.2](https://github.com/NVIDIA/cloud-native-core/blob/master/playbooks/Ubuntu_Server_v1.2.md)

<h1> Cloud Native Core Node Stack Ubuntu Server (x86-64) v1.1 </h1>

This page describes the steps required to use Ansible to install the Cloud Native Core Node Stack.

The final Cloud Native Core Node Stack will include:

- Ubuntu 18.04.3 LTS
- Ansible 2.9.6
- Docker CE 19.03.1
- Kubernetes version 1.15.3
- Helm/Tiller 2.14.3
- NVIDIA GPU Operator (Beta Version)
  - NV containerized driver: 440.33.01
  - NV container toolkit: 1.0.0-alpha.3
  - NV K8S device plug-in: 1.0.0-beta4
  - Data Center GPU Manager (DCGM): 1.7.2
  
### Release Notes

- Added section: "Installing the Ubuntu Operating System"

### The following Ansible Playbooks are available

- [Install Cloud Native Core Node Stack](https://github.com/NVIDIA/cloud-native-core/blob/master/Playbooks/cnc-installation.yaml)

- [Validate Cloud Native Core Node Stack ](https://github.com/NVIDIA/cloud-native-core/blob/master/Playbooks/cnc-validation.yaml)

- [Uninstall Cloud Native Core Node Stack](https://github.com/NVIDIA/cloud-native-core/blob/master/Playbooks/cnc-uninstall.yaml)

## Prerequisites

- NGC-Ready Server
- Ubuntu 18.04.3 LTS installed
- Internet connectivity
- [Ansible](#Ansible-Installation) 

To determine if your system is NGC-Ready for Edge Servers, please review the list of validated systems on the NGC-Ready Systems documentation page: https://docs.nvidia.com/ngc/ngc-ready-systems/index.html

Please note that the Cloud Native Core is only validated on Intel based NGC-Ready systems with the default kernel (not HWE). Using an AMD EPYC 2nd generation (ROME) NGC-Ready server is not validated yet and will require the HWE kernel and manually disabling nouveau.

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
 
### Ansible Installation
The following steps install Ansible on your Cloud Native Core server.

Include the offical Ansible project to the systems list of resources.

```
$ sudo apt-add-repository ppa:ansible/ansible -y
```

Refresh the system package index.

```
$ sudo apt update
```

Install the Ansible package.

```
$ sudo apt install ansible -y
```

Validate the Ansible installation.

```
$  ansible --version
```

Exptected Output:
```
ansible 2.9.6
  config file = /etc/ansible/ansible.cfg
  configured module search path = [u'/home/username/.ansible/plugins/modules', u'/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python2.7/dist-packages/ansible
  executable location = /usr/bin/ansible
  python version = 2.7.17 (default, Nov  7 2019, 10:07:09) [GCC 7.4.0]
```

## Using the Ansible playbooks 
This section describes how to use the ansible playbooks.

### Clone the git repository

Run the below commands to add the Cloud Native Core ansible playbooks.

```
$ git clone https://github.com/NVIDIA/cloud-native-core.git
$ cd cloud-native-core/Playbooks
```

### Installation

Install the Cloud Native Core stack by running the below command. "Skipping" in the ansible output refers to the Kubernetes cluster is up and running.

```
$ sudo ansible-playbook cnc-installation.yaml
```

### Validation

Run the below command to check if the installed versions are match with predefined versions of the Cloud Native Core Node Stack. Here' "Ignored" tasks refer to failed and "Changed/Ok" tasks refer to success.

Run the validation playbook 5 minutes after completing the Cloud Native Core Node Stack Installation.

```
$ sudo ansible-playbook cnc-validation.yaml
```

### Uninstall

Run the below command to uninstall the Cloud Native Core. Taks being "ignored" refers to no kubernetes cluster being available.

```
$ sudo ansible-playbook cnc-uninstall.yaml
```
