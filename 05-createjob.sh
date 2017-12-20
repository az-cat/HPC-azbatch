#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$DIR/common.sh"

if [ $# != 2 ]; then
    echo "Usage: $0 <paramsfile> <jobparamsfile>"
    exit 1
fi

source $1
source $2

required_envvars job_type job_id pool_id storage_account_name container_name jobscript coordinationscript

job_template=$DIR/${job_type}-params-template.json
job_params=${job_id}-params.json
taskid=$(uuidgen | cut -c1-6)
input_dir=input
use_input=false

az storage blob upload \
    --account-name $storage_account_name \
    --container $container_name \
    --file $jobscript \
    --name $jobscript

az storage blob upload \
    --account-name $storage_account_name \
    --container $container_name \
    --file $coordinationscript \
    --name $coordinationscript

if [ -d ${input_dir} ]; then
    tar cvf ${taskid}.tgz ${input_dir}
    az storage blob upload \
        --account-name $storage_account_name \
        --container $container_name \
        --file ${taskid}.tgz \
        --name ${taskid}.tgz
    rm ${taskid}.tgz
    use_input=true
fi

# Create Job
az batch job create \
    --id $job_id \
    --pool-id $pool_id

echo "generating sas key for container $container_name"
saskey=$(az storage container generate-sas --policy-name "write" --name ${container_name} --account-name ${storage_account_name} | jq -r '.')

# create the resource URI for the scripts being executed
jobscript_uri="https://${storage_account_name}.blob.core.windows.net/${container_name}/${jobscript}?${saskey}"
coordinationscript_uri="https://${storage_account_name}.blob.core.windows.net/${container_name}/${coordinationscript}?${saskey}"
if [ "$use_input" = true ]; then
    input_uri="https://${storage_account_name}.blob.core.windows.net/${container_name}/${taskid}.tgz?${saskey}"
    input_data=$(jq -n '.blobSource=$blob | .filePath=$input_pkg' --arg blob "$input_uri" --arg input_pkg ${taskid}.tgz)
fi

resource=$(jq -n '.blobSource=$blob | .filePath=$jobscript' --arg blob "$jobscript_uri" --arg jobscript $jobscript)
commonresource=$(jq -n '.blobSource=$blob | .filePath=$coordinationscript' --arg blob "$coordinationscript_uri" --arg coordinationscript $coordinationscript)

resources=$(jq -n '.resourceFiles=[2]')
resources=$(jq '.resourceFiles[0] = $data' --argjson data "$resource" <<< $resources)
if [ "$use_input" = true ]; then
    resources=$(jq '.resourceFiles[1] = $data' --argjson data "$input_data" <<< $resources)
fi

commonresources=$(jq -n '.commonResourceFiles=[]')
commonresources=$(jq '.commonResourceFiles[.commonResourceFiles| length] += $data' --argjson data "$commonresource" <<< $commonresources)

# create the container URI for storing automatically the results
container_url="https://${storage_account_name}.blob.core.windows.net/${container_name}?${saskey}"
container=$(jq -n '.container.path=$taskid | .container.containerUrl=$url' --arg taskid $taskid --arg url $container_url)

jq '.id=$tid | .commandLine=$cmdline | .outputFiles[0].destination += $container | .+=$resources | .multiInstanceSettings.numberOfInstances=$numnodes | .multiInstanceSettings.coordinationCommandLine=$coordCli | .multiInstanceSettings+=$commonresources ' --arg tid $taskid --arg cmdline "$commandline" --arg numnodes $numnodes --arg coordCli "$coordination" --argjson container "$container" --argjson resources "$resources" --argjson commonresources "$commonresources" $job_template > $job_params

az batch task create \
    --job-id $job_id \
    --json-file $job_params 

echo $job_id $taskid
