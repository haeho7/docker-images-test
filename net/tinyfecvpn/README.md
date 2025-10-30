# tinyfecVPN

## Usage

### OpenWrt

OpenWrt needs to install the `kmod-tun` kernel module.

```sh
ls -al /dev/net/tun

opkg update
opkg install kmod-tun
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

### Generic

```sh
# server
docker run -d \
  --name=tinyfecvpn \
  --restart=unless-stopped \
  --network=host \
  --privileged=true \
  --log-opt max-file=1 \
  --log-opt max-size=20m \
  -e TZ=Asia/Taipei \
  -e USE_IPTABLES_NFT_BACKEND=0 \
  haeho7/docker-images:tinyfecvpn \
  -s -l 0.0.0.0:1900 \
  --mode 0 \
  --key password \
  --tun-dev tinyfecvpn \
  --sub-net 10.1.10.0 \
  --fec 10:6 \
  --timeout 3 \
  --log-level 3 \
  --mssfix 0 \
  --disable-obscure \
  --disable-checksum

# client
docker run -d \
  --name=tinyfecvpn \
  --restart=unless-stopped \
  --network=host \
  --privileged=true \
  --log-opt max-file=1 \
  --log-opt max-size=20m \
  -e TZ=Asia/Taipei \
  -e USE_IPTABLES_NFT_BACKEND=0 \
  haeho7/docker-images:tinyfecvpn \
  -c -r 11.22.33.44:1900 \
  --mode 0 \
  --key password \
  --keep-reconnect \
  --tun-dev tinyfecvpn \
  --sub-net 10.1.10.0 \
  --fec 10:6 \
  --timeout 3 \
  --log-level 3 \
  --mssfix 0 \
  --disable-obscure \
  --disable-checksum
```

### Game

```sh
# server
docker run -d \
  --name=tinyfecvpn-game \
  --restart=unless-stopped \
  --network=host \
  --privileged=true \
  --log-opt max-file=1 \
  --log-opt max-size=20m \
  -e TZ=Asia/Taipei \
  -e USE_IPTABLES_NFT_BACKEND=0 \
  haeho7/docker-images:tinyfecvpn \
  -s -l 0.0.0.0:1901 \
  --mode 0 \
  --key password \
  --tun-dev tinyfecvpn-game \
  --sub-net 10.1.11.0 \
  --fec 2:4 \
  --timeout 1 \
  --log-level 3 \
  --mssfix 0 \
  --disable-obscure \
  --disable-checksum

# client
docker run -d \
  --name=tinyfecvpn-game \
  --restart=unless-stopped \
  --network=host \
  --privileged=true \
  --log-opt max-file=1 \
  --log-opt max-size=20m \
  -e TZ=Asia/Taipei \
  -e USE_IPTABLES_NFT_BACKEND=0 \
  haeho7/docker-images:tinyfecvpn \
  -c -r 11.22.33.44:1901 \
  --mode 0 \
  --key password \
  --keep-reconnect \
  --tun-dev tinyfecvpn-game \
  --sub-net 10.1.11.0 \
  --fec 2:4 \
  --timeout 1 \
  --log-level 3 \
  --mssfix 0 \
  --disable-obscure \
  --disable-checksum
```

## FEC Parameters

tinyfecVPN uses same lib as UDPspeeder, supports all FEC features of UDPspeeder. tinyfecVPN works at VPN mode,while UDPspeeder works at UDP tunnel mode.

- [@wangyu-/UDPspeeder/wiki/推荐设置](https://github.com/wangyu-/UDPspeeder/wiki/推荐设置)
- [@wangyu-/UDPspeeder/wiki/Fine-grained-FEC-Parameters](https://github.com/wangyu-/UDPspeeder/wiki/Fine-grained-FEC-Parameters)

## Mode and MTU

- [tinyfecVPN/wiki/使用经验#mtu-问题](https://github.com/wangyu-/tinyfecVPN/wiki/使用经验#mtu-问题)
- [@UDPspeeder/wiki/mode和mtu选项](https://github.com/wangyu-/UDPspeeder/wiki/mode和mtu选项)

## Upstream

- [@wangyu-/tinyfecVPN](https://github.com/wangyu-/tinyfecVPN)

## Acknowledgments

- [@pexcn/docker-images/tinyfecvpn](https://github.com/pexcn/docker-images/tree/master/net/tinyfecvpn)
