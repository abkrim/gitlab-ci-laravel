## Laravel GitLab CI image (PHP 8.3)

> **Nota importante**: Este repositorio es un fork independiente del proyecto original [edbizarro/gitlab-ci-pipeline-php](https://github.com/edbizarro/gitlab-ci-pipeline-php). 
> 
> **Créditos y agradecimientos**: Todo el mérito del trabajo inicial pertenece a [@edbizarro](https://github.com/edbizarro) y los colaboradores del proyecto original. Este fork mantiene el respeto y reconocimiento al trabajo original.

### Diferencias con el proyecto original

En este fork se mantiene en desarrollo activo únicamente la versión PHP 8.3 y se sustituye Yarn por pnpm (Node 22 vía corepack). El proyecto original incluía múltiples versiones de PHP (7.3, 7.4, 8.0, 8.3) y usaba Yarn como gestor de paquetes de Node.js.

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

---

## Proyecto Original

Este fork está basado en el excelente trabajo de:

- **Repositorio original**: [edbizarro/gitlab-ci-pipeline-php](https://github.com/edbizarro/gitlab-ci-pipeline-php)
- **Autor original**: [@edbizarro](https://github.com/edbizarro)
- **Licencia original**: MIT

El proyecto original proporcionaba imágenes Docker optimizadas para GitLab CI con múltiples versiones de PHP (7.3, 7.4, 8.0, 8.3) y diferentes variantes (Alpine, FPM, Chromium). Este fork mantiene la filosofía y estructura del proyecto original, pero se enfoca únicamente en PHP 8.3 con pnpm como gestor de paquetes de Node.js.

### ¿Por qué este fork?

- El proyecto original parece estar en mantenimiento limitado
- Necesidad específica de mantener solo PHP 8.3 en desarrollo activo
- Migración de Yarn a pnpm para mejor rendimiento y gestión de dependencias
- Mantenimiento independiente sin depender del proyecto original

Si el proyecto original vuelve a tener actividad regular, se recomienda considerar contribuir directamente a ese repositorio.
