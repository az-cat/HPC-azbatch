#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$DIR/common.sh"

if [ $# != 1 ]; then
    echo "Usage: $0 <paramsfile>"
    exit 1
fi

source $1

required_envvars pool_id vm_size vm_image node_agent container_name storage_account_name batch_account

echo "create pool container"
az storage container create \
    -n ${container_name} \
    --account-name ${storage_account_name}

echo "create container policies"
next_year=$(date '+%Y-%m-%d' --date='+1 year')
expirary_date="${next_year}T23:59Z"
echo "expirary date is ${expirary_date}"

az storage container policy create \
    -c ${container_name} \
    --account-name ${storage_account_name} \
    -n "read" \
    --permissions "lr" \
    --expiry ${expirary_date}

az storage container policy create \
    -c ${container_name} \
    --account-name ${storage_account_name} \
    -n "write" \
    --permissions "dlrw" \
    --expiry ${expirary_date}

echo "generating sas key for container $container_name"
saskey=$(az storage container generate-sas --policy-name "read" --name ${container_name} --account-name ${storage_account_name} | jq -r '.')

nodeprep_uri="https://${storage_account_name}.blob.core.windows.net/${container_name}/nodeprep.sh?${saskey}"
jq '.id=$poolId | 
    .vmSize=$vmSize | 
    .virtualMachineConfiguration.nodeAgentSKUId=$node_agent | 
    .startTask.resourceFiles[0].blobSource=$blob' $DIR/pool-template.json \
    --arg blob "$nodeprep_uri" \
    --arg poolId "$pool_id" \
    --arg vmSize "$vm_size" \
    --arg node_agent "$node_agent" > ${pool_id}-pool.json

# check for custom Image or Gallery Image
if [ -n "$image_id" ]; then # Custom Image is specified
    jq '.virtualMachineConfiguration.imageReference.virtualMachineImageId=$imageId' ${pool_id}-pool.json \
    --arg imageId "$image_id" > tmp.json
else # Gallery Image
    jq '.virtualMachineConfiguration.imageReference.publisher=$publisher | 
        .virtualMachineConfiguration.imageReference.offer=$offer | 
        .virtualMachineConfiguration.imageReference.sku=$sku' ${pool_id}-pool.json \
    --arg publisher "$(echo $vm_image | cut -d':' -f1)" \
    --arg offer "$(echo $vm_image | cut -d':' -f2)" \
    --arg sku "$(echo $vm_image | cut -d':' -f3)" > tmp.json
fi
cp tmp.json ${pool_id}-pool.json
rm tmp.json

if [ -n "$app_package" ]; then
    jq '.applicationPackageReferences[0].applicationId=$package | .applicationPackageReferences[0].version="latest"' ${pool_id}-pool.json --arg package "$app_package" > tmp.json
    cp tmp.json ${pool_id}-pool.json
    rm tmp.json
fi

if [ -n "$pool_vnet" ]; then
    jq '.networkConfiguration.subnetId=$pool_vnet ' ${pool_id}-pool.json --arg pool_vnet "$pool_vnet" > tmp.json
    cp tmp.json ${pool_id}-pool.json
    rm tmp.json
fi

echo "create pool ${pool_id}"
az batch pool create \
    --account-name $batch_account \
    --json-file ${pool_id}-pool.json

