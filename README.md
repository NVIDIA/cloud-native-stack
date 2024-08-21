# NVIDIA Cloud Native Stack 

NVIDIA Cloud Native Stack (formerly known as Cloud Native Core) is a collection of software to run cloud native workloads on NVIDIA GPUs. NVIDIA Cloud Native Stack is based on Ubuntu, Kubernetes, Helm and the NVIDIA GPU and Network Operator.

Interested in deploying NVIDIA Cloud Native Stack? This repository has [install guides](https://github.com/NVIDIA/cloud-native-stack/tree/master/install-guides) for manual installations and [ansible playbooks](https://github.com/NVIDIA/cloud-native-stack/tree/master/playbooks) for automated installations.

Interested in a pre-provisioned NVIDIA Cloud Native Stack environment? [NVIDIA LaunchPad](https://www.nvidia.com/en-us/data-center/launchpad/) provides pre-provisioned environments so that you can quickly get started.

# Getting Started

#### Prerequisites

Please make sure to meet the following prerequisites to Install the Cloud Native Stack

- system has direct internet access
- system should have an Operating system either Ubuntu 20.04 and above or RHEL 8.7
- system has adequate internet bandWidth
- DNS server is working fine on the System
- system can access Google repo(for k8s installation)
- system has only 1 network interface configured with internet access. The IP is static and doesn't change
- UEFI secure boot is disabled
- Root file system should has at least 40GB capacity
- system has 2CPU and 4GB Memory
- At least one NVIDIA GPU attached to the system

#### Installation 

Run the below commands to clone the NVIDIA Cloud Native Stack.

```
git clone https://github.com/NVIDIA/cloud-native-stack.git
cd cloud-native-stack/playbooks
```

Update the hosts file in playbooks directory with master and worker nodes(if you have) IP's with username and password like below

```
nano hosts

[master]
<master-IP> ansible_ssh_user=nvidia ansible_ssh_pass=nvidipass ansible_sudo_pass=nvidiapass ansible_ssh_common_args='-o StrictHostKeyChecking=no'
[node]
<worker-IP> ansible_ssh_user=nvidia ansible_ssh_pass=nvidiapass ansible_sudo_pass=nvidiapass ansible_ssh_common_args='-o StrictHostKeyChecking=no'
```

Install the NVIDIA Cloud Native Stack stack by running the below command. "Skipping" in the ansible output refers to the Kubernetes cluster is up and running.

```
bash setup.sh install
```
For more Information about customize the values, please refer [Installation](https://github.com/NVIDIA/cloud-native-stack/tree/master/playbooks#installation)

## NVIDIA Cloud Native Stack Component Matrix

| Branch/Release | Version | Initial Release Date   | Platform              | OS    | Containerd | CRI-O | K8s    | Helm  | NVIDIA GPU Operator | NVIDIA Network Operator | NVIDIA Data Center Driver |
| :---:   |    :------:        | :---:                  | :---:                 | :---: | :---:      | :----: |  :---: | :---:        | :---:            | :---:      | :---: |
| 24.8.0/master  | 13.1   | 20 August 2024 | NVIDIA Certified Server (x86 & arm64)  | Ubuntu 22.04 LTS             | 1.7.20 | 1.30.2 | 1.30.2 |  3.15.3 | 24.6.1   | 24.4.1(x86 only) | 550.90.07  |
| 24.8.0/master  | 13.1   | 20 August 2024 | NVIDIA Certified Server (x86 & arm64)  | RHEL 8.8                     | 1.7.20 | 1.30.2 | 1.30.2 |  3.15.3 | 24.6.1   | 24.4.1(x86 only)    | 550.90.07 |
| 24.8.0/master  | 13.1   | 20 August 2024 | DGX Server                             | DGX OS 6.2(Ubuntu 22.04 LTS) | 1.7.20 | 1.30.2 | 1.30.2 |  3.15.3 | 24.6.1   | N/A              | N/A |
|                |        |               |                               |                             |            |       |       |                  |            |                  |
| 24.8.0/master  | 12.2   | 20 August 2024 | NVIDIA Certified Server (x86 & arm64)  | Ubuntu 22.04 LTS             | 1.7.20 | 1.29.6 | 1.29.6 |  3.15.3 | 24.6.1   | 24.4.1(x86 only) | 550.90.07  |
| 24.8.0/master  | 12.2   | 20 August 2024 | NVIDIA Certified Server (x86 & arm64)  | RHEL 8.8                     | 1.7.20 | 1.29.6 | 1.29.6 |  3.15.3 | 24.6.1   | 24.4.1(x86 only)      | 550.90.07 |
| 24.8.0/master  | 12.2   | 20 August 2024 | DGX Server                             | DGX OS 6.2(Ubuntu 22.04 LTS) | 1.7.20 | 1.29.6 | 1.29.6 |  3.15.3 | 24.6.1   | N/A              | N/A |
|                |        |               |                               |                             |            |       |       |                  |       |                  |
| 24.8.0/masrer  | 11.3   | 20 August 2024 | NVIDIA Certified Server (x86 & arm64)  | Ubuntu 22.04 LTS             | 1.7.20 | 1.28.8 | 1.28.12 |  3.15.3 | 24.6.1   | 24.4.1(x86 only) | 550.90.07  |
| 24.8.0/master  | 11.3   | 20 August 2024 | NVIDIA Certified Server (x86 & arm64)  | RHEL 8.8                     | 1.7.20 | 1.28.8 | 1.28.12 |  3.15.3 | 24.6.1   | 24.4.1(x86 only)    | 550.90.07 |
| 24.8.0/master  | 11.3   | 20 August 2024 | DGX Server                             | DGX OS 6.2(Ubuntu 22.04 LTS) | 1.7.20 | 1.28.8 | 1.28.12 |  3.15.3 | 24.6.1   | N/A              | N/A |

To Find other CNS Release Information, please refer to [Cloud Native Stack Component Matrix](https://github.com/NVIDIA/cloud-native-stack/tree/24.5.0?tab=readme-ov-file#nvidia-cloud-native-stack-component-matrix-1)

`NOTE:` Above CNS versions are available on master branch as well but it's recommend to use specific branch with respective release 

# Cloud Native Stack Topologies

- Cloud Native Stack allows to deploy:
    - 1 node with both control plane and worker functionalities
    - 1 control plane node and any number of worker nodes

`NOTE:` (Cloud Native Stack does not allow the deployment of several control plane nodes)

# Cloud Native Stack Features

- Kubernetes with GPU Operator, Network Operator 
- [MicroK8s on CNS](https://github.com/NVIDIA/cloud-native-stack/tree/master/playbooks#enable-microk8s)
- [Installation on CSP's](https://github.com/NVIDIA/cloud-native-stack/tree/master/playbooks#installation-on-csps)
- [Storage on CNS](https://github.com/NVIDIA/cloud-native-stack/tree/master/playbooks#storage-on-cns)
- [Monitoring on CNS](https://github.com/NVIDIA/cloud-native-stack/tree/master/playbooks#monitoring-on-cns)
- [LoadBalancer on CNS](https://github.com/NVIDIA/cloud-native-stack/tree/master/playbooks#load-balancer-on-cns)
- [Kserve](https://github.com/NVIDIA/cloud-native-stack/tree/master/playbooks#enable-kserve-on-cns)

| Branch/Release | CNS Version  | Release Date   | Kserve | LoadBalancer | Storage  | Monitoring    |
| :---:          | :------:     | :---:                  | :---:  | :---:        | :---:    | :---:         | 
| 24.8.0/master  | 13.1 <br /> 12.2 <br /> 11.3   | 20 August 2024 | <br />  **0.13** <br /> <br /> <ul><li>Istio: 1.20.4</li><li>Knative: 1.13.1</li><li>CertManager: 1.9.0</li></ul>  | MetalLB: 0.14.5 |  NFS: 4.0.18 <br /> Local Path: 0.0.26 | Prometheus: 61.3.0 <br /> Elastic: 8.14.1 |


# Getting help or Providing feedback

Please open an [issue](https://github.com/NVIDIA/cloud-native-stack/issues) on the GitHub project for any questions. Your feedback is appreciated.

# Useful Links
- [NVIDIA LaunchPad](https://www.nvidia.com/en-us/data-center/launchpad/)
- [NVIDIA LaunchPad Labs](https://docs.nvidia.com/launchpad/index.html)
- [Cloud Native Stack on LaunchPad](https://docs.nvidia.com/LaunchPad/developer-labs/overview.html)
- [NVIDIA GPU Operator](https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/overview.html)
- [NVIDIA Network Operator](https://docs.nvidia.com/networking/display/COKAN10/Network+Operator)
- [NVIDIA Certified Systems](https://www.nvidia.com/en-us/data-center/products/certified-systems/)
- [NVIDIA GPU Cloud (NGC)](https://catalog.ngc.nvidia.com/)