#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$DIR/common.sh"

if [ $# != 3 ]; then
    echo "Usage: $0 <paramsfile> <packageparamsfile> <taskid>"
    exit 1
fi

source $1
source $2
task_id=$3

required_envvars job_id

az batch task show \
    --job-id $job_id \
    --task-id $task_id | jq '.executionInfo '

