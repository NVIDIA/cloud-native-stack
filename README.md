# NVIDIA Cloud Native Stack 

NVIDIA Cloud Native Stack (formerly known as Cloud Native Core) is a collection of software to run cloud native workloads on NVIDIA GPUs. NVIDIA Cloud Native Stack is based on Ubuntu, Kubernetes, Helm and the NVIDIA GPU and Network Operator.

Interested in deploying NVIDIA Cloud Native Stack? This repository has [install guides](https://github.com/NVIDIA/cloud-native-stack/tree/master/install-guides) for manual installations and [ansible playbooks](https://github.com/NVIDIA/cloud-native-stack/tree/master/playbooks) for automated installations.

Interested in a pre-provisioned NVIDIA Cloud Native Stack environment? [NVIDIA LaunchPad](https://www.nvidia.com/en-us/data-center/launchpad/) provides pre-provisioned environments so that you can quickly get started.

#### NVIDIA Cloud Native Stack Component Matrix

| Version | Initial Release Date   | Platform              | OS    | Containerd | K8s    | Helm  | NVIDIA GPU Operator | NVIDIA Network Operator | NVIDIA Data Center Driver |
| :---:   |    :---:     | :---:                           | :---:  | :---:      | :---: | :---:        | :---:            | :---:      | :---: |
| 8.1    | 15 Dec 2022   | NVIDIA Certified Server (x86 & arm64)  | Ubuntu 22.04 LTS            | 1.6.10 | 1.25.4 |  3.10.2 | 22.9.1       | 1.4.0(x86 only)            | 525.60.13  |
| 8.0     | 14 Oct 2022   | NVIDIA Certified Server (x86 & arm64)  | Ubuntu 22.04 LTS            | 1.6.8 | 1.25.2 |  3.10.0 | 22.9.0       | 1.3.0(x86 only)            | 520.61.07  |
|         |                |                               |                             |            |       |       |                  |            |                  | 
| 7.2    | 15 Dec 2022   | NVIDIA Certified Server (x86 & arm64)  | Ubuntu 20.04 LTS            | 1.6.10 | 1.24.8 |  3.10.2 | 22.9.1       | 1.4.0(x86 only)            | 525.60.13  |
| 7.1     | 14 Oct 2022   | NVIDIA Certified Server (x86 & arm64)  | Ubuntu 22.04 LTS            | 1.6.8 | 1.24.6 |  3.10.0 | 22.9.0       | 1.3.0(x86 only)            | 520.61.07  | 
| 7.0     | 11 Jul 2022   | NVIDIA Certified Server (x86)  | Ubuntu 22.04 LTS            | 1.6.6 | 1.24.2 |  3.9.0 | 1.11.0       | 1.2.0            | 515.48.07   | 
| 7.0     | 11 Jul 2022   | Jetson NX                      | JetPack 5.0 JetPack 4.6.1   | 1.6.6 | 1.24.2 |  3.9.0 | N/A          | N/A              | N/A         |  
|         |                |                               |                             |            |       |       |                  |            |                  | 
| 6.4    | 15 Dec 2022   | NVIDIA Certified Server (x86 & arm64)  | Ubuntu 20.04 LTS            | 1.6.10 | 1.23.12 |  3.10.2 | 22.9.1       | 1.4.0(x86 only)            | 525.60.13  |
| 6.3    | 14 Oct 2022   | NVIDIA Certified Server (x86 & arm64)  | Ubuntu 20.04 LTS            | 1.6.8 | 1.23.12 | 3.10.0 | 22.9.0       | 1.3.0(x86 only)            | 520.61.07  |
| 6.2     | 11 Jul 2022   | NVIDIA Certified Server (x86)  | Ubuntu 20.04 LTS            | 1.6.5 | 1.23.8 | 3.8.2 | 1.11.0       | 1.2.0            | 515.48.07  | 
| 6.2     | 11 Jul 2022   | Jetson NX                      | JetPack 5.0 JetPack 4.6.1   | 1.6.5 | 1.23.8 | 3.8.2 | N/A         | N/A              | N/A         |  
| 6.1     | 04 Apr 2022   | NVIDIA Certified Server (x86)  | Ubuntu 20.04 LTS            | 1.6.2 | 1.23.5 | 3.8.1 | 1.10.1      | 1.1.0            | 510.47.03 | 
| 6.1     | 04 Apr 2022   | Jetson NX                      | JetPack 4.6.1 JetPack 4.5.1 | 1.6.2 | 1.23.5 | 3.8.1 | N/A         | N/A              | N/A         |    
| 6.0     | 18 Mar 2022   | NVIDIA Certified Server (x86)  | Ubuntu 20.04 LTS            | 1.6.0 | 1.23.3 | 3.8.0 | 1.9.1       | 1.1.0            | 510.47.03     |  
| 6.0     | 18 Mar 2022   | Jetson NX                      | JetPack 4.6.1 JetPack 4.5.1 | 1.6.0 | 1.23.3 | 3.8.0 | N/A         | N/A              | N/A         | 
|         |               |                                |        |            |       |                |                  |            |                 | 
| 5.2     | 19 May 2022   | NVIDIA Certified Server (x86)  | Ubuntu 20.04 LTS            | 1.4.9 |1.22.5  | 3.8.2 | 1.10.1       | 1.1.0            | 510.47.03 | 
| 5.1     | 04 Apr 2022   | NVIDIA Certified Server (x86)  | Ubuntu 20.04 LTS            | 1.4.9 | 1.22.5 | 3.6.3 | 1.10.1       | 1.1.0            | 470.103.01  | 
| 5.0     | 18 Mar 2022  | NVIDIA Certified Server(x86)    | Ubuntu 20.04 LTS            | 1.4.9 | 1.22.5 | 3.6.3  | 1.9.1        | 1.1.0            | 470.103.01 |  
| 5.0     | 18 Mar 2022   | Jetson NX                      | JetPack 4.5.1               | 1.4.9 |1.22.5  | 3.6.3 | N/A          | N/A              | N/A     |

#### Cloud Native Stack Prerequisites

- system has direct internet access
- system has adequate internet bandWidth
- DNS server is working fine on the System
- system can access Google repo(for k8s installation)
- system has only 1 network interface configured with internet access. The IP is static and doesn't change
- UEFI secure boot is disabled
- Root file system should has at least 40GB capacity
- system has 4CPU and 8GB Memory
- At least one NVIDIA GPU attached to the system

#### Cloud Native Stack Limitations

- Cloud Native Stack allows to deploy:
    - 1 node with both control plane and worker functionalities
    - 1 control plane node and any number of worker nodes

`NOTE:` (Cloud Native Stack does not allow the deployment of several control plane nodes)

#### Getting help or Providing feedback

Please open an [issue](https://github.com/NVIDIA/cloud-native-stack/issues) on the GitHub project for any questions. Your feedback is appreciated.

#### Useful Links
- [NVIDIA LaunchPad](https://www.nvidia.com/en-us/data-center/launchpad/)
- [NVIDIA LaunchPad Labs](https://docs.nvidia.com/launchpad/index.html)
- [Cloud Native Stack on LaunchPad](https://docs.nvidia.com/LaunchPad/developer-labs/overview.html)
- [NVIDIA GPU Operator](https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/overview.html)
- [NVIDIA Network Operator](https://docs.nvidia.com/networking/display/COKAN10/Network+Operator)
- [NVIDIA Certified Systems](https://www.nvidia.com/en-us/data-center/products/certified-systems/)
- [NVIDIA GPU Cloud (NGC)](https://catalog.ngc.nvidia.com/)
