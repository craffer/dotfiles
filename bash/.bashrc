eval "$(thefuck --alias)"
export CLICOLOR=1
export LSCOLORS=ExFxBxDxCxegedabagacad
alias ssh='TERM=xterm-256color ssh'
export PS1="\W \$ ";clear;

alias publicip="curl https://ipinfo.io/ip"
alias activate="source env/bin/activate"
alias ls="ls -G"

alias weather="curl http://wttr.in/ann_arbor?Tn1"
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

how_in()
{
  where="$1"; shift
  IFS=+ curl "https://cht.sh/$where/ $*"
}

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion


if [ $ITERM_SESSION_ID ]; then
    export PROMPT_COMMAND='echo -ne "\033]0;${PWD##*/}\007"'
fi

if [ -f /Users/conor.rafferty/.ansible/env.sh ]; then
    . /Users/conor.rafferty/.ansible/env.sh
    # To disable ansible, comment out, but do not delete the following:
    activate_ansible
fi
