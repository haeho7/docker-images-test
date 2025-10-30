#!/bin/sh
set -e

USER=webdrive
GROUP=users
#GROUPS=webdrive,users
PUID=${PUID:-1000}
#PGID=${PGID:-1000}
UMASK=${UMASK:-022}
MOUNT_DIR=${WEBDRIVE_MOUNT:-/mnt/webdrive}

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

error() {
  local red='\e[0;31m'
  local clear='\e[0m'
  local time="$(_get_time)"
  printf "${red}[${time}] [ERROR]: ${clear}%s\n" "$*" >&2
}

if [ -z "${WEBDRIVE_URL}" ]; then
  error "url is not set"
  exit
fi

if [ -z "${WEBDRIVE_USERNAME}" ]; then
  error "username is not set"
fi

if [ -n "${WEBDRIVE_PASSWORD_FILE}" ]; then
  WEBDRIVE_PASSWORD=$(read ${WEBDRIVE_PASSWORD_FILE})
fi

if [ -z "${WEBDRIVE_PASSWORD}" ]; then
  error "password is not set"
fi

# Add davfs2 options out of all the environment variables starting with DAVFS2_
# at the end of the configuration file. Nothing is done to check that these are
# valid davfs2 options, use at your own risk.
if [ -n "$(env | grep "DAVFS2_")" ]; then
  echo "" >> /etc/davfs2/davfs2.conf
  echo "[$MOUNT_DIR]" >> /etc/davfs2/davfs2.conf
    for VAR in $(env); do
      if [ -n "$(echo "$VAR" | grep -E '^DAVFS2_')" ]; then
        OPT_NAME=$(echo "$VAR" | sed -r "s/DAVFS2_([^=]*)=.*/\1/g" | tr '[:upper:]' '[:lower:]')
        VAR_FULL_NAME=$(echo "$VAR" | sed -r "s/([^=]*)=.*/\1/g")
        VAL=$(eval echo \$$VAR_FULL_NAME)
        echo "$OPT_NAME $VAL" >> /etc/davfs2/davfs2.conf
      fi
    done
fi

if [ $PUID -gt 0 ]; then
  adduser -S -u ${PUID} -G ${GROUP} -s /bin/ash ${USER} &> /dev/null
  umask ${UMASK}
fi

if [ ! -d $MOUNT_DIR ]; then
  mkdir -p $MOUNT_DIR
else
  chown ${USER}:${GROUP} $MOUNT_DIR
  echo "$MOUNT_DIR $WEBDRIVE_USERNAME $WEBDRIVE_PASSWORD" >> /etc/davfs2/secrets
  mount -t davfs $WEBDRIVE_URL $MOUNT_DIR -o uid=${PUID},gid=${GROUP},dir_mode=755,file_mode=755
fi

if [ -n "$(ls -1A $MOUNT_DIR)" ]; then
  info "mounted $WEBDRIVE_URL on to $MOUNT_DIR"
  exec "$@"
else
  error "nothing found in $MOUNT_DIR, giving up"
fi
