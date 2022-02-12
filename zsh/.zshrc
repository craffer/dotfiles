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

# set JAVA environment variable
export JAVA_HOME=$(/usr/libexec/java_home)

# Preferred editor for local and remote sessions
export EDITOR='vim'

# set CPATH for Xcode headers
export CPATH="$(xcrun --show-sdk-path)/usr/include"

# add Rust
export PATH="$HOME/.cargo/bin:$PATH"

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
source ~/.zsh/functions.zsh
source ~/.shortcuts.zsh

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

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

### End of Zinit's installer chunk

### Zinit plugins
zinit light zsh-users/zsh-autosuggestions
zinit light zdharma-continuum/fast-syntax-highlighting
zinit light lukechilds/zsh-nvm

zinit ice depth=1; zinit light romkatv/powerlevel10k
### End of Zinit plugins

# Enable Ctrl-x-e to edit command line
autoload -U edit-command-line
# Vi style:
zle -N edit-command-line
bindkey '^xe' edit-command-line
bindkey '^x^e' edit-command-line

export NVM_LAZY_LOAD=true
export GPG_TTY=$(tty)
