#!/bin/bash

echo "namespace,deployment,labels,image" > namespace-export.csv

namespaces=$(oc get namespaces -o jsonpath='{.items[*].metadata.name}')

for namespace in $namespaces
do
  if [[ "$namespace" != openshift* && "$namespace" != kube* && "$namespace" != "default" ]]; then
    echo "Collecting details for $namespace"

    deploys=$(oc get deploy -o jsonpath='{.items[*].metadata.name}' -n $namespace)
    for deploy in $deploys
    do
      labels=$(oc get deploy $deploy -o yaml -n $namespace | yq '.metadata.labels')
      labels="${labels//: /"="}"
      labels="${labels//$'\n'/ }"
      image=$(oc get deploy $deploy -o yaml -n $namespace | yq '.spec.template.spec.containers[0].image')

      echo $labels
      echo $image

      echo "$namespace,$deploy,$labels,$image" >> namespace-export.csv
    done
  fi
done

# Get S3 route.
s3=$(oc get route s3 -o go-template="{{.spec.host}}" -n openshift-storage)

# Get bucket name.
bucket=$(oc get cm reports -o go-template="{{.data.BUCKET_NAME}}")

aws --profile=noobaa \
  --no-verify-ssl \
  --endpoint-url=https://$s3 \
  s3 cp namespace-export.csv s3://$bucket
