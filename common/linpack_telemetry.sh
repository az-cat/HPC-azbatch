#!/bin/bash
result_file=$1

echo "extracting Linpack results from $result_file"
compute=$(curl -s -H Metadata:true "http://169.254.169.254/metadata/instance?api-version=2017-12-01" | jq '.compute')

hpl_perf=$(cat $result_file | jq -s -R 'split("\n") | map(select(contains("WC00C2R2"))) | map(split(" ") | map(select(. != ""))) | map({"N": .[1],"NB": .[2],"P": .[3],"Q": .[
4],"duration": .[5],"gflops": .[6]})'  | jq '.[0]')

jq -n '.Compute=$compute | .Application="linpack" | .Nodes=$nodes | .ppn=$ppn | . += $hpl_perf' \
  --argjson compute "$compute" \
  --argjson hpl_perf "$hpl_perf" \
  --arg nodes $2 \
  --arg ppn $3  > telemetry.json


