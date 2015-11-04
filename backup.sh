#!/bin/bash

AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID:?"AWS_ACCESS_KEY_ID env variable is required"}
AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY:?"AWS_SECRET_ACCESS_KEY env variable is required"}
REMOTE_URL=${REMOTE_URL:?"REMOTE_URL env variable is required"}
SOURCE_PATH=${SOURCE_PATH:?"SOURCE_PATH env variable is required"}

output=$(mktemp)

function finish {
    rm $output
}
trap finish EXIT

/usr/local/bin/duplicity $@ ${PARAMS} --allow-source-mismatch ${SOURCE_PATH} ${REMOTE_URL} > $output 2>&1

code=$?

if [ "$code" -ne 0 ] ; then
    echo "Backup failure - action=${1:-auto} - exit=$code"
    /usr/local/bin/duplicity cleanup --force ${REMOTE_URL}
    exit $code
fi

cat $output

# grab some stats
NewFiles=`grep NewFiles $output | awk '{print $2}'`
DeletedFiles=`grep DeletedFiles $output | awk '{print $2}'`
ChangedFiles=`grep ChangedFiles $output | awk '{print $2}'`

echo "Backup success - action=${1:-auto} - exit=$code - new=$NewFiles - delete=$DeletedFiles - change=$ChangedFiles"
