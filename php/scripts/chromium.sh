#!/bin/bash

set -euo pipefail

# Installing Chromium for Dusk
echo "Installing Chromium dependencies..."

# Install basic dependencies
apt-get update \
  && apt-get install -yq \
    libgconf-2-4 \
    libnss3 \
    libxi6 \
    libgbm-dev \
    wget \
    xvfb \
    gnupg \
    ca-certificates

echo "Adding Google Chrome repository..."

# Add Google Chrome repository
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
  && echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list \
  && apt-get update -yqq

echo "Installing Google Chrome..."

# Install Google Chrome
apt-get install -yqq google-chrome-stable

echo "Chromium installation completed successfully!"
