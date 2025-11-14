# CLAUDE.md - AI Assistant Guide for alpine-jq

## Repository Overview

**Project Name**: alpine-jq
**Purpose**: Weekly automated builds of Alpine Linux Docker images with curl, wget, and jq pre-installed
**Docker Hub**: [apteno/alpine-jq](https://hub.docker.com/r/apteno/alpine-jq)
**Repository Type**: Infrastructure as Code (Docker image distribution)

This is a minimal, focused project that provides a lightweight Alpine Linux base image with commonly-used command-line utilities for JSON processing and HTTP requests.

## Repository Structure

```
alpine-jq/
├── .github/
│   ├── workflows/
│   │   └── build.yml          # CI/CD pipeline for Docker builds
│   └── dependabot.yml         # Automated dependency updates
├── Dockerfile                 # Alpine image definition
├── README.md                  # Basic project documentation
└── CLAUDE.md                  # This file
```

### File Purposes

- **Dockerfile**: Defines the Docker image based on `alpine:latest` with curl, wget, and jq installed via apk
- **build.yml**: GitHub Actions workflow for building and pushing multi-architecture Docker images
- **dependabot.yml**: Configuration for automated GitHub Actions dependency updates

## Development Workflows

### 1. Docker Image Build & Publish

The repository uses GitHub Actions to automate Docker image builds:

**Triggers**:
- Push to `main` branch
- Pull requests to `main` branch
- Weekly schedule: Sundays at 00:00 UTC (cron: `0 0 * * 0`)

**Build Process**:
1. Checks out repository code
2. Sets build date for image tagging
3. Configures QEMU for multi-architecture builds
4. Sets up Docker Buildx
5. Authenticates with Docker Hub (except for PRs)
6. Builds Docker image for 7 platforms:
   - linux/386
   - linux/amd64
   - linux/arm/v6
   - linux/arm/v7
   - linux/arm64
   - linux/ppc64le
   - linux/s390x
7. Pushes to Docker Hub with two tags:
   - `apteno/alpine-jq:YYYY-MM-DD` (date-stamped)
   - `apteno/alpine-jq:latest`

**Important**: Builds always use `--no-cache` and `--pull` flags to ensure fresh images with latest security updates.

### 2. Dependency Management

**Dependabot Configuration**:
- Ecosystem: GitHub Actions only
- Schedule: Daily checks
- Creates PRs for action version updates automatically

**Merge Pattern** (from git history):
- Dependabot PRs are merged regularly
- Recent updates show active maintenance of action versions
- Examples: docker/setup-qemu-action, docker/login-action, docker/build-push-action, actions/checkout

## Key Conventions

### Docker Image Conventions

1. **Base Image**: Always use `alpine:latest` as the base
2. **Package Installation**: Use `apk add --no-cache` to minimize image size
3. **Installed Tools**: Maintain the core trio - curl, wget, jq
4. **Multi-arch Support**: All changes must work across all 7 supported platforms

### CI/CD Conventions

1. **Branch Protection**: `main` branch is the primary/production branch
2. **PR Testing**: All PRs trigger builds but don't push to Docker Hub
3. **Automated Releases**: Only pushes from `main` branch publish to Docker Hub
4. **Tagging Strategy**: Dual tags (date + latest) ensure version tracking and convenience

### Code Style

1. **Simplicity**: Keep the Dockerfile minimal and focused
2. **No Custom Scripts**: The image is intentionally simple - just Alpine + tools
3. **Documentation**: Update README.md for any significant changes to purpose or usage

## Common Tasks for AI Assistants

### Updating the Dockerfile

When modifying the Dockerfile:

1. **Adding Packages**: Use `apk add --no-cache package1 package2`
2. **Version Pinning**: Consider whether specific versions are needed (currently uses latest)
3. **Testing**: Ensure changes work across all 7 architectures
4. **Image Size**: Keep the image small - verify with `docker images` after building

```bash
# Local testing
docker build -t alpine-jq-test .
docker run -it alpine-jq-test sh
# Verify tools work: jq --version, curl --version, wget --version
```

### Updating GitHub Actions

When modifying `.github/workflows/build.yml`:

1. **Action Versions**: Use specific version tags (e.g., `@v3.7.0`, not `@latest`)
2. **Secrets**: Don't expose or log `DOCKER_HUB_USERNAME` or `DOCKER_HUB_ACCESS_TOKEN`
3. **Platform List**: Changes to supported platforms should be deliberate and tested
4. **Workflow Syntax**: Use proper YAML indentation (2 spaces)

### Making Changes

**Standard workflow**:
1. Create a feature branch from `main`
2. Make changes to relevant files
3. Commit with clear, descriptive messages
4. Push to remote branch
5. Create PR to `main` for review
6. PR will trigger test build (no push to Docker Hub)
7. After merge to `main`, production build publishes to Docker Hub

**Commit Message Style** (from git history):
- Use conventional format: "Bump {action} from {old} to {new}"
- For features: Describe what was added/changed and why
- Keep messages concise and informative

### Reviewing PRs

When reviewing Dependabot PRs:
1. Verify the action changelog for breaking changes
2. Check that version updates are legitimate
3. Ensure CI build passes
4. Merge if tests pass and no breaking changes

## Architecture Decisions

### Why Alpine?
- Minimal image size (~5-7MB base)
- Fast downloads and container startup
- Security-focused with minimal attack surface
- Wide package availability via apk

### Why curl, wget, and jq?
- **curl/wget**: Essential for HTTP requests in CI/CD pipelines and automation
- **jq**: Industry-standard JSON processor for API interactions and data parsing
- Common toolset for DevOps and automation workflows

### Why Weekly Builds?
- Ensures images get latest Alpine security updates
- Keeps base `alpine:latest` dependency fresh
- Automated maintenance without manual intervention

### Why Multi-architecture?
- Support for diverse deployment environments
- Enables ARM-based edge computing and IoT deployments
- Supports legacy and modern server architectures
- Future-proofs the image for emerging platforms

## Testing Guidelines

### Local Testing

```bash
# Build locally
docker build -t alpine-jq-test .

# Test installed tools
docker run alpine-jq-test jq --version
docker run alpine-jq-test curl --version
docker run alpine-jq-test wget --version

# Interactive testing
docker run -it alpine-jq-test sh
```

### Multi-architecture Testing

For local multi-arch testing:
```bash
# Setup buildx (one-time)
docker buildx create --use

# Build for multiple platforms
docker buildx build --platform linux/amd64,linux/arm64 -t alpine-jq-test .
```

### CI Testing

- All PR builds run full CI pipeline except Docker Hub push
- Monitor GitHub Actions output for build failures
- Check all 7 architectures complete successfully

## Security Considerations

1. **Base Image Updates**: Weekly builds incorporate Alpine security patches automatically
2. **Package Updates**: Using `alpine:latest` and latest package versions gets security fixes
3. **Minimal Surface**: Only essential tools installed reduces vulnerability exposure
4. **No Custom Code**: No application code means fewer potential vulnerabilities
5. **Secrets Management**: Docker Hub credentials stored as GitHub secrets, never in code

### When to Force a Rebuild

Force a rebuild (manual workflow dispatch or push to main) when:
- Critical security vulnerability announced in Alpine, curl, wget, or jq
- Major Alpine version release requires immediate adoption
- Docker Hub rate limiting or availability issues resolved

## Troubleshooting

### Build Failures

**Common causes**:
1. **Upstream Alpine issues**: Check Alpine Linux status
2. **Docker Hub connectivity**: Check Docker status page
3. **Action version incompatibility**: Review Dependabot PR changes
4. **Platform-specific failures**: Check QEMU and buildx setup steps

**Resolution steps**:
1. Check GitHub Actions logs for specific error
2. Verify Dockerfile syntax with local build
3. Test specific platform: `docker buildx build --platform linux/arm64 .`
4. Review recent changes in git history

### Image Not Updating on Docker Hub

**Checklist**:
1. Did the workflow run on `main` branch? (PRs don't push)
2. Did Docker Hub login succeed? (Check secrets configuration)
3. Did the build complete successfully?
4. Is there a Docker Hub outage? (Check status.docker.com)

## Best Practices for AI Assistants

### DO:
- ✅ Keep the Dockerfile minimal and focused
- ✅ Test locally before pushing changes
- ✅ Update documentation when changing functionality
- ✅ Use specific version tags for GitHub Actions
- ✅ Follow existing commit message patterns
- ✅ Consider image size impact of changes
- ✅ Verify multi-architecture compatibility

### DON'T:
- ❌ Add unnecessary packages or bloat to the image
- ❌ Use `latest` tags for GitHub Actions
- ❌ Push directly to `main` without PR review
- ❌ Expose secrets in logs or code
- ❌ Change core tools (curl, wget, jq) without discussion
- ❌ Disable security features or caching optimizations
- ❌ Remove platform support without justification

## Quick Reference

### Key Commands

```bash
# Local build
docker build -t alpine-jq-test .

# Run container
docker run -it apteno/alpine-jq:latest sh

# Test tools
docker run apteno/alpine-jq:latest jq --version
docker run apteno/alpine-jq:latest curl -V
docker run apteno/alpine-jq:latest wget --version

# Multi-arch build
docker buildx build --platform linux/amd64,linux/arm64 -t test .
```

### Important Links

- Docker Hub: https://hub.docker.com/r/apteno/alpine-jq
- Alpine Linux: https://alpinelinux.org/
- jq Documentation: https://stedolan.github.io/jq/

### GitHub Actions Used

- `actions/checkout@v5` - Repository checkout
- `docker/setup-qemu-action@v3.7.0` - Multi-arch emulation
- `docker/setup-buildx-action@v3.11.1` - Docker Buildx setup
- `docker/login-action@v3.6.0` - Docker Hub authentication
- `docker/build-push-action@v6.18.0` - Build and push images

## Maintenance Schedule

- **Weekly**: Automated image builds (Sundays at 00:00 UTC)
- **Daily**: Dependabot checks for action updates
- **As needed**: Manual builds for security patches
- **Quarterly**: Review and update this documentation

## Contact & Support

For issues or questions about the image:
1. Check existing GitHub issues
2. Create new issue with details about the problem
3. For Docker Hub issues, verify image tag and platform match

---

**Last Updated**: 2025-11-14
**Alpine Version**: latest (rolling)
**Maintained By**: apteno
