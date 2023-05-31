#!/bin/bash

postConfig()
{
   serviceName=$1
   configFile=$2

   printf '%s\n' "$serviceName"
   printf '%s\n' "$configFile"

   baseUrl=http://sericy-settings-api-service:5000/sericy-settings-api/api/v1/services
   echo $baseUrl

   serviceId=$( curl -X 'GET' "${baseUrl}" -H 'accept: application/json' -k | jq --arg nameof $serviceName '.[] | select(.name==$nameof) | .id')

   defaultConfigId=$( curl -X 'GET' "${baseUrl}/${serviceId}/advanced-configurations" -H 'accept: application/json' -k | jq '.[] | select(.name=="Default Config") | .id')
   echo $defaultConfigId
   configuration=$(cat $configFile)

   toSend="{\"name\": \"Default Config\",\"configuration\": ${configuration}}"
   echo $toSend

   if [ -z "$defaultConfigId" ]
   then
      curl -X 'POST' "${baseUrl}/${serviceId}/advanced-configurations" \
        -H 'accept: */*' \
        -H 'Content-Type: application/json' \
        -d "${toSend}" \
        -k
   else
      curl -X 'PATCH' "${baseUrl}/${serviceId}/advanced-configurations/${defaultConfigId}" \
        -H 'accept: */*' \
        -H 'Content-Type: application/json' \
        -d "${toSend}" \
        -k
   fi
}

for file in *.json; do
   [ -e "$file" ] || continue
   name=${file##*/}
   base=${name%.json}
   postConfig $base $file
done