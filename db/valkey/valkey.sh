#!/bin/sh
set -e

USER=valkey
GROUP=valkey
GROUPS=valkey,users
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
  chown ${PUID}:${PGID} /etc/valkey/*.conf
}

start_valkey() {
  setup_user
  setup_owner

  # call valkey official startup script
  sed -i 's/umask 0077/umask/' /usr/local/bin/docker-entrypoint.sh
  exec /usr/local/bin/docker-entrypoint.sh "$@"
}

start_valkey "$@"
