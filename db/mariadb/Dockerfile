#
# Dockerfile for mariadb
#

FROM mariadb:11.4.8-noble
LABEL maintainer="haeho7 <i@demo.com>"
# See more: https://github.com/MariaDB/mariadb-docker/tree/master

RUN apt-get update \
  && apt-get install -y --no-install-recommends tzdata \
  && rm -rf /var/lib/apt/lists/*

COPY mariadb.sh /usr/local/bin/

VOLUME /var/lib/mysql
WORKDIR /var/lib/mysql

EXPOSE 3306

ENTRYPOINT ["mariadb.sh"]
CMD ["mariadbd"]
