# WireGuard

## Usage

Install the `wireguard-tools` package, see: [@wireguard.com](https://www.wireguard.com/install)

```sh
docker run -d \
  --name=wireguard \
  --restart=unless-stopped \
  --network=host \
  --privileged=true \
  --log-opt max-file=1 \
  --log-opt max-size=20m \
  -e TZ=Asia/Taipei \
  -e USE_IPTABLES_NFT_BACKEND=0 \
  -e PEER_RESOLVE_INTERVAL=0 \
  -v /mnt/user/appdata/wireguard/wireguard-data:/etc/wireguard \
  haeho7/docker-images:wireguard
```

## WireGuard-go

If the current system kernel does not support the `wireguard` module (the kernel is lower than 5.6), `wg-quick` will automatically fall back to userspace and use `wireguard-go`.

Reference:

- [@WireGuard/wireguard-tools/wg-quick/linux.bash](https://github.com/WireGuard/wireguard-tools/blob/master/src/wg-quick/linux.bash#L90)
- [@zx2c4.com/wireguard-tools/wg-quick/linux.bash](https://git.zx2c4.com/wireguard-tools/tree/src/wg-quick/linux.bash#n90)
- [@WireGuard/wireguard-go](https://github.com/WireGuard/wireguard-go)

## DDNS Resolve

If the peer Endpoint is DDNS, you can use `PEER_RESOLVE_INTERVAL` to resolve periodically (in seconds).

Script source:

- [@WireGuard/wireguard-tools/reresolve-dns](https://github.com/WireGuard/wireguard-tools/blob/master/contrib/reresolve-dns/reresolve-dns.sh)

## Iptables Backend

Use `iptables` or `iptables-nft` for `PostUp` and `PostDown`, it depends on the iptables backend used by your host machine.

In alpine 3.18 and earlier, `iptables` is a symlink to `iptables-legacy`, and in alpine 3.19 `iptables-nft` is the default iptables backend.

If the host uses the `iptables-nft` backend, the `USE_IPTABLES_NFT_BACKEND` environment variable needs to be set.

> The iptables backend type used in the container needs to be consistent with that on the host.

```sh
# Debian 11 (bullseye)
iptables -V
iptables v1.8.7 (nf_tables)

ls -al /usr/sbin/iptables
lrwxrwxrwx 1 root root 26 12月 11 17:56 /usr/sbin/iptables -> /etc/alternatives/iptables
```

## Generate Privatekey and Publickey

```sh
wg genkey | tee privatekey | wg pubkey > publickey && cat privatekey publickey
```

## Configs

```sh
#
# /etc/wireguard/wg-server.conf
#
[Interface]
PrivateKey = <SERVER_PRIVATE_KEY>
Address = 10.10.10.1/32
ListenPort = <SERVER_PORT>
#DNS = <REMOTE_DNS>
MTU = 1432
PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -A FORWARD -o %i -j ACCEPT
PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -D FORWARD -o %i -j ACCEPT

[Peer]
PublicKey = <CLIENT_PUBLIC_KEY>
AllowedIPs = 10.10.10.2/32, 192.168.2.0/24
#Endpoint = <CLIENT_ADDR:CLIENT_PORT>
#PersistentKeepalive = 30

#
# /etc/wireguard/wg-client.conf
#
[Interface]
PrivateKey = <CLIENT_PRIVATE_KEY>
Address = 10.10.10.2/32
#ListenPort = <CLIENT_PORT>
#DNS = <REMOTE_DNS>
MTU = 1432
PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -A FORWARD -o %i -j ACCEPT
PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -D FORWARD -o %i -j ACCEPT

[Peer]
PublicKey = <SERVER_PUBLIC_KEY>
AllowedIPs = 10.10.10.1/32, 192.168.1.0/24
Endpoint = <SERVER_ADDR:SERVER_PORT or SERVER_DOMAIN NAME:SERVER_PORT>
PersistentKeepalive = 30
```

## Quick Modify Peer

Peer configuration can be modified online without restarting wireguard.

```sh
wg set <WIREGUARD_INTERFACE_NAME> peer <PublicKey> allowed-ips '<old_AllowedIPs, new_AllowedIPs>'
```

## Update WireGuard Running-config

Update the wireguard running-configuration without restart.

```sh
#wg syncconf <WIREGUARD_INTERFACE_NAME> <(wg-quick strip <WIREGUARD_INTERFACE_NAME>)
docker exec -it wireguard sh
wg syncconf wg-home <(wg-quick strip wg-home)
```

## Best Practices

### MTU

The best MTU equals your external MTU minus `60 bytes (IPv4)` or `80 bytes (IPv6)`, e.g.:

```sh
#
# PPPoE MTU: 1492
#
# WireGuard MTU (IPv4): 1492 - 60 = 1432
MTU = 1432

# WireGuard over Phantun MTU (IPv4): 1492 - 60 - 12 = 1420
MTU = 1420

# WireGuard MTU (IPv6): 1492 - 80 = 1412
MTU = 1412

# WireGuard over Phantun MTU (IPv6): 1492 - 80 - 12 = 1400
MTU = 1400

# WireGuard over shadowsocks tunnel mode MTU (IPv4)
# aes-128-gcm encrypt-method
MTU = 1376
```

See more:

- [Header / MTU sizes for Wireguard](https://lists.zx2c4.com/pipermail/wireguard/2017-December/002201.html)

### AllowedIPs

when sending packets, the list of allowed IPs behaves as a sort of routing table, and when receiving packets, the list of allowed IPs behaves as a sort of access control list.

See more:

- [@wireguard.com/#cryptokey-routing](https://www.wireguard.com/#cryptokey-routing)

### DNS (Unconfirmed)

DNS setting be only when as a client, and should be set to the DNS of remote peer, e.g.:

```sh
DNS = 192.168.1.1
```

### As Gateway

As a gateway, there may be MTU related issues, you can try appending the following iptables rules to `PostUp` and `PostDown`:

PC & other Clinet -> Router Device (Routing) -> NodeA WireGuard Tunnel (Gateway) -> NodeB WireGuard Tunnel

```sh
# NodeA Add
PostUp = iptables -t mangle -A POSTROUTING -o %i -p tcp -m tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
PostDown = iptables -t mangle -D POSTROUTING -o %i -p tcp -m tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu

# iptables-nft Usage
#PostUp = iptables -t mangle -A POSTROUTING -o %i -p tcp -j TCPMSS --clamp-mss-to-pmtu
#PostDown = iptables -t mangle -D POSTROUTING -o %i -p tcp -j TCPMSS --clamp-mss-to-pmtu
```

### Address Translation

1. If the WireGuard tunnel acts as a gateway, NodeA internal clients need to access NodeB tunnel address or internal network through the WireGuard tunnel. However, NodeB `AllowedIP` only allows NodeA WireGuard tunnel address to pass through `AllowedIPs = 10.10.10.2/32`. In this case, it is necessary to perform source address translation on NodeA, converting the internal source address to the WireGuard tunnel interface address.

    > 如果 WireGuard 隧道作为网关角色，NodeA 的内部客户端需要通过 WireGuard 隧道访问 NodeB 的隧道地址或内部网络，但 NodeB 的 `AllowedIP` 中只允许 NodeA 的 WireGuard 隧道地址通过 `AllowedIPs = 10.10.10.2/32`，则需要在 NodeA 上将内部源地址转换为 WireGuard 隧道接口地址。

    PC & Other Clinet -> Router Device (Routing) -> NodeA WireGuard Tunnel (Gateway) -> NodeB WireGuard Tunnel -> NodeB Internal Network (192.168.1.0/24)

    ```sh
    # NodeA Add
    PostUp = iptables -t nat -A POSTROUTING -o <WIREGUARD_INTERFACE_NAME> -j SNAT --to-source 10.10.10.2
    PostDown = iptables -t nat -D POSTROUTING -o <WIREGUARD_INTERFACE_NAME> -j SNAT --to-source 10.10.10.2
    ```

2. If NodeA accesses NodeB internal network through a WireGuard tunnel, but NodeB internal network devices do not have routes for WireGuard tunnel addresses, it is necessary to perform source address translation on NodeB, converting the source address of the WireGuard tunnel to NodeB internal interface address. It is recommended to use the `iptables -s` parameter to match only the WireGuard tunnel subnet, in order to prevent other traffic going out from `INTERNAL_INTERFACE_NAME` from being translated.

    > 如果 NodeA 通过 WireGuard 隧道访问 NodeB 的内部网络，但 NodeB 的内部网络设备并没有添加 WireGuard 隧道地址的路由表，需要在 NodeB 上将 WireGuard 隧道的源地址转为 NodeB 的内部接口地址。建议配合 `iptables -s` 参数仅匹配 WireGuard 隧道网段，防止其他从 `INTERNAL_INTERFACE_NAME` 出去的流量被转换。

    NodeA WireGuard Tunnel -> NodeB WireGuard Tunnel (Gateway) -> Router Device (Routing) -> NodeB internal network (192.168.1.0/24)

    ```sh
    # NodeB Add
    PostUp = iptables -t nat -A POSTROUTING -s <WIREGUARD_TUNNEL_NETWORK> -o <INTERNAL_INTERFACE_NAME> -j SNAT --to-source 192.168.1.21
    PostDown = iptables -t nat -D POSTROUTING -s <WIREGUARD_TUNNEL_NETWORK> -o <INTERNAL_INTERFACE_NAME> -j SNAT --to-source 192.168.1.21
    ```

3. If the Docker settings in the unRAID system have enabled `Host access to custom networks`, which means that both the `br0` and `shim-br0` network interfaces exist in the system, it is necessary to configure both interfaces simultaneously when performing source address translation. Failure to do so may result in abnormal traffic access.

    > 如果 unRAID 系统中 Docker 设置启用了 `主机访问自定义网络`，即系统中同时存在 `br0` 和 `shim-br0` 两个网络接口，在进行源地址转换时需要同时进行配置，否则访问流量将会出现异常。

    ```sh
    # NodeB Add
    PostUp = iptables -t nat -A POSTROUTING -s 10.10.10.0/24 -o br0 -j SNAT --to-source 192.168.1.21
    PostUp = iptables -t nat -A POSTROUTING -s 10.10.10.0/24 -o shim-br0 -j SNAT --to-source 192.168.1.21

    PostDown = iptables -t nat -D POSTROUTING -s 10.10.10.0/24 -o br0 -j SNAT --to-source 192.168.1.21
    PostDown = iptables -t nat -D POSTROUTING -s 10.10.10.0/24 -o shim-br0 -j SNAT --to-source 192.168.1.21

    # Or use MASQUERADE
    #PostUp = ..... -s 10.10.10.0/24 -o br0 -j MASQUERADE
    #PostDown = ..... -s 10.10.10.0/24 -o br0 -j MASQUERADE
    ```

### Access Control

If you need access control, you can refer to the following configuration:

```sh
PostUp = iptables -N WIREGUARD-FILTER
PostUp = iptables -I FORWARD -j WIREGUARD-FILTER
PostUp = iptables -A WIREGUARD-FILTER -s <SRC_ADDR> -d <DST_ADDR> -p <PROTOCOL> --dport <DST_PORT> -j ACCEPT
PostUp = iptables -A WIREGUARD-FILTER -m iprange --src-range <SRC_IPRANGE> -d <DST_ADDR> -p <PROTOCOL> --dport <DST_PORT> -j REJECT

PostDown = iptables -D FORWARD -j WIREGUARD-FILTER
PostDown = iptables -F WIREGUARD-FILTER
PostDown = iptables -X WIREGUARD-FILTER
```

## Acknowledgments

- [@pexcn/docker-images/wireguard](https://github.com/pexcn/docker-images/tree/master/net/wireguard)
