# NVIDIA Cloud Native Core 

NVIDIA Cloud Native Core (formerly known as EGX Stack) is a collection of software to run cloud native workloads on NVIDIA GPUs. NVIDIA Cloud Native Core is based on Ubuntu, Kubernetes, Helm and the NVIDIA GPU and Network Operator.

Interested in deploying NVIDIA Cloud Native Core? This repository has [install guides](https://github.com/NVIDIA/cloud-native-core/tree/master/install-guides) for manual installations and [ansible playbooks](https://github.com/NVIDIA/cloud-native-core/tree/master/playbooks) for automated installations.

Interested in a pre-provisioned NVIDIA Cloud Native Core environment? [NVIDIA LaunchPad](https://www.nvidia.com/en-us/data-center/launchpad/) provides pre-provisioned environments so that you can quickly get started.

#### Getting help or Providing feedback

Please open an [issue](https://github.com/NVIDIA/cloud-native-core/issues) on the GitHub project for any questions. Your feedback is appreciated.

#### NVIDIA Cloud Native Core Component Matrix

| Version | Initial Release Date   | Platform              | OS    | Containerd | K8s    | Helm  | NVIDIA GPU Operator | NVIDIA Network Operator | NVIDIA Data Center Driver |
| :---:   |    :---:     | :---:                           | :---:  | :---:      | :---: | :---:        | :---:            | :---:      | :---: |
| 7.0     | 11 Jul 2022   | NVIDIA Certified Server (x86)  | Ubuntu 22.04 LTS            | 1.6.6 | 1.24.2 |  3.9.0 | 1.11.0       | 1.2.0            | 515.48.07   | 
| 7.0     | 11 Jul 2022   | Jetson NX                      | JetPack 5.0 JetPack 4.6.1   | 1.6.6 | 1.24.2 |  3.9.0 | N/A          | N/A              | N/A         |  
|         |                |                               |                             |            |       |       |                  |            |                  | 
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

#### Useful Links
- [NVIDIA LaunchPad](https://www.nvidia.com/en-us/data-center/launchpad/)
- [NVIDIA LaunchPad Labs](https://docs.nvidia.com/launchpad/index.html)
- [Cloud Native Core on LaunchPad](https://docs.nvidia.com/LaunchPad/developer-labs/overview.html)
- [NVIDIA GPU Operator](https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/overview.html)
- [NVIDIA Network Operator](https://docs.nvidia.com/networking/display/COKAN10/Network+Operator)
- [NVIDIA Certified Systems](https://www.nvidia.com/en-us/data-center/products/certified-systems/)
- [NVIDIA GPU Cloud (NGC)](https://catalog.ngc.nvidia.com/)

