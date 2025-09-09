FROM php:8.3-fpm

ARG BUILD_DATE
ARG VCS_REF

LABEL maintainer="Fork Maintainers" \
  PHP="8.3" \
  org.label-schema.name="gitlab-ci-pipeline-php (fork) minimal fpm" \
  org.label-schema.description=":coffee: Minimal PHP 8.3 FPM image for Laravel (mysql, redis)" \
  org.label-schema.build-date=$BUILD_DATE \
  org.label-schema.schema-version="1.0" \
  org.label-schema.vcs-ref=$VCS_REF

ENV IMAGE_USER=php
ENV HOME=/home/$IMAGE_USER
ENV COMPOSER_HOME=$HOME/.composer

USER root

WORKDIR /tmp

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer
COPY ./php/scripts/minimal-*.sh /tmp/

RUN chmod +x /tmp/*.sh \
  && bash ./minimal-packages.sh \
  && bash ./minimal-extensions.sh \
  && adduser --disabled-password --gecos "" $IMAGE_USER \
  && mkdir -p /var/www/html $HOME/.config $COMPOSER_HOME \
  && chown -R $IMAGE_USER:$IMAGE_USER /var/www $HOME

USER $IMAGE_USER

WORKDIR /var/www/html


