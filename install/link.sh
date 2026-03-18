#!/bin/bash
# Link dotfiles to their expected locations
# Safe to re-run: backs up existing files, uses -sf to overwrite symlinks

set -euo pipefail

backup_and_link() {
  local src="$1"
  local dest="$2"
  if [ -e "$dest" ] && [ ! -L "$dest" ]; then
    mv "$dest" "${dest}.bak"
    echo "Backed up: $dest -> ${dest}.bak"
  fi
  ln -sf "$src" "$dest"
  echo "Linked: $dest -> $src"
}

# bash
backup_and_link ~/.dotfiles/bash/.bash_profile ~/.bash_profile
backup_and_link ~/.dotfiles/bash/.bashrc ~/.bashrc

# config — link individual subdirs rather than replacing ~/.config
mkdir -p ~/.config
for dir in ~/.dotfiles/config/*/; do
  dirname=$(basename "$dir")
  backup_and_link "$dir" ~/.config/"$dirname"
done
# also handle config files (not dirs)
for f in ~/.dotfiles/config/*; do
  [ -d "$f" ] && continue
  fname=$(basename "$f")
  backup_and_link "$f" ~/.config/"$fname"
done

# git
backup_and_link ~/.dotfiles/git/.gitconfig ~/.gitconfig

# vim
backup_and_link ~/.dotfiles/vim ~/.vim
backup_and_link ~/.dotfiles/vim/vimrc ~/.vimrc

# zsh
backup_and_link ~/.dotfiles/zsh/.p10k.zsh ~/.p10k.zsh
backup_and_link ~/.dotfiles/zsh/.zshrc ~/.zshrc
backup_and_link ~/.dotfiles/zsh/.zshenv ~/.zshenv
mkdir -p ~/.zsh
backup_and_link ~/.dotfiles/zsh/aliases.zsh ~/.zsh/aliases.zsh
backup_and_link ~/.dotfiles/zsh/functions.zsh ~/.zsh/functions.zsh
backup_and_link ~/.dotfiles/zsh/shortcuts.zsh ~/.shortcuts.zsh

# claude
mkdir -p ~/.claude
backup_and_link ~/.dotfiles/claude/skills ~/.claude/skills
backup_and_link ~/.dotfiles/claude/commands ~/.claude/commands

# other
backup_and_link ~/.dotfiles/other/.eslintrc.js ~/.eslintrc.js 2>/dev/null || true
backup_and_link ~/.dotfiles/other/.always_forget.txt ~/.always_forget.txt 2>/dev/null || true

# VS Code settings
mkdir -p ~/Library/Application\ Support/Code/User
backup_and_link ~/.dotfiles/other/settings.json ~/Library/Application\ Support/Code/User/settings.json

# iTerm2 profiles
mkdir -p ~/Library/Application\ Support/iTerm2/DynamicProfiles
backup_and_link ~/.dotfiles/other/itermprofiles.json ~/Library/Application\ Support/iTerm2/DynamicProfiles/itermprofiles.json
