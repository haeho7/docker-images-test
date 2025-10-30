#!/bin/sh
set -e

USER=www-data
GROUP=www-data
GROUPS=www-data,users
PUID=${PUID:-1000}
PGID=${PGID:-1000}
UMASK=${UMASK:-022}

_get_time() {
  date '+%Y-%m-%d %T'
}

_get_crond() {
  pgrep -f crond | wc -l
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

start_crond() {
  if [ "$(_get_crond)" = 0 ]; then
    info "crond process not runing, starting crond..."
    /cron.sh > /dev/stdout 2>&1 &
    #nohup /cron.sh > /var/www/nextclud/data/crond.log 2>&1 &
  else
    warn "crond process still running"
  fi
}

start_nextcloud() {
  setup_user
  start_crond

  # call official startup script
  exec /entrypoint.sh "$@"
}

start_nextcloud "$@"
