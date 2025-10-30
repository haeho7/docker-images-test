#!/bin/sh
set -e

MOUNT_DIR=${WEBDRIVE_MOUNT:-/mnt/webdrive}

. trap.sh

tail -f /dev/null
