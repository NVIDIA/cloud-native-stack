# Version Update Script

Professional script to automatically update component versions in Cloud Native Stack YAML configuration files.

## Features

✅ **GitHub Token Authentication** - Avoid rate limits with authenticated requests  
✅ **Error Handling** - Comprehensive error checking and logging  
✅ **Minimal Code** - Clean, maintainable implementation  
✅ **Rate Limit Protection** - Uses GitHub API efficiently  
✅ **Automatic Cleanup** - Temp files cleaned up on exit  
✅ **Diff Summary** - Shows what changed after update  

## Prerequisites

```bash
# Make script executable
chmod +x update_versions.sh

# Install required tools (if not already installed)
# curl, grep, sed, awk
```

## GitHub Token Setup

### Create a GitHub Personal Access Token

1. Go to https://github.com/settings/tokens
2. Click "Generate new token" → "Generate new token (classic)"
3. Give it a name: `CNS Version Updater`
4. Select scopes: `public_repo` (read-only access to public repositories)
5. Click "Generate token"
6. Copy the token (you won't see it again!)

### Set Token in Environment

```bash
# Option 1: Export for current session
export GITHUB_TOKEN="ghp_your_token_here"

# Option 2: Add to ~/.bashrc or ~/.zshrc for persistence
echo 'export GITHUB_TOKEN="ghp_your_token_here"' >> ~/.bashrc
source ~/.bashrc

# Option 3: Use a .env file (recommended)
echo "GITHUB_TOKEN=ghp_your_token_here" > .env
source .env
```

### Verify Token

```bash
# Check if token is set
echo $GITHUB_TOKEN

# Test API access with token
curl -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/rate_limit
```

## Usage

### Basic Usage

```bash
# Update with default files
./update_versions.sh

# Specify input and output files
./update_versions.sh input.yaml output.yaml
```

### With GitHub Token

```bash
# Set token and run
export GITHUB_TOKEN="ghp_your_token_here"
./update_versions.sh cns_values_16.0.yaml cns_values_16.2.yaml
```

### Without Token (Limited)

```bash
# Runs with 60 requests/hour limit
./update_versions.sh
```

## What Gets Updated

### Standard Components
- containerd, runc, CNI plugins
- CRI-Docker, Calico
- NVIDIA Container Toolkit
- Helm, Local Path Provisioner
- MetalLB, KServe
- Grafana Operator, Elasticsearch
- GPU Operator, Network Operator
- NIM Operator, DRA Driver
- Dynamo, Volcano, KAI Scheduler
- LeaderWorkerSet (LWS)

### Version-Locked Components
- Kubernetes (maintains major.minor)
- CRI-O (maintains major.minor)

### Helm Charts
- Prometheus Stack
- Prometheus Adapter

### Special Components
- NFS Provisioner
- Ingress Controller

## Output Example

```
[INFO] Starting version update process
[INFO] Input:  cns_values_16.0.yaml
[INFO] Output: cns_values_16.2.yaml
✓ Using GitHub token authentication
[INFO] Updating standard repository versions...
[INFO] ✓ containerd_version: 1.7.24
[INFO] ✓ runc_version: 1.2.3
[INFO] ✓ plugins_version: 1.6.2
[INFO] ✓ gpu_operator_version: 24.12.0
...
[INFO] ✓ Version update complete!
[INFO] Results saved to: cns_values_16.2.yaml
```

## Rate Limits

| Authentication | Rate Limit | Recommended For |
|----------------|------------|-----------------|
| No Token       | 60/hour    | Testing only    |
| With Token     | 5,000/hour | Production use  |

## Troubleshooting

### Token Not Working

```bash
# Verify token format (should start with ghp_, gho_, or github_pat_)
echo $GITHUB_TOKEN | cut -c1-4

# Test authentication
curl -H "Authorization: token $GITHUB_TOKEN" \
  https://api.github.com/user
```

### Rate Limit Exceeded

```bash
# Check remaining rate limit
curl -H "Authorization: token $GITHUB_TOKEN" \
  https://api.github.com/rate_limit
```

### Script Fails

```bash
# Run with debug output
bash -x ./update_versions.sh

# Check for required tools
which curl grep sed awk
```

## Security Best Practices

⚠️ **Never commit tokens to git**

```bash
# Add to .gitignore
echo ".env" >> .gitignore
echo "*.token" >> .gitignore

# Use environment variables or secret managers
# Rotate tokens regularly (every 90 days)
# Use tokens with minimal required permissions
```

## Advanced Usage

### CI/CD Integration

```yaml
# GitHub Actions example
- name: Update versions
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
  run: |
    ./update_versions.sh cns_values.yaml cns_values_updated.yaml
```

### Cron Job

```bash
# Update versions weekly
0 0 * * 0 cd /path/to/repo && GITHUB_TOKEN=$GITHUB_TOKEN ./update_versions.sh
```

## Support

For issues or questions, contact the Cloud Native Stack team.
