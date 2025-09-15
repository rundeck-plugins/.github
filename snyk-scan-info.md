# Central Snyk Security Scan Management for rundeck-plugins Organization

This repository serves as the central location for managing Snyk security scans across all repositories in the `rundeck-plugins` organization using GitHub's reusable workflows feature.

## Current Implementation

### Repository Structure
This `.github` repository contains:
- **Reusable Workflow**: `.github/workflows/snyk-scan-reusable.yml` - The centralized security scan logic
- **Minimal Template**: `snyk-scan.yml` - Ready-to-use minimal workflow file
- **Full Example**: `calling-workflow-example.yml` - Commented example with all configuration options
- **Documentation**: This file explaining the setup and usage

### Reusable Workflow Features
The `snyk-scan-reusable.yml` workflow provides:
- **Configurable Java Environment**: Supports different Java versions and distributions
- **Flexible Snyk Settings**: Customizable detection depth and organization settings
- **Branch-Aware Monitoring**: Only sends data to Snyk dashboard from main/master branches
- **Multi-Project Support**: Scans all projects in a repository with `--all-projects`
- **Non-Blocking Tests**: Security tests run but don't fail the workflow (uses `|| true`)

## Quick Start

**For most repositories, simply copy the minimal template:**
1. Copy `snyk-scan.yml` from this repository
2. Place it as `.github/workflows/security-scan.yml` in your repository
3. Commit and push - no additional configuration needed!

**For advanced configuration, see the full setup instructions below.**

## Setup Instructions

### 1. Central Repository (Complete ✅)
This repository (`rundeck-plugins/.github`) is already set up with:
- Reusable workflow at `.github/workflows/snyk-scan-reusable.yml`
- Proper input parameters and secret handling
- Branch protection and monitoring logic

### 2. Individual Repository Setup
To add security scanning to any `rundeck-plugins` repository:

#### Step 1: Create Workflow File
Create `.github/workflows/security-scan.yml` in your repository. Choose one of these options:

**Option A: Minimal Setup (Recommended for most repositories)**
```yaml
name: Security Scan

on:
  push:
    branches: [ main, master ]
  pull_request:
    branches: [ main, master ]
  workflow_dispatch:

jobs:
  security:
    uses: rundeck-plugins/.github/.github/workflows/snyk-scan-reusable.yml@main
    secrets:
      SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
      SNYK_ORG_ID: ${{ secrets.SNYK_ORG_ID }}
```

**Option B: Custom Configuration Example with Java 17 instead of Default**
```yaml
name: Security Scan

on:
  push:
    branches: [ main, master ]
  pull_request:
    branches: [ main, master ]
  workflow_dispatch:

jobs:
  security:
    uses: rundeck-plugins/.github/.github/workflows/snyk-scan-reusable.yml@main
    with:
      java-version: '17'           # Custom Java version
      java-distribution: 'zulu'    # Custom Java distribution
      snyk-detection-depth: '15'   # Deeper dependency scanning
      runs-on: 'ubuntu-20.04'      # Specific runner version
    secrets:
      SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
      SNYK_ORG_ID: ${{ secrets.SNYK_ORG_ID }}
```

> **All parameters under `with:` are optional!** The workflow uses sensible defaults (Java 11, Temurin distribution, detection depth 10, ubuntu-latest runner) that work for most Java projects.

#### Step 2: Customize Parameters (Optional)
All configuration parameters have sensible defaults and are completely optional. Only customize if your project has specific requirements:

- **java-version**: Only change if your project requires a different Java version than 11
- **java-distribution**: Only change if you have specific vendor requirements
- **snyk-detection-depth**: Only increase if you need deeper dependency scanning (impacts performance)
- **runs-on**: Only change if you need a specific runner environment

> **Secrets**: No setup required! The organization-level secrets (`SNYK_TOKEN` and `SNYK_ORG_ID`) are already configured and automatically available to all repositories in the `rundeck-plugins` organization.

## Workflow Behavior

### Branch-Specific Actions
- **Main/Master Branch (auto-detected)**: 
  - Runs full security scan
  - Sends monitoring data to Snyk dashboard
  - Tests for vulnerabilities (non-blocking)
  - Works with both `main` and `master` branch names automatically

- **Feature Branches & PRs**:
  - Runs security tests only
  - No data sent to Snyk dashboard
  - Prevents dashboard pollution from development branches

### Security Scan Process
1. **Environment Setup**: Configures Java environment based on inputs
2. **Snyk Installation**: Downloads and installs latest Snyk CLI
3. **Authentication**: Configures Snyk with provided token and organization
4. **Monitoring** (main branch only): Sends project snapshot to Snyk dashboard
5. **Testing**: Scans for vulnerabilities across all projects
6. **Reporting**: Results available in GitHub Actions logs

## Configuration Options

### Input Parameters (All Optional)
| Parameter | Default | Description |
|-----------|---------|-------------|
| `java-version` | `'11'` | Java version for the build environment (8, 11, 17, 21) |
| `java-distribution` | `'temurin'` | Java distribution (temurin, zulu, adopt, corretto, microsoft) |
| `snyk-detection-depth` | `'10'` | How many levels deep to scan dependencies |
| `runs-on` | `'ubuntu-latest'` | GitHub runner type (ubuntu-latest, ubuntu-20.04, windows-latest, macos-latest) |

> **Note**: All parameters have sensible defaults. Most repositories can use the minimal configuration without specifying any parameters.

### Organization Secrets (Pre-configured ✅)
The following secrets are already configured at the organization level and automatically available to all repositories:

| Secret | Description | Status |
|--------|-------------|---------|
| `SNYK_TOKEN` | Snyk authentication token | ✅ Configured |
| `SNYK_ORG_ID` | Snyk organization ID | ✅ Configured |

No additional secret setup is required in individual repositories.

## Advanced Configuration

### Branch Detection
The workflow automatically detects your repository's default branch (main or master) and only sends monitoring data from that branch. This eliminates the need to manually configure the `main-branch` parameter.

## Organization-Level Secrets (Already Complete ✅)

The organization-level secrets are already configured with appropriate access to all repositories in the `rundeck-plugins` organization. This setup includes:

- ✅ Organization secrets configured in GitHub
- ✅ Automatic access to all repositories
- ✅ No per-repository secret management required
- ✅ Centralized token management and rotation

## Migration from Existing Workflows

If you have existing security scan workflows in your repositories:

1. **Backup existing workflow**: Save your current `.github/workflows/security-scan.yml`
2. **Choose migration path**:
   - **Simple**: Replace with the minimal `snyk-scan.yml` template
   - **Custom**: Use `calling-workflow-example.yml` as a starting point
3. **Remove duplicate steps**: The reusable workflow handles all Snyk operations
4. **Test the migration**: Run the workflow on a test branch first
5. **Update any custom integrations**: Adapt any custom reporting or notifications

## Monitoring and Maintenance

### Dashboard Access
- View results in the [Snyk Dashboard](https://snyk.io/)
- Monitor vulnerabilities across all `rundeck-plugins` repositories
- Set up alerts for new high-severity issues

### Workflow Updates
- Updates to scan logic are made in this central repository
- All repositories automatically use the latest version (using `@main`)
- For stability, you can pin to specific versions using `@v1.0.0` tags

### Troubleshooting
Common issues and solutions:

**Authentication Errors**:
- Verify `SNYK_TOKEN` is valid and not expired
- Check `SNYK_ORG_ID` matches your Snyk organization

**Java Version Issues**:
- Ensure `java-version` matches your project requirements
- Update `java-distribution` if using a specific vendor

**Dependency Detection**:
- Increase `snyk-detection-depth` for complex dependency trees
- Check that your build files are in expected locations

## Example Repositories

Examples of repositories using this security scan:
- (Add links to repositories that have implemented this workflow)

## Support

For issues with:
- **The reusable workflow**: Create an issue in this repository
- **Snyk configuration**: Check [Snyk documentation](https://docs.snyk.io/)
- **GitHub Actions**: Refer to [GitHub Actions documentation](https://docs.github.com/en/actions)

## Future Enhancements

Planned improvements:
- [ ] Support for additional languages (Node.js, Python, etc.)
- [ ] Integration with GitHub Security tab
- [ ] Custom vulnerability reporting
- [ ] Slack/Teams notifications for critical vulnerabilities
- [ ] Automated PR creation for dependency updates