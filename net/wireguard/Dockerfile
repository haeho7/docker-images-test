#
# Dockerfile for wireguard
#

#
# Build stage
#
FROM golang:1.19-alpine AS builder

ARG VERSION=0.0.20230223
RUN apk update \
  && apk add --no-cache --virtual .build-deps git make gcc musl-dev \
  && git clone https://github.com/WireGuard/wireguard-go.git --branch $VERSION \
  && cd wireguard-go \
  && git checkout $VERSION \
  && sed -i 's/go build -v -o "$@"/env CGO_ENABLED=0 go build -v -o "$@" -trimpath -ldflags "-s -w"/' Makefile \
  && make \
  && make install \
  && cd - \
  && rm -r wireguard-go \
  && apk del .build-deps \
  && rm -rf /var/cache/apk/*

#
# Runtime stage
#
FROM alpine:3.18
LABEL maintainer="haeho7 <i@demo.com>"

ARG WIREGUARD_VER=1.0.20210914-r3
RUN apk update \
  && apk add --no-cache iptables ip6tables tzdata \
      wireguard-tools=$WIREGUARD_VER \
      wireguard-tools-doc=$WIREGUARD_VER \
  && rm -rf /var/cache/apk/*

RUN install /usr/share/doc/wireguard-tools/contrib/reresolve-dns/reresolve-dns.sh /usr/local/bin/

COPY --from=builder /usr/bin/wireguard-go /usr/local/bin/
COPY wireguard.sh /usr/local/bin/

ENV USE_IPTABLES_NFT_BACKEND=0
ENV PEER_RESOLVE_INTERVAL=0

ENTRYPOINT ["wireguard.sh"]
