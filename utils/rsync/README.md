# rsync

## Usage

```sh
# daemon
docker run -d \
  --name=rsync-daemon \
  --restart=unless-stopped \
  --network=host \
  --privileged=true \
  --ulimit nproc=-1 \
  --ulimit nofile=1048576:1048576 \
  --log-opt max-file=1 \
  --log-opt max-size=20m \
  -e TZ=Asia/Taipei \
  -e ENABLE_DAEMON=1 \
  -v /mnt/user/appdata/rsync/conf/rsyncd.conf:/etc/rsync/rsyncd.conf \
  -v /mnt/user/appdata/rsync/conf/rsyncd.secrets:/etc/rsync/rsyncd.secrets \
  -v /mnt/user:/mnt/user:ro \
  haeho7/docker-images:rsync

# nas
docker run -d \
  --name=rsync-nas \
  --restart=unless-stopped \
  --network=host \
  --privileged=true \
  --ulimit nofile=1048576:1048576 \
  --log-opt max-file=1 \
  --log-opt max-size=20m \
  -e TZ=Asia/Taipei \
  -e CRONTAB='0 */12 * * * /opt/script/nas-backup.sh > /proc/1/fd/1' \
  #-v /mnt/user/appdata/rsync/conf/rsyncd.conf:/etc/rsync/rsyncd.conf \
  #-v /mnt/user/appdata/rsync/conf/rsyncd.secrets:/etc/rsync/rsyncd.secrets \
  -v /mnt/user/appdata/rsync/rsync-data/data:/opt \
  -v /mnt/user:/mnt/user:ro \
  -v /mnt/cache_backup/backup/nas-data-backup:/mnt/cache_backup/backup/nas-data-backup \
  haeho7/docker-images:rsync

# unraid
docker run -d \
  --name=rsync-unraid \
  --restart=unless-stopped \
  --network=host \
  --privileged=true \
  --ulimit nofile=1048576:1048576 \
  --log-opt max-file=1 \
  --log-opt max-size=20m \
  -e TZ=Asia/Taipei \
  -e CRONTAB='0 */12 * * * /opt/script/unraid-backup.sh > /proc/1/fd/1' \
 #-v /mnt/user/appdata/rsync/rsync-data/conf/rsyncd.conf:/etc/rsync/rsyncd.conf \
  -v /mnt/user/appdata/rsync/rsync-data/conf/rsyncd.secrets:/etc/rsync/rsyncd.secrets \
  -v /mnt/user/appdata/rsync/rsync-data/data:/opt \
  -v /mnt/cache_backup/backup/unraid-data-backup:/mnt/cache_backup/backup/unraid-data-backup \
  haeho7/docker-images:rsync
```

## Delta-Transfer

rsync disables `delta-transfer` algorithm, by default when both source and destination are specified as local paths. defaule parameter: `--whole-file`.

But the `delta-transfer` algorithm can be enabled by adjusting the `--no-whole-file` parameter.

- [@samba.org/rsync/opt--no-whole-file](https://download.samba.org/pub/rsync/rsync.1#opt--no-whole-file)

disable delta-transfer algorithm demo (default):

```sh
rsync --progress --dry-run -acvvHX --exclude-from='/opt/script/nas-exclude-list' /mnt/user /mnt/cache_backup/backup/test

sending incremental file list
[sender] hiding directory user/medias because of pattern user/medias
[sender] hiding directory user/.datas because of pattern user/.datas
[sender] hiding directory user/9kg because of pattern user/9kg
[sender] hiding directory user/isos because of pattern user/isos
[sender] hiding directory user/timemachine because of pattern user/timemachine
[sender] hiding directory user/datas because of pattern user/datas
[sender] hiding directory user/appdata because of pattern user/appdata
[sender] hiding directory user/domains because of pattern user/domains
[sender] hiding directory user/backup because of pattern user/backup
[sender] hiding directory user/torrent because of pattern user/torrent
delta-transmission disabled for local transfer or --whole-file
```

enable delta-transfer algorithm demo:

```sh
rsync --progress --dry-run -acvvHX --no-whole-file --exclude-from='/opt/script/nas-exclude-list' /mnt/user /mnt/cache_backup/backup/test
sending incremental file list
[sender] hiding directory user/medias because of pattern user/medias
[sender] hiding directory user/.datas because of pattern user/.datas
[sender] hiding directory user/9kg because of pattern user/9kg
[sender] hiding directory user/isos because of pattern user/isos
[sender] hiding directory user/timemachine because of pattern user/timemachine
[sender] hiding directory user/datas because of pattern user/datas
[sender] hiding directory user/appdata because of pattern user/appdata
[sender] hiding directory user/domains because of pattern user/domains
[sender] hiding directory user/backup because of pattern user/backup
[sender] hiding directory user/torrent because of pattern user/torrent
delta-transmission enabled
```

## Docker Privileged

- [@discuss.linuxcontainers.org](https://discuss.linuxcontainers.org/t/cant-run-libvirt-qemu-kvm-in-an-unprivileged-domain-anymore-unable-to-set-xattr/9466)

If the `Privileged` parameter is not enabled for the rsync container, an exception error will occur when using the `--xattrs` parameter to back up virtual images such as `Libvirt` or `QEMU-KVM`.

```sh
# client rsync backup parameter
rsync -vv \
  --dry-run \
  --progress \
  --partial \
  --archive \
  --checksum \
  --hard-links \
  --xattrs \
  user1@192.168.1.21::unRAID \
  /mnt/user/backup/test \
  --password-file=<(cat ./rsyncd.secrets | cut -d ':' -f 2)

# rsync daemon server log
2022/12/29 21:41:01 [10] building file list
2022/12/29 21:41:05 [10] rsync: [sender] get_xattr_data: lgetxattr("/domains/openwrt-192.168.1.1-20221229-done-bak/openwrt-21.02.3-r16577-x86-64-generic-ext4-combined-efi.img" (in unRAID),"trusted.libvirt.security.dac",0) failed: No data available (61)
2022/12/29 21:41:12 [10] rsync: [sender] get_xattr_data: lgetxattr("/domains/openwrt/openwrt-21.02.3-r16577-x86-64-generic-ext4-combined-efi.img" (in unRAID),"trusted.libvirt.security.dac",0) failed: No data available (61)
2022/12/29 21:41:26 [10] sent 3577 bytes  received 257 bytes  total size 13958737658

# client rsync error info
sent 252 bytes  received 3,555 bytes  149.29 bytes/sec
total size is 13,958,737,658  speedup is 3,666,597.76 (DRY RUN)
rsync error: some files/attrs were not transferred (see previous errors) (code 23) at main.c(1816) [generator=3.2.3]
```

## itemize-changes

- [@samba.org/ftp/rsync/opt--itemize-changes](https://download.samba.org/pub/rsync/rsync.1#opt--itemize-changes)

```sh
tail -n 10 /opt/logs/nas_data_backup_20221231_213022.log

2022/12/31 21:09:50 [119] [cS+++++++++]  [rwxrwxrwx] [99:100] [0 bytes] mnt/user/appdata/redis/redis.sock (Trans: 0 bytes)
2022/12/31 21:09:50 [119] [>fcst......]  [rw-------] [99:100] [28974075 bytes] mnt/user/appdata/redis/appendonlydir/appendonly.aof.3.incr.aof (Trans: 28977654 bytes)
2022/12/31 21:09:51 [119] [.d..t......]  [rwxr-xr-x] [99:100] [184 bytes] mnt/user/appdata/rsync-nas/logs (Trans: 0 bytes)
2022/12/31 21:09:51 [119] [>f+++++++++]  [rw-r--r--] [0:0] [4788 bytes] mnt/user/appdata/rsync-nas/logs/nas_data_backup_20221231_210900.log (Trans: 5909 bytes)
2022/12/31 21:09:51 [119] [>f+++++++++]  [rw-r--r--] [0:0] [530 bytes] mnt/user/appdata/rsync-nas/logs/unraid_data_backup_20221231_210542.log (Trans: 573 bytes)
2022/12/31 21:09:51 [119] [.d..t......]  [rwxr-xr-x] [99:100] [171 bytes] mnt/user/appdata/vaultwarden (Trans: 0 bytes)
2022/12/31 21:09:52 [119] [>fcst......]  [rw-r--r--] [99:100] [2190164 bytes] mnt/user/datas/nextcloud/appdata_oc4dr9l61i8d/appstore/apps.json (Trans: 2190471 bytes)
```
