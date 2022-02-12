# link the files in here to the root directory

# bash
ln -svFh ~/dev/projects/dotfiles/bash/.bash_profile ~
ln -svFh ~/dev/projects/dotfiles/bash/.bashrc ~

# config
ln -svFh ~/dev/projects/dotfiles/config ~/.config

# git
ln -svFh ~/dev/projects/dotfiles/git/.gitconfig ~

# vim
ln -svFh ~/dev/projects/dotfiles/vim ~/.vim
ln -svFh ~/dev/projects/dotfiles/vim/vimrc ~/.vimrc

# zsh
ln -svFh ~/dev/projects/dotfiles/zsh/.p10k.zsh ~
ln -svFh ~/dev/projects/dotfiles/zsh/.zshrc ~
ln -svFh ~/dev/projects/dotfiles/zsh/aliases.zsh ~/.zsh/aliases.zsh
ln -svFh ~/dev/projects/dotfiles/zsh/functions.zsh ~/.zsh/functions.zsh
ln -svFh ~/dev/projects/dotfiles/zsh/shortcuts.zsh ~/.shortcuts.zsh

# other
ln -svFh ~/dev/projects/dotfiles/other/.eslintrc.js ~
ln -svFh ~/dev/projects/dotfiles/other/.always_forget.txt ~
ln -svFh ~/dev/projects/dotfiles/other/settings.json ~/Library/Application\ Support/Code/User
ln -svFh ~/dev/projects/dotfiles/other/itermprofiles.json ~/Library/Application\ Support/iTerm2/DynamicProfiles
