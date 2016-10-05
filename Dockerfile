FROM alpine:3.4
MAINTAINER xataz <https://github.com/xataz>
MAINTAINER hardware <https://github.com/hardware>
MAINTAINER slanterns <slanterns.w@gmail.com>

ARG VERSION=v0.1.0-beta.5

ENV GID=991 UID=991

RUN echo "@commuedge https://nl.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories \
 && apk -U add \
    nginx \
    s6 \
    su-exec \
    curl \
    mariadb-client \
    php7-phar@commuedge \
    php7-fpm@commuedge \
    php7-curl@commuedge \
    php7-mbstring@commuedge \
    php7-openssl@commuedge \
    php7-json@commuedge \
    php7-pdo_mysql@commuedge \
    php7-gd@commuedge \
    php7-dom@commuedge \
    php7-ctype@commuedge \
    php7-session@commuedge \
    php7-opcache@commuedge \
 && cd /tmp \
 && ln -s /usr/bin/php7 /usr/bin/php \
 && curl -s http://getcomposer.org/installer | php \
 && mv /tmp/composer.phar /usr/bin/composer \
 && chmod +x /usr/bin/composer \
 && composer config -g repo.packagist composer https://packagist.phpcomposer.com  #Source
 && mkdir -p /flarum/app \
 && chown -R $UID:$GID /flarum \
 && su-exec $UID:$GID composer create-project flarum/flarum /flarum/app $VERSION --stability=beta \
 && composer clear-cache \
 && rm -rf /flarum/.composer /var/cache/apk/*

COPY config.sql /flarum/app/config.sql
COPY nginx.conf /etc/nginx/nginx.conf
COPY php-fpm.conf /etc/php7/php-fpm.conf
COPY opcache.ini /etc/php7/conf.d/00_opcache.ini
COPY composer /usr/local/bin/composeur
COPY s6.d /etc/s6.d
COPY run.sh /usr/local/bin/run.sh

#ADD Chinese support
ADD zh-CN.tar.xz /flarum/app/extensions/

RUN chmod +x /usr/local/bin/* /etc/s6.d/*/* /etc/s6.d/.s6-svscan/*

VOLUME /flarum/app/assets

EXPOSE 8888

CMD ["run.sh"]
