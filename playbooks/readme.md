<h1>Ansible Playbooks for NVIDIA Cloud Native Stack </h1>

<h2> Available Ansible Playbooks </h2>

<h3> Ubuntu Systems </h3>

- [Ubuntu(x86-64) v5.0](https://github.com/NVIDIA/cloud-native-stack/blob/master/playbooks/guides/Ubuntu-20-04_Server_x86_v5.0.md)
- [Ubuntu(x86-64) v5.0](https://github.com/NVIDIA/cloud-native-stack/blob/master/playbooks/guides/Ubuntu-20-04_Server_x86_v5.1.md)
- [Ubuntu(x86-64) v5.0](https://github.com/NVIDIA/cloud-native-stack/blob/master/playbooks/guides/Ubuntu-20-04_Server_x86_v5.2.md)
- [Ubuntu(x86-64) v6.0](https://github.com/NVIDIA/cloud-native-stack/blob/master/playbooks/guides/Ubuntu-20-04_Server_x86_v6.0.md)
- [Ubuntu(x86-64) v5.1](https://github.com/NVIDIA/cloud-native-stack/blob/master/playbooks/guides/Ubuntu-20-04_Server_x86_v5.1.md)
- [Ubuntu(x86-64) v6.1](https://github.com/NVIDIA/cloud-native-stack/blob/master/playbooks/guides/Ubuntu-20-04_Server_x86_v6.1.md)
- [Ubuntu(x86-64) v6.2](https://github.com/NVIDIA/cloud-native-stack/blob/master/playbooks/guides/Ubuntu-20-04_Server_x86_v6.2.md)
- [Ubuntu(x86-64 & arm64) v6.3](https://github.com/NVIDIA/cloud-native-stack/blob/master/playbooks/guides/Ubuntu-20-04_Server_x86-arm64_v6.3.md)
- [Ubuntu(x86-64) v7.0](https://github.com/NVIDIA/cloud-native-stack/blob/master/playbooks/guides/Ubuntu-22-04_Server_x86_v7.0.md)
- [Ubuntu(x86-64 & arm64) v7.1](https://github.com/NVIDIA/cloud-native-stack/blob/master/playbooks/guides/Ubuntu-22-04_Server_x86-arm64_v7.1.md)
- [Ubuntu(x86-64 & arm64) v7.2](https://github.com/NVIDIA/cloud-native-stack/blob/master/playbooks/guides/Ubuntu-22-04_Server_x86-arm64_v7.2.md)
- [Ubuntu(x86-64 & arm64) v8.0](https://github.com/NVIDIA/cloud-native-stack/blob/master/playbooks/guides/Ubuntu-22-04_Server_x86-arm64_v8.0.md)
- [Ubuntu(x86-64 & arm64) v8.1](https://github.com/NVIDIA/cloud-native-stack/blob/master/playbooks/guides/Ubuntu-22-04_Server_x86-arm64_v8.1.md)

<h3> Jetson Systems </h3>

- [Jetson Xavier v5.0](https://github.com/NVIDIA/cloud-native-stack/blob/master/playbooks/guides/Jetson_Xavier_v5.0.md)
- [Jetson Xavier v6.0](https://github.com/NVIDIA/cloud-native-stack/blob/master/playbooks/guides/Jetson_Xavier_v6.0.md)
- [Jetson Xavier v6.1](https://github.com/NVIDIA/cloud-native-stack/blob/master/playbooks/guides/Jetson_Xavier_v6.1.md)
- [Jetson Xavier v6.2](https://github.com/NVIDIA/cloud-native-stack/blob/master/playbooks/guides/Jetson_Xavier_v6.2.md)
- [Jetson Xavier v6.3](https://github.com/NVIDIA/cloud-native-stack/blob/master/playbooks/guides/Jetson_Xavier_v6.3.md)
- [Jetson Xavier v7.0](https://github.com/NVIDIA/cloud-native-stack/blob/master/playbooks/guides/Jetson_Xavier_v7.0.md)
- [Jetson Xavier v7.1](https://github.com/NVIDIA/cloud-native-stack/blob/master/playbooks/guides/Jetson_Xavier_v7.1.md)
- [Jetson Xavier v7.2](https://github.com/NVIDIA/cloud-native-stack/blob/master/playbooks/guides/Jetson_Xavier_v7.2.md)
- [Jetson Xavier v8.0](https://github.com/NVIDIA/cloud-native-stack/blob/master/playbooks/guides/Jetson_Xavier_v8.0.md)
- [Jetson Xavier v8.1](https://github.com/NVIDIA/cloud-native-stack/blob/master/playbooks/guides/Jetson_Xavier_v8.1.md)

### Ubuntu Server for Developers
- [Ubuntu 20.04 Server Developer x86 v6.1](https://github.com/NVIDIA/cloud-native-stack/blob/master/playbooks/guides/Ubuntu-20-04_Server_Developer_x86_v6.1.md)
- [Ubuntu 20.04 Server Developer x86 v6.2](https://github.com/NVIDIA/cloud-native-stack/blob/master/playbooks/guides/Ubuntu-20-04_Server_Developer_x86_v6.2.md)
- [Ubuntu 20.04 Server Developer x86 & arm64 v6.3](https://github.com/NVIDIA/cloud-native-stack/blob/master/playbooks/guides/Ubuntu-20-04_Server_Developer_x86-arm64_v6.3.md)
- [Ubuntu 22.04 Server Developer x86 v7.0](https://github.com/NVIDIA/cloud-native-stack/blob/master/playbooks/guides/Ubuntu-22-04_Server_Developer_x86_v7.0.md)
- [Ubuntu 22.04 Server Developer x86 & arm64 v7.1](https://github.com/NVIDIA/cloud-native-stack/blob/master/playbooks/guides/Ubuntu-22-04_Server_Developer_x86-arm64_v7.1.md)
- [Ubuntu 22.04 Server Developer x86 & arm64 v7.2](https://github.com/NVIDIA/cloud-native-stack/blob/master/playbooks/guides/Ubuntu-22-04_Server_Developer_x86-arm64_v7.2.md)
- [Ubuntu 22.04 Server Developer x86 & arm64 v8.0](https://github.com/NVIDIA/cloud-native-stack/blob/master/playbooks/guides/Ubuntu-22-04_Server_Developer_x86-arm64_v8.0.md)
- [Ubuntu 22.04 Server Developer x86 & arm64 v8.1](https://github.com/NVIDIA/cloud-native-stack/blob/master/playbooks/guides/Ubuntu-22-04_Server_Developer_x86-arm64_v8.1.md)

`NOTE`
A list of older NVIDIA Cloud Native Stack versions (formerly known as Cloud Native Core) can be found [here](https://github.com/NVIDIA/cloud-native-stack/blob/master/playbooks/older_versions/readme.md)

<h2> Ansible Playbook Descriptions </h2>

- [Install NVIDIA Cloud Native Stack](#Install-NVIDIA-Cloud-Native-Stack)
- [Validate NVIDIA Cloud Native Stack](#Validate-NVIDIA-Cloud-Native-Stack)
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

### Uninstall NVIDIA Cloud Native Stack 

The Ansible NVIDIA Cloud Native Stack uninstall playbook will do the following:

- Reset the Kubernetes cluster
- Remove the Helm package
- Uninstall the Docker and Kubernetes Packages

### Getting Help

Please [open an issue on the GitHub project](https://github.com/NVIDIA/cloud-native-stack/issues) for any questions. Your feedback is appreciated.


