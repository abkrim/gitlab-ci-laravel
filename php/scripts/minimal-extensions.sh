#!/usr/bin/env bash

set -euo pipefail

# Minimal PHP extensions for Laravel typical apps
export extensions=" \
  opcache \
  pdo_mysql \
  mysqli \
  bcmath \
  zip \
  "

# Build tools required to compile PHP extensions and PECL
export buildDeps=" \
  build-essential \
  autoconf \
  pkg-config \
  "

# Runtime libraries required by extensions (keep minimal)
export runtimeDeps=" \
  libzip-dev \
  "

apt-get update \
  && apt-get install -yq --no-install-recommends $buildDeps $runtimeDeps \
  && docker-php-ext-install -j$(nproc) $extensions \
  && pecl channel-update pecl.php.net \
  && pecl install redis \
  && docker-php-ext-enable redis \
  && apt-get purge -y --auto-remove $buildDeps \
  && rm -rf /var/lib/apt/lists/*

echo 'opcache.enable=1' > /usr/local/etc/php/conf.d/20-opcache.ini


