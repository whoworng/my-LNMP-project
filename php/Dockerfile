ARG PHP_VERSION=8.2
FROM php:${PHP_VERSION}-fpm-alpine

ARG TZ=UTC

# 必需工具与扩展：根据需要增减。若精简镜像可移除不需要的扩展。
RUN set -ex \
    && apk update \
    && apk add --no-cache $PHPIZE_DEPS bash tzdata icu-dev oniguruma-dev libzip-dev curl git linux-headers \
    && cp /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo ${TZ} > /etc/timezone \
    # 内置扩展
    && docker-php-ext-install -j$(nproc) mysqli pdo pdo_mysql intl zip opcache \
    # 第三方扩展 (按需启用/删除)
    && pecl install redis xdebug \
    && docker-php-ext-enable redis \
    # 可选: 不在这里启用 xdebug，按需在 php.ini 中启用
    # && docker-php-ext-enable xdebug \
    && apk del --no-cache $PHPIZE_DEPS linux-headers

WORKDIR /var/www/html

# TODO: 如需与宿主机用户映射 UID/GID，或设置 Composer，这里追加命令
# 例如：
# RUN addgroup -g 1000 app && adduser -D -G app -u 1000 app \
#     && chown -R app:app /var/www/html

COPY fpm-pool.d/www.conf /usr/local/etc/php-fpm.d/www.conf
