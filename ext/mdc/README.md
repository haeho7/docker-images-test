# Movie Data Capture

## Usage

```sh
docker run -d \
  --name=mdc \
  --restart=unless-stopped \
  --network=host \
  --log-opt max-file=1 \
  --log-opt max-size=20m \
  -e TZ=Asia/Taipei \
  -e PUID=99 \
  -e PGID=100 \
  -v /mnt/user/appdata/mdc/mdc-data:/config \
  -v /mnt/user/9kg/scan:/data \
  vergilgao/mdc:6.6.6-r0
```
