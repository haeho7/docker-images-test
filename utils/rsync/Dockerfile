#
# Dockerfile for rsync
#

# alpine-based image cannot set "use chroot = yes", so based on debian:bullseye-slim
# reference:
#   https://stackoverflow.com/a/64739747
#   https://stackoverflow.com/a/60816190
FROM debian:bullseye-slim
LABEL maintainer="haeho7 <i@demo.com>"

RUN apt-get update \
  && apt-get install --no-install-recommends -y locales cron rsync procps \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN rm -f /etc/cron.*/*

RUN sed -i '/^# en_US.UTF-8 UTF-8/s/^# //' /etc/locale.gen \
  && locale-gen \
  && echo LANG=en_US.UTF-8 > /etc/default/locale

COPY rsync.sh /usr/local/bin/

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US
ENV LC_COLLATE=C

ENV ENABLE_DAEMON=0
ENV CRONTAB=

ENTRYPOINT ["rsync.sh"]
