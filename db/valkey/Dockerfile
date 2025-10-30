#
# Dockerfile for valkey
#

FROM valkey/valkey:8.1.4-alpine
LABEL maintainer="haeho7 <i@demo.com>"
# See more: https://github.com/valkey-io/valkey-container/blob/mainline

RUN apk update \
  && apk add --no-cache tzdata shadow \
  && rm -rf /var/cache/apk/*

COPY valkey.sh /usr/local/bin/

VOLUME /data
WORKDIR /data

EXPOSE 6379

ENTRYPOINT ["valkey.sh"]
CMD ["valkey-server"]
