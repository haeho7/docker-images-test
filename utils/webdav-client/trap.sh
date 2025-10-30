#!/bin/sh
set -e

exit_script() {
  SIGNAL=$1
  echo "caught $SIGNAL, unmounting ${MOUNT_DIR}..."
  umount -l ${MOUNT_DIR}
  dav2fs=$(ps -o pid= -o comm= | grep mount.davfs | sed -E 's/\s*(\d+)\s+.*/\1/g')
  if [ -n "$dav2fs" ]; then
    echo "forwarding $SIGNAL to $dav2fs"
    while $(kill -$SIGNAL $dav2fs 2> /dev/null); do
      sleep 1
    done
fi
  trap - $SIGNAL
  exit $?
}

trap "exit_script INT" INT
trap "exit_script TERM" TERM
