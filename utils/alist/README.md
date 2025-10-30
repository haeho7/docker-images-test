# Alist

## Usage

```sh
docker run -d \
  --name=alist \
  --restart=unless-stopped \
  --network=host \
  --log-opt max-file=1 \
  --log-opt max-size=20m \
  -e TZ=Asia/Taipei \
  -e PUID=99 \
  -e PGID=100 \
  -v /mnt/user/appdata/alist-data:/opt/alist/data \
  haeho7/docker-images:alist
```

## Admin info

```sh
docker exec -it alist alist admin
```

## Upstream

- [@alist-org/alist](https://github.com/alist-org/alist)
