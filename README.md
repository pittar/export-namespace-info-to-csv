# Extract Namespace Data to CSV

... then upload it to an S3 Bucket!

## Prereqs

There is a base container that has the core tools (aws cli, oc cli, yq).  The `Containerfile` for this is in the `base` directory.  The image is available in my public Quay repo, so no need to rebuild unless you want to make modifications.

The actual image that is used to run the `Job` is in the `job` folder.  It simply inherits the base and adds in the `export-data.sh` script.  It's also in my public Quay repo, so no need to rebuild it unless you're tweaking the script.

## Setup

This demo uses an `ObjectBucketClaim`, so you will need ODF/Noobaa installed in your cluster.  Alternatively, you can just use an AWS S3 bucket, but you might need to tweak the last line of the script a bit (the line that actually uploads the file to the S3 bucket).

### Create the Job Namespace

```
oc new-project extractjob
```

### Create the ObjectBucket

```
oc apply -f job/bucketclaim.yaml -n extractjob
```

### Update the Credentials File

Once you've created your OBC, get the Secrey Key ID and Secret Key from the `reports` secret in the `extractjob` namespace and update the `credentials` file in the `noobaa` directory.

Once that is done, switch into that directory and create a secret with these files:

```
cd noobaa
oc create secret generic noobaaconfig --from-file=config --from-file=credentials -o yaml --dry-run > noobaa-config-secret.yaml
```

Now, apply the secret to your namespace.

```
oc apply -f noobaa-config-secret.yaml -n extractjob
```

### Grant the Service Account Permissions

Ideally, you would create a new Service Account and a custom role, but for this demo I'm simply granting a `view` `cluster-role` to the `default` service account.  This way the script will be able to list and get resources from all namespace.

```
oc adm policy add-cluster-role-to-user view -z default -n extractjob
```

## Run the Job!

Now, you're ready to run the job:

```
oc apply -f job/k8s-job.yaml -n extractjob
```

When it's done, it will upload resulting CSV file to your S3 bucket.

## View Results

If you have the `aws` command line locally, you can use it to retrieve the CSV file that the `Job` created.

Locally, create (or update) the file `~/.aws/config` by adding the contents of the `config` file in the `noobaa` dir.
Do the same for `~/.aws/credentials` (making sure to use the secret key and secret key id for your bucket).

The last thing you'll need is the name of your object bucket.  You can get that from the `ConfigMap` named `reports` in the `extractjob` namespace.

Finally, use the aws cli to download the CSV file from the bucket:

```
aws --profile=noobaa \
   --endpoint-url=https://s3-openshift-storage.apps.<cluster domain> \
   s3 cp s3://<bucket name> ./  \
   --recursive
```

## Bonus

If you want to upload a local file to your bucket:

```
aws --profile=noobaa \
   --endpoint-url=https://s3-openshift-storage.apps.<cluster domain> \
   s3 cp stuff.txt s3://<bucket name>
```


