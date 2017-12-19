#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$DIR/common.sh"
if [ $# != 1 ]; then
    echo "Usage: $0 <paramsfile>"
    exit 1
fi

source $1

nodeprep=$DIR/nodeprep.sh
if [ ! -f ./nodeprep.sh ]; then
    cp $nodeprep nodeprep.sh
    nodeprep="./nodeprep.sh"
fi

required_envvars container_name storage_account_name

az storage blob upload \
    --account-name $storage_account_name \
    --container $container_name \
    --file $nodeprep \
    --name nodeprep.sh
