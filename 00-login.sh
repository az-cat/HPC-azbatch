#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$DIR/common.sh"

if [ $# != 1 ]; then
    echo "Usage: $0 <paramsfile>"
    exit 1
fi

source $1

required_envvars subscription resource_group batch_account

az account set \
    --subscription $subscription

# Authenticate Batch account CLI session.
az batch account login \
    -g $resource_group \
    -n $batch_account
