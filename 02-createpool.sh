#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$DIR/common.sh"

if [ $# != 1 ]; then
    echo "Usage: $0 <paramsfile>"
    exit 1
fi

source $1

required_envvars pool_id vm_size vm_image node_agent container_name storage_account_name batch_account
envsettings="./${pool_id}-envsettings.json"
poolfile=${pool_id}-pool.json

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
    --arg node_agent "$node_agent" > $poolfile

# check for custom Image or Gallery Image
if [ -n "$image_id" ]; then # Custom Image is specified
    jq '.virtualMachineConfiguration.imageReference.virtualMachineImageId=$imageId' $poolfile \
    --arg imageId "$image_id" > tmp.json
else # Gallery Image
    jq '.virtualMachineConfiguration.imageReference.publisher=$publisher | 
        .virtualMachineConfiguration.imageReference.offer=$offer | 
        .virtualMachineConfiguration.imageReference.sku=$sku' $poolfile \
    --arg publisher "$(echo $vm_image | cut -d':' -f1)" \
    --arg offer "$(echo $vm_image | cut -d':' -f2)" \
    --arg sku "$(echo $vm_image | cut -d':' -f3)" > tmp.json
fi
cp tmp.json $poolfile
rm tmp.json

if [ -n "$app_package" ]; then
    jq '.applicationPackageReferences[0].applicationId=$package | .applicationPackageReferences[0].version="latest"' $poolfile --arg package "$app_package" > tmp.json
    cp tmp.json $poolfile
    rm tmp.json
fi

if [ -n "$pool_vnet" ]; then
    jq '.networkConfiguration.subnetId=$pool_vnet ' $poolfile --arg pool_vnet "$pool_vnet" > tmp.json
    cp tmp.json $poolfile
    rm tmp.json
fi

# if enviroment variable file exists, merge it
if [ -f $envsettings ]; then
    jq '.startTask += $data' $poolfile --argfile data $envsettings > tmp.json
    cp tmp.json $poolfile
    rm tmp.json    
fi

echo "create pool ${pool_id}"
az batch pool create \
    --account-name $batch_account \
    --json-file $poolfile

