#!/usr/bin/env bash

set -euo pipefail

# Install Node.js current and pnpm via corepack (Alpine)
apk add --update --no-cache nodejs-current npm \
  && corepack enable \
  && corepack prepare pnpm@latest --activate \
  && npm i -g --force npm \
  && rm -rf /usr/share/man /var/cache/apk/* \
    /root/.npm /root/.node-gyp /root/.gnupg /usr/lib/node_modules/npm/man \
    /usr/lib/node_modules/npm/doc /usr/lib/node_modules/npm/html /usr/lib/node_modules/npm/scripts
