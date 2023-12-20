source /Users/conor.rafferty/.bootstrap_rc
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block, everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# enable auto-complete from middle of filename
zstyle ':completion:*' completer _complete
zstyle ':completion:*' matcher-list '' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' '+l:|=* r:|=*'
autoload -Uz compinit
compinit

# Case-sensitive completion must be off. _ and - will be interchangeable.
HYPHEN_INSENSITIVE="true"
# Disable auto-setting terminal title.
DISABLE_AUTO_TITLE="true"
# `dirname` is equivalent to `cd dirname`
setopt AUTO_CD
# if history needs to be trimmed, evict dupes first
setopt HIST_EXPIRE_DUPS_FIRST
# print hex numbers as 0xFF instead of 16#FF
setopt C_BASES
# allow vi mode
setopt VI
# turn on timestamps in history
setopt EXTENDED_HISTORY

export JAVA_8_HOME="/Library/Java/JavaVirtualMachines/zulu8.72.0.18-sa-jdk8.0.382-macosx_aarch64/zulu-8.jdk/Contents/Home"
export JAVA_11_HOME="/Library/Java/JavaVirtualMachines/sfdc-openjdk_11.0.20.1.101_11.67.16.jdk/Contents/Home"
export JAVA_17_HOME="/Library/Java/JavaVirtualMachines/zulu17.46.20-sa-jdk17.0.9-macosx_aarch64/zulu-17.jdk/Contents/Home"

# set default Java home to Java 11
export JAVA_HOME=$JAVA_11_HOME

export XDG_CONFIG_HOME="~/"

alias java8='export JAVA_HOME=$JAVA_8_HOME'
alias java11='export JAVA_HOME=$JAVA_11_HOME'
alias java17='export JAVA_HOME=$JAVA_17_HOME'

# Preferred editor for local and remote sessions
export EDITOR='vim'

# set CPATH for Xcode headers
export CPATH="$(xcrun --show-sdk-path)/usr/include"

# add Rust
export PATH="$HOME/.cargo/bin:$PATH"

export SPINNAKER_HOME="/Users/conor.rafferty/dev/salesforce/other/sfcd/spinnaker"

# update PATH to include personal bin if it exists
[ -d "$HOME/bin" ] && PATH="$HOME/bin:$PATH"

# add spark to PATH
export PATH=$PATH:/usr/local/spark/bin

# needed to make `fuck` command work
eval $(thefuck --alias)

# sets the terminal tab title to current dir
precmd() {
  echo -ne "\e]1;${PWD##*/}\a"
}

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


# make ls and lsd pretty
export LS_COLORS="di=34:fi=0:ln=35:or=31:ex=33"

# reduce indents
export ZLE_RPROMPT_INDENT=0.75
export ZLE_LPROMPT_INDENT=0.75

# P10k customization. To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# hook direnv into shell
eval "$(direnv hook zsh)"

# source our various aliases and functions
source ~/.zsh/aliases.zsh
source ~/.dotfiles/zsh/functions.zsh ~/.zsh/functions.zsh
source ~/.dotfiles/zsh/shortcuts.zsh ~/.shortcuts.zsh

### Added by Zinit's installer
if [[ ! -f $HOME/.zinit/bin/zinit.zsh ]]; then
    print -P "%F{33}▓▒░ %F{220}Installing DHARMA Initiative Plugin Manager (zdharma-continuum/zinit)…%f"
    command mkdir -p "$HOME/.zinit" && command chmod g-rwX "$HOME/.zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.zinit/bin" && \
        print -P "%F{33}▓▒░ %F{34}Installation successful.%f" || \
        print -P "%F{160}▓▒░ The clone has failed.%f"
fi
source "$HOME/.zinit/bin/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit
### End of Zinit installer's chunk

export NVM_LAZY_LOAD=true

### Zinit plugins
zinit light zsh-users/zsh-autosuggestions
zinit light zdharma-continuum/fast-syntax-highlighting
zinit light lukechilds/zsh-nvm

# disable syntax highlighting for man pages to prevent hanging
# see https://github.com/zdharma-continuum/fast-syntax-highlighting/issues/179
# FAST_HIGHLIGHT[chroma-man]=

zinit ice depth=1; zinit light romkatv/powerlevel10k
### End of Zinit plugins

# if [ -f /Users/conor.rafferty/.ansible/env.sh ]; then
#     . /Users/conor.rafferty/.ansible/env.sh
#     # To disable ansible, comment out, but do not delete the following:
#     activate_ansible
# fi


# Enable Ctrl-x-e to edit command line
autoload -U edit-command-line
# Vi style:
zle -N edit-command-line
bindkey '^xe' edit-command-line
bindkey '^x^e' edit-command-line
