# NVIDIA Cloud Native Stack

NVIDIA Cloud Native Stack (formerly known as Cloud Native Core) is a collection of software to run cloud native workloads on NVIDIA GPUs. NVIDIA Cloud Native Stack is based on Ubuntu, Kubernetes, Helm and the NVIDIA GPU and Network Operator.

Interested in deploying NVIDIA Cloud Native Stack? This repository has [install guides](https://github.com/NVIDIA/cloud-native-stack/tree/master/install-guides) for manual installations and [ansible playbooks](https://github.com/NVIDIA/cloud-native-stack/tree/master/playbooks) for automated installations.

Interested in a pre-provisioned NVIDIA Cloud Native Stack environment? [NVIDIA LaunchPad](https://www.nvidia.com/en-us/data-center/launchpad/) provides pre-provisioned environments so that you can quickly get started.

#### NVIDIA Cloud Native Stack Component Matrix

# NVIDIA Cloud Native Stack

NVIDIA Cloud Native Stack (formerly known as Cloud Native Core) is a collection of software to run cloud native workloads on NVIDIA GPUs. NVIDIA Cloud Native Stack is based on Ubuntu, Kubernetes, Helm and the NVIDIA GPU and Network Operator.

Interested in deploying NVIDIA Cloud Native Stack? This repository has [install guides](https://github.com/NVIDIA/cloud-native-stack/tree/master/install-guides) for manual installations and [ansible playbooks](https://github.com/NVIDIA/cloud-native-stack/tree/master/playbooks) for automated installations.

Interested in a pre-provisioned NVIDIA Cloud Native Stack environment? [NVIDIA LaunchPad](https://www.nvidia.com/en-us/data-center/launchpad/) provides pre-provisioned environments so that you can quickly get started.

#### NVIDIA Cloud Native Stack Component Matrix

| Branch/Release | Version | Initial Release Date   | Platform              | OS    | Containerd | CRI-O | K8s    | Helm  | NVIDIA GPU Operator | NVIDIA Network Operator | NVIDIA Data Center Driver |
| :---:   |    :------:        | :---:                  | :---:                 | :---: | :---:      | :----: |  :---: | :---:        | :---:            | :---:      | :---: |
| 23.12.0/master | 11.0   | 12 Dec  2023 | NVIDIA Certified Server (x86 & arm64)  | Ubuntu 22.04 LTS            | 1.7.7 | 1.28.1 | 1.28.2 |  3.13.1 | 23.9.1       | 23.10.0(x86 only)            | 535.129.03  |
| 23.12.0/master | 11.0   | 12 Dec  2023 | NVIDIA Certified Server (x86 & arm64)  | RHEL 8.8             | 1.7.7 | 1.28.1 | 1.28.2 |  3.13.1 | 23.9.1       | N/A            | 535.129.03 |
| 23.12.0/master | 11.0   | 12 Dec  2023 | Jetson Devices(AGX, NX, Orin)  | JetPack 5.1 and JetPack 5.0   | 1.7.7 | 1.28.1 | 1.28.2 |  3.13.1  | N/A         | N/A              | N/A         |
| 23.12.0/master | 11.0   | 12 Dec 2023  | DGX Server  | DGX OS 6.0(Ubuntu 22.04 LTS)        | 1.7.7 | 1.28.1 | 1.28.2 |  3.13.1 | 23.9.1       | N/A            | N/A |
|                |        |               |                               |                             |            |       |       |                  |            |                  |
| 23.12.0/master | 10.3   | 12 Dec 2023  | NVIDIA Certified Server (x86 & arm64)  | Ubuntu 22.04 LTS            | 1.7.7 | 1.27.1 | 1.27.6 |  3.13.1 | 23.9.1       | 23.10.0(x86 only)            | 535.129.03  |
| 23.12.0/master | 10.3   | 12 Dec 2023  | NVIDIA Certified Server (x86 & arm64)  | RHEL 8.8             | 1.7.7 | 1.27.1 | 1.27.6 |  3.13.1 | 23.9.1       | N/A            | 535.129.03 |
| 23.12.0/master | 10.3   | 12 Dec 2023  | Jetson Devices(AGX, NX, Orin)  | JetPack 5.1 and JetPack 5.0   | 1.7.7 | 1.27.1 | 1.27.6 |  3.13.1  | N/A         | N/A              | N/A         |
| 23.12.0/master | 10.3   | 12 Dec 2023  | DGX Server  | DGX OS 6.0(Ubuntu 22.04 LTS)        | 1.7.7 | 1.27.1 | 1.27.6 |  3.13.1 | 23.9.1       | N/A            | N/A |
| 23.12.0/23.8.0 | 10.2   | 17 Aug 2023  | NVIDIA Certified Server (x86 & arm64)  | Ubuntu 22.04 LTS            | 1.7.3 | 1.27.1 | 1.27.4 |  3.12.2 | 23.6.1       | 23.7.0(x86 only)            | 535.104.05  |
| 23.12.0/23.8.0 | 10.2   | 17 Aug 2023  | NVIDIA Certified Server (x86 & arm64)  | RHEL 8.7/RHEL 8.8             | 1.7.3 | 1.27.1 | 1.27.4 |  3.12.2 | 23.6.1       | N/A            | 535.104.05 |
| 23.12.0/23.8.0 | 10.2   | 17 Aug 2023  | Jetson Devices(AGX, NX, Orin)  | JetPack 5.1 and JetPack 5.0   | 1.7.3 | 1.27.1 | 1.27.4 |  3.12.2  | N/A         | N/A              | N/A         |
| 23.12.0/23.8.0 | 10.2   | 28 Sep 2023  | DGX Server  | DGX OS 6.0(Ubuntu 22.04 LTS)        | 1.7.3 | 1.27.1 | 1.27.4 |  3.12.2 | 23.6.1       | N/A            | N/A |
| 23.12.0/23.8.0 | 10.1   | 14 July 2023 | NVIDIA Certified Server (x86 & arm64)  | Ubuntu 22.04 LTS            | 1.7.2 | 1.27.0 | 1.27.2 |  3.12.1 | 23.3.2       | 23.5.0(x86 only)            | 535.54.03  |
| 23.12.0/23.8.0 | 10.1   | 14 July 2023 | NVIDIA Certified Server (x86 & arm64)  | RHEL 8.7             | 1.7.2 | 1.27.0 | 1.27.2 |  3.12.1 | 23.3.2       | N/A            | 525.105.17  |
| 23.12.0/23.8.0 | 10.0   | 1 May 2023   | Jetson Devices(AGX, NX, Orin)  | JetPack 5.1 and JetPack 5.0   | 1.7.2 | 1.27.2 | 1.27.0 |  3.12.1  | N/A         | N/A              | N/A         |
| 23.12.0/23.8.0 | 10.0   | 1 May 2023   | NVIDIA Certified Server (x86 & arm64)  | Ubuntu 22.04 LTS            | 1.7.0 | 1.27.0 | 1.27.0 |  3.11.2 | 23.3.1       | 23.1.0(x86 only)            | 525.105.17  |
| 23.12.0/23.8.0 | 10.0   | 1 May 2023   | NVIDIA Certified Server (x86 & arm64)  | RHEL 8.7             | 1.7.0 | 1.27.0 | 1.27.0 |  3.11.2 | 23.3.1       | N/A            | 525.105.17  |
| 23.12.0/23.8.0 | 10.0   | 1 May 2023   | Jetson Devices(AGX, NX, Orin)  | JetPack 5.1 and JetPack 5.0   | 1.7.0 | 1.27.0 | 1.27.0 |  3.11.2  | N/A         | N/A              | N/A         |
|         |                |                               |                             |            |       |       |                  |            |                  |
| 23.12.0/master | 9.4    | 12 Dec 2023  | NVIDIA Certified Server (x86 & arm64)  | Ubuntu 22.04 LTS            | 1.7.7 | 1.26.4 | 1.26.9 |  3.13.1 | 23.9.1       | 23.10.0(x86 only)            | 535.129.03  |
| 23.12.0/master | 9.4    | 12 Dec 2023  | Jetson Devices(AGX, NX, Orin)  | JetPack 5.1 and JetPack 5.0   | 1.7.7 | 1.26.4 | 1.26.9 | 3.13.1 | N/A         | N/A              | N/A         |
| 23.12.0/master | 9.4    | 12 Dec 2023  | DGX Server  | DGX OS 6.0(Ubuntu 22.04 LTS)          | 1.7.7 | 1.26.4 | 1.26.9 |  3.13.1 | 23.9.1       | N/A            | N/A  |
| 23.12.0/23.8.0 | 9.3    |  17 Aug 2023 | NVIDIA Certified Server (x86 & arm64)  | Ubuntu 22.04 LTS            | 1.7.3 | 1.26.4 | 1.26.7 |  3.12.2 | 23.6.1       | 23.7.0(x86 only)            | 535.104.05  |
| 23.12.0/23.8.0 | 9.3    |  17 Aug 2023 | Jetson Devices(AGX, NX, Orin)  | JetPack 5.1 and JetPack 5.0   | 1.7.3 | 1.26.4 | 1.26.7 | 3.12.2 | N/A         | N/A              | N/A         |
| 23.12.0/23.8.0 | 9.3    |  28 Sep 2023 | DGX Server  | DGX OS 6.0(Ubuntu 22.04 LTS)          | 1.7.3 | 1.26.4 | 1.26.7 |  3.12.2 | 23.6.1       | N/A            | N/A  |
| 23.12.0/23.8.0 | 9.2    | 14 July 2023 | NVIDIA Certified Server (x86 & arm64)  | Ubuntu 22.04 LTS            | 1.7.2 | 1.26.3 | 1.26.5 |  3.12.1 | 23.3.2       | 23.5.0(x86 only)            | 535.54.03  |
| 23.12.0/23.8.0 | 9.2    | 14 July 2023 | Jetson Devices(AGX, NX, Orin)  | JetPack 5.1 and JetPack 5.0   | 1.7.2 | 1.26.3 | 1.26.5 | 3.12.1 | N/A         | N/A              | N/A         |
| 23.12.0/23.8.0 | 9.1    | 1 May 2023   | NVIDIA Certified Server (x86 & arm64)  | Ubuntu 22.04 LTS            | 1.7.0 | 1.26.3 | 1.26.3 |  3.11.2 | 23.3.1       | 23.1.0(x86 only)            | 525.105.17  |
| 23.12.0/23.8.0 | 9.1    | 1 May 2023   | Jetson Devices(AGX, NX, Orin)  | JetPack 5.1 and JetPack 5.0   | 1.7.0 | 1.26.3 | 1.26.3 | 3.11.2 | N/A         | N/A              | N/A         |
| 23.12.0/23.8.0 | 9.0    | 28 Feb 2023  | NVIDIA Certified Server (x86 & arm64)  | Ubuntu 22.04 LTS            | 1.6.16 | 1.26.1 | 1.26.1 |  3.11.0 | 22.9.2       | 1.4.0(x86 only)            | 525.85.12  |
| 23.12.0/23.8.0 | 9.0    | 28 Feb 2023  | Jetson Devices(AGX, NX, Orin)  | JetPack 5.1 and JetPack 5.0   | 1.6.16 | 1.26.1 | 1.26.1 | 3.11.0 | N/A         | N/A              | N/A         |

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

> [!NOTE]
> Cloud Native Stack does not allow the deployment of several control plane nodes

#### Getting help or Providing feedback

Please open an [issue](https://github.com/NVIDIA/cloud-native-stack/issues) on the GitHub project for any questions. Your feedback is appreciated.

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

> [!NOTE]
> Cloud Native Stack does not allow the deployment of several control plane nodes

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
