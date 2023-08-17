# EKS(Elastic Kubernetes Service) with Cloud Native Stack

Amazon EKS is a managed Kubernetes service to run Kubernetes in the AWS cloud and on-premises data centers. NVIDIA Cloud Native Stack,  is a collection of software to run cloud native workloads on NVIDIA GPUs. is supported to run on EKS. In the cloud, Amazon EKS automatically manages the availability and scalability of the Kubernetes control plane nodes responsible for scheduling containers, managing application availability, storing cluster data, and other key tasks. This guide provides details for deploying and running NVIDIA Cloud Native Stack on EKS clusters with GPU Accelerated nodes.

## Prerequisites

- Install the [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- Install the [EKS CLI](https://docs.aws.amazon.com/eks/latest/userguide/eksctl.html)
- Install the [Helm](https://helm.sh/docs/intro/install/#from-script)
- [AWS IAM role](https://docs.aws.amazon.com/eks/latest/userguide/service_IAM_role.html) to create EKS Cluster 