# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block, everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="/Users/conorrafferty/.oh-my-zsh"

# good theme: common
ZSH_THEME="powerlevel10k/powerlevel10k"

# Set list of themes to pick from when loading at random
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Case-sensitive completion must be off. _ and - will be interchangeable.
HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable auto-setting terminal title.
DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots while waiting for completion
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

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

export JAVA_HOME=$(/usr/libexec/java_home)

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

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
   export EDITOR='vim'
else
   export EDITOR='vim'
fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

# set CPATH for Xcode headers
export CPATH="$(xcrun --show-sdk-path)/usr/include"

eval "$(thefuck --alias)"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
alias publicip="curl https://ipinfo.io/ip"
alias activate="source env/bin/activate"
alias ls="colorls"
alias weather="curl http://wttr.in/ann_arbor\?Tn1"
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias smell="say --interactive=green -v Albert smell"
alias kill_vm="VBoxManage controlvm 388-kali poweroff"
alias vm_ssh="ssh -p 2222 conor@127.0.0.1"
alias 485tree="tree --matchdirs -I 'env|__pycache__|node_modules|*.egg*'"
alias notion="open /Applications/Notion.app"
alias preview="quick-look"
alias ql="quick-look"
alias mv="mv -iv"
alias cp="cp -iv"
alias vimless="/usr/share/vim/vim80/macros/less.sh"
alias tldr="tldr -t ocean"
alias googler="googler -n 3"
alias createfs="~/UofM/F19/EECS_482/p4/utility/createfs_macos"
alias showfs="~/UofM/F19/EECS_482/p4/utility/showfs_macos"
alias say="say --interactive=green"

cecho()
{
    text="$1";
    echo $text | figlet | lolcat -t
}

untar()
{
    file="$1";
    tar -xzvf $file
}

how_in()
{
  where="$1"; shift
  IFS=+ curl "https://cht.sh/$where/ $*"
}

precmd() {
  # sets the tab title to current dir
  echo -ne "\e]1;${PWD##*/}\a"
}

# expand aliases into what they are on space
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

# enable pure theme, if uncommented make sure theme = "" and change font
# autoload -U promptinit; promptinit
# prompt pure
# # disable title feature
# prompt_pure_set_title() {}

# tab completion for colorls
source $(dirname $(gem which colorls))/tab_complete.sh
source ~/.purepower

# PATH stuff
export PATH="/usr/local/opt/ruby/bin:$PATH"
export PATH=~/.gem/ruby/2.6.0/bin:$PATH

export FS_CRYPT=CLEAR

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
