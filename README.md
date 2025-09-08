# Laravel GitLab CI Docker Image (PHP 8.3)

> **Important Note**: This repository is an independent fork of the original project [edbizarro/gitlab-ci-pipeline-php](https://github.com/edbizarro/gitlab-ci-pipeline-php). 
> 
> **Credits and Acknowledgments**: All credit for the initial work belongs to [@edbizarro](https://github.com/edbizarro) and the contributors of the original project. This fork maintains respect and recognition for the original work.

## Docker Hub Repository

**Repository**: [abkrim/laravel-gitlab-ci](https://hub.docker.com/repository/docker/abkrim/laravel-gitlab-ci/general)

**Available Tags**:
- `abkrim/laravel-gitlab-ci:8.3` (also available as `latest`)
- Multi-arch support: `linux/amd64` and `linux/arm64`

## Image Specifications

- **Base**: `php:8.3` (Debian)
- **Package Manager**: pnpm (Node 22 via corepack)
- **Included Tools**: Composer 2, Node 22 + pnpm, Redis, APCu, PDO MySQL, Imagick, Xdebug (coverage), git, jq, rsync, unzip, zip
- **MySQL CLI**: Configured for local environment (no TLS) via `~/.my.cnf`

## Differences from Original Project

This fork maintains active development only for PHP 8.3 and replaces Yarn with pnpm (Node 22 via corepack). The original project included multiple PHP versions (7.3, 7.4, 8.0, 8.3) and used Yarn as the Node.js package manager.

## Usage

### Quick Start (Local Development)

Run Laravel tests with MySQL 8.0 and Redis running separately:

```bash
docker run --rm -it -v "$PWD":/var/www/html -w /var/www/html abkrim/laravel-gitlab-ci:8.3 bash -lc 'composer install --no-interaction --prefer-dist && pnpm install && cp .env.example .env && php artisan key:generate && php artisan migrate --force && ./vendor/bin/pest -v'
```

### Docker Compose Example

If you need local MySQL/Redis, here's a minimal docker-compose example:

```yaml
services:
  mysql:
    image: mysql:8.0
    environment:
      MYSQL_ROOT_PASSWORD: root
      MYSQL_USER: homestead
      MYSQL_PASSWORD: secret
      MYSQL_DATABASE: homestead
  redis:
    image: redis:7
  app:
    image: abkrim/laravel-gitlab-ci:8.3
    command: ["sleep","infinity"]
    volumes:
      - ./:/var/www/html
    environment:
      DB_HOST: mysql
      DB_PORT: 3306
      DB_DATABASE: homestead
      DB_USERNAME: homestead
      DB_PASSWORD: secret
      REDIS_HOST: redis
      REDIS_PORT: 6379
```

### GitLab CI Example

Example `.gitlab-ci.yml` for tests with pnpm + Pest:

```yaml
stages:
  - test

image: abkrim/laravel-gitlab-ci:8.3

services:
  - name: mysql:8.0
  - name: redis:7

variables:
  MYSQL_ROOT_PASSWORD: root
  MYSQL_USER: homestead
  MYSQL_PASSWORD: secret
  MYSQL_DATABASE: homestead
  DB_HOST: mysql
  DB_PORT: "3306"
  REDIS_HOST: redis
  REDIS_PORT: "6379"

cache:
  paths:
    - vendor
    - node_modules

test:
  stage: test
  script:
    - composer install --no-interaction --prefer-dist
    - pnpm install
    - cp .env.example .env
    - php artisan key:generate
    - php artisan migrate --force
    - ./vendor/bin/pest -v
```

## Notes

- This image uses pnpm (not Yarn). Node 22 via corepack.
- Xdebug is configured in coverage mode for PHP 8.x (coverage in Pest if you enable it in your commands).
- The `mysql` client is configured without TLS to facilitate local usage; PDO in Laravel doesn't require changes by default.

## License

MIT (same as the original project).

---

## Original Project

This fork is based on the excellent work of:

- **Original Repository**: [edbizarro/gitlab-ci-pipeline-php](https://github.com/edbizarro/gitlab-ci-pipeline-php)
- **Original Author**: [@edbizarro](https://github.com/edbizarro)
- **Original License**: MIT

The original project provided Docker images optimized for GitLab CI with multiple PHP versions (7.3, 7.4, 8.0, 8.3) and different variants (Alpine, FPM, Chromium). This fork maintains the philosophy and structure of the original project, but focuses solely on PHP 8.3 with pnpm as the Node.js package manager.

### Why This Fork?

- The original project appears to have limited maintenance
- Specific need to maintain only PHP 8.3 in active development
- Migration from Yarn to pnpm for better performance and dependency management
- Independent maintenance without depending on the original project

If the original project returns to regular activity, it's recommended to consider contributing directly to that repository.

## Docker Hub Integration

This repository is designed to work with Docker Hub's automated builds. The images are automatically built and pushed to [abkrim/laravel-gitlab-ci](https://hub.docker.com/repository/docker/abkrim/laravel-gitlab-ci/general) when changes are pushed to this repository.

### Building Images Locally

To build images locally for testing:

```bash
# Build PHP 8.3 image
docker build -t abkrim/laravel-gitlab-ci:8.3 -f php/8.3/Dockerfile .

# Build Alpine variant
docker build -t abkrim/laravel-gitlab-ci:8.3-alpine -f php/8.3/alpine/Dockerfile .

# Build FPM variant
docker build -t abkrim/laravel-gitlab-ci:8.3-fpm -f php/8.3/fpm/Dockerfile .
```

### Multi-arch Builds

For multi-architecture builds (AMD64 and ARM64):

```bash
# Build and push multi-arch
docker buildx build --platform linux/amd64,linux/arm64 -t abkrim/laravel-gitlab-ci:8.3 --push .
```