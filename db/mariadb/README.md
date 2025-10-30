# MariaDB

## Usage

```sh
docker run -d \
  --name=mariadb \
  --restart=unless-stopped \
  --network=host \
  --security-opt seccomp=unconfined \
  --ulimit memlock=-1 \
  --ulimit nproc=-1 \
  --ulimit nofile=1048576:1048576 \
  --log-opt max-file=1 \
  --log-opt max-size=20m \
  -e TZ=Asia/Taipei \
  -e PUID=99 \
  -e PGID=100 \
  #-e MARIADB_DATABASE=example \
  #-e MARIADB_USER=example \
  #-e MARIADB_PASSWORD='example' \
  -e MARIADB_ROOT_HOST='%' \
  -e MARIADB_ROOT_PASSWORD='example' \
  -v /mnt/user/appdata/mariadb/mariadb-data/init.d:/docker-entrypoint-initdb.d \
  -v /mnt/user/appdata/mariadb/mariadb-data/conf.d:/etc/mysql/conf.d \
  -v /mnt/user/appdata/mariadb/mariadb-data/data:/var/lib/mysql \
  haeho7/docker-images:mariadb
```

## Fix Permission

If the configuration file does not take effect, you need to repair the configuration file permissions.

```sh
chmod 0644 /mnt/user/appdata/mariadb/mariadb-data/conf.d/mariadb.cnf
```

## Case Sensitive

- [@mariadb.com/docs/server/system-variables](https://mariadb.com/docs/server/server-management/variables-and-modes/server-system-variables#lower_case_table_names)

Determines whether table names, table aliases, and database names are compared in a case-sensitive manner, and whether tablespace files are stored on disk in a case-sensitive manner.

```cnf
# linux default
lower_case_table_names = 0

# windows default
lower_case_table_names = 1

# macos default
lower_case_table_names = 2
```

## Variable

```sql
show variables;
show global variables;
```
