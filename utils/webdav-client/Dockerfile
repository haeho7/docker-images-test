FROM alpine:3.16
LABEL maintainer="haeho7 <i@demo.com>"

RUN apk update \
  && apk --no-cache add ca-certificates tzdata davfs2 tini \
  && rm -rf /var/cache/apk/*

COPY *.sh /usr/local/bin/

ENV WEBDRIVE_URL=
ENV WEBDRIVE_USERNAME=
ENV WEBDRIVE_PASSWORD=
ENV WEBDRIVE_PASSWORD_FILE=
ENV WEBDRIVE_MOUNT=/mnt/webdrive

VOLUME [ "/mnt/webdrive" ]

ENTRYPOINT [ "tini", "-g", "--", "webdav-client.sh" ]
CMD [ "ls.sh" ]
