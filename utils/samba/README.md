# Samba

## Usage

```sh
docker run -d \
  --name=samba \
  --restart=unless-stopped \
  --network=host \
  #--ulimit memlock=-1 \
  --ulimit nproc=-1 \
  --ulimit nofile=1048576:1048576 \
  --log-opt max-file=1 \
  --log-opt max-size=20m \
  -e TZ=Asia/Taipei \
  -e PUID=99 \
  -e PGID=100 \
  -v /mnt/user/appdata/samba/samba-data/conf:/etc/samba \
  -v /mnt/user:/mnt/user \
  -v /mnt/cache_torrent:/mnt/cache_torrent \
  -v /mnt/cache_backup:/mnt/cache_backup \
  haeho7/docker-images:samba
```

## Owner

You can change the UID and PID of the container's default samba user by passing the `PUID` and `PGUD` variables, and configure the `force user` and `force group` parameters in smb.conf to ensure that permissions match those of the host machine.

## Optimize

By default, SMB file transfers result in high disk IO usage.

Adding these parameters can reduce disk IO usage while maintaining high throughput:

```sh
# host
cat /proc/sys/net/core/rmem_max
cat /proc/sys/net/core/wmem_max
#sysctl -w net.core.rmem_max=18750000
#sysctl -w net.core.wmem_max=18750000

cat << EOF > /etc/sysctl.d/83-samba.conf
# samba tuning
net.core.rmem_max = 18750000
net.core.wmem_max = 18750000
EOF

# apply
sysctl --system
```

```sh
# smb.conf
[global]
  socket options = IPTOS_LOWDELAY TCP_NODELAY IPTOS_THROUGHPUT SO_RCVBUF=1048576 SO_SNDBUF=1048576
  use sendfile = yes
  getwd cache = yes
  min receivefile size = 65535
```

## Command

```sh
# add user and group
#addgroup -g <gid> <groupname>
#adduser -D -H -G <groupname> -s /sbin/nologin -u <uid> <username>

groupadd -o -g <gid> <groupname>
useradd -o -M -u <uid> -g <groupname> -G {group_list} -s /sbin/nologin <username>

# add samba user
#pdbedit -a <username>
pdbedit -a <username> -f <fullname>
echo -e "<password>\n<password>" | pdbedit -a <username> -f <fullname> -t

# delete samba user
pdbedit -x <username>
deluser <username>

# show user info
pdbedit -v <username>

# show samba user list
pdbedit -L
pdbedit -Lv

# test samba conf
testparm /etc/samba/smb.conf

# reload samba conf
smbcontrol all reload-config
```

## Xattr

```sh
# show xattr
getfattr -d -m- <dir_name> or <file_name>

user.DOSATTRIB=0sAAAEAAQAAABRAAAAIAAAAQ93jX4l...
user.DosStream.AFP_AfpInfo:$DATA=0sQUZQAAAAAQAAAAAAA...
user.DosStream.com.apple.FinderInfo:$DATA=0sAABBCCDD...
user.DosStream.com.apple.ResourceFork:$DATA=0sXXYYZZ...
user.DosStream.com.apple.lastuseddate#PS:$DATA=0sIFa...
user.DosStream.com.apple.quarantine:$DATA=0sQUZQAAAA...

# delete xattr
find . -type f -exec setfattr -x 'user.DosStream.AFP_AfpInfo:$DATA' {} \; 
find . -type d -exec setfattr -x 'user.DosStream.AFP_AfpInfo:$DATA' {} \;
```

## Errors

### Bad Switch

Samba encountered an illegal or unknown value (switch value 5) while parsing the file's EA (extended attribute) information `xattr: user.DOSATTRIB`.

```log
[2025/09/28 21:34:31.533854,  1] ../../librpc/ndr/ndr.c:630(_ndr_pull_error)
  ndr_pull_xattr_DosInfo: ndr_pull_error(Bad Switch): Bad switch value 5 at librpc/gen_ndr/ndr_xattr.c:390 at librpc/gen_ndr/ndr_xattr.c:390
[2025/09/28 21:34:31.533936,  1] ../../source3/smbd/dosmode.c:249(parse_dos_attribute_blob)
  parse_dos_attribute_blob: bad ndr decode from EA on file torrent/9kg/..: Error = Bad Switch

[2025/09/28 01:35:58.070975,  1] ../../librpc/ndr/ndr.c:630(_ndr_pull_error)
  ndr_pull_xattr_DosInfo: ndr_pull_error(Bad Switch): Bad switch value 5 at librpc/gen_ndr/ndr_xattr.c:390 at librpc/gen_ndr/ndr_xattr.c:390
[2025/09/28 01:35:58.071011,  1] ../../source3/smbd/dosmode.c:249(parse_dos_attribute_blob)
  parse_dos_attribute_blob: bad ndr decode from EA on file torrent/9kg/vixen/vixen.xx.xx.xx-C-4K.nfo: Error = Bad Switch
```

Just delete the extended attribute value of the corresponding file:

```sh
getfattr -d -m- ./*

# illegal or unknown value
# file: test1.txt
user.DOSATTRIB=0sAAAFAAUAAAARAAAAIAAAAABj2qpxsdkB

# normal value
# file: test2.txt
user.DOSATTRIB=0sAAAEAAQAAABRAAAAIAAAAJoCTPTRL9w32kJL9NEv3AE=

# delete bad value
setfattr -x 'user.DosStream.com.apple.macl:$DATA' test1.txt
```

### Not supported

Samba fails when trying to map Windows ACL to Linux file system ACL.

```sh
[2025/09/28 02:07:16.211409,  1] ../../source3/smbd/posix_acls.c:2962(set_canon_ace_list)
  set_canon_ace_list: sys_acl_set_file on file [torrent/9kg/vixen/test-dir]: (Not supported)
```

The current file system does not support or has not enabled the `POSIX ACL` feature.

Don't worry, Samba will restore `normal UNIX permissions`, which are the `rwx` permissions of a Linux file system. Therefore, you can ignore this warning message.

## Acknowledgments

- [@pexcn/docker-images/samba](https://github.com/pexcn/docker-images/blob/master/utils/samba)
