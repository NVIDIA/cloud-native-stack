<h1>Ansible playbooks for EGX Platform</h1>

<h2> Available Ansible Playbooks </h2>

- [Ubuntu(x86-64)_v1.1](https://github.com/NVIDIA/egx-platform/blob/master/playbooks/Ubuntu_Server_v1.1.md)(DEPRECATED)
- [Ubuntu(x86-64)_v1.2](https://github.com/NVIDIA/egx-platform/blob/master/playbooks/Ubuntu_Server_v1.2.md)
- [Ubuntu(x86-64) v1.3](https://github.com/NVIDIA/egx-platform/blob/master/playbooks/Ubuntu_Server_v1.3.md)
- [Ubuntu(x86-64) v2.0](https://github.com/NVIDIA/egx-platform/blob/master/playbooks/Ubuntu_Server_v2.0.md)
- [Ubuntu(x86-64) v3.0](https://github.com/NVIDIA/egx-platform/blob/master/playbooks/Ubuntu_Server_v3.0.md)
- [Ubuntu(x86-64) v3.1](https://github.com/NVIDIA/egx-platform/blob/master/playbooks/Ubuntu_Server_v3.1.md)
- [Ubuntu(x86-64) v4.0](https://github.com/NVIDIA/egx-platform/blob/master/playbooks/Ubuntu_Server_v4.0.md)
- [Ubuntu(x86-64) v4.1](https://github.com/NVIDIA/egx-platform/blob/master/playbooks/Ubuntu_Server_v4.1.md)
- [Ubuntu(x86-64) v4.2](https://github.com/NVIDIA/egx-platform/blob/master/playbooks/Ubuntu_Server_v4.2.md)

<h2> Ansible Playbook Descriptions </h2>

- [Install EGX Platform](#Install-EGX-Platform)
- [Validate EGX Platform](#Validate-EGX-Platform)
- [Uninstall EGX Platform](#Uninstall-EGX-Platform)

The Ansible EGX Platform installation playbook will do the following:

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

### Validate EGX Platform

The Ansible EGX Platform validation playbook will do the following:

- Validate if Kubernetes cluster is up
- Check if node is up and running
- Check if all pods are in running state
- Validate that Helm installed
- Validate the GPU Operator pods state
- Report Operating System, Docker, Kubernetes, Helm, GPU Operator versions
- Validate nvidia-smi and cuda liberaries on kubernetes

### Uninstall EGX Platform

The Ansible EGX Platform uninstall playbook will do the following:

- Reset the Kubernetes cluster
- Remove the Helm package
- Uninstall the Docker and Kubernetes Packages

### Getting Help

Please [open an issue on the GitHub project](https://github.com/NVIDIA/egx-platform/issues) for any questions. Your feedback is appreciated.
