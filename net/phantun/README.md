# Phantun

- [x] unRAID
- [ ] OpenWrt
- [x] Normal

## Usage

```sh
# server
docker run -d \
  --name=phantun \
  --restart=unless-stopped \
  --network=host \
  --privileged=true \
  --log-opt max-file=1 \
  --log-opt max-size=20m \
  -e TZ=Asia/Taipei \
  -e USE_IPTABLES_NFT_BACKEND=0 \
  -e RUST_LOG=INFO \
  haeho7/docker-images:phantun \
  phantun-server \
  --local 1025 \
  --remote 127.0.0.1:1025 \
  --ipv4-only \
  --tun phantun \
  --tun-local 10.1.1.1 \
  --tun-peer 10.1.1.2

# client
docker run -d \
  --name=phantun \
  --restart=unless-stopped \
  --network=host \
  --privileged=true \
  --log-opt max-file=1 \
  --log-opt max-size=20m \
  -e TZ=Asia/Taipei \
  -e USE_IPTABLES_NFT_BACKEND=0 \
  -e RUST_LOG=INFO \
  haeho7/docker-images:phantun \
  phantun-client \
  --local 127.0.0.1:1025 \
  --remote 11.22.33.44:1025 \
  --ipv4-only \
  --tun phantun \
  --tun-local 10.1.1.2 \
  --tun-peer 10.1.1.1
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

## Local Listening

- [@dndx/phantun/issues/65](https://github.com/dndx/phantun/issues/65)

Phantun uses Tun interface which is Layer 3 and has no listing ports `--local` shown in the Kernel TCP stack. It will still work.

## MTU overHead

- [@dndx/phantun#mtu-overhead](https://github.com/dndx/phantun#mtu-overhead)

## With LotServer

Phantun is not compatible with LotServer, because phantun is not a real TCP protocol, so Phantun and LotServer must be used separately.

- [@dndx/phantun/issues/95](https://github.com/dndx/phantun/issues/95)

## Upstream

- [@dndx/phantun](https://github.com/dndx/phantun)

## Acknowledgments

- [@pexcn/docker-images/phantun](https://github.com/pexcn/docker-images/tree/master/net/phantun)
