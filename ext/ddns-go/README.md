# DDNS-GO

## Usage

```sh
docker run -d \
  --name=ddns-go \
  --restart=unless-stopped \
  --network=host \
  --log-opt max-file=1 \
  --log-opt max-size=20m \
  -e TZ=Asia/Taipei \
  -v /mnt/user/appdata/ddns-go/ddns-go-data:/root \
  jeessy/ddns-go:v6.12.5
```
