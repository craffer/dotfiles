# MacBook Migration Guide

How to migrate from one MacBook to another when company policy requires a clean setup (no backup restore). Uses rsync over LAN for transfer.

## Overview

1. **Audit** the old Mac — inventory what needs to come over
2. **Bundle** everything into `~/migration/` on the old Mac
3. **Transfer** the bundle to the new Mac via rsync
4. **Set up** the new Mac using the migration bundle + setup script

---

## Step 1: Audit the old Mac

### Scan repos for local changes

Most git repos can be cloned fresh from remote. Only copy repos that have unpushed work. Scan all repos:

```bash
for dir in ~/dev/salesforce/**/*/.git; do
  repo="$(dirname "$dir")"
  dirty=$(git -C "$repo" status --porcelain 2>/dev/null | head -1)
  stashes=$(git -C "$repo" stash list 2>/dev/null | head -1)
  unpushed=$(git -C "$repo" log --branches --not --remotes --oneline 2>/dev/null | head -1)
  if [ -n "$dirty" ] || [ -n "$stashes" ] || [ -n "$unpushed" ]; then
    echo "=== $repo ==="
    [ -n "$dirty" ] && echo "  DIRTY: $(git -C "$repo" status --porcelain | wc -l | tr -d ' ') changed files"
    [ -n "$stashes" ] && echo "  STASHES: $(git -C "$repo" stash list | wc -l | tr -d ' ')"
    [ -n "$unpushed" ] && echo "  UNPUSHED: $(git -C "$repo" log --branches --not --remotes --oneline | wc -l | tr -d ' ') commits"
  fi
done
```

Add any repos with output to the `REPOS_HIGH` or `REPOS_MED` arrays in `migrate-out.sh`.

### Collect remote URLs for fresh cloning

```bash
for dir in ~/dev/salesforce/**/*/.git; do
  repo="$(dirname "$dir")"
  url=$(git -C "$repo" remote get-url origin 2>/dev/null)
  relpath=$(echo "$repo" | sed "s|$HOME/dev/salesforce/||")
  echo "git clone $url ~/dev/salesforce/$relpath"
done > ~/clone-commands.sh
```

Review and paste the commands for clean repos into `README-NEW-MAC.md` Step 18.

### Inventory installed software

```bash
brew bundle dump --file=/tmp/Brewfile.current    # Homebrew packages + casks
code --list-extensions > /tmp/vscode-ext.txt     # VS Code extensions
nvm ls                                           # Node versions
/usr/libexec/java_home -V                        # JDK installations
ls /Applications/                                # All apps
```

Review each list and decide what to keep vs drop for the new machine. Save the pruned Brewfile as `install/Brewfile.migration`.

### Check for important files outside of repos

Things that commonly need migrating:

| What | Where |
|------|-------|
| SSH keys | `~/.ssh/` |
| GPG keys | `~/.gnupg/` (export with `gpg --export-secret-keys --armor KEYID`) |
| Certificates | Varies — check `.zshenv` or env vars for cert paths |
| Maven settings | `~/.m2/settings.xml` |
| Kube config | `~/.kube/config` |
| Fonts | `~/Library/Fonts/` |
| JDKs | `/Library/Java/JavaVirtualMachines/` |
| Personal files | `~/Documents/`, `~/Desktop/`, `~/other/`, etc. |

---

## Step 2: Prepare the bundle

### Update migrate-out.sh

Edit `install/migrate-out.sh` with:
- The correct GPG key ID (find with `gpg --list-secret-keys --keyid-format=long`)
- The correct cert directory path
- The repo lists (`REPOS_HIGH` and `REPOS_MED`) based on the audit
- Any additional files specific to your setup

### Update templates

Review and update `zsh/.zshenv.template` and `zsh/.bootstrap_rc.template` if env var structure has changed.

### Clean up zsh config

Before migrating, clean the zsh config of stale references:
- Remove hardcoded paths with old hostnames
- Replace `/Users/username/` with `$HOME/`
- Remove references to tools no longer in use
- Remove directory shortcuts to directories that no longer exist
- Keep all work-critical config (k8s contexts, vault, tool integrations)

### Run the bundle script

```bash
bash ~/.dotfiles/install/migrate-out.sh
```

This creates `~/migration/` with everything organized into subdirectories.

---

## Step 3: Transfer

### Set up SSH access to the new Mac

1. On the new Mac: System Settings > General > Sharing > Remote Login: ON
2. Get the new Mac's IP: `ipconfig getifaddr en0`
3. Copy your public key to the new Mac:

```bash
# On the new Mac, run:
mkdir -p ~/.ssh && echo 'PASTE_YOUR_PUBLIC_KEY_HERE' >> ~/.ssh/authorized_keys && chmod 700 ~/.ssh && chmod 600 ~/.ssh/authorized_keys
```

Get your public key with `cat ~/.ssh/id_ed25519.pub` on the old Mac.

4. Test from old Mac: `ssh username@NEW_MAC_IP "echo works"`

### rsync the bundle

```bash
rsync -avz --progress ~/migration/ username@NEW_MAC_IP:~/migration/
```

For large bundles (many repos with full git history), this may transfer several GB.

---

## Step 4: Set up the new Mac

### Option A: Run the setup script

```bash
bash ~/migration/repos/dev/other/personal/dotfiles/install/migrate-in.sh
```

This is an interactive script that walks through each step with confirmations.

### Option B: Use Claude Code

Open Claude Code on the new Mac and say:

> Read ~/migration/repos/dev/other/personal/dotfiles/install/README-NEW-MAC.md and set up my machine following these instructions.

### Option C: Manual setup

Follow the steps in `README-NEW-MAC.md` manually.

### Post-setup tasks (always manual)

- Sign into browsers (Chrome, Firefox) to sync bookmarks/passwords
- Sign into password managers (1Password, Bitwarden)
- Sign into communication apps (Slack, Spotify, etc.)
- Install IT-managed apps via Self Service (CrowdStrike, Okta, Zscaler, VPN)
- Install IDE (JetBrains Toolbox, etc.)
- Edit `~/.dotfiles/zsh/.zshenv` with correct cert paths for the new machine
- Edit `~/.bootstrap_rc` with correct Python path
- Configure Dock, wallpaper, and other personal preferences

---

## File inventory

| File | Purpose |
|------|---------|
| `install/migrate-out.sh` | Bundles old Mac into `~/migration/` |
| `install/migrate-in.sh` | Interactive setup script for new Mac |
| `install/README-NEW-MAC.md` | Step-by-step guide (for Claude or manual use) |
| `install/Brewfile.migration` | Curated Homebrew package list |
| `zsh/.zshenv.template` | Template for machine-specific env vars (cert paths) |
| `zsh/.bootstrap_rc.template` | Template for machine-specific bootstrap config |
| `other/.macos.zsh` | macOS system defaults (Finder, screenshots, etc.) |
| `install/link.sh` | Creates dotfile symlinks from `~/.dotfiles/` to `~/` |

---

## Before your next migration

When you get a new machine in the future:

1. **Update `migrate-out.sh`** — re-audit repos (the scan command above), update GPG key ID if rotated, update cert paths if changed
2. **Update `Brewfile.migration`** — run `brew bundle dump` and prune
3. **Update `README-NEW-MAC.md`** — update the clone commands for any new repos, remove repos you no longer work on
4. **Update templates** — if `.zshenv` or `.bootstrap_rc` structure changed
5. **Update the app lists** — new apps to install, old ones to drop
6. **Run the process** — bundle, transfer, set up

The scripts are designed to be re-run safely. They use `mkdir -p` and `cp` (not destructive operations), so running them twice won't break anything.
