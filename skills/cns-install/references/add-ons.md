# CNS Add-Ons Reference

Edit the selected `playbooks/cns_values_<version>.yaml` file. Use only keys that exist in that file.

## Add-On Mapping

| User request | Values key |
| --- | --- |
| Storage | `storage: yes` |
| Monitoring / Grafana / Kibana / Prometheus | `monitoring: yes` |
| Load balancer / MetalLB | `loadbalancer: yes` plus `loadbalancer_ips` when present |
| KServe | `kserve: yes` |
| NIM Operator | `enable_nim_operator: yes` |
| Nsight Operator | `enable_nsight_operator: yes` |
| KAI Scheduler / Kubernetes AI Scheduler | `enable_kai_scheduler: yes` |
| LeaderWorkerSet / LWS | `lws: yes` |
| Volcano | `volcano: yes` |
| Ingress Controller | `ingress_controller: yes` when the key exists |
| Knative Serving | `knative_serving: yes` when the key exists |
| MicroK8s | `microk8s: yes` |
| Confidential Computing | use `bash setup.sh install cc`; do not enable through values only |

## Recommended Bundles

- KServe should normally include:
  - `storage: yes`
  - `monitoring: yes`
  - `loadbalancer: yes`
  - `kserve: yes`
- Network Operator should include RDMA when requested for NVIDIA certification:
  - `enable_network_operator: yes`
  - `enable_rdma: yes`
- GDS requires open kernel modules:
  - `enable_gds: yes`
  - `use_open_kernel_module: yes`

## Extra Inputs

Ask for these before editing when they are required:

- Load balancer: one or more IP/CIDR values for `loadbalancer_ips`, unless the repo version supports defaulting to the host IP and the user accepts that default.
- Private NGC registry access: `ngc_registry_username`, `ngc_registry_email`, and `ngc_registry_password` or API key.
- vGPU: license server and any required license files or tokens.
- KServe with NIM models: Hugging Face token, NGC API key, model choice, and storage requirements if the user asks for model deployment, not just platform install.
- Proxy environment: `proxy: yes`, `http_proxy`, and `https_proxy`.

## Version Differences

The values keys can differ across CNS versions. Before editing:

```bash
grep -nE '^(storage|monitoring|loadbalancer|loadbalancer_ips|loadbalancer_ip|kserve|enable_nim_operator|enable_nsight_operator|enable_kai_scheduler|lws|volcano|ingress_controller|knative_serving|microk8s|enable_network_operator|enable_rdma|enable_gds|use_open_kernel_module):' playbooks/cns_values_<version>.yaml
```

If a requested key is absent, do not invent it. Explain that the selected CNS version does not expose that option in its values file.

## Validation Pointers

After install, check add-on namespaces and pods relevant to the requested options:

```bash
kubectl get pods -A
kubectl get storageclass
helm list -A
```

For monitoring, report service access hints from the README:

- Grafana: `http://<node-ip>:32222`, default credentials `admin/cns-stack`.
- Kibana: `http://<node-ip>:32221`, default credentials `elastic/cns-stack`.
