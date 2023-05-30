# Cloud Guide for NVIDIA Cloud Native Stack 

This page describes the steps required to use Ansible Playbooks

## Following supported cloud environments

- EKS(Elastci Kubernetes Service)
- GKE(Google Kubernetes Engine)
- AKS(Azure Kubernetes Service) - In Progress

## Prerequisites

- For EKS on AWS 
    - [AWS IAM role](https://docs.aws.amazon.com/eks/latest/userguide/service_IAM_role.html) to create a EKS Cluster
    - Update the AWS key values in `aws_credentials` file
- For GKE on Google Cloud 
    - Kubernetes Engine Admin and Kubernetes Engine Cluster Admin Role


## Using the Ansible playbooks 
This section describes how to use the ansible playbooks.

### Clone the git repository

Run the below commands to clone the NVIDIA Cloud Native Stack ansible playbooks.

```
git clone https://github.com/NVIDIA/cloud-native-stack.git
cd cloud-native-stack/playbooks
```

### Installation

Edit the `csp_values.yaml` and update the required information

```
nano csp_values.yaml
```

If you want to cusomize any predefined components versions or any other custom paramenters, modify the respective CNS version values file like below and trigger the installation. 

Example:
```
$ nano csp_values.yaml

## Google cloud values
installon_gke: no
gke_cluster_name: gke-gpu-cluster
#https://cloud.google.com/resource-manager/docs/creating-managing-projects#identifying_projects
gke_project_id: 
# https://cloud.google.com/compute/docs/regions-zones#available
gke_zone: us-west1-a
gke_version: "1.25"
#https://console.cloud.google.com/networking/networks/
gke_network: default

##TODO
# https://developers.google.com/identity/protocols/oauth2/service-account
#cred_file: 

## AWS values
installon_eks: no
eks_cluster_name: eks-gpu
#https://cloud-images.ubuntu.com/aws-eks/ 
eks_ami: ami-000ec9ff4552093c1
eks_version: "1.25"
eks_region: us-west-1
instance_type: g4dn.xlarge

## Azure values
installon_aks: no
aks_cluster_name: aks-gpu-cluster
#https://learn.microsoft.com/en-us/azure/azure-portal/get-subscription-tenant-id
azure_account_name: 
#https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/manage-resource-groups-portal#list-resource-groups
azure_resource_group: 
azure_location: eastus
az_k8s_version: "1.25.6"
## TODO
# https://learn.microsoft.com/en-us/cli/azure/create-an-azure-service-principal-azure-cli#1-create-a-service-principal
#azure_sp_appId: 
#azure_sp_password:
#azure_tenant: 

```
`NOTE:` Please wait for a while to install Cloud Kubernetes Clusters 

Install the NVIDIA Cloud Native Stack stack by running the below command. "Skipping" in the ansible output refers to the Kubernetes cluster is up and running.
```
bash setup.sh install
```
 