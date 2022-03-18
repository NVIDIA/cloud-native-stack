<h1>Ansible Playbooks for NVIDIA Cloud Native Core </h1>

<h2> Available Ansible Playbooks </h2>

<h3> Ubuntu Systems </h3>

- [Ubuntu(x86-64) v5.0](https://github.com/NVIDIA/cloud-native-core/blob/master/playbooks/Ubuntu_Server_v5.0.md)
- [Ubuntu(x86-64) v6.0](https://github.com/NVIDIA/cloud-native-core/blob/master/playbooks/Ubuntu_Server_v6.0.md)

<h3> Jetson Systems </h3>

- [Jetson Xavier v5.0](https://github.com/NVIDIA/cloud-native-core/blob/master/playbooks/Jetson_Xavier_v5.0.md)
- [Jetson Xavier v6.0](https://github.com/NVIDIA/cloud-native-core/blob/master/playbooks/Jetson_Xavier_v6.0.md)

`NOTE`
A list of older NVIDIA Cloud Native Core versions (formerly known as EGX Stack) can be found [here](https://github.com/NVIDIA/cloud-native-core/blob/master/playbooks/older_versions/readme.md)

<h2> Ansible Playbook Descriptions </h2>

- [Install NVIDIA Cloud Native Core](#Install-NVIDIA-Cloud-Native-Core)
- [Validate NVIDIA Cloud Native Core](#Validate-NVIDIA-Cloud-Native-Core)
- [Uninstall NVIDIA Cloud Native Core](#Uninstall-NVIDI-Cloud-Native-Core)

### Install NVIDIA Cloud Native Core 

The Ansible NVIDIA Cloud Native Core installation playbook will do the following:

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

### Validate NVIDIA Cloud Native Core 

The Ansible NVIDIA Cloud Native Core validation playbook will do the following:

- Validate if Kubernetes cluster is up
- Check if node is up and running
- Check if all pods are in running state
- Validate that Helm installed
- Validate the GPU Operator pods state
- Report Operating System, Docker, Kubernetes, Helm, GPU Operator versions
- Validate nvidia-smi and cuda liberaries on kubernetes

### Uninstall NVIDIA Cloud Native Core 

The Ansible NVIDIA Cloud Native Core uninstall playbook will do the following:

- Reset the Kubernetes cluster
- Remove the Helm package
- Uninstall the Docker and Kubernetes Packages

### Getting Help

Please [open an issue on the GitHub project](https://github.com/NVIDIA/cloud-native-core/issues) for any questions. Your feedback is appreciated.


