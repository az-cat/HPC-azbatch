#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$DIR/common.sh"

if [ $# != 2 ]; then
    echo "Usage: $0 <paramsfile> <nbNodes>"
    exit 1
fi

source $1

required_envvars pool_id batch_account

az batch pool resize \
    --account-name $batch_account \
    --pool-id $pool_id \
    --target-dedicated $2
