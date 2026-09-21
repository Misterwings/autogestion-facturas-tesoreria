FROM php:8.4-cli

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        git \
        unzip \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libicu-dev \
        libonig-dev \
        libpng-dev \
        libpq-dev \
        libsqlite3-dev \
        libzip-dev \
        libxml2-dev \
        fonts-dejavu-core \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install \
        dom \
        gd \
        intl \
        mbstring \
        pdo_pgsql \
        pdo_sqlite \
        simplexml \
        xml \
        xmlreader \
        xmlwriter \
        zip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]
