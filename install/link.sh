# link the files in here to the root directory

# bash
ln -svF ~/.dotfiles/bash/.bash_profile ~
ln -svF ~/.dotfiles/bash/.bashrc ~

# config
ln -svF ~/.dotfiles/config ~/.config

# git
ln -svF ~/.dotfiles/git/.gitconfig ~

# vim
ln -svF ~/.dotfiles/vim ~/.vim
ln -svF ~/.dotfiles/vim/vimrc ~/.vimrc

# zsh
ln -svF ~/.dotfiles/zsh/.p10k.zsh ~
ln -svF ~/.dotfiles/zsh/.zshrc ~
ln -svF ~/.dotfiles/zsh/aliases.zsh ~/.oh-my-zsh/custom
ln -svF ~/.dotfiles/zsh/functions.zsh ~/.oh-my-zsh/custom
ln -svF ~/.dotfiles/zsh/shortcuts.zsh ~/.oh-my-zsh/custom

# other
ln -svF ~/.dotfiles/other/.eslintrc.js ~
ln -svF ~/.dotfiles/other/.always_forget.txt ~
ln -svF ~/.dotfiles/other/settings.json ~/Library/Application\ Support/Code/User
ln -svF ~/.dotfiles/other/itermprofiles.json ~/Library/Application\ Support/iTerm2/DynamicProfiles
