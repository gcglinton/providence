FROM php:8.3-apache

RUN apt-get update && \
    apt-get install -y ghostscript libgraphicsmagick1-dev libpoppler-dev poppler-utils dcraw \
        ffmpeg libimage-exiftool-perl libreoffice mediainfo libicu-dev libzip-dev libgmp-dev

RUN docker-php-ext-install -j$(nproc) gd && \
    docker-php-ext-install -j$(nproc) intl && \
    docker-php-ext-install -j$(nproc) mysqli && \ 
    docker-php-ext-install -j$(nproc) zip && \
    docker-php-ext-install -j$(nproc) gmp && \
    pecl install -o -f xmlrpc && \
    docker-php-ext-enable xmlrpc && \
    yes '' | pecl install -o -f redis && \
    docker-php-ext-enable redis && \
    yes '' | pecl install -o -f gmagick && \
    docker-php-ext-enable gmagick

COPY . /var/www/html/

WORKDIR /var/www/html

ENV PHP_MEMORY_LIMIT=256m
ENV PHP_UPLOAD_MAX_FILESIZE=500m
ENV PHP_POST_MAX_SIZE=600m
ENV PHP_DISPLAY_ERRORS=On
ENV COLLECTIVEACCESS_HOME=/var/www/html 

RUN cp support/scripts/install_composer.sh.txt app/tmp/install_composer.sh && \
    chmod +x app/tmp/install_composer.sh && \
    COLLECTIVEACCESS_HOME=/var/www/html ./app/tmp/install_composer.sh

RUN php app/tmp/composer.phar -n install

RUN rm app/tmp/composer.phar app/tmp/install_composer.sh
