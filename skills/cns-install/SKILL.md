# CNS Install Skill

Use this skill when a user asks an AI agent to install, validate, upgrade, or uninstall NVIDIA Cloud Native Stack from this repository. The workflow is intentionally agent-agnostic and can be followed by Claude, Cursor, Devin, Codex, or another coding agent.

## Required Inputs

- Master host IP or hostname.
- SSH username.
- SSH password and sudo password, if password-based access is used.

## Optional Inputs

- Worker node IPs and credentials.
- CNS version from `playbooks/cns_version.yaml`.
- Install mode: default install, confidential computing install, launchpad install, validate, upgrade, or uninstall.
- Add-ons to enable. Read `references/add-ons.md` before changing values.
- Load balancer IPs for MetalLB.
- NGC registry username, email, or API key when private registry access is required.
- Whether to run `bash setup.sh validate` after install.

## Credential Rules

- Never commit `playbooks/hosts` when it contains real credentials.
- Never include passwords, API keys, tokens, or unredacted inventory lines in summaries.
- Redact credentials in logs or output snippets before sharing them.
- Prefer saving command logs on the target host under a timestamped filename.
- If creating temporary files that contain credentials, keep permissions restrictive and remove them when they are no longer needed.

## Workflow

1. Read `playbooks/readme.md` and the selected `playbooks/cns_values_<version>.yaml` before editing.
2. Build `playbooks/hosts` from the user-provided target information. Use templates in `templates/`.
3. If the user requests a CNS version change, update `playbooks/cns_version.yaml` and use the matching values file.
4. If the user requests add-ons, edit only the matching values file and follow `references/add-ons.md`.
5. Run the requested setup command from `playbooks/`, saving output to a timestamped log.
6. Review the log for recap and failure patterns.
7. If validation is requested, run `bash setup.sh validate` and save a second timestamped log.
8. Report the command, log path, recap, and sanitized findings. Do not expose secrets.

## Reference Files

- `references/install-workflow.md`: command sequence, inventory examples, logging, and validation checks.
- `references/add-ons.md`: add-on names, values-file keys, dependencies, and extra inputs.
- `templates/hosts.master-only.example`: single master placeholder inventory.
- `templates/hosts.master-workers.example`: master plus worker placeholder inventory.

## Stop Conditions

Stop and ask the user before proceeding when:

- A required credential, host IP, or add-on input is missing.
- The requested add-on needs an input not provided, such as load balancer IPs or private registry credentials.
- A command would overwrite unrelated local changes.
- Installation fails for an environmental reason that cannot be resolved from the repo, such as missing GPU, DNS failure, no internet access, unsupported OS, or unavailable external image/package.
