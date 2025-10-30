# WebDAV

## Usage

```sh
docker run -d \
  --name=webdav \
  --restart=unless-stopped \
  --network=host \
  --log-opt max-file=1 \
  --log-opt max-size=20m \
  -e TZ=Asia/Taipei \
  -e PUID=99 \
  -e PGID=100 \
  -e USERNAME=example \
  -e PASSWORD='example' \
  -v /mnt/user/appdata/webdav/webdav-data/conf:/etc/webdav \
  -v /mnt/user/appdata/webdav/webdav-data/data:/data \
  haeho7/docker-images:webdav
```
