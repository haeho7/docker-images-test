# GFW-Defense

## Usage

```sh
docker run -d \
  --name=gfw-defense \
  --restart=unless-stopped \
  --network=host \
  --privileged=true \
  --log-opt max-file=1 \
  --log-opt max-size=20m \
  -e TZ=Asia/Taipei \
  -e BLOCKING_POLICY=DROP \
  -e PASSING_POLICY=ACCEPT \
  -e DEFAULT_POLICY=RETURN \
  -e QUICK_MODE=0 \
  -e PREFER_BLACKLIST=0 \
  -e ALLOW_RESERVED_ADDRESS=1 \
  -e USE_IPTABLES_NFT_BACKEND=0 \
  -e BLACKLIST_FILES='/etc/gfw-defense/blacklist.txt,/etc/gfw-defense/chnroute.txt' \
  -e WHITELIST_FILES='/etc/gfw-defense/whitelist.txt,/etc/gfw-defense/440100.txt' \
  -e UPDATE_LIST_INTERVAL=86400 \
  -e UPDATE_LIST_URLS='https://raw.githubusercontent.com/pexcn/daily/gh-pages/chnroute/chnroute.txt,https://raw.githubusercontent.com/metowolf/iplist/master/data/cncity/440100.txt' \
  -v /mnt/user/appdata/gfw-defense/gfw-defense-data:/etc/gfw-defense \
  pexcn/docker-images:gfw-defense
```

### iptables Backend

If the host uses the `iptables-nft` backend, the `USE_IPTABLES_NFT_BACKEND` environment variable needs to be set.

```sh
# Debian 11 (bullseye)
iptables -V
iptables v1.8.7 (nf_tables)

ls -al /usr/sbin/iptables
lrwxrwxrwx 1 root root 26 12月 11 17:56 /usr/sbin/iptables -> /etc/alternatives/iptables
```

## Acknowledgments

- [@pexcn/docker-images/gfw-defense](https://github.com/pexcn/docker-images/tree/master/civ/gfw-defense)
