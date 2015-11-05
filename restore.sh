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

function error_exit
{
    local parent_lineno="$1"
    local message="$2"
    local code="${3:-1}"
    echo "Restore failed.  Err ${code}"
    if [[ -n "$message" ]] ; then
        echo "Error on or near line ${parent_lineno}: ${message};"
    else
        echo "Error on or near line ${parent_lineno};"
    fi
    exit "${code}"
}
trap 'error_exit ${LINENO}' ERR


/usr/local/bin/duplicity restore $@ ${REMOTE_URL} ${RESTORE_PATH}

# Move existing source elsewhere
DATESTAMP=`date +"%Y-%m-%dT%H%M%S"`
ROTATE_DIR=/var/backups/${DATESTAMP}
mkdir -p ${ROTATE_DIR}

# Shuffle everything out of SOURCE_PATH
# We do this instead of just moving the directory because it may be
# a mounted volume.
[ -n "$(shopt -s nullglob; echo ${SOURCE_PATH%/}/*)" ] && mv ${SOURCE_PATH%/}/* ${ROTATE_DIR}/
mv ${RESTORE_PATH%/}/* ${SOURCE_PATH%/}/

echo "Restore success - previous version stored as ${ROTATE_DIR}"
