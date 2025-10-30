#!/bin/sh
set -e

USER=webdav
GROUP=webdav
GROUPS=webdav,users
PUID=${PUID:-1000}
PGID=${PGID:-1000}
UMASK=${UMASK:-022}

_get_time() {
  date '+%Y-%m-%d %T'
}

info() {
  local green='\e[0;32m'
  local clear='\e[0m'
  local time="$(_get_time)"
  printf "${green}[${time}] [INFO]: ${clear}%s\n" "$*"
}

warn() {
  local yellow='\e[1;33m'
  local clear='\e[0m'
  local time="$(_get_time)"
  printf "${yellow}[${time}] [WARN]: ${clear}%s\n" "$*" >&2
}

setup_user() {
  usermod -o -u ${PUID} -g ${GROUP} -aG ${GROUPS} -s /bin/ash ${USER}
  groupmod -o -g ${PGID} ${GROUP}
  umask ${UMASK}
}

setup_owner() {
  chown ${PUID}:${PGID} /etc/webdav/*.yml
  chown ${PUID}:${PGID} /data
}

start_webdav() {
  setup_user
  setup_owner
  exec gosu webdav "$@"
}

start_webdav "$@"
