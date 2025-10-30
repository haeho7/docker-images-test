# Transmission

## Usage

```sh
docker run -d \
  --name=transmission \
  --restart=unless-stopped \
  --network=external-network \
  --ip=192.168.1.39 \
  --sysctl net.ipv6.conf.all.disable_ipv6=1 \
  --log-opt max-file=1 \
  --log-opt max-size=20m \
  -e TZ=Asia/Taipei \
  -e PUID=99 \
  -e PGID=100 \
  -e USER=example \
  -e PASS='example' \
  -e TRANSMISSION_WEB_HOME='/transmission-web-control/' \
  -e WHITELIST='127.0.0.1,192.168.1.*' \
  -e HOST_WHITELIST='*.example.com' \
  -e PEERPORT=51314 \
  -v /mnt/user/appdata/transmission/transmission-data:/config \
  -v /mnt/user/torrent/watch:/watch \
  -v /mnt/user/torrent/downloads:/downloads \
  haeho7/docker-images:transmission
```

## Macvlan

OpenWrt need install `kmod-macvlan` package.

See more: <https://forum.openwrt.org/t/solved-docker-macvlan-network/106478>

When creating a macvlan, if the bridge device, `parent` needs to specify a bridge device instead of a physical interface, such as: `parent=br-lan` .

```sh
# create network
docker network create \
  --driver=macvlan \
  --subnet=192.168.1.0/24 \
  --gateway=192.168.1.1 \
  --opt parent=br0 \
  external-network

# show network
docker network ls
docker network inspect external-network
```

## BT or PT

```sh
# BT download enabled options, PT download needs to be off.
# Many PT stations default automatically mask dht and pex options.
dht-enabled
pex-enabled
lpd-enabled
```
