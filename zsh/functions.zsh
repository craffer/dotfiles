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
    export FI=$1
    export AWS_REGION=us-east-1 # STS service is always in us-east-1
    if [ $# -eq 2 ]
    then
        export VAULT_ROLE=$2
    else
        export VAULT_ROLE=kv_orcapg-$FI-uip-saf-huron-1-ro
    fi
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

huron()
{
    # for metrics, use `huron metrics`
    # for tokenized core app logs, use `huron tokenized`
    # for untokenized core app logs, just use `huron`
    if [ "$#" -gt 0 ]; then
        if [ "$1" == "metrics" ]; then
            catalog="huron_iceberg"
            schema="metrics"
        elif [ "$1" == "tokenized" ]; then
            catalog="coreapplogs"
            schema="coreapplogs_tokenized"
        fi
    else
        catalog="coreapplogs"
        schema="coreapplogs_untokenized"
    fi
    
    fi="${FALCON_INSTANCE:-aws-esvc1-useast2}"
    fd="${FUNCTIONAL_DOMAIN:-uip}"
    echo $fi $fd

    trino --server https://trino-gateway.sfproxy.$fd.$fi.aws.sfdc.cl:9443 \
    --keystore-path $CERT_FILE_WITH_KEY \
    --truststore-path $CA_CERT_FILE  \
    --debug \
    --catalog "huron_iceberg" \
    --schema "metrics" \
    --user $USERNAME
}

docker-versions()
{
    # you can optionally supply the repo name, in the form monitoring/huron_dbt_client
    if [[ $# -eq 2 ]]; then
        image="$2"
    # we assume image name == repo name by default
    elif [[ $# -ne 1 ]]; then
        echo "This function requires either one or two parameters"
        return 1
    fi
    repo="$1"
    url="https://docker.repo.local.sfdc.net/v2/sfci/$repo/$image/tags/list"
    echo "Getting the 20 most recent versions for $repo $image"
    echo $url
    # here we exclude all PR images (jenkins-monitoring) and just get images that are only integers (96) or integer-hash (96-aoisdhoaidhs)
    # then we sort by the integer, and return only the 10 most recent values
    curl -s -u "$USERNAME:$DOCKER_TOKEN" $url | jq '[.tags[] | select(test("^[0-9]+(-.*)*$")) | select(startswith("jenkins-monitoring") | not)] | map({key: ., value: (. | split("-")[0] | tonumber)}) | sort_by(.value) | reverse | .[:20] | map(.key)'
}

docker-test-repo()
{
    # package the current directory as a tarball and write it to an already running Docker image
    # this is useful for testing a git repo in a Docker
    # the Docker container should already be running, i.e. with:
    # docker run -it --platform=linux/amd64 --rm --name strata-test docker.repo.local.sfdc.net/sfci/docker-images/sfdc_rhel9_python3:48 bash
    if [ "$#" -ne 1 ]; then
        echo "Usage: docker-test-repo [IMAGE NAME]"
        return 1
    fi

    container=$1

    echo "Packaging git files from this directory into a tarball"
    git archive -v -o project.tar.gz --format=tar.gz HEAD

    echo "Copying the tarball onto $container"
    docker cp project.tar.gz $container:/tmp/

    echo "Un-tarring the project to /tmp/project on the Docker image $image"
    docker exec $container bash -c "rm -rf /tmp/project && mkdir -p /tmp/project && tar -xzvf /tmp/project.tar.gz -C /tmp/project && rm /tmp/project.tar.gz"
}

dl_mover() {
  # move files from the last $1 minutes from downloads to the path at $2
  find ~/Downloads -type f -mmin -$1 -exec mv -vi {} "$2" \;
}

spinnaker-jsons() {
    if [ "$#" -ne 1 ]; then
        echo "Usage: spinnaker-jsons [JOB ID]"
        echo "You can find the job ID in the output of falcon inspect --local -v --export"
        return 1
    fi

    job_id=$1
    # get Spinnaker validation job details from pgaas
    download_url=$(curl -H "Authorization: Bearer $(falcon login --output=json | jq -r .token)" https://dxgateway.sfproxy.controltelemetry.aws-esvc1-useast2.aws.sfdc.cl/pgaas/validations/$job_id | jq -r .download_url)
    echo "Download URL: " $download_url

    # download the PGaaS output
    dl_loc="$HOME/Downloads/pipeline-validation.tar.gz"
    curl -L "$download_url" --output $dl_loc

    mkdir -p spinnaker-output && tar -xzvf $dl_loc -C spinnaker-output && trash $dl_loc
}

# k8s contexts
_k8s_context_setup() {
    local underscored_fi=$1
    # get the environment from the first part of fi, before the first underscore
    local env="${underscored_fi%%_*}"
    local aws_context="moncloud_grafana_${underscored_fi}_monitoring"
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
    local namespace=${2:-moncloud-api}
    
    cd ~/dev/salesforce/other/personal/tools/periscope
    falcon context apply "$aws_context"
    falcon kube config
    kubectl config set-context --current --namespace "$namespace"
}

_k8s_arbitrary_context_setup() {
    local falcon_context=$1
    local directory=$2
    local role=${3:-PCSKDeveloperRole}
    local details=${4:-"Development work"}
    
    cd "$directory"
    echo "Requesting & exporting credentials for $falcon_context with role $role"
    eval $(falcon credentials request \
        --context "$falcon_context" \
        --role "$role" \
        --duration 744h \
        --major-reason "Development" \
        --details "$details" \
        | grep "export AWS_" \
        | sed 's/INFO  Use below shell command to export AWS Credentials for account.*//')
}

kdev1() {
    _k8s_context_setup "dev1_uswest2"
}

ktest1() {
    _k8s_context_setup "test1_uswest2"
}

kperf1() {
    _k8s_context_setup "perf1_useast2"
}

kstage() {
    _k8s_read_only_setup "moncloud_grafana_aws_esvc1_useast2_monitoring_s"
}

kprod() {
    _k8s_read_only_setup "moncloud_grafana_aws_esvc1_useast2_monitoring"
}

kprod_monex() {
    _k8s_read_only_setup "moncloud_ui005_aws_esvc2_uswest2_monitoring" "monitoring-experience"
}

kprod_trino() {
    _k8s_read_only_setup "bdmpresto_huron_etl_01_aws_esvc1_useast2_uip" "presto"
}

kdev1_trino() {
    _k8s_arbitrary_context_setup \
        "bdmpresto_huron_etl_dev1_uswest2_uip001" \
        "$HOME/dev/salesforce/other/personal/k8s-contexts/dev1-trino" \
        "PCSKDeveloperRole" \
        "Huron developer, need access to the Trino clusters to test out changes"
}
