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

# k8s contexts
_k8s_context_setup() {
    local env=$1
    local aws_context="moncloud_grafana_${env}_uswest2_monitoring"
    local directory="$HOME/dev/salesforce/other/personal/k8s-contexts/${env}-fkp-moncloud-api"
    
    cd "$directory"
    echo "Requesting & exporting PCSKDeveloper credentials for $aws_context"
    eval $(falcon credentials request \
        --context "$aws_context" \
        --role PCSKDeveloperRole \
        --duration 744h \
        --major-reason "Development" \
        --details "Grafana developer, need kubectl access" \
        | grep "export AWS_" \
        | sed 's/INFO  Use below shell command to export AWS Credentials for account.*//')
}

_k8s_read_only_setup() {
    local aws_context=$1
    
    cd ~/dev/salesforce/other/personal/tools/periscope
    falcon context apply "$aws_context"
    falcon kube config
    kubectl config set-context --current --namespace moncloud-api
}

kdev1() {
    _k8s_context_setup "dev1"
}

ktest1() {
    _k8s_context_setup "test1"
}

kstage() {
    _k8s_read_only_setup "moncloud_grafana_aws_esvc1_useast2_monitoring_s"
}

kprod() {
    _k8s_read_only_setup "moncloud_grafana_aws_esvc1_useast2_monitoring"
}
