#!/bin/bash

set -euo pipefail

# Installing Chromium for Dusk (Debian Trixie compatible)
echo "Installing Chromium dependencies..."

# Install basic dependencies for Debian Trixie (modern packages)
apt-get update \
  && apt-get install -yq \
    libnss3 \
    libxi6 \
    libgbm-dev \
    libxss1 \
    libxrandr2 \
    libasound2 \
    libpangocairo-1.0-0 \
    libatk1.0-0 \
    libcairo-gobject2 \
    libgtk-3-0 \
    libdrm2 \
    libxcomposite1 \
    libxdamage1 \
    libxfixes3 \
    libxrender1 \
    wget \
    xvfb \
    gnupg \
    ca-certificates \
  && (apt-get install -yq libgdk-pixbuf-2.0-0 || apt-get install -yq libgdk-pixbuf-xlib-2.0-0)

arch=$(dpkg --print-architecture)

if [ "$arch" = "amd64" ]; then
  echo "Adding Google Chrome repository (amd64)..."
  wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /usr/share/keyrings/googlechrome-linux-keyring.gpg \
    && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/googlechrome-linux-keyring.gpg] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list \
    && apt-get update -yqq

  echo "Installing Google Chrome..."
  apt-get install -yqq google-chrome-stable
else
  echo "Non-amd64 architecture ($arch) detected. Installing Chromium from Debian repos..."
  apt-get update -yqq \
    && apt-get install -yqq chromium || (echo "Chromium not available for $arch" && exit 1)
fi

echo "Chromium installation completed successfully!"
