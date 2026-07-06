# CNS Install Workflow

Run commands from the repository checkout unless noted otherwise. The playbook entrypoint is `playbooks/setup.sh`.

## Prepare Inventory

For a single-node install, write `playbooks/hosts` using the master-only template:

```ini
[master]
<HOST_IP> ansible_ssh_user=<USERNAME> ansible_ssh_pass=<PASSWORD> ansible_sudo_pass=<PASSWORD> ansible_ssh_common_args='-o StrictHostKeyChecking=no'
[nodes]
```

For master plus worker nodes, put the control-plane host under `[master]` and workers under `[nodes]`:

```ini
[master]
<MASTER_IP> ansible_ssh_user=<USERNAME> ansible_ssh_pass=<PASSWORD> ansible_sudo_pass=<PASSWORD> ansible_ssh_common_args='-o StrictHostKeyChecking=no'
[nodes]
<WORKER_1_IP> ansible_ssh_user=<USERNAME> ansible_ssh_pass=<PASSWORD> ansible_sudo_pass=<PASSWORD> ansible_ssh_common_args='-o StrictHostKeyChecking=no'
<WORKER_2_IP> ansible_ssh_user=<USERNAME> ansible_ssh_pass=<PASSWORD> ansible_sudo_pass=<PASSWORD> ansible_ssh_common_args='-o StrictHostKeyChecking=no'
```

For local testing on the target itself, `localhost` may be used in `[master]` when the user explicitly requests that shape.

## Select Version and Values

1. Inspect `playbooks/cns_version.yaml`.
2. If the user requested a different supported version, update `cns_version.yaml`.
3. Edit only the matching `playbooks/cns_values_<version>.yaml`.
4. Keep default values unless the user requested add-ons or custom settings.

## Install Commands

From `playbooks/`:

```bash
ts=$(date +%Y%m%dT%H%M%S)
log="$HOME/cns-install-${ts}.log"
bash setup.sh install 2>&1 | tee "$log"
```

For confidential computing:

```bash
ts=$(date +%Y%m%dT%H%M%S)
log="$HOME/cns-install-cc-${ts}.log"
bash setup.sh install cc 2>&1 | tee "$log"
```

For launchpad mode:

```bash
ts=$(date +%Y%m%dT%H%M%S)
log="$HOME/cns-install-launchpad-${ts}.log"
bash setup.sh install launchpad 2>&1 | tee "$log"
```

## Validate Commands

Run validation only when requested or when the task requires proof:

```bash
ts=$(date +%Y%m%dT%H%M%S)
log="$HOME/cns-validate-${ts}.log"
bash setup.sh validate 2>&1 | tee "$log"
```

## Log Review

Check the saved log before reporting success:

```bash
grep -A3 'PLAY RECAP' "$log" | tail -20
grep -Ein 'FAILED!|failed=[1-9]|Traceback|template error|ImagePullBackOff|ErrImagePull|no runtime for|debconf|apt does not have a stable CLI interface' "$log" || true
```

Success requires:

- Setup command exits with `0`.
- Play recap has `failed=0`.
- No unhandled `FAILED!`, traceback, template error, image-pull failure, or container runtime failure.
- Any ignored task is reviewed and explained if it is relevant to the requested install.

## Reporting

Report only sanitized details:

- Target OS and host role.
- Command run.
- Saved log path.
- Play recap.
- Add-ons enabled.
- Any warnings that remain.

Do not report passwords, API keys, full inventory lines, or unredacted command history.

## Git Hygiene

- Do not stage or commit `playbooks/hosts` if it contains real credentials.
- Do not stage generated logs, kubeconfigs, downloaded charts, tarballs, or temporary values files unless the user explicitly requests it.
- Keep repo changes limited to requested configuration or skill documentation.
