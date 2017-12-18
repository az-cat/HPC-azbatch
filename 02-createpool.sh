#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$DIR/common.sh"

if [ $# != 1 ]; then
    echo "Usage: $0 <paramsfile>"
    exit 1
fi

source $1

required_envvars pool_id vm_size vm_image node_agent container_name storage_account_name

# The image reference is in the format: {publisher}:{offer}:{sku}:{version} where {version} is
# optional and will default to 'latest'.

echo "create pool ${pool_id}"
az batch pool create --id $pool_id --vm-size $vm_size --image $vm_image --node-agent-sku-id "$node_agent" --enable-inter-node-communication

echo "generating sas key for container $container_name"
saskey=$(az storage container generate-sas --policy-name rw --name ${container_name} --account-name ${storage_account_name} | jq -r '.')

nodeprep_uri="https://${storage_account_name}.blob.core.windows.net/${container_name}/nodeprep.sh?${saskey}"
jq '.startTask.resourceFiles[0].blobSource=$blob' $DIR/pool-template.json --arg blob "$nodeprep_uri" > ${pool_id}-pool.json
jq '.applicationPackageReferences[0].applicationId=$package | .applicationPackageReferences[0].version="latest"' ${pool_id}-pool.json --arg package "$app_package" > tmp.json
cp tmp.json ${pool_id}-pool.json
rm tmp.json

echo "set pool configuration"
az batch pool set --pool-id $pool_id --json-file ${pool_id}-pool.json

