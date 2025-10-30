#
# Dockerfile for samba
#

FROM alpine:3.22
LABEL maintainer="haeho7 <i@demo.com>"

ARG SAMBA_VER=4.21.4-r4
RUN apk update \
  && apk add --no-cache tzdata shadow samba=$SAMBA_VER \
  && rm -rf /var/cache/apk/*

COPY samba.sh /usr/local/bin/

EXPOSE 445/tcp 445/udp
ENTRYPOINT ["samba.sh"]
