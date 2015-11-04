dataferret/cron-duplicity
==============================
![Latest tag](https://img.shields.io/github/tag/dataferret/duplicity-s3-backup.svg?style=flat)
![License MIT](https://img.shields.io/badge/license-MIT-blue.svg?style=flat)

Provides [duplicity](http://duplicity.nongnu.org/) backup to S3 under cron.


### Usage

To act as a sidecar to backup the volumes of an existing container.

        docker run -d [OPTIONS] --volumes-from <DATAVOL> dataferret/cron-duplicity

* `DATAVOL`: The name of the docker container that contains the data.
* `OPTIONS`: See parameters below.

### Parameters

* `-e AWS_ACCESS_KEY_ID=<AWS_KEY>`: Your AWS key.
* `-e AWS_SECRET_ACCESS_KEY=<AWS_SECRET>`: Your AWS secret.
* `-e REMOTE_URL=s3+http://<BUCKET_NAME/<PATH>>`: S3 Bucket name and path. Should end with trailing slash.
* `-e PASSPHRASE=<SYMMETRIC_KEY>`: An encryption passphrase.
* `-e SOURCE_PATH=<PATH>`: A path to the root of files to backup.  This can be a mount.
* `-e CRON_SCHEDULE=[0 1 * * *]`: Optional cron schedule.  Default 1AM everyday if not provided.
* `-e PARAMS=[--full-if-older-than 1M]`: Optional [duplicity params](http://duplicity.nongnu.org/duplicity.1.html).  Default provided to
    use full backups every month, with incrementals inbetween.

There is currently no cleaning nor removal of older backup sets.

### Manual Exec

Additional scripts are provided to make it easier to manually invoke backups.

        docker exec -it mybackup backup [full|incremental]
        docker exec -it mybackup status
        docker exec -it mybackup list
        docker exec -it mybackup restore

### Limitations

Additional duplicity `cleanup` and `remove-*` commands are not implemented with wrappers.
They are directly accessible through bash.  The environment variables above are available.

        docker exec -it mybackup /bin/bash

        # duplicity cleanup --force $REMOTE_URL


Tested only with US Standard S3 buckets.

This is mostly a cobbled together a proof of concept that works fine for my needs.  If you have
any specific needs that aren't met - like another S3 region or backend, feel free to fork and
file a pull request.


### S3 Permissions

If one chooses to use subdirectories in a bucket and to restrict the IAM user to it, there's
an issue with duplicity's S3 implementation (boto) that fails to provide the `s3:prefix` which causes
ACCESS DENIED errors.  Use the `deny` effect as suggested in this [thread](https://forums.aws.amazon.com/thread.jspa?threadID=173874&tstart=0):

    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Sid": "AllowUserToSeeBucketListInTheConsole",
                "Action": [
                    "s3:ListAllMyBuckets",
                    "s3:GetBucketLocation"
                ],
                "Effect": "Allow",
                "Resource": [
                    "arn:aws:s3:::*"
                ]
            },
            {
                "Sid": "AllowRootAndHomeListingOfCompanyBucket",
                "Action": [
                    "s3:ListBucket"
                ],
                "Effect": "Allow",
                "Resource": [
                    "arn:aws:s3:::mybucketexample"
                ]
            },
            {
                "Sid": "DenyAllListingExceptRootAndUserFolders",
                "Effect": "Deny",
                "Action": [
                    "s3:ListBucket"
                ],
                "Resource": [
                    "arn:aws:s3:::mybucketexample"
                ],
                "Condition": {
                    "Null": {
                        "s3:prefix": "false"
                    },
                    "StringNotLike": {
                        "s3:prefix": [
                            "",
                            "${aws:username}/*"
                        ]
                    }
                }
            },
            {
                "Sid": "AllowAllS3ActionsInUserFolder",
                "Effect": "Allow",
                "Action": [
                    "s3:*"
                ],
                "Resource": [
                    "arn:aws:s3:::mybucketexample/${aws:username}/*"
                ]
            }
        ]
    }

### Additional Credit

* [cjhardekopf/duplicity](https://github.com/cjhardekopf/docker-duplicity): Duplicity installation.
* [istepanov/docker-backup-to-s3](https://github.com/istepanov/docker-backup-to-s3) Inspired the cron setup.


### License

MIT