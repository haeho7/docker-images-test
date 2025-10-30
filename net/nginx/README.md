# Nginx

## Usage

```sh
docker run -d \
  --name=nginx \
  --restart=unless-stopped \
  --network=host \
  --cap-add=NET_ADMIN \
  --cap-add=SYS_ADMIN \
  --cap-add=SYS_NICE \
  --log-opt max-file=1 \
  --log-opt max-size=20m \
  -l me.local.container.name=nginx \
  -e TZ=Asia/Taipei \
  -v /mnt/user/appdata/nginx/nginx-data/nginx.conf:/etc/nginx/nginx.conf \
  -v /mnt/user/appdata/nginx/nginx-data/conf.d:/etc/nginx/conf.d \
  -v /mnt/user/appdata/nginx/nginx-data/http.d:/etc/nginx/http.d \
  -v /mnt/user/appdata/nginx/nginx-data/stream.d:/etc/nginx/stream.d \
  -v /mnt/user/appdata/nginx/nginx-data/html:/etc/nginx/html \
  -v /mnt/user/appdata/acme.sh/acme.sh-data:/cert \
  haeho7/docker-images:nginx
```

## Repair File Permissions

```sh
cd /mnt/user/appdata/nginx/nginx-data
find . -type f -iname "*.conf" -print -exec chmod 644 {} \;
```

## Basic Authentication

- [@nginx/admin-guide/security-controls](https://docs.nginx.com/nginx/admin-guide/security-controls/configuring-http-basic-authentication/)

```sh
apk add apache2-utils
htpasswd -c /srv/htpasswd <username>

cat /srv/htpasswd
demo:$xxx$LbahLwNb$0rD/8Jzyg4BUXAgVKxxx

apk del apache2-utils

# nginx location config
   location /xxx {
        auth_basic "Private";
        auth_basic_user_file /srv/htpasswd;
    }
```

## proxy_set_header Host Test

```conf
server {
    listen 8090;
    server_name _;

    location / {
        proxy_set_header Host xxxx
        proxy_pass http://192.168.1.1:5000;
    }
}
```

```sh
proxy_set_header Host $host
# The IP or domain name requested by the browser, excluding the port number.
# If the page has redirection routes, the port information will be lost, resulting in 404.
# browser: 123.123.123.123:8090
# return:  123.123.123.123

proxy_set_header Host $http_host
# The IP or domain name requested by the browser, including the port number.
# browser: 123.123.123.123:8090
# return:  123.123.123.123:8090

no setting proxy_set_header Host
proxy_set_header Host $proxy_host
# Upstream server IP or domain, default port 80 is not displayed, others are displayed.
# browser: 123.123.123.123:8090
# return:  192.168.1.1:5000

proxy_set_header Host $host:$proxy_port
# The IP or domain name requested by the browser, the port number of the upstream server.
# browser: 123.123.123.123:8090
# return:  123.123.123.123:5000

proxy_set_header Host $host:$server_port
# The IP or domain name requested by the browser, the port number that nginx listens to.
# browser: 123.123.123.123:8090
# return:  123.123.123.123:8090
```

## Acknowledgments

- [@pexcn/docker-images/nginx](https://github.com/pexcn/docker-images/tree/master/net/nginx)
