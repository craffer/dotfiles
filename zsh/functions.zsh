# my custom zsh functions

# edit zsh aliases
aliases()
{
    vim ~/.zsh/aliases.zsh
}

# edit zsh functions (this file)
func()
{
    vim ~/.zsh/functions.zsh
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

upgrade_shell()
{
    echo "Updating homebrew..."
    brew update && brew upgrade && brew cleanup
    echo "Updating zsh plugins..."
    zinit self-update
    zinit update --all
    echo "Updating homebrew cask apps..."
    brew upgrade --cask
}

quick-look()
{
    qlmanage -p "$@" >& /dev/null &
}

activate_blt()
{
    source ~/blt/env.sh
}
