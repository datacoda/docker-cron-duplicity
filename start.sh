#!/bin/bash

set -e

# Pre-check required environment variables.
AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID:?"AWS_ACCESS_KEY_ID env variable is required"}
AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY:?"AWS_SECRET_ACCESS_KEY env variable is required"}
REMOTE_URL=${REMOTE_URL:?"REMOTE_URL env variable is required"}
SOURCE_PATH=${SOURCE_PATH:?"SOURCE env variable is required"}
CRON_SCHEDULE=${CRON_SCHEDULE:-0 1 * * *}

if [[ "$1" == 'backup' ]]; then
    /usr/src/app/backup.sh
elif [[ "$1" == 'restore' ]]; then
    echo "RESTORE"
else
    LOGFIFO='/var/log/cron.fifo'
    if [[ ! -e "$LOGFIFO" ]]; then
        mkfifo "$LOGFIFO"
    fi

    CRON_ENV="PARAMS='$PARAMS'"
    CRON_ENV="$CRON_ENV\nAWS_ACCESS_KEY_ID='$AWS_ACCESS_KEY_ID'"
    CRON_ENV="$CRON_ENV\nAWS_SECRET_ACCESS_KEY='$AWS_SECRET_ACCESS_KEY'"
    CRON_ENV="$CRON_ENV\nPASSPHRASE='$PASSPHRASE'"
    CRON_ENV="$CRON_ENV\nSOURCE_PATH='$SOURCE_PATH'"
    CRON_ENV="$CRON_ENV\nREMOTE_URL='$REMOTE_URL'"
    echo -e "$CRON_ENV\n$CRON_SCHEDULE /usr/bin/flock -n /tmp/fcj.lockfile /usr/src/app/backup.sh > $LOGFIFO 2>&1" | crontab -
    echo "Cron backup scheduled ${CRON_SCHEDULE} for ${REMOTE_URL}"
    cron
    tail -f "$LOGFIFO"
fi
