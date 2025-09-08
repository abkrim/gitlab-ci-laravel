# Docker Hub Integration Guide

This document explains how to set up and maintain the Docker Hub integration for the Laravel GitLab CI images.

## Repository Structure

The repository is organized to support multiple Docker image variants:

```
php/8.3/
├── Dockerfile          # Default variant (Debian-based)
├── alpine/
│   └── Dockerfile      # Alpine variant (smaller size)
├── fpm/
│   └── Dockerfile      # FPM variant (for web servers)
└── chromium/
    └── Dockerfile      # Chromium variant (for browser testing)
```

## Docker Hub Repository

**Repository URL**: https://hub.docker.com/repository/docker/abkrim/laravel-gitlab-ci/general

**Available Tags**:
- `abkrim/laravel-gitlab-ci:8.3` (default, also available as `latest`)
- `abkrim/laravel-gitlab-ci:8.3-alpine`
- `abkrim/laravel-gitlab-ci:8.3-fpm`
- `abkrim/laravel-gitlab-ci:8.3-chromium`

## Automated Builds

### Option 1: GitHub Actions (Recommended)

The repository includes GitHub Actions workflow (`.github/workflows/docker-build.yml`) that automatically builds and pushes images when:

- Code is pushed to `main` or `master` branch
- Tags are created (e.g., `v1.0.0`)
- Pull requests are created (builds but doesn't push)

**Setup**:
1. Go to GitHub repository settings
2. Add secrets:
   - `DOCKER_USERNAME`: Your Docker Hub username
   - `DOCKER_PASSWORD`: Your Docker Hub access token

### Option 2: Docker Hub Automated Builds

1. Connect your GitHub repository to Docker Hub
2. Configure build rules for each variant:
   - **Source Type**: Branch
   - **Source**: `main` or `master`
   - **Dockerfile Location**: `php/8.3/Dockerfile` (or respective variant)
   - **Docker Tag**: `8.3` (or respective variant)

## Manual Building

### Using the Build Script

```bash
# Build default variant
./build.sh default 8.3

# Build Alpine variant
./build.sh alpine 8.3

# Build FPM variant
./build.sh fpm 8.3

# Build Chromium variant
./build.sh chromium 8.3
```

### Using Docker Compose

```bash
# Build all variants
docker-compose -f docker-compose.build.yml build

# Build specific variant
docker-compose -f docker-compose.build.yml build php83-alpine
```

### Using Docker Commands

```bash
# Default variant
docker build -t abkrim/laravel-gitlab-ci:8.3 -f php/8.3/Dockerfile .

# Alpine variant
docker build -t abkrim/laravel-gitlab-ci:8.3-alpine -f php/8.3/alpine/Dockerfile .

# FPM variant
docker build -t abkrim/laravel-gitlab-ci:8.3-fpm -f php/8.3/fpm/Dockerfile .

# Chromium variant
docker build -t abkrim/laravel-gitlab-ci:8.3-chromium -f php/8.3/chromium/Dockerfile .
```

## Multi-Architecture Builds

For AMD64 and ARM64 support:

```bash
# Create and use buildx builder
docker buildx create --name multiarch --use

# Build and push multi-arch
docker buildx build --platform linux/amd64,linux/arm64 \
  -t abkrim/laravel-gitlab-ci:8.3 \
  -f php/8.3/Dockerfile \
  --push .
```

## Repository Maintenance

### Updating Images

1. Make changes to Dockerfiles or scripts
2. Test locally using the build script
3. Commit and push changes
4. Images will be automatically built and pushed

### Version Management

- Use semantic versioning for tags (e.g., `v1.0.0`)
- The `latest` tag always points to the current `8.3` variant
- Specific version tags (e.g., `8.3`) are maintained for stability

### Monitoring

- Check Docker Hub repository for build status
- Monitor GitHub Actions for automated builds
- Review build logs for any issues

## Security Considerations

- Use Docker Hub access tokens instead of passwords
- Regularly update base images and dependencies
- Scan images for vulnerabilities
- Keep secrets secure in GitHub repository settings

## Troubleshooting

### Build Failures

1. Check Dockerfile syntax
2. Verify all required files are present
3. Review build logs for specific errors
4. Test locally before pushing

### Push Failures

1. Verify Docker Hub credentials
2. Check repository permissions
3. Ensure image tags are correct
4. Verify network connectivity

### Multi-arch Issues

1. Ensure buildx is properly configured
2. Check platform support
3. Verify emulation is available
4. Review resource constraints