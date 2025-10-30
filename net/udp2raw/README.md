# UDP2Raw

## Usage

```sh
# server
docker run -d \
  --name=udp2raw \
  --restart=unless-stopped \
  --network=host \
  --privileged=true \
  --log-opt max-file=1 \
  --log-opt max-size=20m \
  -e TZ=Asia/Taipei \
  -e USE_IPTABLES_NFT_BACKEND=0 \
  haeho7/docker-images:udp2raw \
  -s -l 0.0.0.0:1800 -r 127.0.0.1:1900 \
  --raw-mode faketcp \
  --key password \
  --cipher-mode none \
  --auth-mode none \
  --auto-rule \
  #--dev eth0 \
  --log-level 3 \
  --mtu-warn 1375 \
  --hb-mode 0 \
  --wait-lock \
  --fix-gro

# client
docker run -d \
  --name=udp2raw \
  --restart=unless-stopped \
  --network=host \
  --privileged=true \
  --log-opt max-file=1 \
  --log-opt max-size=20m \
  -e TZ=Asia/Taipei \
  -e USE_IPTABLES_NFT_BACKEND=0 \
  haeho7/docker-images:udp2raw \
  -c -l 127.0.0.1:1900 -r 11.22.33.44:1800 \
  --raw-mode faketcp \
  --key password \
  --cipher-mode none \
  --auth-mode none \
  --auto-rule \
  #--dev eth0 \
  --log-level 3 \
  --mtu-warn 1375 \
  --hb-mode 0 \
  --wait-lock \
  --fix-gro
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

## Huge Packet

- [@wangyu-/udp2raw/wiki/Known-issues-and-solutions#huge-packet-warning](https://github.com/wangyu-/udp2raw/wiki/Known-issues-and-solutions#huge-packet-warning)
- [@wangyu-/udp2raw/issues/226](https://github.com/wangyu-/udp2raw/issues/226)
- [@wangyu-/udp2raw/issues/260](https://github.com/wangyu-/udp2raw/issues/260)

```log
[2023-06-21 22:48:19][WARN]huge packet, data_len 2214 > 1800(max_data_len) dropped, maybe you need to turn down mtu at upper level, or you may take a look at --fix-gro
```

## Upstream

- [@wangyu-/udp2raw](https://github.com/wangyu-/udp2raw)

## Acknowledgments

- [@pexcn/docker-images/udp2raw](https://github.com/pexcn/docker-images/tree/master/net/udp2raw)
