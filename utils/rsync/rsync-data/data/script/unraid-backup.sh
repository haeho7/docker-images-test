#!/bin/bash
set -e
set -o pipefail

_get_time() {
  date '+%Y-%m-%d %T'
}

_get_status() {
  ps aux | grep -v grep | grep -v daemon | grep rsync | wc -l
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

daily_backup() {
  rsync --verbose \
    --dry-run \
    --progress \
    --partial \
    --archive \
    --sparse \
    --checksum \
    --hard-links \
    --xattrs \
    --exclude-from='/opt/script/unraid-exclude-list' \
    --log-file=/opt/logs/daily_backup_"$(date +%Y%m%d_%H%M%S)".log \
    --log-file-format="[%i] %L [%B] [%U:%G] [%l bytes] %f (Trans: %b bytes)" \
    --password-file=<(cat /etc/rsync/rsyncd.secrets | cut -d ':' -f 2) \
    user1@192.168.1.21::unRAID \
    /mnt/cache_backup/backup/unraid-data-backup \
    #| tee /opt/logs/daily_backup_"$(date +%Y%m%d_%H%M%S)".log
}

monthly_backup() {
  rsync --verbose \
    --dry-run \
    --progress \
    --partial \
    --archive \
    --sparse \
    --checksum \
    --hard-links \
    --xattrs \
    --delete \
    --exclude-from='/opt/script/unraid-exclude-list' \
    --log-file=/opt/logs/monthly_backup_"$(date +%Y%m%d_%H%M%S)".log \
    --log-file-format="[%i] %L [%B] [%U:%G] [%l bytes] %f (Trans: %b bytes)" \
    --password-file=<(cat /etc/rsync/rsyncd.secrets | cut -d ':' -f 2) \
    user1@192.168.1.21::unRAID \
    /mnt/cache_backup/backup/unraid-data-backup \
    #| tee /opt/logs/monthly_backup_"$(date +%Y%m%d_%H%M%S)".log
}

select_backup_mode() {
  if [ "$(date +%d)" == 01 ] || [ "$(date +%d)" == 15 ]; then
    monthly_backup && info "unraid monthly backup complete." || error "unraid monthly backup failed."
  else
    daily_backup && info "unraid daily backup complete." || error "unraid daily backup failed."
  fi
}

start_backup() {
  if [ "$(_get_status)" == 0 ]; then
    info "rsync backup starting..."
    select_backup_mode
  else
    warn "rsync process still running, skip backup."
  fi
}

start_backup
