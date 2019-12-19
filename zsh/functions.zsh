# my custom zsh functions

# edit zsh aliases
aliases()
{
    vim $ZSH_CUSTOM/aliases.zsh
}

# edit zsh functions (this file)
func()
{
    vim $ZSH_CUSTOM/functions.zsh
}

# print colorful text
cecho()
{
    text="$1";
    echo $text | figlet | lolcat -t
}

# untar a file
untar()
{
    file="$1";
    tar -xzvf $file
}

# search stack overflow for how to do something in a language
how_in()
{
  where="$1"; shift
  IFS=+ curl "https://cht.sh/$where/ $*"
}

# update custom oh-my-zsh plugins
update_plugins() 
{
    printf "\n${BLUE}%s${NORMAL}\n" "Updating custom plugins"

    for plugin in $ZSH_CUSTOM/plugins/*; do
        if [ -d "$plugin/.git" ]; then
            printf "${YELLOW}%s${NORMAL}\n" "${plugin%/}"
            git -C "$plugin" pull
        fi
    done
}
