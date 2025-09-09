#!/usr/bin/env bash

set -euo pipefail

# Treat all PHP 8.x versions the same as 8.0
if [[ "$PHP_VERSION" == 8.* ]]; then
  export extensions=" \
    bcmath \
    bz2 \
    calendar \
    exif \
    gmp \
    intl \
    mysqli \
    opcache \
    pcntl \
    pdo_mysql \
    pdo_pgsql \
    pgsql \
    soap \
    xsl \
    zip
    "
else
  export extensions=" \
    bcmath \
    bz2 \
    calendar \
    exif \
    gmp \
    intl \
    mysqli \
    opcache \
    pcntl \
    pdo_mysql \
    pdo_pgsql \
    pgsql \
    soap \
    xmlrpc \
    xsl \
    zip
    "
fi

export buildDeps=" \
    libbz2-dev \
    libsasl2-dev \
    pkg-config \
    "

export runtimeDeps=" \
    imagemagick \
    libfreetype6-dev \
    libgmp-dev \
    libicu-dev \
    libjpeg-dev \
    libkrb5-dev \
    libldap2-dev \
    libmagickwand-dev \
    libpng-dev \
    libpq-dev \
    librabbitmq-dev \
    libssl-dev \
    libuv1-dev \
    libwebp-dev \
    libxml2-dev \
    libxslt1-dev \
    libzip-dev \
    "


apt-get update \
  && apt-get install -yq $buildDeps \
  && apt-get install -yq $runtimeDeps \
  && rm -rf /var/lib/apt/lists/* \
  && docker-php-ext-install -j$(nproc) $extensions

# Determine LDAP libdir based on architecture
arch=$(dpkg --print-architecture || echo amd64)
case "$arch" in
  amd64)
    LDAP_LIBDIR="lib/x86_64-linux-gnu/"
    ;;
  arm64)
    LDAP_LIBDIR="lib/aarch64-linux-gnu/"
    ;;
  *)
    # Fallback: derive from uname
    LDAP_LIBDIR="lib/$(uname -m)-linux-gnu/"
    ;;
esac

if [[ "$PHP_VERSION" == 8.* || $PHP_VERSION == "7.4" ]]; then
  docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-configure ldap --with-libdir=$LDAP_LIBDIR \
    && docker-php-ext-install -j$(nproc) ldap \
    && docker-php-source delete
else
  docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ --with-webp-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-configure ldap --with-libdir=$LDAP_LIBDIR \
    && docker-php-ext-install -j$(nproc) ldap \
    && docker-php-source delete
fi

if [[ "$PHP_VERSION" != 8.* ]]; then
  docker-php-source extract \
    && git clone https://github.com/php-memcached-dev/php-memcached /usr/src/php/ext/memcached/ \
    && docker-php-ext-install memcached \
    && docker-php-ext-enable memcached \
    && docker-php-source delete

  pecl channel-update pecl.php.net \
    && pecl install redis apcu xdebug \
    && docker-php-ext-enable redis apcu xdebug

  #AMQP
  docker-php-source extract \
    && mkdir /usr/src/php/ext/amqp \
    && curl -L https://github.com/php-amqp/php-amqp/archive/master.tar.gz | tar -xzC /usr/src/php/ext/amqp --strip-components=1 \
    && docker-php-ext-install amqp \
    && docker-php-source delete

  #Imagick
  cd /usr/local/src \
    && git clone https://github.com/Imagick/imagick \
    && cd imagick \
    && phpize \
    && ./configure \
    && make \
    && make install \
    && cd .. \
    && rm -rf imagick \
    && docker-php-ext-enable imagick

  #XMLRPC
  mkdir /usr/local/src/xmlrpc \
    && cd /usr/local/src/xmlrpc \
    && curl -L https://pecl.php.net/get/xmlrpc-1.0.0RC1.tgz | tar -xzC /usr/local/src/xmlrpc --strip-components=1 \
    && phpize \
    && ./configure \
    && make \
    && make install \
    && cd .. \
    && rm -rf xmlrpc \
    && docker-php-ext-enable xmlrpc

else

  # Skip memcached on PHP 8.x to avoid missing runtime lib issues

  echo "Installing PECL extensions for PHP 8.x..."
  
  # Install extensions one by one to avoid failures
  pecl channel-update pecl.php.net
  
  # Install Redis
  pecl install redis && docker-php-ext-enable redis
  
  # Install APCu
  pecl install apcu && docker-php-ext-enable apcu
  
  # Install Imagick
  pecl install imagick && docker-php-ext-enable imagick
  
  # Install Xdebug
  pecl install xdebug && docker-php-ext-enable xdebug
  
  # Install AMQP (may fail, but continue)
  pecl install amqp && docker-php-ext-enable amqp || echo "AMQP installation failed, continuing..."
fi

{ \
    echo 'opcache.enable=1'; \
    echo 'opcache.revalidate_freq=0'; \
    echo 'opcache.validate_timestamps=1'; \
    echo 'opcache.max_accelerated_files=10000'; \
    echo 'opcache.memory_consumption=192'; \
    echo 'opcache.max_wasted_percentage=10'; \
    echo 'opcache.interned_strings_buffer=16'; \
    echo 'opcache.fast_shutdown=1'; \
} > /usr/local/etc/php/conf.d/opcache-recommended.ini

{ \
    echo 'apc.shm_segments=1'; \
    echo 'apc.shm_size=1024M'; \
    echo 'apc.num_files_hint=7000'; \
    echo 'apc.user_entries_hint=4096'; \
    echo 'apc.ttl=7200'; \
    echo 'apc.user_ttl=7200'; \
    echo 'apc.gc_ttl=3600'; \
    echo 'apc.max_file_size=100M'; \
    echo 'apc.stat=1'; \
} > /usr/local/etc/php/conf.d/apcu-recommended.ini

echo 'memory_limit=1024M' > /usr/local/etc/php/conf.d/zz-conf.ini

if [[ "$PHP_VERSION" == 8.* || $PHP_VERSION == "7.4" ]]; then
  # https://xdebug.org/docs/upgrade_guide#changed-xdebug.coverage_enable
  echo 'xdebug.mode=coverage' > /usr/local/etc/php/conf.d/20-xdebug.ini
else
  echo 'xdebug.coverage_enable=1' > /usr/local/etc/php/conf.d/20-xdebug.ini
fi

