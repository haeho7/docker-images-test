#
# Dockerfile for nextcloud
#

FROM nextcloud:24.0.12-fpm-alpine
LABEL maintainer="haeho7 <i@demo.com>"

# install nextcloud ext packages
RUN apk update \
  && apk add --no-cache tzdata shadow ffmpeg imagemagick samba-client \
  && rm -rf /var/cache/apk/*

ENV UPLOAD_TMP_DIR="/var/www/nextcloud/temp"
ENV PHP_OUTPUT_BUFFERING=0
ENV PHP_MAX_EXECUTION_TIME=900
ENV PHP_MAX_FILE_UPLOADS=30

# php optimize
RUN mkdir /usr/src/nextcloud/temp \
  && { \
        echo 'upload_tmp_dir=${UPLOAD_TMP_DIR}'; \
        echo 'output_buffering=${PHP_OUTPUT_BUFFERING}'; \
        echo 'max_execution_time=${PHP_MAX_EXECUTION_TIME}'; \
        echo 'max_file_uploads=${PHP_MAX_FILE_UPLOADS}'; \
      } > "${PHP_INI_DIR}/conf.d/php-optimize.ini"

# change nextcloud webroot
RUN sed -i 's|/var/www/html|/var/www/nextcloud|g' /entrypoint.sh \
  && sed -i 's|/var/www/html|/var/www/nextcloud|g' /var/spool/cron/crontabs/www-data

# add logs dir
RUN mkdir /usr/src/nextcloud/logs

COPY nextcloud.sh /usr/local/bin/
COPY nextcloud-data/php-fpm.d/www.conf /usr/local/etc/php-fpm.d/

WORKDIR /var/www/nextcloud

EXPOSE 9000

ENTRYPOINT ["nextcloud.sh"]
CMD ["php-fpm"]
