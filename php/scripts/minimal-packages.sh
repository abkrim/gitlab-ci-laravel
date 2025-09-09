#!/usr/bin/env bash

set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

echo "Installing minimal system packages..."

apt-get update \
  && apt-get install -yq --no-install-recommends \
      ca-certificates \
      apt-transport-https \
      apt-utils \
      curl \
      git \
      unzip \
      mariadb-client \
  && rm -rf /var/lib/apt/lists/*

echo "Minimal system packages installed successfully!"


