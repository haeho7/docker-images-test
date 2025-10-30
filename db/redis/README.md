# Redis

## Usage

```sh
docker run -d \
  --name=redis \
  --restart=unless-stopped \
  --network=host \
  --log-opt max-file=1 \
  --log-opt max-size=20m \
  -e TZ=Asia/Taipei \
  -e PUID=99 \
  -e PGID=100 \
  -v /mnt/user/appdata/redis/redis-data/conf:/etc/redis \
  -v /mnt/user/appdata/redis/redis-data/data:/data \
  haeho7/docker-images:redis \
  redis-server /etc/redis/redis.conf
```

### Auth

Authentication is required to connect to redis. For the default password, refer to the configuration file: [redis.conf](./redis-data/conf/redis.conf)

Modify the `requirepass` parameter in the configuration file, or creating the container add the `--requirepass password` extra parameter.

### Optimize

If you need high performance, you can optimize the default redis parameters.

Please refer to the following parameters: [redis.conf](./redis-data/conf/redis.conf)

### Command

``` sh
# login
redis-cli -h 127.0.0.1 -p 6379 -a password

# show all cinfig
CONFIG GET *
CONFIG GET requirepass

# show all key
SELECT 0
KEYS *

# benchmark
redis-benchmark <host> -p <port> -a <password>
```
