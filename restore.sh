#!/bin/bash

AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID:?"AWS_ACCESS_KEY_ID env variable is required"}
AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY:?"AWS_SECRET_ACCESS_KEY env variable is required"}
REMOTE_URL=${REMOTE_URL:?"REMOTE_URL env variable is required"}
SOURCE_PATH=${SOURCE_PATH:?"SOURCE_PATH env variable is required"}

# Restore to a temporary folder first
RESTORE_PATH=$(mktemp)
rm ${RESTORE_PATH}

function finish {
    rm -rf ${RESTORE_PATH}
}
trap finish EXIT

/usr/local/bin/duplicity restore $@ ${REMOTE_URL} ${RESTORE_PATH}

code=$?

if [ "$code" -ne 0 ] ; then
    echo "Restore failure - exit=$code"
    exit $code
fi

# Move existing source elsewhere
DATESTAMP=`date +"%Y-%m-%dT%H%M%S"`

ROTATE_DIR=/var/backups/${DATESTAMP}/
mv ${SOURCE_PATH%/} ${ROTATE_DIR}
mv ${RESTORE_PATH} ${SOURCE_PATH%/}

echo "Restore success - previous version stored as ${ROTATE_DIR}"
