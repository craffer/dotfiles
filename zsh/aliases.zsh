# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes.
# For a full list of active aliases, run `alias`.

# core
alias ls="lsd"
alias la="lsd -a"
alias ll="lsd -la"
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias mv="mv -iv"
alias cp="cp -iv"
alias v="vim"
alias x+="chmod +x"

# macos
alias ql="quick-look"
alias preview="quick-look"
alias chrome="open -a 'Google Chrome'"

# directory shortcuts
alias sf="cd ~/dev/salesforce/"
alias dotfiles="cd ~/.dotfiles"

# other
alias weather="curl http://wttr.in/ann_arbor\?Tn1"
alias publicip="curl https://ipinfo.io/ip"
alias activate="source env/bin/activate"
alias say="say --interactive=green"
alias f="fuck"
alias mergepdf="/System/Library/Automator/Combine\ PDF\ Pages.action/Contents/Resources/join.py -vo"


# salesforce specific
alias trino="/Users/conor.rafferty/dev/salesforce/other/personal/tools/trino-cli-436-executable.jar"
alias fdev1='ssh -t bastion.syssec.monitoring.fdev1-uswest2.aws.sfdc.cl "tmux -CC new -A -s tmux-main"'
alias dev1='ssh -t bastion.syssec.monitoring.dev1-uswest2.aws.sfdc.cl "tmux -CC new -A -s tmux-main"'
alias orc-tools="java -jar ~/dev/salesforce/other/personal/tools/orc-tools/orc-tools-2.0.1-uber.jar"
