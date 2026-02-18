#!/bin/bash
# migrate-out.sh — Run on OLD Mac to transfer everything directly to the new Mac
set -euo pipefail

REMOTE="conor.rafferty@192.168.4.77"

# Verify connectivity first
echo "=== Testing connection to $REMOTE ==="
if ! ssh -o ConnectTimeout=5 "$REMOTE" "echo 'Connected.'" 2>/dev/null; then
    echo "ERROR: Cannot SSH to $REMOTE"
    echo "Make sure Remote Login is enabled and your public key is in ~/.ssh/authorized_keys on the new Mac."
    exit 1
fi

echo ""
echo "=== MacBook Migration: Transferring directly to $REMOTE ==="

# helper: rsync to remote, creating parent dirs as needed
send() {
    local src="$1"
    local dest="$2"
    ssh "$REMOTE" "mkdir -p $(dirname "$dest")"
    rsync -avz --progress "$src" "$REMOTE:$dest"
}

send_dir() {
    local src="$1"
    local dest="$2"
    ssh "$REMOTE" "mkdir -p $dest"
    rsync -avz --progress \
        --exclude='node_modules' \
        --exclude='.git/objects' \
        --exclude='*.pyc' \
        --exclude='__pycache__' \
        --exclude='.pytest_cache' \
        --exclude='.venv' \
        --exclude='venv' \
        --exclude='dist' \
        --exclude='build' \
        --exclude='target' \
        "$src/" "$REMOTE:$dest/"
}

# ─── SSH Keys ───
echo ""
echo "=== SSH keys ==="
ssh "$REMOTE" "mkdir -p ~/.ssh && chmod 700 ~/.ssh"
rsync -avz ~/.ssh/id_ed25519 ~/.ssh/id_ed25519.pub ~/.ssh/config "$REMOTE:~/.ssh/"
ssh "$REMOTE" "chmod 600 ~/.ssh/id_ed25519 && chmod 644 ~/.ssh/id_ed25519.pub ~/.ssh/config"

# # ─── GPG Keys ───
# echo ""
# echo "=== GPG keys ==="
# TMPGPG=$(mktemp -d)
# gpg --export-secret-keys --armor AC9024ABBF280C8A > "$TMPGPG/gpg-private.asc"
# gpg --export --armor AC9024ABBF280C8A > "$TMPGPG/gpg-public.asc"
# cp "$HOME/.gnupg/gpg-agent.conf" "$TMPGPG/"
# ssh "$REMOTE" "mkdir -p ~/migration/gpg"
# rsync -avz "$TMPGPG/" "$REMOTE:~/migration/gpg/"
# rm -rf "$TMPGPG"

# ─── Git Config ───
echo ""
echo "=== Git config ==="
rsync -avz "$HOME/.gitconfig" "$REMOTE:~/.gitconfig" 2>/dev/null || \
rsync -avz "$HOME/.dotfiles/git/.gitconfig" "$REMOTE:~/.gitconfig" 2>/dev/null || true

# ─── Maven Settings ───
echo ""
echo "=== Maven settings ==="
ssh "$REMOTE" "mkdir -p ~/.m2"
rsync -avz "$HOME/.m2/settings.xml" "$REMOTE:~/.m2/settings.xml"

# ─── Kube Config ───
echo ""
echo "=== Kube config ==="
ssh "$REMOTE" "mkdir -p ~/.kube"
rsync -avz "$HOME/.kube/config" "$REMOTE:~/.kube/config"
ssh "$REMOTE" "chmod 600 ~/.kube/config"

# ─── Certificates (direct to final location) ───
echo ""
echo "=== Certificates ==="
send_dir "$HOME/dev/salesforce/other/personal/certs" "~/dev/salesforce/other/personal/certs"

# # ─── JDKs (direct to final location, requires sudo on remote) ───
# echo ""
# echo "=== JDKs ==="
# echo "Transferring JDKs to temp location, then moving with sudo on remote..."
# send_dir "/Library/Java/JavaVirtualMachines" "~/migration/jdks"
# ssh -t "$REMOTE" "sudo mkdir -p /Library/Java/JavaVirtualMachines && sudo cp -R ~/migration/jdks/* /Library/Java/JavaVirtualMachines/ && rm -rf ~/migration/jdks"

# ─── Fonts ───
echo ""
echo "=== Fonts ==="
ssh "$REMOTE" "mkdir -p ~/Library/Fonts"
rsync -avz "$HOME/Library/Fonts/" "$REMOTE:~/Library/Fonts/"

# ─── Config Files ───
echo ""
echo "=== Config files (macOS defaults, iTerm profiles, VS Code settings) ==="
ssh "$REMOTE" "mkdir -p ~/migration/config"
rsync -avz "$HOME/.dotfiles/other/settings.json" "$REMOTE:~/migration/config/" 2>/dev/null || true
rsync -avz "$HOME/.dotfiles/other/.macos.zsh" "$REMOTE:~/migration/config/" 2>/dev/null || true
rsync -avz "$HOME/.dotfiles/other/itermprofiles.json" "$REMOTE:~/migration/config/" 2>/dev/null || true

# ─── Personal Files ───
echo ""
echo "=== Personal files (Documents, Desktop, ~/other) ==="
rsync -avz "$HOME/Documents/" "$REMOTE:~/Documents/" 2>/dev/null || true
rsync -avz "$HOME/Desktop/" "$REMOTE:~/Desktop/" 2>/dev/null || true
rsync -avz "$HOME/other/" "$REMOTE:~/other/" 2>/dev/null || true

# ─── Package Inventories ───
echo ""
echo "=== Package inventories ==="
TMPINV=$(mktemp -d)
cp "$HOME/.dotfiles/install/Brewfile.migration" "$TMPINV/Brewfile"
code --list-extensions > "$TMPINV/vscode-extensions.txt" 2>/dev/null || echo "VS Code not available" > "$TMPINV/vscode-extensions.txt"
nvm ls --no-colors > "$TMPINV/node-versions.txt" 2>/dev/null || echo "nvm not available" > "$TMPINV/node-versions.txt"
ssh "$REMOTE" "mkdir -p ~/migration/inventories"
rsync -avz "$TMPINV/" "$REMOTE:~/migration/inventories/"
rm -rf "$TMPINV"

# ─── Dotfiles repo (direct to final location) ───
echo ""
echo "=== Dotfiles repo ==="
send_dir "$HOME/dev/other/personal/dotfiles" "~/dev/other/personal/dotfiles"
ssh "$REMOTE" "ln -sf ~/dev/other/personal/dotfiles ~/.dotfiles 2>/dev/null || true"

# ─── Git Repos (full copy — high priority, direct to final paths) ───
echo ""
echo "=== High-priority repos (with local changes) ==="

REPOS_HIGH=(
    "dev/other/personal/dipsea-results"
    "dev/salesforce/other/personal/scripts"
    "dev/salesforce/DataViz/Grafana"
    "dev/salesforce/DataViz/grafana-scripts"
    "dev/salesforce/DataViz/moncloud-grafana"
    "dev/salesforce/DataViz/moncloud-grafana-infra"
    "dev/salesforce/DataViz/moncloudapi-group-service-docs"
    "dev/salesforce/monitoring/huron"
    "dev/salesforce/monitoring/huron_dbt_docker"
    "dev/salesforce/monitoring/huron-fedx"
    "dev/salesforce/monitoring/huron-on-call-scripts"
    "dev/salesforce/monitoring/huron-terramon-config"
    "dev/salesforce/sfdc-presto/sfdc-trino-platform"
    "dev/salesforce/sfdc-presto/trino"
)

for repo in "${REPOS_HIGH[@]}"; do
    src="$HOME/$repo"
    if [ -d "$src" ]; then
        echo "  Sending $repo ..."
        send_dir "$src" "~/$repo"
    else
        echo "  WARNING: $src not found, skipping"
    fi
done

# ─── Git Repos (full copy — medium priority) ───
echo ""
echo "=== Medium-priority repos ==="

REPOS_MED=(
    "dev/salesforce/DataViz/druid-grafana"
    "dev/salesforce/DataViz/sfdc-trino-demo"
    "dev/salesforce/monitoring/huron-terraform-module"
    "dev/salesforce/monitoring/huron-transforms-dag"
    "dev/salesforce/monitoring/teles"
    "dev/salesforce/other/ArgusMonitoring/Argus"
    "dev/salesforce/other/apache/orc"
    "dev/salesforce/other/falcon-addons/aurora-addon"
    "dev/salesforce/other/infrastructure-monitoring/monitoring-config"
    "dev/salesforce/other/personal/gmail-filters"
    "dev/salesforce/other/terraform-modules/terraform-aws-rds-aurora2"
)

for repo in "${REPOS_MED[@]}"; do
    src="$HOME/$repo"
    if [ -d "$src" ]; then
        echo "  Sending $repo ..."
        send_dir "$src" "~/$repo"
    else
        echo "  WARNING: $src not found, skipping"
    fi
done

# ─── Summary ───
echo ""
echo "=========================================="
echo "=== Transfer complete! ==="
echo "=========================================="
echo ""
echo "On the new Mac, run the setup script:"
echo "  bash ~/.dotfiles/install/migrate-in.sh"
echo ""
echo "Or use Claude Code on the new Mac:"
echo "  Read ~/.dotfiles/install/README-NEW-MAC.md and set up my machine."
