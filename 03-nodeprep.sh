#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$DIR/common.sh"
if [ $# != 1 ]; then
    echo "Usage: $0 <paramsfile>"
    exit 1
fi

source $1

required_envvars container_name storage_account_name

az storage blob upload \
    --account-name $storage_account_name \
    --container $container_name \
    --file $DIR/nodeprep.sh \
    --name nodeprep.sh
