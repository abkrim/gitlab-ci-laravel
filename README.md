## Laravel GitLab CI image (PHP 8.3)

Este repositorio es un fork del proyecto original `edbizarro/gitlab-ci-pipeline-php`.

En este fork solo se mantiene en desarrollo activo la versión PHP 8.3 y se sustituye Yarn por pnpm (Node 22 vía corepack).

### Imagen
- Docker Hub: `abkrim/laravel-gitlab-ci:8.3` (también `latest`)
- Base: `php:8.3` (Debian). Multi‑arch: linux/amd64 y linux/arm64
- Incluye: Composer 2, Node 22 + pnpm, Redis, APCu, PDO MySQL, Imagick, Xdebug (coverage), git, jq, rsync, unzip, zip
- `mysql` CLI configurado para entorno local (sin TLS) mediante `~/.my.cnf`

---

### Uso rápido (local)
Ejecuta tests de un proyecto Laravel con MySQL 8.0 y Redis levantados aparte:

```bash
docker run --rm -it -v "$PWD":/var/www/html -w /var/www/html abkrim/laravel-gitlab-ci:8.3 bash -lc 'composer install --no-interaction --prefer-dist && pnpm install && cp .env.example .env && php artisan key:generate && php artisan migrate --force && ./vendor/bin/pest -v'
```

Si necesitas MySQL/Redis locales, ejemplo mínimo con docker compose:

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

---

### Ejemplo `.gitlab-ci.yml` (tests con pnpm + Pest)
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

---

### Notas
- Esta imagen usa pnpm (no Yarn). Node 22 via corepack.
- Xdebug está configurado en modo cobertura para PHP 8.x (coverage en Pest si lo habilitas en tus comandos).
- El cliente `mysql` se configura sin TLS para facilitar el uso en local; PDO en Laravel no requiere cambios por defecto.

### Licencia
MIT (igual que el proyecto original).
