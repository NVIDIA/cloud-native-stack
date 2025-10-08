# Ansible Playbooks for NVIDIA Cloud Native Stack

This page describes the steps required to use Ansible to install the NVIDIA Cloud Native Stack.

### The following Ansible Playbooks are available

- [Install NVIDIA Cloud Native Stack](https://github.com/NVIDIA/cloud-native-stack/blob/master/playbooks/cns-installation.yaml)

- [Upgrade NVIDIA Cloud Native Stack ](https://github.com/NVIDIA/cloud-native-stack/blob/master/playbooks/cns-upgrade.yaml)

- [Validate NVIDIA Cloud Native Stack ](https://github.com/NVIDIA/cloud-native-stack/blob/master/playbooks/cns-validation.yaml)

- [Uninstall NVIDIA Cloud Native Stack](https://github.com/NVIDIA/cloud-native-stack/blob/master/playbooks/cns-uninstall.yaml)

## Prerequisites

- system has direct internet access
- system should have an Operating system either Ubuntu 20.04 and above or RHEL 8.7
- system has adequate internet bandWidth
- DNS server is working fine on the System
- system can access Google repo(for k8s installation)
- system has only 1 network interface configured with internet access. The IP is static and doesn't change
- UEFI secure boot is disabled
- Root file system should has at least 40GB capacity
- system has 4CPU and 8GB Memory
- At least one NVIDIA GPU attached to the system

## Systems support 
The following systems are support for Cloud Native Stack:

- You have [NVIDIA-Certified Systems](https://docs.nvidia.com/ngc/ngc-deploy-on-premises/nvidia-certified-systems/index.html) with Mellanox CX NICs for x86-64 servers 
- You have [NVIDIA Qualified Systems](https://www.nvidia.com/en-us/data-center/data-center-gpus/qualified-system-catalog/?start=0&count=50&pageNumber=1&filters=eyJmaWx0ZXJzIjpbXSwic3ViRmlsdGVycyI6eyJwcm9jZXNzb3JUeXBlIjpbIkFSTS1UaHVuZGVyWDIiLCJBUk0tQWx0cmEiXX0sImNlcnRpZmllZEZpbHRlcnMiOnt9LCJwYXlsb2FkIjpbXX0=) for arm64 servers 
  `NOTE:` For ARM systems, NVIDIA Network Operator is not supported yet. 
- You have [NVIDIA Jetson Systems](https://www.nvidia.com/en-us/autonomous-machines/embedded-systems/)

To determine if your system qualifies as an NVIDIA Certified System, review the list of NVIDIA Certified Systems [here](https://docs.nvidia.com/ngc/ngc-deploy-on-premises/nvidia-certified-systems/index.html). 

Please note that NVIDIA Cloud Native Stack is validated only on systems with the default kernel (not HWE).

### Installing the Ubuntu Operating System
These instructions require Ubuntu server please reference the [Ubuntu Server Installation Guide](https://ubuntu.com/tutorials/tutorial-install-ubuntu-server#1-overview).

### Installing JetPack for Jetson 

JetPack (the Jetson SDK) is an on-demand all-in-one package that bundles developer software for the NVIDIA® Jetson platform. There are two ways to install the JetPack 

1. Use the SDK Manager installer to flash your Jetson Developer Kit with the latest OS image, install developer tools for both host PC and Developer Kit, and install the libraries and APIs, samples, and documentation needed to jump-start your development environment.

Follow the [instructions](https://docs.nvidia.com/sdk-manager/install-with-sdkm-jetson/index.html) on how to install JetPack 5.0There are two ways to install the JetPack 

Download the SDK Manager from [here](https://developer.nvidia.com/nvidia-sdk-manager)

2. Use the SD Card Image method to download the JetPack and load the OS image to external drive. For more information, please refer [flash using SD Card method](https://developer.nvidia.com/embedded/learn/get-started-jetson-xavier-nx-devkit#prepare)

## Using the Ansible playbooks 
This section describes how to use the ansible playbooks.

### Clone the git repository

Run the below commands to clone the NVIDIA Cloud Native Stack ansible playbooks.

```
git clone https://github.com/NVIDIA/cloud-native-stack.git
cd cloud-native-stack/playbooks
```

Update the hosts file in playbooks directory with master and worker nodes(if you have) IP's with username and password like below

```
nano hosts

[master]
10.110.16.178 ansible_ssh_user=nvidia ansible_ssh_pass=nvidipass ansible_sudo_pass=nvidiapass ansible_ssh_common_args='-o StrictHostKeyChecking=no'
[node]
10.110.16.179 ansible_ssh_user=nvidia ansible_ssh_pass=nvidiapass ansible_sudo_pass=nvidiapass ansible_ssh_common_args='-o StrictHostKeyChecking=no'
```

## Installation
Cloud Native Stack Supports below versions.

Available versions are:

- 16.0 (Ubuntu 24.04)
- 15.1 (Ubuntu 24.04)
- 15.0 (Ubuntu 24.04)
- 14.2
- 14.1
- 14.0

Edit the `cns_version.yaml` and update the version you want to install

```
nano cns_version.yaml
```

If you want to cusomize any predefined components versions or any other custom paramenters, modify the respective CNS version values file like below and trigger the installation. 

Example:
```
$ nano cns_values_15.1.yaml
cns_version: 15.1

## MicroK8s cluster
microk8s: no
## Kubernetes Install with Kubeadm
install_k8s: yes

## Components Versions
# Container Runtime options are containerd, cri-o, cri-dockerd
container_runtime: "containerd"
containerd_version: "2.1.3"
runc_version: "1.3.0"
cni_plugins_version: "1.7.1"
containerd_max_concurrent_downloads: "5"
nvidia_container_toolkit_version: "1.17.8"
crio_version: "1.32.6"
cri_dockerd_version: "0.3.18"
k8s_version: "1.32.6"
calico_version: "3.30.2"
flannel_version: "0.25.6"
helm_version: "3.18.3"
gpu_operator_version: "25.3.1"
network_operator_version: "25.4.0"
nim_operator_version: "2.0.1"
nsight_operator_version: "1.1.2"
local_path_provisioner: "0.0.31"
nfs_provisioner: "4.0.18"
metallb_version: "0.15.2"
kserve_version: "0.15"
prometheus_stack: "75.9.0"
prometheus_adapter: "4.15.1"
grafana_operator: "v5.18.0"
elastic_stack: "9.0.0"
lws_version: "0.6.2"

# GPU Operator Values
enable_gpu_operator: yes
confidential_computing: no
gpu_driver_version: "570.158.01"
use_open_kernel_module: no
enable_mig: no
mig_profile: all-disabled
mig_strategy: single
# To use GDS, use_open_kernel_module needs to be enabled
enable_gds: no
#Secure Boot for only Ubuntu
enable_secure_boot: no
enable_cdi: no
enable_vgpu: no
vgpu_license_server: ""
# URL of Helm repo to be added. If using NGC get this from the fetch command in the console
helm_repository: "https://helm.ngc.nvidia.com/nvidia"
# Name of the helm chart to be deployed
gpu_operator_helm_chart: nvidia/gpu-operator
## This is most likely GPU Operator Driver Registry
gpu_operator_driver_registry: "nvcr.io/nvidia"

# NGC Values
## If using a private/protected registry. NGC API Key. Leave blank for public registries
ngc_registry_password: ""
## This is most likely an NGC email
ngc_registry_email: ""
ngc_registry_username: "$oauthtoken"

# Network Operator Values
## If the Network Operator is yes then make sure enable_rdma as well yes
enable_network_operator: no
## Enable RDMA yes for NVIDIA Certification
enable_rdma: no
## Enable for MLNX-OFED Driver Deployment
deploy_ofed: no

# Prxoy Configuration
proxy: no
http_proxy: ""
https_proxy: ""

# Cloud Native Stack for Developers Values
## Enable for Cloud Native Stack Developers
cns_docker: no
## Enable For Cloud Native Stack Developers with TRD Driver
cns_nvidia_driver: no
nvidia_driver_mig: no

## Kubernetes resources
k8s_apt_key: "https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key"
k8s_gpg_key: "https://pkgs.k8s.io/core:/stable:/v1.32/rpm/repodata/repomd.xml.key"
k8s_apt_ring: "/etc/apt/keyrings/kubernetes-apt-keyring.gpg"
k8s_registry: "registry.k8s.io"

# Enable NVIDIA NSight Operator
enable_nsight_operator: no

# Install NVIDIA NIM Operator
enable_nim_operator: no

# LeaderWorkerSet https://github.com/kubernetes-sigs/lws/tree/main
lws: no

# Local Path Provisioner and NFS Provisoner as Storage option
storage: no

# Monitoring Stack Prometheus/Grafana with GPU Metrics and Elastic Logging stack
monitoring: no

# Enable Kserve on Cloud Native Stack with Istio and Cert-Manager
kserve: no

# Install MetalLB
loadbalancer: no
# Example input loadbalancer_ip: "10.78.17.85/32"
loadbalancer_ip: ""

## Cloud Native Stack Validation
cns_validation: no

# BMC Details for Confidential Computing
bmc_ip:
bmc_username:
bmc_password:

# CSP values
## AWS EKS values
aws_region: us-east-2
aws_cluster_name: cns-cluster-1
aws_gpu_instance_type: g4dn.2xlarge

## Google Cloud GKE Values
#https://cloud.google.com/resource-manager/docs/creating-managing-projects#identifying_projects
gke_project_id:
#https://cloud.google.com/compute/docs/regions-zones#available
gke_region: us-west1
gke_node_zones: ["us-west1-b"]
gke_cluster_name: gke-cluster-1

## Azure AKS Values
aks_cluster_name: aks-cluster-1
#https://azure.microsoft.com/en-us/explore/global-infrastructure/geographies/#geographies
aks_cluster_location: "West US 2"
#https://learn.microsoft.com/en-us/partner-center/marketplace/find-tenant-object-id
azure_object_id: [""]
```

Install the NVIDIA Cloud Native Stack stack by running the below command. "Skipping" in the ansible output refers to the Kubernetes cluster is up and running.
```
bash setup.sh install
```
`NOTE:` When you trigger the installation on DGX System you need to click `Enter/Return` command when you see `Restarting Services`

### Custom Configuration
By default Cloud Native Stack uses Google kubernetes apt repository, if you want to use any other kubernetes apt repository, please adjust the `k8s_apt_key` and `k8s_apt_repository` in `cns_values_<version>.yaml`.

Example:
```

## Kubernetes apt resources
k8s_apt_key: "https://mirrors.aliyun.com/kubernetes/apt/doc/apt-key.gpg"
k8s_apt_repository: "deb https://mirrors.aliyun.com/kubernetes/apt/ kubernetes-xenial main"
k8s_registry: "registry.aliyuncs.com/google_containers"
```

#### Enable Feature Gates to Cloud Native Stack

`NOTE:` Below config only works with CNS version 16.0 and above which is kubernetes 1.33 and above. 

Update the `templates/kubeadm-init-config.template` with feature gates like below and trigger the installation

```
apiVersion: kubeadm.k8s.io/v1beta4
kind: InitConfiguration
nodeRegistration:
  criSocket: "{{ cri_socket }}"
localAPIEndpoint:
  advertiseAddress: "{{ network.stdout_lines[0] }}"
---
apiVersion: kubeadm.k8s.io/v1beta4
kind: ClusterConfiguration
apiServer:
  extraArgs:
  - name: "feature-gates"
    value: "DynamicResourceAllocation=true"
  - name: "runtime-config"
    value: "resource.k8s.io/v1beta1=true"
  - name: "runtime-config"
    value: "resource.k8s.io/v1beta2=true"
controllerManager:
  extraArgs:
  - name: "feature-gates"
    value: "DynamicResourceAllocation=true"
scheduler:
  extraArgs:
  - name: "feature-gates"
    value: "DynamicResourceAllocation=true"
networking:
  podSubnet: "{{ subnet }}"
kubernetesVersion: "v{{ k8s_version }}"
imageRepository: "{{ k8s_registry }}"
---
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
featureGates:
  DynamicResourceAllocation: true
```
Run the below commands to enable DRA FeatureGates on existing Kubernetes Cluster with Kubernetes v1.33 or newer. 

```sh
sudo sed -i 's/- kube-apiserver/- kube-apiserver\n    - --feature-gates=DynamicResourceAllocation=true\n    - --runtime-config=resource.k8s.io\/v1beta1=true\n    - --runtime-config=resource.k8s.io\/v1beta2=true/' /etc/kubernetes/manifests/kube-apiserver.yaml

sudo sed -i 's/- kube-scheduler/- kube-scheduler\n    - --feature-gates=DynamicResourceAllocation=true/' /etc/kubernetes/manifests/kube-scheduler.yaml
         
sudo sed -i 's/- kube-controller-manager/- kube-controller-manager\n    - --feature-gates=DynamicResourceAllocation=true/' /etc/kubernetes/manifests/kube-controller-manager.yaml
         
sudo sed -i '$a\'$'\n''featureGates:\n  DynamicResourceAllocation: true' /var/lib/kubelet/config.yaml 
         
sudo systemctl daemon-reload; sudo systemctl restart kubelet
```

Run the below command to verify if the features is enabled 

```
kubectl get --raw /metrics  | grep kubernetes_feature_enabled  | grep -i DynamicResourceAllocation
```

If you're planning to enable DRA, then it's recommended to enable CDI with GPU Operator. Set the flag as per below

Example:
```
$ nano cns_values_15.1.yaml

cns_version: 15.1

enable_cdi: yes
```

## Enable NIM Operator

If you wnt to enable NIM Operator on Cloud Native Stack, you can enable the configuration in `cns_values_xx.yaml` and trigger the installation

Example:
```
$ nano cns_values_15.1.yaml

cns_version: 15.1

enable_nim_operator: yes
```
For more information, Refer [NIM Operator](https://docs.nvidia.com/nim-operator/latest/index.html)

## Enable Nsight Operator

If you wnt to enable Nsight Operator on Cloud Native Stack, you can enable the configuration in `cns_values_xx.yaml` and trigger the installation

Example:
```
$ nano cns_values_15.1.yaml

cns_version: 15.1

enable_nsight_operator: yes
```
For more information, Refer [Nsight Operator](https://catalog.ngc.nvidia.com/orgs/nvidia/teams/devtools/helm-charts/nsight-operator)

### Enable MicroK8s 

If you want to use microk8s you can enable the configuration in `cns_values_xx.yaml` and trigger the installation

Example:
```
$ nano cns_values_15.1.yaml

cns_version: 15.1

microk8s: yes
```

### Enable LeaderWorkerSet 

If you want to use LWS you can enable the configuration in `cns_values_xx.yaml` and trigger the installation

Example:
```
$ nano cns_values_15.1.yaml

cns_version: 15.1

lws: yes
```
For more information, Refer [LeaderWorkerSet](https://github.com/kubernetes-sigs/lws/tree/main). Examples can be found [here](https://github.com/kubernetes-sigs/lws/blob/main/docs/examples/sample/README.md)

### Enable Kserve on CNS

If you want to use Kserve on CNS, you can enable the configuration in `cns_values_xx.yaml` and trigger the installation

`NOTE:` It's recommned to enable the [loadbalancer](#load-balancer-on-cns), [storage](#storage-on-cns) and [monitoring](#monitoring-on-cns) option as `yes` in `cns_values_xx.yaml` for Kserve 

Example: 
```
nano cns_values_15.1.yaml

# Local Path Provisioner and NFS Provisoner as Storage option
storage: yes

# Monitoring Stack Prometheus/Grafana with GPU Metrics and Elastic Logging stack
monitoring: yes

# Enable Kserve on Cloud Native Stack with Istio and Cert-Manager
kserve: yes

# Install MetalLB
loadbalancer: yes
# Example input loadbalancer_ip: "10.117.20.50/32", , it could be system IP
loadbalancer_ip: "10.110.10.2/32"
```

For more information please refer [Kserve](https://github.com/kserve/kserve)

#### Kserve Validation

`NOTE:` This will create a Inference Resources on the cluster, please cleanup once you're done with Validation

##### Example: Deploying Sample Application  

First, create a namespace to use for deploying KServe resources:

```
kubectl create namespace kserve-test
```

Create Inference Service

```
kubectl apply -n kserve-test -f - <<EOF
apiVersion: "serving.kserve.io/v1beta1"
kind: "InferenceService"
metadata:
  name: "sklearn-iris"
spec:
  predictor:
    model:
      modelFormat:
        name: sklearn
      storageUri: "gs://kfserving-examples/models/sklearn/1.0/model"
EOF
```
Please wait a minute to create the Inference Service and check the status 

```
kubectl get inferenceservices sklearn-iris -n kserve-test
```

Expected OutPut:

```
NAME           URL                                                 READY   PREV   LATEST   PREVROLLEDOUTREVISION   LATESTREADYREVISION                    AGE
sklearn-iris   http://sklearn-iris.kserve-test.example.com         True           100                              sklearn-iris-predictor-default-47q2g   23h
```

Determine the ingress IP and ports

```
kubectl get svc istio-ingressgateway -n istio-system
```

If the EXTERNAL-IP value is set, your environment has an external load balancer that you can use for the ingress gateway.

```
export INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].port}')
```

If Load Balancer is not enabled on Cloud Native Stack, you can access the gateway using the service’s node port.
```
export INGRESS_HOST=$(kubectl get po -l istio=ingressgateway -n istio-system -o jsonpath='{.items[0].status.hostIP}')
export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')
```

Create the Inference Input Request File

```
cat <<EOF > "./iris-input.json"
{
  "instances": [
    [6.8,  2.8,  4.8,  1.4],
    [6.0,  3.4,  4.5,  1.6]
  ]
}
EOF
```
Run curl with the ingress gateway external IP using the HOST Header.

```
SERVICE_HOSTNAME=$(kubectl get inferenceservice sklearn-iris -n kserve-test -o jsonpath='{.status.url}' | cut -d "/" -f 3)
curl -H "Host: ${SERVICE_HOSTNAME}" -H "Content-Type: application/json" "http://${INGRESS_HOST}:${INGRESS_PORT}/v1/models/sklearn-iris:predict" -d @./iris-input.json
```

Expected Output:
```
{"predictions": [1, 1]}
```

Cleanup:
```
kubectl delete inferenceservices sklearn-iris -n kserve-test
```

For more infomration about sample validation, Please refer [here](https://kserve.github.io/website/0.12/get_started/first_isvc/)

##### Example: Deploying NIM on top of KServe

1. Execute the below command to create `kserve-nim.yaml` 

  ```
  cat <<EOF | tee kserve-nim.yaml
  apiVersion: v1
  kind: Secret
  metadata:
    name: nvidia-nim-secrets
  data:
    HF_TOKEN: \${HF_TOKEN}
    NGC_API_KEY: \${NGC_API_KEY}
  type: Opaque
  ---
  apiVersion: v1
  kind: PersistentVolumeClaim
  metadata:
    name: nvidia-nim-pvc
  spec:
    accessModes:
      - ReadWriteMany
    storageClassName: nfs-client
    resources:
      requests:
        storage: 200G
  ---
  apiVersion: serving.kserve.io/v1alpha1
  kind: ClusterServingRuntime
  metadata:
    name: nvidia-nim-llama3-8b-instruct-24.05
  spec:
    annotations:
      prometheus.kserve.io/path: /metrics
      prometheus.kserve.io/port: "8000"
      serving.kserve.io/enable-metric-aggregation: "true"
      serving.kserve.io/enable-prometheus-scraping: "true"
    containers:
    - env:
      - name: NIM_CACHE_PATH
        value: /opt/nim/.cache
      - name: HF_TOKEN
        valueFrom:
          secretKeyRef:
            name: nvidia-nim-secrets
            key: HF_TOKEN
      - name: NGC_API_KEY
        valueFrom:
          secretKeyRef:
            name: nvidia-nim-secrets
            key: NGC_API_KEY
      image: nvcr.io/nim/meta/llama3-8b-instruct:1.0.0
      name: kserve-container
      ports:
      - containerPort: 8000
        protocol: TCP
      volumeMounts:
      - mountPath: /dev/shm
        name: dshm
    imagePullSecrets:
    - name: ngc-secret
    protocolVersions:
    - v2
    - grpc-v2
    supportedModelFormats:
    - autoSelect: true
      name: nvidia-nim-llama3-8b-instruct
      priority: 1
      version: "24.05"
    volumes:
    - emptyDir:
        medium: Memory
        sizeLimit: 16Gi
      name: dshm
  ---
  apiVersion: serving.kserve.io/v1beta1
  kind: InferenceService
  metadata:
    annotations:
      autoscaling.knative.dev/target: "10"
    name: llama3-8b-instruct-1xgpu
  spec:
    predictor:
      minReplicas: 1
      model:
        modelFormat:
          name: nvidia-nim-llama3-8b-instruct
        resources:
          limits:
            nvidia.com/gpu: "1"
          requests:
            nvidia.com/gpu: "1"
        runtime: nvidia-nim-llama3-8b-instruct-24.05
        storageUri: pvc://nvidia-nim-pvc/
  EOF
  ```

2. Run the below command to update the Knative configuration. 

  ```
  kubectl patch configmap config-features -n knative-serving --type merge -p '{"data":{"kubernetes.podspec-nodeselector":"enabled"}}'
  ```

3. Export the `NGC_API_KEY` and `HF_TOKEN` values. 
  
  Follow the steps to get 

  - [NGC API KEY](https://docs.nvidia.com/ngc/gpu-cloud/ngc-private-registry-user-guide/index.html#generating-api-key)
  - [HF TOKEN](https://huggingface.co/docs/hub/en/security-tokens#user-access-tokens)
  ```
  export NGC_API_KEY=
  export HF_TOKEN=
  ```
4. Run the below commands to create secrets and NIM with kserve. 

  ```
  kubectl create secret docker-registry ngc-secret \
  --docker-server=nvcr.io \
  --docker-username='$oauthtoken' \
  --docker-password=${NGC_API_KEY}
  ```

  ```
  HF_TOKEN_BASE64=$(echo -n "$HF_TOKEN" | base64 -w0)
  NGC_API_KEY_BASE64=$(echo -n "$NGC_API_KEY" | base64 -w0)
  ```

  ```
  sed -e "s|\${HF_TOKEN}|${HF_TOKEN_BASE64}|g" -e "s|\${NGC_API_KEY}|${NGC_API_KEY_BASE64}|g" kserve-nim.yaml | kubectl apply -f -
  ```

Please refer [NIM-Deploy](https://github.com/NVIDIA/nim-deploy/tree/main/kserve) to know more about NIM's on KServe. 

###### Check NIM Deployment

Exccute the below commands to check the status of the deployment 

```
kubectl get inferenceservice
```
Example Output:
```
NAME                      URL                                                  READY     PREV  LATEST  PREVROLLEDOUTREVISION  LATESTREADYREVISION            AGE
llama3-8b-instruct-1xgpu  http://llama3-8b-instruct-1xgpu.default.example.com  True      100               llama3-8b-instruct-1xgpu-predictor-00001  5m2s
```

```
kubectl get pod
```
Example Output:
```
NAME                                                             READY  STATUS  RESTARTS  AGE
llama3-8b-instruct-1xgpu-predictor-00001-deployment-5574b67xmvw  2/2    Running  0        4m30s
```

###### NIM with Kserve Validation

Execute the below commands to export Inference, Ingress host and port details

  ```
  SERVICE_HOSTNAME=$(kubectl get inferenceservice llama3-8b-instruct-1xgpu -o jsonpath='{.status.url}' | cut -d "/" -f 3)
  export INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
  export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].port}')
  ```

Run the below command to find the available models

  ```
  curl -X 'GET' \
      -H "Host: ${SERVICE_HOSTNAME}" \
      "http://${INGRESS_HOST}:${INGRESS_PORT}/v1/models" \
      -H 'accept: application/json' \
      -H 'Content-Type: application/json'
  ```

Run the below command to get the response from Inference. 

  ```
  curl -X 'POST' \
      -H "Host: ${SERVICE_HOSTNAME}" \
      "http://${INGRESS_HOST}:${INGRESS_PORT}/v1/completions" \
      -H 'accept: application/json' \
      -H 'Content-Type: application/json' \
      -d '{
  "model": "meta/llama3-8b-instruct",
  "prompt": "Once upon a time",
  "max_tokens": 64
  }'
  ```


### Monitoring on CNS

Deploy Prometheus/Grafan and Elastic Logging stack on Cloud Native Stack

You need to enable `monitoring` in the `cns_values_xx.yaml` like below
```
# Monitoring Stack Prometheus/Grafana with GPU Metrics and Elastic Logging stack
monitoring: no
```
Once stack is install access the Grafana with url `http://<node-ip>:32222` with credentials as `admin/cns-stack`

Once stack is install access the Kibana with url `http://<node-ip>:32221` with credentials as `elastic/cns-stack`

### Storage on CNS

Deploy Storage Provisoner and NFS Provisioner on Cloud Native Stack. 
- It will deply [Local Path Provisoner](https://github.com/rancher/local-path-provisioner?tab=readme-ov-file#local-path-provisioner)
- It will deploy [NFS Provisioner](https://github.com/kubernetes-sigs/nfs-subdir-external-provisioner)

You need to enable `storage` in the `cns_values_xx.yaml` like below
```
# Local Path Provisioner and NFS Provisoner as Storage option
storage: no
```

### Load Balancer on CNS

Deploy Load Balancer using NodeIP on Cloud Native Stack, it will deploy [MetalLB](https://metallb.universe.tf/installation/#installation-by-manifest)

You need to enable `loadbalancer` option in the `cns_values_xx.yaml` like below 
```
# Install MetalLB
loadbalancer: no
# Example input loadbalancer_ip: "10.117.20.50/32", it could be node/host IP
loadbalancer_ip: ""
```

### Installation on CSP's

Cloud Native Stack can also support to install on CSP providers like AWS, Azure and Google Cloud. 

###### AWS
  Run below command to create AWS EKS cluster and install GPU Operator on EKS

  `NOTE:` Update the aws credentials in `files/aws_credentials` file before trigger the installation
  
  Update the AWS EKS values in the `cns_values_xx.yaml` before trigger the installation if needed.

  ```
  ## AWS EKS values
  aws_region: us-east-2
  aws_cluster_name: cns-cluster-1
  aws_gpu_instance_type: g4dn.2xlarge
  ```

  ```
  bash setup.sh install eks
  ```
###### Azure
Run below command to create Azure AKS cluster and install GPU Operator on AKS

Update Azure Object ID's on `cns_values_xx.yaml` before trigger the installation

  ```
  ## Azure AKS Values
  aks_cluster_name: cns-cluster-1
  aks_cluster_location: "West US 2"
  #https://learn.microsoft.com/en-us/partner-center/marketplace/find-tenant-object-id
  azure_object_id: [""]
  ```

  ```
  bash setup.sh install aks
  ```
###### Google cloud
Run below command to create Google Cloud GKE cluster and install GPU Operator on GKE 

Update the GKE Project ID `cns_values_xx.yaml` before trigger the installation
  ```
  ## Google Cloud GKE Values
  #https://cloud.google.com/resource-manager/docs/creating-managing-projects#identifying_projects
  gke_project_id: 
  #https://cloud.google.com/compute/docs/regions-zones#available
  gke_region: us-west1
  gke_node_zones: ["us-west1-b"]
  gke_cluster_name: cns-cluster-1
  ```

  ```
  bash setup.sh install gke
  ```

`NOTE:`

- After GKE cluster created run the below command to use kubectl library

      ```
      source $HOME/cloud-native-stack/playbooks/google-cloud-sdk/path.bash.inc
      ```

- If you encounter any destroy issue while uninstall you can try to run below commands which might help

      ```
      NS=`kubectl get ns |grep Terminating | awk 'NR==1 {print $1}'` && kubectl get namespace "$NS" -o json   | tr -d "\n" | sed "s/\"finalizers\": \[[^]]\+\]/\"finalizers\": []/"   | kubectl replace --raw /api/v1/namespaces/$NS/finalize -f -
      ```

      ```
      cd nvidia-terraform-modules/aks
      terraform destroy --auto-approve
      ```
###  Confidential Computing on CNS stack 

You can install Cloud Native Stack with Confidentail Computing, run the below command to trigger the installation

You need add the `cns_values_xx.yaml` with BMC details like below 
```
# BMC Details for Confidential Computing 
bmc_ip:
bmc_username:
bmc_password:
```
Run the below command to change the BIOS configuration and Install SNP Kernel for Confidential computing and system will eventually reboot

```
bash setup.sh install cc
```
Once it's rebooted then run the below command to install the Cloud Native Stack with Confidentail Computing.

```
bash setup.sh install
```
`NOTE:` 
  - If you want to re use the system It's recommended to re install the Operating system after used for Confidential Computing installation.
  - Currently playbooks supports only local system for confidential computing not supported for remote system installation. 

### Validation

Run the below command to check if the installed versions are match with predefined versions of the NVIDIA Cloud Native Stack. Here' "Ignored" tasks refer to failed and "Changed/Ok" tasks refer to success.

Run the validation playbook after 5 minutes once completing the NVIDIA Cloud Native Stack Installation. Depends on your internet speed, you need to wait more time.

```
bash setup.sh validate
```
### Upgrade 

Cloud Native Stack can be support life cycle management with upgrade option. you can upgrade the current running stack version to next available version. 

Upgrade option is available from one minor version to next minor version of CNS.

Example: Cloud Native Stack 13.0 can upgrade to 13.1 but 13.x can not upgrade to 14.x

`NOTE:` Currently there's a containerd limitation for upgrade from CNS 14.0 to CNS 15.1, please find the details [here](https://github.com/containerd/containerd/issues/11535)

### Uninstall

Run the below command to uninstall the NVIDIA Cloud Native Stack. Tasks being "ignored" refers to no kubernetes cluster being available.

```
bash setup.sh uninstall
```

`NOTE`
A list of older NVIDIA Cloud Native Stack versions (formerly known as Cloud Native Core) can be found [here](https://github.com/NVIDIA/cloud-native-stack/blob/master/playbooks/older_versions/readme.md)

<h2> Ansible Playbook Descriptions </h2>

- [Install NVIDIA Cloud Native Stack](#Install-NVIDIA-Cloud-Native-Stack)
- [Validate NVIDIA Cloud Native Stack](#Validate-NVIDIA-Cloud-Native-Stack)
- [Upgrade NVIDIA Cloud Native Stack](#Upgrade-NVIDIA-Cloud-Native-Stack)
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

### Upgrade NVIDIA Cloud Native Stack

The Ansible NVIDIA Cloud Native Stack upgrade playbook will do the following:

- Validate the Cloud Native stack is running
- Update the Cloud Native Stack Version 
- Upgrade the Container runtime and kubernetes components
- Upgrade the Kubernetes cluster to new version
- Upgrade the networking plugin to new version
- Upgrade the GPU Operator to next available version

### Uninstall NVIDIA Cloud Native Stack 

The Ansible NVIDIA Cloud Native Stack uninstall playbook will do the following:

- Reset the Kubernetes cluster
- Remove the Helm package
- Uninstall the Docker and Kubernetes Packages

### Getting Help

Please [open an issue on the GitHub project](https://github.com/NVIDIA/cloud-native-stack/issues) for any questions. Your feedback is appreciated.


