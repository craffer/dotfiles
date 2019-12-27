# link the files in here to the root directory

# bash
ln -svFh ~/.dotfiles/bash/.bash_profile ~
ln -svFh ~/.dotfiles/bash/.bashrc ~

# config
ln -svFhFh ~/.dotfiles/config ~/.config

# git
ln -svFh ~/.dotfiles/git/.gitconfig ~

# vim
ln -svFhFh ~/.dotfiles/vim ~/.vim
ln -svFh ~/.dotfiles/vim/vimrc ~/.vimrc

# zsh
ln -svFhFh ~/.dotfiles/zsh/.p10k.zsh ~
ln -svFhFh ~/.dotfiles/zsh/.zshrc ~
ln -svFh ~/.dotfiles/zsh/aliases.zsh ~/.oh-my-zsh/custom
ln -svFh ~/.dotfiles/zsh/functions.zsh ~/.oh-my-zsh/custom
ln -svFh ~/.dotfiles/zsh/shortcuts.zsh ~/.oh-my-zsh/custom

# other
ln -svFh ~/.dotfiles/other/.eslintrc.js ~
ln -svFh ~/.dotfiles/other/.always_forget.txt ~
ln -svFh ~/.dotfiles/other/settings.json ~/Library/Application\ Support/Code/User
ln -svFh ~/.dotfiles/other/itermprofiles.json ~/Library/Application\ Support/iTerm2/DynamicProfiles
