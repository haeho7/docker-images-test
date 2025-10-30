# AdGuard Home

## Usage

```sh
docker run -d \
  --name=adguardhome \
  --restart=unless-stopped \
  --network=host \
  --log-opt max-file=1 \
  --log-opt max-size=20m \
  -e TZ=Asia/Taipei \
  -v /mnt/user/appdata/adguardhome/adguardhome-data/conf:/opt/adguardhome/conf \
  -v /mnt/user/appdata/adguardhome/adguardhome-data/work:/opt/adguardhome/work \
  adguard/adguardhome:v0.107.67
```
