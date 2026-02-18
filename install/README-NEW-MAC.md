# New MacBook Setup Instructions

These instructions are designed to be followed by a Claude instance on the new Mac.
The migration bundle should already be at `~/migration/` (transferred via rsync from old Mac).

## Prerequisites
- macOS on Apple Silicon
- Admin access (sudo)
- Internet connection
- Migration bundle at `~/migration/`

---

## Step 1: Install Homebrew

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"
```

## Step 2: SSH Keys

```bash
mkdir -p ~/.ssh
cp ~/migration/ssh/id_ed25519 ~/.ssh/
cp ~/migration/ssh/id_ed25519.pub ~/.ssh/
cp ~/migration/ssh/config ~/.ssh/
chmod 600 ~/.ssh/id_ed25519
chmod 644 ~/.ssh/id_ed25519.pub
chmod 644 ~/.ssh/config
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
```

Test: `ssh -T git@git.soma.salesforce.com`

## Step 3: GPG Keys

```bash
brew install gnupg pinentry-mac
mkdir -p ~/.gnupg
cp ~/migration/gpg/gpg-agent.conf ~/.gnupg/

# Import public key
gpg --import ~/migration/gpg/gpg-public.asc

# Import private key (--batch --pinentry-mode loopback needed for non-interactive shells)
gpg --batch --pinentry-mode loopback --import ~/migration/gpg/gpg-private.asc

# Set trust to ultimate (requires full fingerprint, not short key ID)
FINGERPRINT=$(gpg --list-keys --with-colons AC9024ABBF280C8A 2>/dev/null | grep fpr | head -1 | cut -d: -f10)
echo "${FINGERPRINT}:6:" | gpg --import-ownertrust
```

Test: `gpg --list-secret-keys --keyid-format=long`

## Step 4: Git Config

Git config is symlinked by `link.sh` in Step 16. If running before Step 16:
```bash
cp ~/migration/config/.gitconfig ~/.gitconfig
```

Test: `git config --global user.name` should show "conor-rafferty"

## Step 5: Install from Brewfile

Review and edit `~/migration/inventories/Brewfile` first if needed, then:
```bash
brew bundle install --file=~/migration/inventories/Brewfile --no-upgrade
```

**Important:** `brew bundle` will abort if any single formula/cask fails (e.g. a renamed or removed package).
If that happens, fix or remove the offending line from the Brewfile and re-run, or install packages individually.

Note: The Salesforce falcon-cli tap requires SSH access to git.soma.salesforce.com (Step 2 must be done first).
Docker Desktop requires sudo — install it separately if `brew bundle` can't prompt for a password.

## Step 6: Fonts

```bash
cp ~/migration/fonts/* ~/Library/Fonts/
```

This installs Hasklig and Hasklug Nerd Font (needed for iTerm2 and VS Code).

## Step 7: JDKs

```bash
sudo cp -R ~/migration/jdks/* /Library/Java/JavaVirtualMachines/
```

Verify: `/usr/libexec/java_home -V` should show all installed JDKs.

## Step 8: Certificates

```bash
mkdir -p ~/dev/salesforce/other/personal/certs
cp -R ~/migration/certs/* ~/dev/salesforce/other/personal/certs/
```

## Step 9: Maven Settings

```bash
mkdir -p ~/.m2
cp ~/migration/maven/settings.xml ~/.m2/
```

## Step 10: Kube Config

```bash
mkdir -p ~/.kube
cp ~/migration/kube/config ~/.kube/
chmod 600 ~/.kube/config
```

## Step 11: macOS System Defaults

```bash
bash ~/migration/config/.macos.zsh
```

This configures: screenshot naming, Finder preferences, .DS_Store behavior, etc.

Additional manual settings:
- System Settings → Desktop & Dock → Automatically hide and show the Dock: ON
- System Settings → Desktop & Dock → Show recent applications in Dock: OFF

## Step 11b: Remap Caps Lock to Escape (persistent)

```bash
# If running before Step 16:
bash ~/migration/repos/dev/other/personal/dotfiles/install/remap-caps-lock-to-esc.sh

# If dotfiles are already linked:
bash ~/.dotfiles/install/remap-caps-lock-to-esc.sh
```

Test: open a terminal app and press Caps Lock while in normal mode (it should behave like Escape in Vim/shell tooling).

## Step 12: VS Code Extensions

```bash
cat ~/migration/inventories/vscode-extensions.txt | xargs -L 1 code --install-extension
```

## Step 13: Cursor Extensions

Cursor shares VS Code extension format. After installing Cursor, extensions can be installed similarly or via Cursor's marketplace.

## Step 14: NVM & Node.js

```bash
# nvm should be installed via zinit (zsh-nvm plugin), or manually:
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash

# Install Node LTS
nvm install --lts
nvm alias default lts/*
```

## Step 15: pyenv & Python

```bash
# pyenv should be installed via Brewfile
pyenv install 3.12
pyenv global 3.12
```

## Step 16: Set up Dotfiles & Zsh

```bash
# Clone the dotfiles repo (or copy from migration bundle)
mkdir -p ~/dev/other/personal
cp -R ~/migration/repos/dev/other/personal/dotfiles ~/dev/other/personal/dotfiles

# Create the symlink
ln -sf ~/dev/other/personal/dotfiles ~/.dotfiles

# Run the symlink script (idempotent — backs up existing files)
bash ~/.dotfiles/install/link.sh

# Create .zshenv from template (link.sh symlinks it to ~/.zshenv)
cp ~/.dotfiles/zsh/.zshenv.template ~/.dotfiles/zsh/.zshenv
# EDIT ~/.dotfiles/zsh/.zshenv to fill in actual cert paths for this machine

# Create .bootstrap_rc from template
cp ~/.dotfiles/zsh/.bootstrap_rc.template ~/.bootstrap_rc
# EDIT ~/.bootstrap_rc to fill in the correct Python path (e.g. $HOME/.pyenv/versions/3.12.x/bin/python3)

# Zinit auto-installs on first interactive shell load
# Open a new terminal window to trigger it
```

## Step 17: Place Copied Repos

```bash
# High-priority repos (with local changes)
rsync -a ~/migration/repos/dev/ ~/dev/

# This places all repos back in their original directory structure
```

## Step 18: Clone Fresh Repos

These repos were clean on the old machine — clone fresh from remote.
Clones can be run in parallel (append `&` to each line, `wait` at the end) to speed things up.
Large repos like `apache/druid`, `sfcd/spinnaker`, and `sfdc-falcon/falcon-derived-bom` may
take a long time — consider skipping them if not immediately needed.

```bash
# DataViz
mkdir -p ~/dev/salesforce/DataViz
git clone git@git.soma.salesforce.com:DataViz/argus-ui.git ~/dev/salesforce/DataViz/argus-ui
git clone git@git.soma.salesforce.com:DataViz/grafana-trino.git ~/dev/salesforce/DataViz/grafana-trino
git clone git@git.soma.salesforce.com:DataViz/moncloud-api-infra.git ~/dev/salesforce/DataViz/moncloud-api-infra
git clone git@git.soma.salesforce.com:DataViz/moncloud-api.git ~/dev/salesforce/DataViz/moncloud-api
git clone git@git.soma.salesforce.com:DataViz/moncloud-gateway.git ~/dev/salesforce/DataViz/moncloud-gateway
git clone git@git.soma.salesforce.com:DataViz/moncloudapi-batch.git ~/dev/salesforce/DataViz/moncloudapi-batch
git clone git@git.soma.salesforce.com:conor-rafferty/monex.git ~/dev/salesforce/DataViz/monex
git clone git@github.com:grafana/grafana.git ~/dev/salesforce/DataViz/oss-grafana
git clone git@github.com:grafana/helm-charts.git ~/dev/salesforce/DataViz/oss-helm-charts
git clone git@git.soma.salesforce.com:DataViz/terra-migrate.git ~/dev/salesforce/DataViz/terra-migrate
git clone git@git.soma.salesforce.com:DataViz/terraform-provider-moncloud.git ~/dev/salesforce/DataViz/terraform-provider-moncloud
git clone git@git.soma.salesforce.com:DataViz/grafana-scripts.git ~/dev/salesforce/DataViz/grafana-scripts  # Only if not in migration bundle

# monitoring
mkdir -p ~/dev/salesforce/monitoring
git clone git@git.soma.salesforce.com:monitoring/cipher-metric-configs.git ~/dev/salesforce/monitoring/cipher-metric-configs
git clone git@git.soma.salesforce.com:conor-rafferty/cloudwatch-metrics-onboarding-registry.git ~/dev/salesforce/monitoring/cloudwatch-metrics-onboarding-registry
git clone git@git.soma.salesforce.com:monitoring/config-refresh-tools.git ~/dev/salesforce/monitoring/config-refresh-tools
git clone git@git.soma.salesforce.com:monitoring/druid_sfmc_helm.git ~/dev/salesforce/monitoring/druid_sfmc_helm
git clone git@git.soma.salesforce.com:monitoring/FunnelOrchestra.git ~/dev/salesforce/monitoring/FunnelOrchestra
git clone git@git.soma.salesforce.com:monitoring/huron_airflow_docker_test.git ~/dev/salesforce/monitoring/huron_airflow_docker_test
git clone git@git.soma.salesforce.com:monitoring/huron-data-models.git ~/dev/salesforce/monitoring/huron-data-models
git clone git@git.soma.salesforce.com:monitoring/loganalytics-falcon-configs.git ~/dev/salesforce/monitoring/loganalytics-falcon-configs
git clone git@git.soma.salesforce.com:monitoring/loganalytics-helm-charts.git ~/dev/salesforce/monitoring/loganalytics-helm-charts
git clone git@git.soma.salesforce.com:monitoring/loganalytics-vmf.git ~/dev/salesforce/monitoring/loganalytics-vmf
git clone git@git.soma.salesforce.com:monitoring/mackinac.git ~/dev/salesforce/monitoring/mackinac
git clone git@git.soma.salesforce.com:monitoring/madeira.git ~/dev/salesforce/monitoring/madeira
git clone git@git.soma.salesforce.com:monitoring/monc-streaming-vmf.git ~/dev/salesforce/monitoring/monc-streaming-vmf
git clone git@git.soma.salesforce.com:monitoring/moncloud-events-fedx.git ~/dev/salesforce/monitoring/moncloud-events-fedx
git clone git@git.soma.salesforce.com:monitoring/moncloud-ui-service-docs.git ~/dev/salesforce/monitoring/moncloud-ui-service-docs
git clone git@git.soma.salesforce.com:monitoring/moncloud-ui.git ~/dev/salesforce/monitoring/moncloud-ui
git clone git@git.soma.salesforce.com:monitoring/pr-lifeguard.git ~/dev/salesforce/monitoring/pr-lifeguard
git clone git@git.soma.salesforce.com:monitoring/sorting-hat-helm-chart.git ~/dev/salesforce/monitoring/sorting-hat-helm-chart
git clone git@git.soma.salesforce.com:monitoring/sorting-hat.git ~/dev/salesforce/monitoring/sorting-hat
git clone git@git.soma.salesforce.com:monitoring/splunk-api-mtls-example.git ~/dev/salesforce/monitoring/splunk-api-mtls-example
git clone git@git.soma.salesforce.com:monitoring/splunk-nova-configs.git ~/dev/salesforce/monitoring/splunk-nova-configs
git clone git@git.soma.salesforce.com:monitoring/splunk-nova-content.git ~/dev/salesforce/monitoring/splunk-nova-content
git clone git@git.soma.salesforce.com:monitoring/splunk-terraform-module.git ~/dev/salesforce/monitoring/splunk-terraform-module

# sfdc-presto
mkdir -p ~/dev/salesforce/sfdc-presto
git clone git@git.soma.salesforce.com:conor-rafferty/bdmpresto-fedx.git ~/dev/salesforce/sfdc-presto/bdmpresto-fedx
git clone git@git.soma.salesforce.com:conor-rafferty/sfdc-presto-vmf.git ~/dev/salesforce/sfdc-presto/sfdc-presto-vmf
git clone git@git.soma.salesforce.com:conor-rafferty/sfdc-trino-helm-chart.git ~/dev/salesforce/sfdc-presto/sfdc-trino-helm-chart

# other
mkdir -p ~/dev/salesforce/other/{ArgusMonitoring,apache,bd-orca,personal,buildpacks,estates,falcon-addons,infrastructure-monitoring,knalluri,sfcd,sfdc-falcon,terraform-modules}
git clone git@git.soma.salesforce.com:conor-rafferty/argus-cloud-infra.git ~/dev/salesforce/other/ArgusMonitoring/argus-cloud-infra
git clone git@git.soma.salesforce.com:ArgusMonitoring/argus-cloud-release.git ~/dev/salesforce/other/ArgusMonitoring/argus-cloud-release
git clone git@git.soma.salesforce.com:ArgusMonitoring/argus-core.git ~/dev/salesforce/other/ArgusMonitoring/argus-core
git clone git@git.soma.salesforce.com:ArgusMonitoring/argus-query.git ~/dev/salesforce/other/ArgusMonitoring/argus-query
git clone git@git.soma.salesforce.com:conor-rafferty/argus-vmf.git ~/dev/salesforce/other/ArgusMonitoring/argus-vmf
git clone https://github.com/apache/druid.git ~/dev/salesforce/other/apache/druid
git clone git@git.soma.salesforce.com:conor-rafferty/airflow-config-addon.git ~/dev/salesforce/other/bd-orca/airflow-config-addon
git clone git@git.soma.salesforce.com:conor-rafferty/gridforce-orca-fedx.git ~/dev/salesforce/other/bd-orca/gridforce-orca-fedx
git clone git@git.soma.salesforce.com:bd-orca/orca-helm-chart.git ~/dev/salesforce/other/bd-orca/orca-helm-chart
git clone git@git.soma.salesforce.com:conor-rafferty/orca-self-service-helm-chart.git ~/dev/salesforce/other/bd-orca/orca-self-service-helm-chart
git clone git@git.soma.salesforce.com:conor-rafferty/sherlock-queries.git ~/dev/salesforce/other/personal/sherlock-queries
git clone git@git.soma.salesforce.com:buildpacks/falcon-buildpack.git ~/dev/salesforce/other/buildpacks/falcon-buildpack
git clone git@git.soma.salesforce.com:conor-rafferty/identity.git ~/dev/salesforce/other/estates/identity
git clone git@git.soma.salesforce.com:falcon-addons/helm-addon.git ~/dev/salesforce/other/falcon-addons/helm-addon
git clone git@git.soma.salesforce.com:falcon-addons/rds-postgres-addon.git ~/dev/salesforce/other/falcon-addons/rds-postgres-addon
git clone git@git.soma.salesforce.com:falcon-addons/vault-addon.git ~/dev/salesforce/other/falcon-addons/vault-addon
git clone git@git.soma.salesforce.com:infrastructure-monitoring/argus-cloud-release.git ~/dev/salesforce/other/infrastructure-monitoring/argus-cloud-release
git clone git@git.soma.salesforce.com:knalluri/grafana-dashboard-metrics-usage.git ~/dev/salesforce/other/knalluri/grafana-dashboard-metrics-usage
git clone git@git.soma.salesforce.com:sfcd/argo-rollouts.git ~/dev/salesforce/other/sfcd/argo-rollouts
git clone git@git.soma.salesforce.com:sfcd/spinnaker.git ~/dev/salesforce/other/sfcd/spinnaker
git clone git@git.soma.salesforce.com:sfdc-falcon/cli.git ~/dev/salesforce/other/sfdc-falcon/cli
git clone git@git.soma.salesforce.com:sfdc-falcon/config.git ~/dev/salesforce/other/sfdc-falcon/config
git clone git@git.soma.salesforce.com:sfdc-falcon/falcon-derived-bom.git ~/dev/salesforce/other/sfdc-falcon/falcon-derived-bom
git clone git@git.soma.salesforce.com:conor-rafferty/falcon-service-definition.git ~/dev/salesforce/other/sfdc-falcon/falcon-service-definition
git clone git@git.soma.salesforce.com:terraform-modules/terraform-aws-iam-policies.git ~/dev/salesforce/other/terraform-modules/terraform-aws-iam-policies
git clone git@git.soma.salesforce.com:terraform-modules/terraform-aws-rds-postgres.git ~/dev/salesforce/other/terraform-modules/terraform-aws-rds-postgres
git clone git@git.soma.salesforce.com:conor-rafferty/terraform-aws-s3_bucket2.git ~/dev/salesforce/other/terraform-modules/terraform-aws-s3_bucket2
git clone git@git.soma.salesforce.com:edge-ad/terraform-perimeter-module.git ~/dev/salesforce/other/terraform-modules/terraform-perimeter-module
```

Note: Some clones may fail if repos have been archived or access has changed. That's fine — skip those.

## Step 19: Personal Files

```bash
cp -R ~/migration/personal/Documents/* ~/Documents/ 2>/dev/null || true
cp -R ~/migration/personal/Desktop/* ~/Desktop/ 2>/dev/null || true
cp -R ~/migration/personal/other ~/other 2>/dev/null || true
```

## Step 20: iTerm2 Profiles

`link.sh` (Step 16) symlinks the iTerm2 profiles into DynamicProfiles automatically.
If running before Step 16, place them manually:
```bash
mkdir -p ~/Library/Application\ Support/iTerm2/DynamicProfiles/
cp ~/migration/config/itermprofiles.json ~/Library/Application\ Support/iTerm2/DynamicProfiles/
```

## Step 21: Manual Steps (do these yourself)

- [ ] Sign into Chrome with Google account (syncs bookmarks, extensions, passwords)
- [ ] Sign into Firefox with Firefox account
- [ ] Sign into 1Password
- [ ] Sign into Bitwarden
- [ ] Sign into Spotify
- [ ] Install apps from IT Self Service: Falcon, Okta Verify, Zscaler, Cisco VPN, Slack, Zoom, Chrome
- [ ] Install JetBrains Toolbox and IntelliJ IDEA
- [ ] Install AWS WorkSpaces from App Store or direct download
- [ ] Set up Dock: add Chrome, IntelliJ, System Settings
- [ ] Edit `~/.dotfiles/zsh/.zshenv` — verify cert paths match this machine (especially `CERT_KEY_FILE` date suffix)
- [ ] Edit `~/.bootstrap_rc` — verify Python path (should point to pyenv version, e.g. `$HOME/.pyenv/versions/3.12.x/bin/python3`)

## Verification Checklist

Run these to confirm everything is working:

```bash
ssh -T git@git.soma.salesforce.com          # SSH key works
gpg --list-secret-keys                        # GPG key imported
git commit --allow-empty -m "test" -S && git reset HEAD~1  # GPG signing works
source ~/.zshrc                               # Shell loads without errors
brew doctor                                   # Homebrew healthy
node --version                                # nvm/Node working
python3 --version                             # pyenv/Python working
java -version                                 # JDK installed
/usr/libexec/java_home -V                     # All JDKs visible
kubectl config get-contexts                   # Kube contexts available
ls ~/dev/salesforce/other/personal/certs/     # Certs in place
cat ~/.m2/settings.xml | head -5              # Maven settings present
```
