# nvidia_container_toolkit

Ansible role that installs and configures the [NVIDIA Container
Toolkit](https://github.com/NVIDIA/nvidia-container-toolkit) on Ubuntu/Debian or
RHEL/CentOS, and sets up the Container Device Interface (CDI) for Docker,
containerd, cri-dockerd, or CRI-O. Extracted from the NVIDIA Cloud Native Stack
playbooks so it can be reused standalone, as requested in
[NVIDIA/cloud-native-stack#74](https://github.com/NVIDIA/cloud-native-stack/issues/74).

## Requirements

- `gather_facts: true` on the play using this role (it relies on `ansible_facts['os_family']`)
- Docker, containerd, or CRI-O already installed on the target host
- `become: true` privileges

## Role Variables

| Variable | Default | Description |
|---|---|---|
| `nvidia_container_toolkit_version` | `"1.18.1"` | Version to install on Ubuntu/Debian (apt pin). RHEL installs the latest available from the NVIDIA yum repo. |
| `nvidia_container_toolkit_runtime` | `"containerd"` | One of `docker`, `containerd`, `cri-docker`, `cri-o`. Used to configure CDI for the right runtime. |
| `nvidia_container_toolkit_enable_cdi` | `true` | Whether to run `nvidia-ctk runtime configure --cdi.enabled`. |
| `nvidia_container_toolkit_remove_existing` | `true` | Remove any previously installed toolkit packages before installing the pinned version. |

## Usage

Install directly from this repository with `ansible-galaxy`:

```bash
ansible-galaxy role install git+https://github.com/NVIDIA/cloud-native-stack,master#/roles/nvidia_container_toolkit
```

Then reference it in a playbook:

```yaml
- hosts: gpu_nodes
  gather_facts: true
  roles:
    - role: nvidia_container_toolkit
      vars:
        nvidia_container_toolkit_version: "1.18.1"
        nvidia_container_toolkit_runtime: "containerd"
```

## License

Apache-2.0, matching the rest of this repository.
