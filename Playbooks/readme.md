<h1>Ansible playbooks for EGX DIY Node Stack</h1>

<h2> Available Ansible Playbooks </h2>

- [Ubuntu(x86-64)_2020.02.25](https://github.com/erikbohnhorst/EGX-DIY-Node-Stack/blob/master/Playbooks/Ubuntu(x86-64)_2020.02.25.md)

<h2> Ansible Playbook Descriptions </h2>

- [Install EGX DIY Stack](#Install-EGX-DIY-Stack)
- [Validate EGX DIY Stack](#Validate-EGX-DIY-Stack)
- [Uninstall EGX DIY Stack](#Uninstall-EGX-DIY-Stack)

### Install EGX DIY Stack

The Ansible EGX DIY Node Stack installation playbook will do the following:

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
- Create a RBAC for Helm Tiller
- Initialize Helm with service account
- Install the NVIDIA GPU Operator

### Validate EGX DIY Stack

The Ansible EGX DIY Node Stack validation playbook will do the following:

- Validate if Kubernetes cluster is up
- Check if node is up and running
- Check if all pods are in running state
- Validate that Helm installed
- Validate cluster role is created for Helm
- Validate cluster rolebinding is created for Helm
- Validate Tiller Service Account is created for Helm
- Validate Tiller Service Account is added to Helm
- Validate the GPU Operator pods state
- Report Operating System, Docker, Kubernetes, Helm, GPU Operator versions

### Uninstall EGX DIY Stack

The Ansible EGX DIY Node Stack uninstall playbook will do the following:

- Reset the Kubernetes cluster
- Remove the Helm package
- Uninstall the Docker and Kubernetes Packages

### Getting Help

Please [open an issue on the GitHub project](https://github.com/erikbohnhorst/EGX-DIY-Node-Stack/issues) for any questions. Your feedback is appreciated.
