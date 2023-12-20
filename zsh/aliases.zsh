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
alias notion="open /Applications/Notion.app"
alias chrome="open -a 'Google Chrome'"

# schoolwork
alias kill_vm="VBoxManage controlvm 388-kali poweroff"
alias vm_ssh="ssh -p 2222 conor@127.0.0.1"
alias 485tree="tree --matchdirs -I 'env|__pycache__|node_modules|*.egg*'"
alias createfs="~/UofM/F19/EECS_482/p4/utility/createfs_macos"
alias showfs="~/UofM/F19/EECS_482/p4/utility/showfs_macos"

# directory shortcuts
alias projects="cd ~/Other/coding/projects"
alias coding="cd ~/Other/coding/"
alias sf="cd ~/dev/salesforce/"
alias dotfiles="cd ~/.dotfiles"
alias uofm="cd ~/UofM"
alias ufom="cd ~/UofM"
alias f18="cd ~/UofM/F18"
alias w19="cd ~/UofM/W19"
alias f19="cd ~/UofM/F19"
alias w20="cd ~/UofM/W20"

# other
alias weather="curl http://wttr.in/ann_arbor\?Tn1"
alias smell="say --interactive=green -v Albert smell"
alias publicip="curl https://ipinfo.io/ip"
alias activate="source env/bin/activate"
alias vimless="/usr/share/vim/vim80/macros/less.sh"
alias googler="googler -n 3"
alias say="say --interactive=green"
alias f="fuck"
alias mergepdf="/System/Library/Automator/Combine\ PDF\ Pages.action/Contents/Resources/join.py -vo"
alias dossh="ssh craffer@134.209.43.248"
alias tomcat="catalina"

# salesforce specific
alias huron="trino --server https://bdmpresto-huron-query.presto.uip.aws-esvc1-useast2.aws.sfdc.cl:443 \
--truststore-path /Users/conor.rafferty/dev/salesforce/other/personal/certs/huron/cacerts.pem \
--catalog coreapplogs \
--schema log_record_types \
--user conor.rafferty \
--password"
alias fdev1='ssh -t bastion.syssec.monitoring.fdev1-uswest2.aws.sfdc.cl "tmux -CC new -A -s tmux-main"'
alias dev1='ssh -t bastion.syssec.monitoring.dev1-uswest2.aws.sfdc.cl "tmux -CC new -A -s tmux-main"'
