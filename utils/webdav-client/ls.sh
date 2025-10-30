#!/bin/sh
set -e

PERIOD=${1:-120}
MOUNT_DIR=${WEBDRIVE_MOUNT:-/mnt/webdrive}

. trap.sh

while true; do
  ls $MOUNT_DIR
  sleep $PERIOD
done
