## Laravel GitLab CI Docker Images (PHP 8.3)

Imágenes Docker listas para CI/CD de proyectos Laravel con PHP 8.3. Incluyen Composer, Node.js 22/pnpm (según variante), extensiones PHP frecuentes y una variante con Chromium para test E2E con Dusk.

### Tags disponibles
- 8.3: Base CLI con Composer y Node 22/pnpm (Debian)
- 8.3-fpm: PHP-FPM con Composer y Node 22/pnpm (Debian)
- 8.3-alpine: Base CLI con Composer y Node 22/pnpm (Alpine)
- 8.3-chromium: Base con Google Chrome/Chromium y dependencias para Laravel Dusk
- 8.3-fpm-min: PHP-FPM mínima para runtime Laravel (sin Node, solo MySQL/Redis y extensiones básicas)
- latest: alias de 8.3

### Características
- **PHP**: 8.3
- **Node.js**: 22 + pnpm (todas menos `8.3-fpm-min`)
- **Extensiones PHP (base/fpm/alpine)**: pdo_mysql, mysqli, bcmath, zip, intl, gd, ldap, soap, xsl, opcache, pgsql/pdo_pgsql; PECL: redis, apcu, imagick, xdebug; AMQP opcional
- **Cliente MySQL**: `mariadb-client` incluido
- **Chromium/Dusk**: `8.3-chromium` instala Chrome en amd64; en otras arquitecturas usa `chromium` de Debian
- **Optimización**: purga de build-deps, limpieza de cachés apt/apk

### Cuándo usar cada tag
- **8.3-fpm-min**: deploy/runtime ligero para apps Laravel (FPM + MySQL + Redis + opcache)
- **8.3-fpm**: necesitas FPM y tooling de Node/pnpm en el mismo contenedor
- **8.3** / **8.3-alpine**: jobs de build/test en CI (Composer + Node/pnpm)
- **8.3-chromium**: tests E2E con Laravel Dusk

### Ejemplos de uso
- Composer y Node en CI:
```bash
docker run --rm -v $PWD:/var/www/html -w /var/www/html abkrim/laravel-gitlab-ci:8.3 bash -lc "composer install --no-interaction && pnpm i && pnpm build"
```

- PHP-FPM mínimo para Laravel:
```bash
docker run -d --name app -v $PWD:/var/www/html abkrim/laravel-gitlab-ci:8.3-fpm-min
```

- Test Dusk (headless):
```bash
docker run --rm -v $PWD:/var/www/html -w /var/www/html abkrim/laravel-gitlab-ci:8.3-chromium php artisan dusk
```

### Docker Compose (desarrollo)
```yaml
services:
  mysql:
    image: mysql:8.0
    environment:
      MYSQL_ROOT_PASSWORD: root
      MYSQL_DATABASE: homestead
      MYSQL_USER: homestead
      MYSQL_PASSWORD: secret
    ports: ["33060:3306"]

  redis:
    image: redis:7
    ports: ["63790:6379"]

  php:
    image: abkrim/laravel-gitlab-ci:8.3-fpm-min
    volumes:
      - ./:/var/www/html
```

### GitHub Actions (ejemplo)
```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    container: abkrim/laravel-gitlab-ci:8.3
    steps:
      - uses: actions/checkout@v4
      - run: composer install --no-interaction --prefer-dist
      - run: pnpm i && pnpm build
      - run: php artisan test
```

### Arquitecturas
- amd64 y arm64 (Chromium: Chrome en amd64; `chromium` de Debian en arm64)

### Notas
- LDAP: detección automática del `libdir` según arquitectura para evitar errores de `configure`
- Chromium: fallback entre `libgdk-pixbuf-2.0-0` y `libgdk-pixbuf-xlib-2.0-0` según disponibilidad

### Enlaces
- **Código**: https://github.com/abkrim/gitlab-ci-laravel
- **Issues**: usar el repositorio de GitHub


