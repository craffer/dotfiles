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

vault-login()
{
    # Export the AWS credentials for one of the roles with the appropriate read/write privilege before running the commands.
    # Or, if you are using vaultconf-basic* pipelines, use *PCSKDeveloperRole*
    if [ $# -eq 2 ]
    then
        export VAULT_ROLE=$2
    else
        export VAULT_ROLE=kv_loganalytics-rw
    fi
    export FI=$1
    export AWS_REGION=us-east-1 # STS service is always in us-east-1
    if [ $FI = "aws-giadev1-usgoveast1" ]
    then
        echo "In GIA2H Dev"
        export AWS_REGION=us-gov-east-1
        export AWS_STS_REGIONAL_ENDPOINTS=regional
    fi
    export AWS_LOGIN_HEADER=api.vault.secrets.$FI.aws.sfdc.cl
    export VAULT_SKIP_VERIFY=1
    export VAULT_ADDR=https://$AWS_LOGIN_HEADER
    export VAULT_TOKEN=$(vault login --token-only --method=aws header_value=$AWS_LOGIN_HEADER role=$VAULT_ROLE region=$AWS_REGION)
}
