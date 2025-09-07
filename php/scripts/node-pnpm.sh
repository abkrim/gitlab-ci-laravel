#!/usr/bin/env bash

set -euo pipefail

# Install Node.js 22.x and pnpm via corepack (Debian/Ubuntu)
curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
  && DEBIAN_FRONTEND=noninteractive apt-get install -yq nodejs \
  && corepack enable \
  && corepack prepare pnpm@latest --activate \
  && npm i -g --force npm \
  && npm cache clean --force
