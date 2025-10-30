#
# Dockerfile for webdav
#

#
# Build stage
#
FROM golang:alpine AS builder

ARG VERSION=v5.8.1
RUN apk update \
  && apk add --no-cache --virtual .build-deps git gcc musl-dev \
  && git clone https://github.com/hacdias/webdav.git --branch $VERSION \
  && cd webdav \
  && CGO_ENABLED=0 go build -trimpath -ldflags="-w -s -X github.com/hacdias/webdav/v5/cmd.version=$VERSION" -o webdav -v \
  && cp webdav /usr/local/bin/ \
  && cd .. \
  && rm -r webdav \
  && apk del .build-deps \
  && rm -rf /var/cache/apk/*

#
# Runtime stage
#
FROM alpine:3.22
LABEL maintainer="haeho7 <i@demo.com>"

RUN apk update \
  && apk add tzdata shadow \
  && apk add gosu --repository=https://dl-cdn.alpinelinux.org/alpine/edge/community \
  && rm -rf /var/cache/apk/*

RUN groupadd -r webdav \
  && useradd -r -g webdav webdav

COPY --from=builder /usr/local/bin/webdav /usr/local/bin/
COPY webdav.sh /usr/local/bin/

VOLUME /data

ENTRYPOINT ["webdav.sh"]
