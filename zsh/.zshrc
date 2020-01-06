# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block, everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to your oh-my-zsh installation.
export ZSH="/home/craffer/.oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"

# Case-sensitive completion must be off. _ and - will be interchangeable.
HYPHEN_INSENSITIVE="true"

# Disable auto-setting terminal title.
DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# set JAVA environment variable

# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
plugins=(
    colored-man-pages
    command-not-found
    git
    gitfast
    osx
    tmux
    zsh-autosuggestions
    zsh-output-highlighting
    zsh-syntax-highlighting
)

# Activate oh-my-zsh manager
source $ZSH/oh-my-zsh.sh

# User configuration

# Preferred editor for local and remote sessions
export EDITOR='vim'

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

# sets the terminal tab title to current dir
precmd() {
  echo -ne "\e]1;${PWD##*/}\a"
}

# expand aliases into what they stand for on space
expand-alias() {
    zle _expand_alias
    zle self-insert
}
zle -N expand-alias
bindkey -M main ' ' expand-alias

# speeds up pasting
pasteinit() {
  OLD_SELF_INSERT=${${(s.:.)widgets[self-insert]}[2,3]}
  zle -N self-insert url-quote-magic
}
pastefinish() {
  zle -N self-insert $OLD_SELF_INSERT
}
zstyle :bracketed-paste-magic paste-init pasteinit
zstyle :bracketed-paste-magic paste-finish pastefinish

# P10k customization. To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ls colors
export LS_COLORS='di=34:fi=0:ln=35:pi=5:so=5:bd=5:cd=5:or=31:mi=0:ex=33:*.rpm=90'
alias ls="ls --color"

# Tell ZSH not to exit when an error happens; only exit on quit
setopt no_err_exit

# hook direnv into shell
eval "$(direnv hook zsh)"
