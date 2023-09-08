
```
aws --profile=noobaa \
   --endpoint-url=https://s3-openshift-storage.apps.cluster-ngqwn.ngqwn.sandbox2103.opentlc.com \
   s3 cp stuff.txt s3://s3demo-06200c12-07ff-46d2-8c72-d6de8c726542

aws --profile=noobaa \
   --endpoint-url=https://s3-openshift-storage.apps.cluster-ngqwn.ngqwn.sandbox2103.opentlc.com \
   s3 cp s3://reports-88a20b11-b229-4678-b73c-2860aad0be45 ./  \
   --recursive
```

```
cd noobaa
oc create secret generic noobaaconfig --from-file=config --from-file=credentials -o yaml --dry-run > noobaa-config-secret.yaml
```


