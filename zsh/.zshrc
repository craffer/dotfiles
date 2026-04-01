source "$HOME/.bootstrap_rc"
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

export JAVA_8_HOME="/Library/Java/JavaVirtualMachines/openjdk1.8.0.401_8.75.0.16_aarch64/zulu-8.jdk/Contents/Home"
export JAVA_11_HOME="/Library/Java/JavaVirtualMachines/openjdk_11.0.21.0.101_11.69.14_aarch64/zulu-11.jdk/Contents/Home"
export JAVA_17_HOME="/Library/Java/JavaVirtualMachines/openjdk_17.0.10_17.48.16_aarch64/zulu-17.jdk/Contents/Home"
export JAVA_24_HOME="/Library/Java/JavaVirtualMachines/zulu24.30.11-ca-jdk24.0.1-macosx_aarch64/zulu-24.jdk/Contents/Home"
export JAVA_25_HOME="/Library/Java/JavaVirtualMachines/sfdc-jdk-zulu-25.0.1.0.101_17-macos_aarch64/zulu-25.jdk/Contents/Home"

# set default Java home to Java 17
export JAVA_HOME=$JAVA_17_HOME

export XDG_CONFIG_HOME=~/

alias java8='export JAVA_HOME=$JAVA_8_HOME'
alias java11='export JAVA_HOME=$JAVA_11_HOME'
alias java17='export JAVA_HOME=$JAVA_17_HOME'
alias java24='export JAVA_HOME=$JAVA_24_HOME'
alias java25='export JAVA_HOME=$JAVA_25_HOME'

# use Apple Silicon brew
eval "$(/opt/homebrew/bin/brew shellenv)"

# enable falcon cli autocompletion
# eval "$(falcon completion zsh)"

# my Splunk/Aloha username
export USERNAME="conor.rafferty"

# falcon inspect: skip upstream remote prompt (repo has origin=fork, upstream=canonical)
export UPSTREAM_REPO_NAME=upstream

# Huron login URL
export HURON_LOGIN_URL="https://bdmpresto-access-server.sfproxy.uip.aws-esvc1-useast2.aws.sfdc.cl/"

# Preferred editor for local and remote sessions
export EDITOR='vim'

# set CPATH for Xcode headers
export CPATH="$(xcrun --show-sdk-path)/usr/include"

# add Rust
export PATH="$HOME/.cargo/bin:$PATH"

export SPINNAKER_HOME="$HOME/dev/salesforce/other/sfcd/spinnaker"

# update PATH to include personal bin if it exists
[ -d "$HOME/bin" ] && PATH="$HOME/bin:$PATH"

# needed to make `fuck` command work (interactive-only: spawns a Python process)
[[ -o interactive ]] && eval $(thefuck --alias)

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
source ~/.dotfiles/zsh/secrets.zsh
source ~/.dotfiles/zsh/.zshenv

# Enable Ctrl-x-e to edit command line
autoload -U edit-command-line
# Vi style:
zle -N edit-command-line
bindkey '^xe' edit-command-line
bindkey '^x^e' edit-command-line

# zinit plugins, p10k prompt, pyenv, and nvm are interactive-only —
# no need to load them in subshells spawned by git, npm, etc.
if [[ -o interactive ]]; then
  ### Added by Zinit's installer
  if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
      print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
      command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
      command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
          print -P "%F{33} %F{34}Installation successful.%f%b" || \
          print -P "%F{160} The clone has failed.%f%b"
  fi

  source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
  autoload -Uz _zinit
  (( ${+_comps} )) && _comps[zinit]=_zinit

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

  eval "$(pyenv init -)"
fi

# conda shell integration is interactive-only (slow and not needed in subshells)
if [[ -o interactive ]]; then
  unset CONDA_SHLVL
  # >>> conda initialize >>>
  # !! Contents within this block are managed by 'conda init' !!
  __conda_setup="$('/opt/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
  if [ $? -eq 0 ]; then
      eval "$__conda_setup"
  else
      if [ -f "/opt/miniconda3/etc/profile.d/conda.sh" ]; then
          . "/opt/miniconda3/etc/profile.d/conda.sh"
      else
          export PATH="/opt/miniconda3/bin:$PATH"
      fi
  fi
  unset __conda_setup
  # <<< conda initialize <<<
fi

# rbenv for Ruby version management
eval "$(rbenv init - zsh)"

export PATH="$HOME/.local/bin:$PATH"

# fix for Cursor cd issues
# see https://forum.cursor.com/t/numerous-error-warning-messages-in-shell-output/134490/4
export HEXDUMP_PATH=/usr/bin/hexdump


# gvm is interactive-only: its helper functions call _encode/_decode which are
# not available in non-interactive subshells, causing spurious warnings
[[ -o interactive && -s "/Users/conor.rafferty/.gvm/scripts/gvm" ]] && source "/Users/conor.rafferty/.gvm/scripts/gvm"
# BEGIN ANSIBLE MANAGED BLOCK - GO ENVIRONMENT
export GOPRIVATE=git.soma.salesforce.com
export GOPROXY=https://nexus-proxy.repo.local.sfdc.net/nexus/repository/go-proxy
# END ANSIBLE MANAGED BLOCK - GO ENVIRONMENT

export PATH="$PATH:$HOME/go/bin"

export PATH="$PATH:$HOME/Library/Application Support/JetBrains/Toolbox/scripts"
# devbar-managed-start
export NODE_EXTRA_CA_CERTS="$HOME/.devbar/certs/corporate-ca-bundle.pem"
# devbar-managed-end
