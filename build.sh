#!/bin/bash

# Build script for Laravel GitLab CI Docker images
# Usage: ./build.sh [variant] [tag]

set -e

VARIANT=${1:-default}
TAG=${2:-8.3}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Building Laravel GitLab CI Docker Image${NC}"
echo -e "${YELLOW}Variant: ${VARIANT}${NC}"
echo -e "${YELLOW}Tag: ${TAG}${NC}"

case $VARIANT in
  "default")
    DOCKERFILE="php/8.3/Dockerfile"
    IMAGE_TAG="abkrim/laravel-gitlab-ci:${TAG}"
    ;;
  "alpine")
    DOCKERFILE="php/8.3/alpine/Dockerfile"
    IMAGE_TAG="abkrim/laravel-gitlab-ci:${TAG}-alpine"
    ;;
  "fpm")
    DOCKERFILE="php/8.3/fpm/Dockerfile"
    IMAGE_TAG="abkrim/laravel-gitlab-ci:${TAG}-fpm"
    ;;
  "chromium")
    DOCKERFILE="php/8.3/chromium/Dockerfile"
    IMAGE_TAG="abkrim/laravel-gitlab-ci:${TAG}-chromium"
    ;;
  *)
    echo -e "${RED}Error: Unknown variant '${VARIANT}'${NC}"
    echo "Available variants: default, alpine, fpm, chromium"
    exit 1
    ;;
esac

echo -e "${GREEN}Building image: ${IMAGE_TAG}${NC}"
echo -e "${GREEN}Using Dockerfile: ${DOCKERFILE}${NC}"

# Build the image
docker build -t "${IMAGE_TAG}" -f "${DOCKERFILE}" .

echo -e "${GREEN}Build completed successfully!${NC}"
echo -e "${YELLOW}Image: ${IMAGE_TAG}${NC}"

# Ask if user wants to push
read -p "Do you want to push this image to Docker Hub? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${GREEN}Pushing to Docker Hub...${NC}"
    docker push "${IMAGE_TAG}"
    echo -e "${GREEN}Push completed!${NC}"
fi