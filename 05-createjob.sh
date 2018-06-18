#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$DIR/common.sh"

if [ $# != 3 ]; then
    echo "Usage: $0 <paramsfile> <jobparamsfile> <nbnodes>"
    exit 1
fi

source $1
source $2 $3

required_envvars job_type job_id pool_id storage_account_name container_name jobscript input_dir AZURE_BATCH_ACCOUNT

job_template=$DIR/${job_type}-params-template.json
job_params=${job_id}-params.json
taskid=$(date "+%Y%m%d-%H%M%S")
#taskid=$(uuidgen | cut -c1-6)
use_input=false
mpi_job=false
if [ "$job_type" == "mpijob" ]; then
    mpi_job=true
fi


az storage blob upload \
    --account-name $storage_account_name \
    --container $container_name \
    --file $jobscript \
    --name "${taskid}/$jobscript"

if [ "$mpi_job" = true ]; then
    az storage blob upload \
        --account-name $storage_account_name \
        --container $container_name \
        --file $coordinationscript \
        --name "${taskid}/$coordinationscript"
fi

if [ -n "${input_dir}" ] && [ -d ${input_dir} ] ; then
    echo "using input directory $input_dir"
    tar cvf ${taskid}.tgz ${input_dir}
    az storage blob upload \
        --account-name $storage_account_name \
        --container $container_name \
        --file ${taskid}.tgz \
        --name "${taskid}/${taskid}.tgz"
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
task_root_uri="https://${storage_account_name}.blob.core.windows.net/${container_name}"
jobscript_uri="${task_root_uri}/${taskid}/${jobscript}?${saskey}"
if [ "$use_input" = true ]; then
    input_uri="${task_root_uri}/${taskid}/${taskid}.tgz?${saskey}"
    input_data=$(jq -n '.blobSource=$blob | .filePath=$input_pkg' --arg blob "$input_uri" --arg input_pkg ${taskid}.tgz)
fi

resource=$(jq -n '.blobSource=$blob | .filePath=$jobscript' --arg blob "$jobscript_uri" --arg jobscript $jobscript)

resources=$(jq -n '.resourceFiles=[2]')
resources=$(jq '.resourceFiles[0] = $data' --argjson data "$resource" <<< $resources)
if [ "$use_input" = true ]; then
    resources=$(jq '.resourceFiles[1] = $data' --argjson data "$input_data" <<< $resources)
fi

if [ "$mpi_job" = true ]; then
    coordinationscript_uri="${task_root_uri}/${taskid}/${coordinationscript}?${saskey}"
    commonresource=$(jq -n '.blobSource=$blob | .filePath=$coordinationscript' --arg blob "$coordinationscript_uri" --arg coordinationscript $coordinationscript)
    commonresources=$(jq -n '.commonResourceFiles=[]')
    commonresources=$(jq '.commonResourceFiles[.commonResourceFiles| length] += $data' --argjson data "$commonresource" <<< $commonresources)
fi

# create the container URI for storing automatically the results
container_url="${task_root_uri}/?${saskey}"
container=$(jq -n '.container.path=$taskid | .container.containerUrl=$url' --arg taskid $taskid --arg url $container_url)

# add environment variable
envVariable=$(jq -n '.name="JOB_CONTAINER_URL" | .value=$jobUrl' --arg jobUrl $container_url)

# if job environment variables exists, merge them
if [ -n "$jobenvsettings" ]; then
    envSettings=$(jq -n '.environmentSettings += $data' --argjson data "$jobenvsettings")
else
    envSettings=$(jq -n '.environmentSettings=[]')
fi
envSettings=$(jq '.environmentSettings[.environmentSettings| length] += $data' --argjson data "$envVariable" <<< $envSettings)

# application package
applicationPackageReferences=$(jq -n '.applicationPackageReferences=[]')
if [ -n "$task_app_package" ]; then
    appPackageJson=$(jq -n '.applicationId=$package | .version="latest"' --arg package "$task_app_package")
    applicationPackageReferences=$(jq '.applicationPackageReferences[.applicationPackageReferences| length] += $data' --argjson data "$appPackageJson" <<< $applicationPackageReferences)    
fi

if [ "$mpi_job" = true ]; then
    jq '.id=$tid | . += $envSettings | . += $applicationPackageReferences  | .commandLine=$cmdline | .outputFiles[0].destination += $container | .outputFiles[1].destination += $container | .+=$resources | .multiInstanceSettings.numberOfInstances=$numnodes | .multiInstanceSettings.coordinationCommandLine=$coordCli | .multiInstanceSettings+=$commonresources ' \
        --arg tid $taskid \
        --arg cmdline "$commandline" \
        --arg numnodes $numnodes \
        --arg coordCli "$coordination" \
        --argjson container "$container" \
        --argjson resources "$resources" \
        --argjson commonresources "$commonresources" \
        --argjson applicationPackageReferences "$applicationPackageReferences" \
        --argjson envSettings "$envSettings" $job_template > $job_params
else
    jq '.id=$tid | . += $envSettings | . += $applicationPackageReferences  | .commandLine=$cmdline | .outputFiles[0].destination += $container | .outputFiles[1].destination += $container | .+=$resources ' \
        --arg tid $taskid \
        --arg cmdline "$commandline" \
        --argjson container "$container" \
        --argjson resources "$resources" \
        --argjson applicationPackageReferences "$applicationPackageReferences" \
        --argjson envSettings "$envSettings" $job_template > $job_params
fi

az batch task create \
    --job-id $job_id \
    --json-file $job_params 

echo $job_id $taskid
