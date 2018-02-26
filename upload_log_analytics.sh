#!/bin/bash
# upload a json file in to a log analytics custom table
# https://docs.microsoft.com/en-us/azure/log-analytics/log-analytics-data-collector-api

workspace_id=$1
logName=$2
key=$3
jsonFile=$4

content=$(cat $jsonFile | iconv -t utf8)
content_len=${#content}

rfc1123date="$(date -u +%a,\ %d\ %b\ %Y\ %H:%M:%S\ GMT)"

string_to_hash="POST\n${content_len}\napplication/json\nx-ms-date:${rfc1123date}\n/api/logs"
utf8_to_hash=$(echo -n "$string_to_hash" | iconv -t utf8)

signature="$(echo -ne "$utf8_to_hash" | openssl dgst -sha256 -hmac "$(echo "$key" | base64 --decode)" -binary | base64)"
auth_token="SharedKey $workspace_id:$signature"

curl   -s -S \
        -H "Content-Type: application/json" \
        -H "Log-Type: $logName" \
        -H "Authorization: $auth_token" \
        -H "x-ms-date: $rfc1123date" \
        -X POST \
        --data "$content" \
        https://$workspace_id.ods.opinsights.azure.com/api/logs?api-version=2016-04-01
