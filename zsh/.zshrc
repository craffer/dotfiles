# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block, everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to your oh-my-zsh installation.
export ZSH="/Users/conorrafferty/.oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"

# Case-sensitive completion must be off. _ and - will be interchangeable.
HYPHEN_INSENSITIVE="true"

# Disable auto-setting terminal title.
DISABLE_AUTO_TITLE="true"

# lazyload nvm
# all props goes to http://broken-by.me/lazy-load-nvm/
# grabbed from reddit @ https://www.reddit.com/r/node/comments/4tg5jg/lazy_load_nvm_for_faster_shell_start/
declare -a NODE_GLOBALS=(`find ~/.nvm/versions/node -maxdepth 3 -type l -wholename '*/bin/*' | xargs -n1 basename | sort | uniq`)

NODE_GLOBALS+=("node")
NODE_GLOBALS+=("nvm")

load_nvm () {
    export NVM_DIR=~/.nvm
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
}

for cmd in "${NODE_GLOBALS[@]}"; do
    eval "${cmd}(){ unset -f ${NODE_GLOBALS}; load_nvm; ${cmd} \$@ }"
done

# set JAVA environment variable
export JAVA_HOME=$(/usr/libexec/java_home)

# Preferred editor for local and remote sessions
export EDITOR='vim'

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

# set CPATH for Xcode headers
export CPATH="$(xcrun --show-sdk-path)/usr/include"

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

# tab completion for colorls
source $(dirname $(gem which colorls))/tab_complete.sh

# PATH stuff to make ruby gems work (colorls)
export PATH="/usr/local/opt/ruby/bin:$PATH"
export PATH=~/.gem/ruby/2.6.0/bin:$PATH

# reduce indents
export ZLE_RPROMPT_INDENT=0.75
export ZLE_LPROMPT_INDENT=0.75

# P10k customization. To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# hook direnv into shell
eval "$(direnv hook zsh)"
