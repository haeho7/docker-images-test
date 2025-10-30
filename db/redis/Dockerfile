#
# Dockerfile for redis
#

FROM redis:8.2.2-alpine
LABEL maintainer="haeho7 <i@demo.com>"
# See more: https://github.com/redis/docker-library-redis/tree/master

RUN apk update \
  && apk add --no-cache tzdata shadow \
  && rm -rf /var/cache/apk/*

COPY redis.sh /usr/local/bin/

VOLUME /data
WORKDIR /data

EXPOSE 6379

ENTRYPOINT ["redis.sh"] 
CMD ["redis-server"]
