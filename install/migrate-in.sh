#!/bin/bash
# migrate-in.sh — Run on NEW Mac after migrate-out.sh has transferred files directly
# Most files are already in their final locations. This script handles:
# - Homebrew install + packages
# - GPG import
# - Dotfile symlinks + zsh setup
# - VS Code extensions
# - macOS defaults
# - Cloning remaining repos from remote
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== MacBook Migration: New Mac Setup ==="
echo ""

# ─── Helper ───
confirm() {
    read -r -p "$1 [Y/n] " response
    case "$response" in
        [nN][oO]|[nN]) return 1 ;;
        *) return 0 ;;
    esac
}

# ─── Step 1: Homebrew ───
if ! command -v brew &> /dev/null; then
    echo "=== Step 1: Installing Homebrew ==="
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    echo "=== Step 1: Homebrew already installed ==="
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# ─── Step 2: GPG Import ───
echo ""
echo "=== Step 2: Importing GPG keys ==="
if [ -d ~/migration/gpg ]; then
    brew install gnupg pinentry-mac 2>/dev/null || true
    gpg --import ~/migration/gpg/gpg-public.asc 2>/dev/null || true
    gpg --import ~/migration/gpg/gpg-private.asc 2>/dev/null || true
    mkdir -p ~/.gnupg
    cp ~/migration/gpg/gpg-agent.conf ~/.gnupg/ 2>/dev/null || true
    echo -e "5\ny\n" | gpg --command-fd 0 --expert --edit-key AC9024ABBF280C8A trust quit 2>/dev/null || \
        echo "Set GPG trust manually: gpg --edit-key AC9024ABBF280C8A → trust → 5 → quit"
    echo "GPG keys imported."
else
    echo "No GPG export found at ~/migration/gpg — skipping."
fi

# ─── Step 3: Brew Packages ───
echo ""
echo "=== Step 3: Installing Homebrew packages ==="
BREWFILE="${HOME}/migration/inventories/Brewfile"
if [ -f "$BREWFILE" ]; then
    echo "Brewfile at: $BREWFILE"
    echo "Review/edit it before installing if needed."
    if confirm "Install from Brewfile now?"; then
        brew bundle install --file="$BREWFILE" || echo "Some packages may have failed — check output above."
    else
        echo "Skipped. Run later with: brew bundle install --file=$BREWFILE"
    fi
else
    echo "No Brewfile found — skipping."
fi

# ─── Step 4: macOS Defaults ───
echo ""
echo "=== Step 4: macOS system defaults ==="
if [ -f ~/migration/config/.macos.zsh ]; then
    if confirm "Apply macOS system defaults (screenshots, Finder, etc.)?"; then
        bash ~/migration/config/.macos.zsh || true
        echo "macOS defaults applied."
    fi
fi

echo ""
echo "=== Step 4b: Keyboard remap ==="
if confirm "Remap Caps Lock to Escape?"; then
    if [ -f "$SCRIPT_DIR/remap-caps-lock-to-esc.sh" ]; then
        bash "$SCRIPT_DIR/remap-caps-lock-to-esc.sh"
    else
        echo "Remap script not found at $SCRIPT_DIR/remap-caps-lock-to-esc.sh"
    fi
fi

# ─── Step 5: VS Code Extensions ───
echo ""
echo "=== Step 5: VS Code extensions ==="
EXTFILE="${HOME}/migration/inventories/vscode-extensions.txt"
if command -v code &> /dev/null && [ -f "$EXTFILE" ]; then
    if confirm "Install VS Code extensions?"; then
        while read -r ext; do
            code --install-extension "$ext" 2>/dev/null || echo "  Failed: $ext"
        done < "$EXTFILE"
    fi
else
    echo "VS Code not found or extension list missing. Install extensions later."
fi

# ─── Step 6: Dotfile Symlinks + Zsh ───
echo ""
echo "=== Step 6: Setting up dotfiles & zsh ==="
if [ -d ~/.dotfiles ]; then
    # Create .zshenv from template if it doesn't exist
    if [ -f ~/.dotfiles/zsh/.zshenv.template ] && [ ! -f ~/.dotfiles/zsh/.zshenv ]; then
        cp ~/.dotfiles/zsh/.zshenv.template ~/.dotfiles/zsh/.zshenv
        echo "Created .zshenv from template — EDIT ~/.dotfiles/zsh/.zshenv to fill in cert paths"
    fi

    # Create .bootstrap_rc from template if it doesn't exist
    if [ -f ~/.dotfiles/zsh/.bootstrap_rc.template ] && [ ! -f ~/.bootstrap_rc ]; then
        cp ~/.dotfiles/zsh/.bootstrap_rc.template ~/.bootstrap_rc
        echo "Created .bootstrap_rc from template — EDIT ~/.bootstrap_rc to fill in Python path"
    fi

    # Run symlinks
    bash ~/.dotfiles/install/link.sh || true
    echo "Dotfiles linked."
else
    echo "WARNING: ~/.dotfiles not found. Was the dotfiles repo transferred?"
fi

# ─── Step 7: NVM & Node ───
echo ""
echo "=== Step 7: NVM & Node.js ==="
echo "NVM will be installed via zinit (zsh-nvm plugin) when zsh loads."
echo "After restarting your shell, run: nvm install --lts && nvm alias default lts/*"

# ─── Step 8: pyenv ───
echo ""
echo "=== Step 8: pyenv ==="
if command -v pyenv &> /dev/null; then
    echo "pyenv is installed. Install Python with: pyenv install 3.12 && pyenv global 3.12"
else
    echo "pyenv not found. It should be installed via Brewfile."
fi

# ─── Step 9: iTerm2 Profiles ───
echo ""
echo "=== Step 9: iTerm2 profiles ==="
if [ -f ~/migration/config/itermprofiles.json ]; then
    mkdir -p ~/Library/Application\ Support/iTerm2/DynamicProfiles/
    cp ~/migration/config/itermprofiles.json ~/Library/Application\ Support/iTerm2/DynamicProfiles/
    echo "iTerm2 profiles installed."
fi

# ─── Step 10: Clone remaining repos ───
echo ""
echo "=== Step 10: Clone remaining repos ==="
echo "See ~/.dotfiles/install/README-NEW-MAC.md Step 18 for the full list of git clone commands."
echo "Or run Claude Code and ask it to clone them for you."

# ─── Done ───
echo ""
echo "=========================================="
echo "=== Setup complete! ==="
echo "=========================================="
echo ""
echo "Remaining manual steps:"
echo "  1. Edit ~/.dotfiles/zsh/.zshenv — fill in cert paths"
echo "  2. Edit ~/.bootstrap_rc — fill in Python path"
echo "  3. Open a new terminal to load zsh config"
echo "  4. Run: nvm install --lts && nvm alias default lts/*"
echo "  5. Clone remaining repos (see README-NEW-MAC.md Step 18)"
echo "  6. Sign into: Chrome, Firefox, 1Password, Bitwarden, Spotify"
echo "  7. Install from IT Self Service: Falcon, Okta, Zscaler, Cisco, Slack, Zoom"
echo "  8. Install JetBrains Toolbox + IntelliJ IDEA"
echo "  9. Install AWS WorkSpaces"
echo "  10. Verify Caps Lock sends Escape"
echo ""
echo "Verify with:"
echo "  ssh -T git@git.soma.salesforce.com"
echo "  gpg --list-secret-keys"
echo "  source ~/.zshrc"
echo "  brew doctor"
echo "  java -version"
