#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")"/.. && pwd)
cd "$ROOT_DIR"

echo "[1/5] Building PHP 8.3 image..."
docker build --build-arg VCS_REF=local --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') -t local/gitlab-ci-pipeline-php:8.3 -f php/8.3/Dockerfile .

echo "[2/5] Starting MySQL 8.0 and Redis..."
docker compose -f docker-compose.local.yml up -d mysql redis

echo "[3/5] Waiting for services to be healthy..."
docker compose -f docker-compose.local.yml ps

# Run goss tests inside the built image (using host volume to access tests folder)
echo "[4/5] Running goss sanity tests..."
docker run --rm -t -v "$ROOT_DIR":/var/www/html local/gitlab-ci-pipeline-php:8.3 goss -g tests/goss-8.3.yaml v

echo "[5/5] Spinning container to test app connectivity..."
docker compose -f docker-compose.local.yml up -d php83

echo
read -p $'Manual check: Container up with MySQL/Redis. Press ENTER to continue building/publishing later...\n' -r

# Leave stack running for manual checks

echo "Done. You can now exec into php83: docker compose -f docker-compose.local.yml exec php83 bash"
