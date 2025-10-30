# Gogs

## Usage

```sh
docker run -d \
  --name=gogs \
  --restart=unless-stopped \
  --network=host \
  --log-opt max-file=1 \
  --log-opt max-size=20m \
  -e TZ=Asia/Taipei \
  -e PUID=99 \
  -e PGID=100 \
  -v /mnt/user/appdata/gogs/gogs-data:/data \
  gogs/gogs:0.13.3
```
