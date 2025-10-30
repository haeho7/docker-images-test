# Valkey

## Usage

```sh
docker run -d \
  --name=valkey \
  --restart=unless-stopped \
  --network=host \
  --log-opt max-file=1 \
  --log-opt max-size=20m \
  -e TZ=Asia/Taipei \
  -e PUID=99 \
  -e PGID=100 \
  -v /mnt/user/appdata/valkey/valkey-data/conf:/etc/valkey \
  -v /mnt/user/appdata/valkey/valkey-data/data:/data \
  haeho7/docker-images:valkey \
  valkey-server /etc/valkey/valkey.conf
```

### Auth

Authentication is required to connect to valkey. For the default password, refer to the configuration file: [valkey.conf](./valkey-data/conf/valkey.conf)

Modify the `requirepass` parameter in the configuration file, or creating the container add the `--requirepass password` extra parameter.

### Optimize

If you need high performance, you can optimize the default valkey parameters.

Please refer to the following parameters: [valkey.conf](./valkey-data/conf/valkey.conf)

### Command

``` sh
# login
valkey-cli -h <host> -p <port> -a <password>

# show all cinfig
CONFIG GET *
CONFIG GET requirepass

# show all key
SELECT 0
KEYS *

# benchmark
valkey-benchmark <host> -p <port> -a <password>
```
