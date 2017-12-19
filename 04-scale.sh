#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$DIR/common.sh"

if [ $# != 2 ]; then
    echo "Usage: $0 <paramsfile> <nbcores>"
    exit 1
fi

source $1

required_envvars pool_id

az batch pool resize \
    --pool-id $pool_id \
    --target-dedicated $2
