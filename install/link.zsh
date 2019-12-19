# link the files in here to the root directory

# bash
ln -sv ~/.dotfiles/bash/.bash_profile ~
ln -sv ~/.dotfiles/bash/.bashrc ~

# config
ln -svFh ~/.dotfiles/config ~/.config

# git
ln -sv ~/.dotfiles/git/.gitconfig ~

# vim
ln -svFh ~/.dotfiles/vim ~/.vim
ln -sv ~/.dotfiles/vim/vimrc ~/.vimrc

# zsh
ln -sv ~/.dotfiles/zsh/.p10k.zsh ~
ln -sv ~/.dotfiles/zsh/.zshrc ~
ln -sv ~/.dotfiles/zsh/aliases.zsh ~/.oh-my-zsh/custom
ln -sv ~/.dotfiles/zsh/functions.zsh ~/.oh-my-zsh/custom
ln -sv ~/.dotfiles/zsh/shortcuts.zsh ~/.oh-my-zsh/custom

# other
ln -sv ~/.dotfiles/other/.eslintrc.js ~
ln -sv ~/.dotfiles/other/settings.json ~/Library/Application\ Support/Code/User
ln -sv ~/.dotfiles/other/.always_forget.txt ~
