#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$DIR/common.sh"

if [ $# != 2 ]; then
    echo "Usage: $0 <paramsfile> <nbNodes>"
    exit 1
fi

source $1

required_envvars pool_id AZURE_BATCH_ACCOUNT

az batch pool resize \
    --pool-id $pool_id \
    --target-dedicated $2
