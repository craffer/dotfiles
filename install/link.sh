# link the files in here to the root directory

# bash
ln -svFh ~/.dotfiles/bash/.bash_profile ~
ln -svFh ~/.dotfiles/bash/.bashrc ~

# config
ln -svFh ~/.dotfiles/config ~/.config

# git
ln -svFh ~/.dotfiles/git/.gitconfig ~

# vim
ln -svFh ~/.dotfiles/vim ~/.vim
ln -svFh ~/.dotfiles/vim/vimrc ~/.vimrc

# zsh
ln -svFh ~/.dotfiles/zsh/.p10k.zsh ~
ln -svFh ~/.dotfiles/zsh/.zshrc ~
ln -svFh ~/.dotfiles/zsh/aliases.zsh ~/.zsh/aliases.zsh
ln -svFh ~/.dotfiles/zsh/functions.zsh ~/.zsh/functions.zsh
ln -svFh ~/.dotfiles/zsh/shortcuts.zsh ~/.shortcuts.zsh

# other
ln -svFh ~/.dotfiles/other/.eslintrc.js ~
ln -svFh ~/.dotfiles/other/.always_forget.txt ~
ln -svFh ~/.dotfiles/other/settings.json ~/Library/Application\ Support/Code/User
ln -svFh ~/.dotfiles/other/itermprofiles.json ~/Library/Application\ Support/iTerm2/DynamicProfiles
