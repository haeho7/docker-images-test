#!/bin/sh
set -e
set -o pipefail

USER=samba
GROUP=samba
GROUPS=samba,users
PUID=${PUID:-1000}
PGID=${PGID:-1000}
UMASK=${UMASK:-022}

SAMBA_USERS=/etc/samba/users

_is_exist_group() {
  getent group $1 &>/dev/null
}

_is_exist_user() {
  id -u $1 &>/dev/null
}

_trim_lines() {
  sed '/^[[:space:]]*$/d' | sed '/^#/ d'
}

_get_uid() {
  awk -F ':' '{print $1}'
}

_get_username() {
  awk -F ':' '{print $2}'
}

_get_password() {
  awk -F ':' '{print $3}'
}

create_accounts() {
  # samba user and group
  _is_exist_group ${GROUP} || groupadd -r -o -g ${PGID} ${GROUP}
  _is_exist_user ${USER} || useradd -r -o -M -u ${PUID} -g ${GROUP} -G ${GROUPS} -s /sbin/nologin ${USER}
  umask ${UMASK}

  # system user
  cat $SAMBA_USERS | _trim_lines | while read line
  do
    local uid=$(echo $line | _get_uid)
    local username=$(echo $line | _get_username)
    _is_exist_user $username || useradd -o -M -g ${GROUP} -G ${GROUPS} -s /sbin/nologin -u $uid $username
  done

  # samba users
  cat $SAMBA_USERS | _trim_lines | while read line
  do
    local username=$(echo $line | _get_username)
    local password=$(echo $line | _get_password)
    echo -e "$password\n$password" | pdbedit -a $username -f "Samba User" -t
  done
}

start_samba() {
  nmbd --daemon
  exec smbd --foreground --no-process-group
}

create_accounts
start_samba
