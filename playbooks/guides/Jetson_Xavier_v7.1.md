<h1> NVIDIA Cloud Native Stack Jetson Xavier v7.1 </h1>

This page describes the steps required to use Ansible to install the NVIDIA Cloud Native Stack.

The final NVIDIA Cloud Native Stack will include:


- JetPack 5.0
- Kubernetes version 1.24.6
- Helm 3.10.0
- NVIDIA Container Runtime 3.11.0-1
- Containerd 1.6.8


### The following Ansible Playbooks are available

- [Install NVIDIA Cloud Native Stack](https://github.com/NVIDIA/cloud-native-stack/blob/master/playbooks/jetson-xavier.yaml)

- [Validate NVIDIA Cloud Native Stack ](https://github.com/NVIDIA/cloud-native-stack/blob/master/playbooks/cnc-validation.yaml)

- [Uninstall NVIDIA Cloud Native Stack](https://github.com/NVIDIA/cloud-native-stack/blob/master/playbooks/cnc-uninstall.yaml)


### Prerequisites
 
These instructions assume you have a Jetson Xavier or Xavier NX Developer Kit.

- You will perform a clean install.
- The server has internet connectivity.

### Installing JetPack 5.0

JetPack (the Jetson SDK) is an on-demand all-in-one package that bundles developer software for the NVIDIA® Jetson platform. There are two ways to install the JetPack 

1. Use the SDK Manager installer to flash your Jetson Developer Kit with the latest OS image, install developer tools for both host PC and Developer Kit, and install the libraries and APIs, samples, and documentation needed to jump-start your development environment.

Follow the [instructions](https://docs.nvidia.com/sdk-manager/install-with-sdkm-jetson/index.html) on how to install JetPack 5.0There are two ways to install the JetPack 

Download the SDK Manager from [here](https://developer.nvidia.com/nvidia-sdk-manager)

2. Use the SD Card Image method to download the JetPack and load the OS image to external drive. For more information, please refer [flash using SD Card method](https://developer.nvidia.com/embedded/learn/get-started-jetson-xavier-nx-devkit#prepare)

### Jetson Xavier NX Storage
Running NVIDIA Cloud Native Stack on Xavier NX production modules (16GB) might not provide sufficient storage capacity with fully loaded JetPack 4.5 to host your specific container images. If you require additional storage, use the Jetson Xavier NX Development Kit during the development phase, as you can insert greater than 16GB via microSD cards and/or remove unused JetPack 5.0 packages. For production deployments, remove packages that are not required from fully loaded JetPack 5.0 and/or extend the storage capacity via NVMe or SSD.

 
## Using the Ansible playbooks 
This section describes how to use the ansible playbooks.

### Clone the git repository

Run the below commands to clone the NVIDIA Cloud Native Stack ansible playbooks.

```
$ git clone https://github.com/NVIDIA/cloud-native-stack.git
$ cd cloud-native-stack/playbooks
```

Update the hosts file in playbooks directory with master and worker nodes(if you have) IP's with username and password like below

```
$ sudo nano hosts

[master]
10.110.16.178 ansible_ssh_user=nvidia ansible_ssh_pass=nvidipass ansible_sudo_pass=nvidiapass ansible_ssh_common_args='-o StrictHostKeyChecking=no'
[node]
10.110.16.179 ansible_ssh_user=nvidia ansible_ssh_pass=nvidiapass ansible_sudo_pass=nvidiapass ansible_ssh_common_args='-o StrictHostKeyChecking=no'
```

### Installation

Install the NVIDIA Cloud Native Stack stack by running the below command. "Skipping" in the ansible output refers to the Kubernetes cluster is up and running.

```
sudo nano cnc_version.yaml

cnc_version: 7.1

```

```
$ bash setup.sh install
```

### Uninstall

Run the below command to uninstall the NVIDIA Cloud Native Stack. Taks being "ignored" refers to no kubernetes cluster being available.

```
$ bash setup.sh uninstall
```

