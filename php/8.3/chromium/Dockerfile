FROM edbizarro/gitlab-ci-pipeline-php:8.3

ARG BUILD_DATE
ARG VCS_REF

LABEL maintainer="Fork Maintainers" \
  PHP="8.3" \
  NODE="22" \
  org.label-schema.name="gitlab-ci-pipeline-php (fork)" \
  org.label-schema.description=":coffee: PHP 8.3 Chromium image for Dusk with pnpm and Node 22" \
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

USER root

WORKDIR /tmp

COPY ./php/scripts/*.sh /tmp/
RUN chmod +x /tmp/*.sh

RUN bash ./packages.sh \
  && bash ./chromium.sh

USER $IMAGE_USER

WORKDIR /var/www/html
