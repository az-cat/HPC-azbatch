#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$DIR/common.sh"

if [ $# != 2 ]; then
    echo "Usage: $0 <paramsfile> <packageparamsfile>"
    exit 1
fi

source $1
source $2

required_envvars app_id app_name app_version resource_group batch_account

zip -r $app_id.zip $app_id

az batch application create --resource-group $resource_group --name $batch_account --application-id $app_id --display-name "$app_name"
az batch application package create --resource-group $resource_group --name $batch_account --application-id $app_id --package-file ${app_id}.zip --version $app_version
az batch application set --resource-group $resource_group --name $batch_account --application-id $app_id --default-version $app_version

