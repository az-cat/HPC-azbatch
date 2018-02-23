#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$DIR/common.sh"

if [ $# != 1 ]; then
    echo "Usage: $0 <paramsfile>"
    exit 1
fi

source $1

required_envvars subscription resource_group AZURE_BATCH_ACCOUNT

az account set \
    --subscription $subscription

# Authenticate Batch account CLI session.
if [ "$AZURE_BATCH_ACCESS_KEY" ]; then
    echo "login thru shared key"
    az batch account login \
        -g $resource_group \
        -n $AZURE_BATCH_ACCOUNT \
        --shared-key-auth
else
    echo "login thru Azure AD"
    az batch account login \
        -g $resource_group \
        -n $AZURE_BATCH_ACCOUNT
fi
