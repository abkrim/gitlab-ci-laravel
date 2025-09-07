FROM php:8.3-alpine

ARG BUILD_DATE
ARG VCS_REF

LABEL maintainer="Fork Maintainers" \
  PHP="8.3" \
  NODE="22" \
  org.label-schema.name="gitlab-ci-pipeline-php (fork)" \
  org.label-schema.description=":coffee: PHP 8.3 Alpine image for build/test with pnpm and Node 22" \
  org.label-schema.build-date=$BUILD_DATE \
  org.label-schema.schema-version="1.0" \
  org.label-schema.vcs-ref=$VCS_REF

# Set correct environment variables
ENV IMAGE_USER=php
ENV HOME=/home/$IMAGE_USER
ENV COMPOSER_HOME=$HOME/.composer
ENV PATH=$HOME/.local/share/pnpm:$PATH
ENV GOSS_VERSION="0.4.4"
ENV PHP_VERSION=8.3

WORKDIR /tmp

COPY ./php/scripts/alpine/*.sh /tmp/
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

RUN chmod +x /tmp/*.sh \
  && adduser -D $IMAGE_USER \
  && mkdir -p /var/www/html \
  && apk add --update --no-cache bash \
  && bash ./packages.sh \
  && bash ./extensions.sh \
  && bash ./node-pnpm.sh \
  && rm -rf ~/.composer/cache/* \
  && chown -R $IMAGE_USER:$IMAGE_USER /var/www $HOME \
  && echo "$IMAGE_USER  ALL = ( ALL ) NOPASSWD: ALL" >> /etc/sudoers \
  && curl -fsSL https://goss.rocks/install | GOSS_VER=v${GOSS_VERSION} sh \
  && bash ./cleanup.sh

USER $IMAGE_USER

WORKDIR /var/www/html

CMD ["php", "-a"]
