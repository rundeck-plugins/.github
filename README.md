# Organization Infrastructure Repository

This repository provides shared security scanning infrastructure for all repositories in the rundeck-plugins organization.

## Purpose

The primary goal is centralized Snyk security scanning across all plugin repositories. This ensures consistent security standards and simplifies maintenance.

## Files

- **`.github/workflows/snyk-scan-reusable.yml`** - Central reusable workflow for security scanning
- **`snyk-scan.yml`** - Minimal template for implementing security scans  
- **`calling-workflow-example.yml`** - Full configuration example with comments
- **`snyk-scan-info.md`** - Complete setup documentation and troubleshooting
- **`profile/README.md`** - Organization profile page content

## Snyk Scanning

### Documentation

See [snyk-scan-info.md](snyk-scan-info.md) for detailed setup instructions and configuration options.

### Quick Setup

For repository maintainers:

1. Copy `snyk-scan.yml` to your repository as `.github/workflows/security-scan.yml`
2. Commit and push
3. Security scans run automatically on pushes and pull requests

No additional configuration is required. All parameters are optional with sensible defaults.

### Features

- Automatic detection of main/master branches
- Pre-configured organization secrets
- Non-blocking security tests
- Results integrated with Snyk dashboard
- Support for Java 8, 11, 17, and 21

### Benefits

- Single point of maintenance for security scanning logic
- Consistent security standards across all repositories
- Easy updates to scanning procedures organization-wide
- Simplified onboarding for new repositories