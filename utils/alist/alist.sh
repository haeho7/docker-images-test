#!/bin/sh
set -e

USER=alist
GROUP=alist
GROUPS=alist,users
PUID=${PUID:-1000}
PGID=${PGID:-1000}
UMASK=${UMASK:-022}

setup_user() {
  usermod -o -u ${PUID} -g ${GROUP} -aG ${GROUPS} -s /bin/ash ${USER}
  groupmod -o -g ${PGID} ${GROUP}
  umask ${UMASK}
}

setup_owner() {
  chown -R ${PUID}:${PGID} /opt/alist
}

start_alist() {
  setup_user
  setup_owner
  exec gosu ${PUID}:${PGID} alist server --no-prefix
  #exec gosu ${PUID}:${PGID} sh -c "umask ${UMASK} && alist server --no-prefix"
}

start_alist
