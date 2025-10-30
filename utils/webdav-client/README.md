# WebDAV-Client

## Usage

```sh
docker run -d \
  --name=webdav-cilnet \
  --restart=unless-stopped \
  --network=host \
  --cap-add=SYS_ADMIN \
  --device=/dev/fuse \
  --log-opt max-file=1 \
  --log-opt max-size=20m \
  -e TZ=Asia/Taipei \
  -e PUID=99 \
  -e PGID=100 \
  -e DAVFS2_ASK_AUTH=0 \
  -e WEBDRIVE_URL='http://localhost:5244/dav' \
  -e WEBDRIVE_USERNAME=example \
  -e WEBDRIVE_PASSWORD='example' \
  -v /mnt/user/appdata/webdav-cilnet/webdav-cilnet-data:/mnt/webdrive:rshared \
  haeho7/docker-images:webdav-client
```

## Acknowledgments

- [@efrecon/docker-webdav-client](https://github.com/efrecon/docker-webdav-client)
