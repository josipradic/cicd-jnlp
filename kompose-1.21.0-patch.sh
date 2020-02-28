#!/bin/sh

# kompose v1.21.0 has the issue with labels where it adds metadata/annotations
# to all yaml configuration files except for ingress. we need it for ingress in
# case if we want to rewrite the target endpoints in case if we use expose host
# paths.
# 
# @author Josip Radic <josip.radic@gmail.com><skype:josip.radich>
# @version 2020/02/28

# find deployment or service
files=$(find * -type f -name "*-deployment.yaml" -o -name "*-service.yaml" -exec echo {} \;)

for file in $files;
do
    service=$(echo $file | cut -d "-" -f 1)

    # add missing metadata.annotations to ingress files
    find * -type f -name "$service-ingress.yaml" -exec yq write -i {} metadata.annotations "$(yq read $file metadata.annotations)" \;

    # fix annotations added by yq (needs to be as objects, not strings)
    find * -type f -name "$service-ingress.yaml" -exec sed -i 's/annotations: |-/annotations:/g' {} \;
done