# Vaultwarden

## Usage

```sh
docker run -d \
  --name=vaultwarden \
  --restart=unless-stopped \
  --network=host \
  --user=99:100 \
  --log-opt max-file=1 \
  --log-opt max-size=20m \
  --env-file=/mnt/user/appdata/vaultwarden/config.env \
  -e TZ=Asia/Taipei \
  -e ROCKET_ENV=production \
  -e ADMIN_TOKEN='example' \
  -v /mnt/user/appdata/vaultwarden/vaultwarden-data:/data \
  vaultwarden/server:1.34.3-alpine
```
