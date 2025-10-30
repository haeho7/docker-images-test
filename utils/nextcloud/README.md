# NextCloud

## Usage

```sh
docker run -d \
  --name=nextcloud \
  --restart=unless-stopped \
  --network=host \
  --log-opt max-file=1 \
  --log-opt max-size=20m \
  -e TZ=Asia/Taipei \
  -e PUID=99 \
  -e PGID=100 \
  -e MYSQL_HOST='192.168.1.31:3306' \
  -e MYSQL_DATABASE=nextcloud \
  -e MYSQL_USER=nextcloud \
  -e MYSQL_PASSWORD='example' \
  -e REDIS_HOST='192.168.1.31' \
  -e REDIS_HOST_PORT=6379 \
  -e REDIS_HOST_PASSWORD='example' \
  -e NEXTCLOUD_ADMIN_USER=example \
  -e NEXTCLOUD_ADMIN_PASSWORD='example' \
  -e NEXTCLOUD_TRUSTED_DOMAINS='192.168.1.31 nextcloud.example.com nextcloud.local.example.com' \
  -e PHP_MEMORY_LIMIT=1024M \
  -e PHP_UPLOAD_LIMIT=0 \
  -v /mnt/user/appdata/nextcloud/nextcloud-data:/var/www/nextcloud \
  -v /mnt/user/datas/nextcloud:/var/www/nextcloud/data \
  haeho7/docker-images:nextcloud
```

### Ngnix Webroot

If you use nginx to proxy nextcloud, you need to mount the nextcloud working directory to the nginx container.

```sh
# nginx container add volumes
-v /mnt/user/appdata/nextcloud/nextcloud-data:/var/www/nextcloud \
```

### Redis

If you need to use a redis database, please create a [redis container](../../db/redis//README.md) first. For redis parameters, please refer to [redis.conf](../../db/redis/redis-data/redis.conf)

### MariaDB

If you need to use a mariadb database, please create a [mariadb container](../../db/mariadb/README.md) first. For mariadb parameters, please refer to [mariadb.cnf](../../db/mariadb/mariadb-data/conf.d/mariadb.cnf)

Initialize the database used by the nextcloud container in mariadb.

```sql

CREATE DATABASE `nextcloud` CHARACTER SET 'utf8mb4' COLLATE 'utf8mb4_general_ci';

CREATE USER `nextcloud`@`%` IDENTIFIED BY 'example';

-- GRANT ALL PRIVILEGES ON `nextcloud`.* TO `nextcloud`@`%`;

GRANT ALTER, ALTER ROUTINE, CREATE, CREATE ROUTINE, CREATE TEMPORARY TABLES, CREATE VIEW, DELETE, DROP, EXECUTE, INDEX, INSERT, LOCK TABLES, REFERENCES, SELECT, SHOW VIEW, TRIGGER, UPDATE ON `nextcloud`.* TO `nextcloud`@`%`;

FLUSH PRIVILEGES;
```

### PHP Memory and Upload Limit

variables in `nextcloud.ini` configuration files.

- [@nextcloud/docker/24/fpm-alpine/Dockerfile#L99](https://github.com/nextcloud/docker/blob/c5a8a8863b1db95fb45c872a0078b177347db959/24/fpm-alpine/Dockerfile#L99)

```ini
# cat /usr/local/etc/php/conf.d/nextcloud.ini
memory_limit=${PHP_MEMORY_LIMIT}
upload_max_filesize=${PHP_UPLOAD_LIMIT}
post_max_size=${PHP_UPLOAD_LIMIT}
```

### Database and Trusted Domains List

variables in `config.php` configuration files

```sh
cat /var/www/nextcloud/config/config.php
```

### OPcache Default

- [@nextcloud/docker/24/fpm-alpine/Dockerfile#L91](https://github.com/nextcloud/docker/blob/c5a8a8863b1db95fb45c872a0078b177347db959/24/fpm-alpine/Dockerfile#L91)

```ini
# cat /usr/local/etc/php/conf.d/opcache-recommended.ini
opcache.enable=1
opcache.interned_strings_buffer=16
opcache.max_accelerated_files=10000
opcache.memory_consumption=128
opcache.save_comments=1
opcache.revalidate_freq=60
```

### PHP INFO

add `phpinfo ();` parameter in `Nextcloud_Home/index.php` file.

```php
<?php
phpinfo ();
```

### Crontab

if nextcloud container is run with `--user` parameter,cron tasks may fail to execute.need custom scheduled tasks.

```sh
# nextcloud default cron configuration files.
cat /etc/crontabs/www-data 
*/5 * * * * php -f /var/www/nextcloud/cron.php
```

custom scheduled tasks:

```sh
# Unraid use User Scripts plugin
docker exec -i --user=99:100 nextcloud php -f /var/www/nextcloud/cron.php
```

### APCu and Crontab

APCu is disabled by default on CLI which could cause issues with nextcloud’s cron jobs.

- [@nexntcloud/docs/admin_manual/caching_configuration](https://docs.nextcloud.com/server/latest/admin_manual/configuration_server/caching_configuration.html#id1)

```ini
# cat /usr/local/etc/php/conf.d/docker-php-ext-apcu.ini
extension=apcu
apc.enable_cli=1
```

## Extend Config

- [@nexntcloud/docs/admin_manual/config_sample_php_parameters](https://docs.nextcloud.com/server/latest/admin_manual/configuration_server/config_sample_php_parameters.html)

```php
  // enable extra preview
  // preview video need install ffmpeg
  'enable_previews' => true,
  'enabledPreviewProviders' => [
    'OC\Preview\PNG',
    'OC\Preview\JPEG',
    'OC\Preview\GIF',
    'OC\Preview\BMP',
    'OC\Preview\XBitmap',
    'OC\Preview\PDF',
    'OC\Preview\TXT',
    'OC\Preview\MarkDown',
    'OC\Preview\OpenDocument',
    'OC\Preview\MSOfficeDoc',
    'OC\Preview\MSOffice2003',
    'OC\Preview\MSOffice2007',
    'OC\Preview\OpenDocument',
    'OC\Preview\Krita',
    'OC\Preview\MP3',
    'OC\Preview\Movie',
    'OC\Preview\MKV',
    'OC\Preview\MP4',
    'OC\Preview\AVI',
    'OC\Preview\HEIC',
  ],

  // filelocking defaul true
  'filelocking.enabled' => true,

  // cookie lifetime default 15 day
  'remember_login_cookie_lifetime' => 60*60*24*3,

  // session lifetime default 1 day
  'session_lifetime' => 60 * 60 * 24,

  // session keepalive default true
  'session_keepalive' => true,

  // force logout default false
  'auto_logout' => true,

  // auto scan files changes default 0
  'filesystem_check_changes' => 1,

  // file versions control default auto
  'versions_retention_obligation' => 'auto',

  // clear trashbin default auto(30 day)
  'trashbin_retention_obligation' => 'auto',

  // temp directory (not working)
  'tempdirectory' => '/var/www/nextcloud/temp',

  // user setting
  'skeletondirectory'  => '',
  'templatedirectory'  => '',
  'default_language' => 'zh_CN',
  'default_locale' => 'zh_Hans_CN',
  'default_phone_region' => 'CN',

  // logfile
  // you need mkdir and chown logs directory
  'log_type' => 'file',
  'logfile' => '/var/www/nextcloud/logs/nextcloud.log',
  // database query
  'log_query' => false,
  'loglevel' => 2,
  'logdateformat' => 'Y-m-d H:i:s',
  'logtimezone' => 'Asia/Taipei',
```

## PHP OCC Command

- [@nexntcloud/docs/admin_manual/occ_command](https://docs.nextcloud.com/server/stable/admin_manual/configuration_server/occ_command.html)

Find the path where occ is located in the container.

```sh
find / -iname "*occ*"
cd /var/www/nextcloud
./occ --version

# display config
docker exec --user=99:100 nextcloud php /var/www/nextcloud/occ config:list

# display get single value
docker exec --user=99:100 nextcloud php /var/www/nextcloud/occ config:system:get trusted_domains

# display user list
docker exec --user=99:100 nextcloud php /var/www/nextcloud/occ user:list

# display user setting
docker exec --user=99:100 nextcloud php /var/www/nextcloud/occ user:setting <usernmae>

# display config and private
docker exec --user=99:100 nextcloud php /var/www/nextcloud/occ config:list --private

# scan user file
docker exec --user=99:100 nextcloud php /var/www/nextcloud/occ files:scan <usernmae1> <usernmae2>

# scan user file and limit the search path
docker exec --user=99:100 nextcloud php /var/www/nextcloud/occ files:scan --path="/<username>/files/Photos"

# scan all user file,show directories and files verbose
docker exec --user=99:100 nextcloud php /var/www/nextcloud/occ files:scan --all --verbose

# clear users trashbin
docker exec --user=99:100 nextcloud php /var/www/nextcloud/occ trashbin:cleanup <usernmae1> <usernmae2>
docker exec --user=99:100 nextcloud php /var/www/nextcloud/occ trashbin:cleanup --all-users

# clean database tables not match files (Not tested)
docker exec --user=99:100 nextcloud php /var/www/nextcloud/occ files:cleanup
```

## Error Fix

- WARNING: [pool www] server reached pm.max_children setting (5), consider raising it.

Please refer to the following parameters: [www.conf](./nextcloud-data/php-fpm.d/www.conf)

- Module php-imagick in this instance has no SVG support. For better compatibility it is recommended to install it.

```sh
docker exec -it -u root:root nextcloud sh
apk add --no-cache imagemagick
```

## Improving

### Upload Chunk Size

For upload performance improvements in environments with high upload bandwidth, the server’s upload chunk size may be adjusted.Default is 10485760 (10 MiB).

```sh
# disable upload chunk size
docker exec --user=99:100 nextcloud php /var/www/nextcloud/occ config:app:set files max_chunk_size --value 0
```

### PHP-FPM

If you need high performance, you can optimize the default PHP-FPM parameters.

Please refer to the following parameters: [www.conf](./nextcloud-data/php-fpm.d/www.conf)

```sh
# nextcloud container add volumes
-v /mnt/user/appdata/nextcloud/nextcloud-data/config/php-fpm.d/www.conf:/usr/local/etc/php-fpm.d/www.conf \
```

Tips: It is recommended to do it after the nextcloud container is initialized, otherwise it may cause initialization errors or other problems.

## PHP-FPM Status Monitoring

If you need to monitor the running status of php-fpm:

- Uncomment in the `www.conf` configuration file the `pm.status_path`

```conf
pm.status_path = /status
```

- nginx configuration add `location` ,it is recommended to enable it only on internal networks.

```conf
    # php-fpm running status monitoring
    location /status {
        fastcgi_index   index.php;
        fastcgi_pass    php-handler;
        #fastcgi_pass    unix:/dev/shm/php-fpm.sock;
        include         fastcgi_params;
        fastcgi_param   SCRIPT_FILENAME    $document_root$fastcgi_script_name;
        fastcgi_param   SCRIPT_NAME        $fastcgi_script_name;
    }
```

## APPS

### Pre-Generate Previews

Reference:

- [@nextcloud/previewgenerator](https://github.com/nextcloud/previewgenerator)
- [Improving Nextcloud's Thumbnail Response Time](https://www.bentasker.co.uk/posts/documentation/linux/671-improving-nextcloud-s-thumbnail-response-time.html)

```sh
# nextcloud appstore install Preview Generator
docker exec --user=99:100 nextcloud php /var/www/nextcloud/occ preview:generate-all --verbose

# root user add crontab
*/30 * * * * php /var/www/nextcloud/occ preview:pre-generate

# reload crontab
killall busybox
nohup /cron.sh >/var/www/nextcloud/data/crond.log &
```

#### Limit the maximum size of the preview

```sh
# change nextcloud preview_max
docker exec --user=99:100 nextcloud php /var/www/nextcloud/occ config:system:set preview_max_x --value 1080
docker exec --user=99:100 nextcloud php /var/www/nextcloud/occ config:system:set preview_max_y --value 1920

# change nextcloud preview images quality
docker exec --user=99:100 nextcloud php /var/www/nextcloud/occ config:system:set jpeg_quality --value 50

# change preview generator sizes
docker exec --user=99:100 nextcloud php /var/www/nextcloud/occ config:app:set --value="32 64 1024"  previewgenerator squareSizes
docker exec --user=99:100 nextcloud php /var/www/nextcloud/occ config:app:set --value="64 128 1024" previewgenerator widthSizes
docker exec --user=99:100 nextcloud php /var/www/nextcloud/occ config:app:set --value="64 256 1024" previewgenerator heightSizes

# show config
docker exec --user=99:100 nextcloud php /var/www/nextcloud/occ config:list --private | grep preview
docker exec --user=99:100 nextcloud php /var/www/nextcloud/occ config:list --private | grep jpeg_quality
docker exec --user=99:100 nextcloud php /var/www/nextcloud/occ config:list --private | grep Sizes

# reset previews database
1. stop nextcloud docker
2. remove the folder your-nextcloud-data-directory/appdata_*/preview
3. run docker exec --user=99:100 nextcloud php /var/www/nextcloud/occ files:scan-app-data
4. run docker exec --user=99:100 nextcloud php /var/www/nextcloud/occ preview:generate-all --verbose
```

### Extract

Reference:

- [@PaulLereverend/NextcloudExtract](https://github.com/PaulLereverend/NextcloudExtract)
- [@nextcloud appstore/Extract](https://apps.nextcloud.com/apps/extract)

```sh
# nextcloud appstore install Extract

# zip
apk add --no-cache unzip

# rar
apk add --no-cache unrar --repository=https://dl-cdn.alpinelinux.org/alpine/v3.14/main

# 7z
apk add --no-cache p7zip
```

### Face Recognition (Deprecation)

Reference:

- [@matiasdelellis/facerecognition/issues/160](https://github.com/matiasdelellis/facerecognition/issues/160#issuecomment-741785257)

```sh
apk add --no-cache php8-pdlib --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing

cp -a /usr/lib/php8/modules/pdlib.so /usr/local/lib/php/extensions/no-debug-non-zts-20200930
cp -a /etc/php8/conf.d/pdlib.ini /usr/local/etc/php/conf.d/pdlib.ini

apk add --no-cache bzip2-dev
docker-php-ext-install bz2

docker exec --user=99:100 nextcloud php /var/www/nextcloud/occ face:stats

docker exec --user=99:100 nextcloud php /var/www/nextcloud/occ face:setup
docker exec --user=99:100 nextcloud php /var/www/nextcloud/occ face:setup 1
docker exec --user=99:100 nextcloud php /var/www/nextcloud/occ face:setup 2
docker exec --user=99:100 nextcloud php /var/www/nextcloud/occ face:setup 3
docker exec --user=99:100 nextcloud php /var/www/nextcloud/occ face:setup 4

docker exec --user=99:100 nextcloud php /var/www/nextcloud/occ face:setup --memory 4G --model 4
docker exec --user=99:100 nextcloud php /var/www/nextcloud/occ face:background_job -u <username1>
```
