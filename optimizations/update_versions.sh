#!/usr/bin/env bash
#
# Version Update Script for Cloud Native Stack
# Updates component versions from upstream GitHub releases and Helm charts
#

set -euo pipefail

# ============================================================================
# Configuration
# ============================================================================

readonly INPUT_YAML="${1:-cns_values_16.0.yaml}"
readonly OUTPUT_YAML="${2:-cns_values_16.2.yaml}"
readonly GITHUB_TOKEN="${GITHUB_TOKEN:-}"
readonly TEMP_FILE=$(mktemp)

# Cleanup on exit
trap 'rm -f "$TEMP_FILE"' EXIT

# ============================================================================
# GitHub API Configuration
# ============================================================================

CURL_OPTS=(-s -f)
if [[ -n "$GITHUB_TOKEN" ]]; then
    CURL_OPTS+=(-H "Authorization: token $GITHUB_TOKEN")
    echo "✓ Using GitHub token authentication"
else
    echo "⚠️  Warning: No GITHUB_TOKEN set. Rate limits apply (60 requests/hour)"
    echo "   Set GITHUB_TOKEN environment variable for authenticated requests (5000/hour)"
fi

# ============================================================================
# Helper Functions
# ============================================================================

log_info() {
    echo "[INFO] $*"
}

log_error() {
    echo "[ERROR] $*" >&2
}

# Fetch latest stable version from GitHub
# Uses grep -oE + sed for BSD/macOS compatibility (grep -oP / \K is GNU-only)
get_latest_github_version() {
    local repo="$1"
    local result
    result=$(curl "${CURL_OPTS[@]}" "https://api.github.com/repos/$repo/releases/latest" \
        | grep -oE '"tag_name"[[:space:]]*:[[:space:]]*"[^"]+"' \
        | head -1 \
        | sed -E 's/.*"([^"]+)"$/\1/' \
        | sed 's/^v//') || return 1
    echo "$result"
}

# Fetch multiple recent versions from tags
# per_page=100 ensures we capture older minor versions still receiving patches
# (e.g. when finding latest v1.33 patch while v1.36 is current)
get_github_versions() {
    local repo="$1"
    local count="${2:-100}"
    local result
    result=$(curl "${CURL_OPTS[@]}" "https://api.github.com/repos/$repo/tags?per_page=100" \
        | grep -oE '"name"[[:space:]]*:[[:space:]]*"[^"]+"' \
        | sed -E 's/.*"([^"]+)"$/\1/' \
        | grep -Ev 'rc|dev|alpha|beta' \
        | head -n "$count") || return 1
    echo "$result"
}

# Fetch version from Helm Chart.yaml
get_helm_chart_version() {
    local chart_url="$1"
    local result
    result=$(curl -sf "$chart_url/Chart.yaml" \
        | awk '/^version:/ {print $2; exit}' \
        | tr -d '"') || return 1
    echo "$result"
}

# Update YAML field
update_yaml_field() {
    local file="$1"
    local key="$2"
    local value="$3"
    sed -i.bak "s|^${key}:.*|${key}: \"${value}\"|" "$file"
    rm -f "${file}.bak"
}

# ============================================================================
# Version Update Logic
# ============================================================================

update_standard_repos() {
    log_info "Updating standard repository versions..."
    
    declare -A repos
    repos[containerd]="containerd/containerd"
    repos[runc]="opencontainers/runc"
    repos[plugins]="containernetworking/plugins"
    repos[cri_dockerd]="Mirantis/cri-dockerd"
    repos[calico]="projectcalico/calico"
    repos[nvidia_container_toolkit]="NVIDIA/nvidia-container-toolkit"
    repos[helm]="helm/helm"
    repos[local_path_provisioner]="rancher/local-path-provisioner"
    repos[metallb]="metallb/metallb"
    repos[kserve]="kserve/kserve"
    repos[grafana_operator]="grafana/grafana-operator"
    repos[lws]="kubernetes-sigs/lws"
    repos[elasticsearch]="elastic/elasticsearch"
    repos[gpu_operator]="NVIDIA/gpu-operator"
    repos[network_operator]="Mellanox/network-operator"
    repos[k8s_nim_operator]="NVIDIA/k8s-nim-operator"
    repos[k8s_dra_driver_gpu]="NVIDIA/k8s-dra-driver-gpu"
    repos[dynamo]="ai-dynamo/dynamo"
    repos[volcano]="volcano-sh/volcano"
    repos[kai_scheduler]="NVIDIA/KAI-Scheduler"
    repos[flannel]="flannel-io/flannel"

    declare -A yaml_keys
    yaml_keys[cri_dockerd]="cri_dockerd_version"
    yaml_keys[nvidia_container_toolkit]="nvidia_container_toolkit_version"
    yaml_keys[gpu_operator]="gpu_operator_version"
    yaml_keys[network_operator]="network_operator_version"
    yaml_keys[k8s_nim_operator]="nim_operator_version"
    yaml_keys[k8s_dra_driver_gpu]="dra_driver_version"
    yaml_keys[lws]="lws_version"
    yaml_keys[volcano]="volcano_version"
    yaml_keys[dynamo]="dynamo_release_version"
    yaml_keys[kai_scheduler]="kai_scheduler_version"
    yaml_keys[elasticsearch]="elastic_stack"
    yaml_keys[plugins]="cni_plugins_version"
    yaml_keys[local_path_provisioner]="local_path_provisioner"
    yaml_keys[grafana_operator]="grafana_operator"
    yaml_keys[flannel]="flannel_version"
    
    local component repo version yaml_key
    for component in "${!repos[@]}"; do
        repo="${repos[$component]}"
        version=$(get_latest_github_version "$repo") || continue
        if [[ "$component" == "metallb" ]]; then
            version="${version#metallb-chart-}"
        fi
        
        yaml_key="${yaml_keys[$component]:-}"
        if [[ -z "$yaml_key" ]]; then
            yaml_key="${component}_version"
        fi
        
        update_yaml_field "$TEMP_FILE" "$yaml_key" "$version"
        log_info "✓ $yaml_key: $version"
    done
}

update_kubernetes_crio() {
    log_info "Updating Kubernetes and CRI-O versions..."
    
    local k8s_major_minor crio_major_minor k8s_versions crio_versions k8s_version crio_version
    
    k8s_major_minor=$(awk '/^k8s_version:/ {gsub(/"/,"",$2); split($2,a,"."); print a[1]"."a[2]}' "$TEMP_FILE")
    crio_major_minor=$(awk '/^crio_version:/ {gsub(/"/,"",$2); split($2,a,"."); print a[1]"."a[2]}' "$TEMP_FILE")
    
    # Kubernetes
    k8s_versions=$(get_github_versions "kubernetes/kubernetes") || true
    if [[ -n "$k8s_versions" ]]; then
        k8s_version=$(echo "$k8s_versions" | grep -m1 "^v${k8s_major_minor}" | sed 's/^v//' || true)
        if [[ -n "$k8s_version" ]]; then
            update_yaml_field "$TEMP_FILE" "k8s_version" "$k8s_version"
            log_info "✓ k8s_version: $k8s_version"
        fi
    fi
    
    # CRI-O
    crio_versions=$(get_github_versions "cri-o/cri-o") || true
    if [[ -n "$crio_versions" ]]; then
        crio_version=$(echo "$crio_versions" | grep -m1 "^v${crio_major_minor}" | sed 's/^v//' || true)
        if [[ -n "$crio_version" ]]; then
            update_yaml_field "$TEMP_FILE" "crio_version" "$crio_version"
            log_info "✓ crio_version: $crio_version"
        fi
    fi
}

update_helm_charts() {
    log_info "Updating Helm chart versions..."
    
    local version
    
    # Prometheus Stack
    version=$(get_helm_chart_version "https://raw.githubusercontent.com/prometheus-community/helm-charts/main/charts/kube-prometheus-stack") || true
    if [[ -n "$version" ]]; then
        update_yaml_field "$TEMP_FILE" "prometheus_stack" "$version"
        log_info "✓ prometheus_stack: $version"
    fi
    
    # Prometheus Adapter
    version=$(get_helm_chart_version "https://raw.githubusercontent.com/prometheus-community/helm-charts/main/charts/prometheus-adapter") || true
    if [[ -n "$version" ]]; then
        update_yaml_field "$TEMP_FILE" "prometheus_adapter" "$version"
        log_info "✓ prometheus_adapter: $version"
    fi
}

update_special_components() {
    log_info "Updating special components..."
    
    local version
    
    # NFS Provisioner
    version=$(curl -sf "https://api.github.com/repos/kubernetes-sigs/nfs-subdir-external-provisioner/releases/latest" \
        | grep -oE '"tag_name"[[:space:]]*:[[:space:]]*"[^"]+"' \
        | head -1 \
        | sed -E 's/.*"([^"]+)"$/\1/' \
        | sed 's/^nfs-subdir-external-provisioner-//' \
        | sed 's/^v//' || true)
    if [[ -n "$version" ]]; then
        update_yaml_field "$TEMP_FILE" "nfs_provisioner" "$version"
        log_info "✓ nfs_provisioner: $version"
    fi

    # Ingress Controller
    version=$(curl -sf "https://artifacthub.io/api/v1/packages/helm/ingress-nginx/ingress-nginx" \
        | grep -oE '"version"[[:space:]]*:[[:space:]]*"[^"]+"' \
        | head -1 \
        | sed -E 's/.*"([^"]+)"$/\1/' || true)
    if [[ -n "$version" ]]; then
        update_yaml_field "$TEMP_FILE" "ingress_controller_version" "$version"
        log_info "✓ ingress_controller_version: $version"
    fi

    # NVIDIA Nsight Operator (scraped from docs release notes — no GitHub releases page)
    version=$(curl -sf "https://docs.nvidia.com/nsight-operator/ReleaseNotes/index.html" \
        | grep -oE 'Current Release \([0-9]+\.[0-9]+\.[0-9]+\)' \
        | head -1 \
        | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || true)
    if [[ -n "$version" ]]; then
        update_yaml_field "$TEMP_FILE" "nsight_operator_version" "$version"
        log_info "✓ nsight_operator_version: $version"
    fi

    # GPU Driver Version — pinned by the matching gpu-operator release, not auto-released.
    # We read gpu_operator_version (already updated above), fetch that tag's values.yaml,
    # and extract driver.version. This keeps driver/operator combos consistent.
    local gpu_op_version driver_version
    gpu_op_version=$(awk '/^gpu_operator_version:/ {gsub(/"/,"",$2); print $2}' "$TEMP_FILE")
    if [[ -n "$gpu_op_version" ]]; then
        driver_version=$(curl -sf "https://raw.githubusercontent.com/NVIDIA/gpu-operator/v${gpu_op_version}/deployments/gpu-operator/values.yaml" \
            | awk '
                /^driver:$/ {in_driver=1; next}
                /^[a-zA-Z]/ {in_driver=0}
                in_driver && $1=="version:" {gsub(/"/,"",$2); print $2; exit}
              ' || true)
        if [[ -n "$driver_version" ]]; then
            update_yaml_field "$TEMP_FILE" "gpu_driver_version" "$driver_version"
            log_info "✓ gpu_driver_version: $driver_version (from gpu-operator v$gpu_op_version)"
        else
            log_info "  skipped gpu_driver_version: could not parse values.yaml for v$gpu_op_version"
        fi
    fi
}

# ============================================================================
# Main Execution
# ============================================================================

main() {
    log_info "Starting version update process"
    log_info "Input:  $INPUT_YAML"
    log_info "Output: $OUTPUT_YAML"
    
    # Validate input file
    if [[ ! -f "$INPUT_YAML" ]]; then
        log_error "Input file not found: $INPUT_YAML"
        exit 1
    fi
    
    # Copy input to temp file
    cp "$INPUT_YAML" "$TEMP_FILE"
    
    # updates
    update_standard_repos
    update_kubernetes_crio
    update_helm_charts
    update_special_components
    
    # Save output
    mv "$TEMP_FILE" "$OUTPUT_YAML"
    
    log_info "✓ Version update complete!"
    log_info "Results saved to: $OUTPUT_YAML"
    
    # Show diff if input != output
    if [[ "$INPUT_YAML" != "$OUTPUT_YAML" ]]; then
        if command -v diff > /dev/null 2>&1; then
            echo ""
            log_info "Changes summary:"
            diff -u "$INPUT_YAML" "$OUTPUT_YAML" | grep -E '^[+-].*_version|^[+-].*_stack|^[+-]k8s_' || true
        fi
    fi
}

# Run main function
main "$@"
