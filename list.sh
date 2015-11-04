#!/bin/bash

AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID:?"AWS_ACCESS_KEY_ID env variable is required"}
AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY:?"AWS_SECRET_ACCESS_KEY env variable is required"}
REMOTE_URL=${REMOTE_URL:?"REMOTE_URL env variable is required"}

duplicity list-current-files $@ ${REMOTE_URL}
