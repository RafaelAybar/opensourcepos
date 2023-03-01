FROM php:7.4-fpm AS ospos
LABEL maintainer="jekkos"

RUN deluser --remove-home www-data && adduser -u1000 -D www-data && rm -rf /var/www /usr/local/etc/php-fpm.d/* && \
    mkdir -p /var/www/.composer /app && chown -R www-data:www-data /app /var/www/.composer; \
    mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

COPY --from=composer:2.5 /usr/bin/composer /usr/bin/composer

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    libicu-dev \
    libgd-dev \
    openssl --no-install-recommends && docker-php-ext-install -j$(nproc) mysqli bcmath intl gd \
    && echo "date.timezone = \"\${PHP_TIMEZONE}\"" > /usr/local/etc/php/conf.d/timezone.ini && apt autoremove -y \
    && apt autoclean

# COPY docker/php/base-*   $PHP_INI_DIR/conf.d
# COPY docker/fpm/*.conf  /usr/local/etc/php-fpm.d/
USER www-data