#
# Dockerfile for alist
#

#
# Build stage
#
FROM golang:alpine AS builder

ARG VERSION=v3.39.4
RUN apk update \
  && apk add --no-cache --virtual .build-deps bash curl git gcc musl-dev \
  && git clone https://github.com/alist-org/alist.git --branch $VERSION \
  && cd alist \
  && sed -i 's|repos/alist-org/alist-web/releases/latest|repos/alist-org/alist-web/releases/tags/3.39.2|g' build.sh \
  && sed -i 's|alist-org/alist-web/releases/latest/download|alist-org/alist-web/releases/download/3.39.2|g' build.sh \
  && bash build.sh release docker \
  && cp bin/alist /usr/local/bin/ \
  && cd - \
  && rm -rf alist \
  && apk del .build-deps \
  && rm -rf /var/cache/apk/*

#
# Runtime stage
#
FROM alpine:3.19
LABEL maintainer="haeho7 <i@demo.com>"

RUN apk update \
  && apk add --no-cache tzdata shadow ffmpeg \
  && apk add --no-cache gosu --repository=https://dl-cdn.alpinelinux.org/alpine/edge/community \
  && rm -rf /var/cache/apk/*

RUN groupadd -r alist \
  && useradd -r -g alist alist

COPY --from=builder /usr/local/bin/alist /usr/local/bin/
COPY alist.sh /usr/local/bin/

VOLUME /opt/alist/data
WORKDIR /opt/alist

EXPOSE 5244 5245

ENTRYPOINT ["alist.sh"]
