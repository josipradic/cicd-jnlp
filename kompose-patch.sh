#!/bin/sh

# until kompose is updated to support the kubernetes version v1.19 this script
# is patching improperly generated configuration .yaml files and applies the
# necessary information and changes
# 
# @author Josip Radic <josip.radic@gmail.com><skype:josip.radich>
# @version 2019/12/23
find * -type f -name "*-networkpolicy.yaml" -exec sed -i 's/extensions\/v1beta1/networking.k8s.io\/v1/g' {} \;
find * -type f -name "*-podsecuritypolicy.yaml" -exec sed -i 's/extensions\/v1beta1/policy\/v1beta1/g' {} \;
find * -type f -name "*-daemonset.yaml" -o -name "*-deployment.yaml" -exec sed -i 's/extensions\/v1beta1/apps\/v1/g' {} \;
find * -type f -name "*-statefulset.yaml" -o -name "*-replicaset.yaml" -exec sed -i 's/extensions\/v1beta1/apps\/v1/g' {} \;
find * -type f -name "*-deployment.yaml" -exec bash -c 'SERVICE=$(echo "{}" | cut -f1 -d"-") && sed -i "s/template:/selector:%NL%    matchLabels:%NL%      io.kompose.service: $SERVICE%NL%  template:/g" {}' \;
find * -type f -name "*-deployment.yaml" -exec bash -c "sed -i 's/%NL%/\'$'\n''/g' {}" \;