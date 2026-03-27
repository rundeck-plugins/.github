# Grails 7 Migration Handoff Documentation

**Status:** In Progress  
**Target Release:** Rundeck 6.0  
**Last Updated:** February 18, 2026

---

## Overview

This directory contains technical documentation for the ongoing Grails 6 → Grails 7 migration effort. These docs capture patterns, solutions, and architectural decisions made during the migration to help engineers working on the project.

---

## Workspace Setup for Engineers

### Quick Start with AI Agent

Ask your AI coding agent to help set up your workspace:

**Prompt for your AI agent:**

```
I'm joining the Rundeck Grails 7 migration project. Please help me set up my workspace:

1. Create a base directory called "rundeck-plugins" in my home directory
2. Clone ALL repositories from the rundeck-plugins GitHub organization into this directory as subdirectories
3. Also clone the rundeck-plugins/.github repository (contains shared documentation)
4. Switch all repositories to the "grails7-upgrade" branch
5. Show me which repos are now ready to work on

Important context:
- All Grails 7 work is on the grails7-upgrade branch (standard branch name)
- Shared documentation is in .github/Grails7-Handoff/ directory
- After setup, I should read the Grails7-Handoff/README.md and PLUGIN_VERSIONS.md

Key technical standards:
- Version format: X.Y.Z-grails7 (temporary suffix during development)
- GroupId: com.rundeck.plugins
- Git tags: NO "v" prefix (use Axion scmVersion with prefix = '')
- Java 17 required for JAR plugins
- Bottom-up update strategy (plugins first, then core, then applications)
```

### Manual Setup (Alternative)

If you prefer manual setup:

1. Create base directory: `mkdir -p ~/rundeck-plugins && cd ~/rundeck-plugins`
2. Clone all repos from `https://github.com/rundeck-plugins/` organization
3. Clone documentation repo: `https://github.com/rundeck-plugins/.github`
4. Checkout `grails7-upgrade` branch in all repos
5. Read `~/rundeck-plugins/.github/Grails7-Handoff/README.md` (this file)

---

## Migration Scope

### Core Technology Upgrades
- **Grails Framework:** 6.x → 7.x
- **Groovy:** 3.x → 4.x
- **Spring Boot:** 2.x → 3.x
- **Java:** 11 → 17
- **Jakarta EE:** javax.* → jakarta.*

### Plugin Ecosystem
- 22+ plugins being migrated to Grails 7 compatibility
- All plugins maintain backward compatibility with Rundeck 5.x
- Temporary `-grails7` version suffix during development (removed at release)

### Integration Architecture

**Note for Integration Work:** These plugins integrate into the main application via ua-runner:
- Plugins are built and published from rundeck-plugins repos
- ua-runner embeds them as `rbaPlugins` dependencies
- rundeckpro extracts them from ua-runner JAR
- For integration details, see `rundeckpro/GRAILS7_HANDOFF/QUICK_START.md` (Plugin Bundling Architecture section)
- **This documentation focuses on plugin development only**

---

## Document Index

### Architecture & Standards
- **[Plugin Tagging Architecture](./PLUGIN_TAGGING_ARCHITECTURE.md)** - Git tagging conventions, version management with Axion, Maven artifact publishing standards

### Common Issues & Solutions
- **[Merge Conflict Patterns](./MERGE_CONFLICT_PATTERNS.md)** - Handling nested conflicts, verification strategies, cleanup patterns

### Migration Tracking (Coming Soon)
- Testing strategies for Grails 7
- Dependency management patterns
- Common compilation errors and fixes

---

## Key Principles

### Backward Compatibility
- **100% backward compatibility required** - users must upgrade seamlessly from 5.x → 6.0
- No breaking changes without deprecation period
- All plugin updates include CVE fixes merged from upstream

### Version Suffix Strategy
- **Development:** `-grails7` suffix (e.g., `4.0.19-grails7`)
- **Production:** No suffix (e.g., `4.0.19`)
- Suffix removed at release time, not before

### Bottom-Up Update Strategy
1. Individual plugins first (lowest dependency layer)
2. Core rundeck modules (middle layer)
3. Application layers (top layer)
4. Integration testing last

---

## Getting Started

### For New Engineers
1. Start with [Plugin Tagging Architecture](./PLUGIN_TAGGING_ARCHITECTURE.md) to understand versioning
2. Review merge conflict patterns document for Git workflows
3. Check `grails7-upgrade` branch in each plugin repo for current state
4. Reference these docs when stuck, but always verify current state in code

### For Contributors
- Add new patterns as you discover them
- Include "why" context, not just "what" solutions
- Keep examples generic and applicable to OSS Rundeck
- Update this README when adding new documents

---

## Current State (Feb 18, 2026)

### Completed Core Plugins (grails7-upgrade branch)
- ✅ kubernetes: 2.0.19-grails7
- ✅ azure-storage: 1.0.13-grails7
- ✅ http-step: 1.1.20-grails7
- ✅ ansible-plugin: 4.0.19-grails7
- ✅ nixy-step-plugins: 1.2.14-grails7
- ✅ All pushed to remote

### Known Challenges
- Dependency version conflicts when merging from main/master
- Netty version compatibility with different frameworks
- Merge conflict markers persisting after `git status` shows "All conflicts fixed"
- Axion version parsing with mixed tag formats

---

## Testing Strategy

### Plugin-Level Testing
```bash
cd <plugin-directory>
./gradlew clean build test
```

### Dependency Resolution Verification
```bash
./gradlew dependencies --configuration runtimeClasspath | grep <dependency>
```

### Tag Verification
```bash
./gradlew currentVersion -q
# Should output clean version matching latest tag
```

---

## TODO: Functional Test Re-enablement

**Status:** Blocked - Waiting for Rundeck 6.0 Docker image

**Problem:** Two plugins have functional tests disabled on `grails7-upgrade` branch because they require a Rundeck 6.0 (Grails 7) Docker image which has not been published to Docker Hub.

**Plugins Affected:**

### 1. ansible-plugin
- **Test Framework:** Testcontainers with Docker Compose
- **Current State:** Tests skipped on `grails7-upgrade` branch
- **Workflow:** `.github/workflows/gradle.yml` (lines 26-30 have conditionals)
- **Required Image:** `rundeck/rundeck:6.0.0` (or similar Grails 7-compatible tag)
- **When Fixed:**
  - Remove `if: github.ref == 'refs/heads/main' || startsWith(github.ref, 'refs/tags/')` conditionals
  - Update `functional-test/build.gradle` systemProperty to use Grails 7 image tag
  - Verify tests pass in CI

### 2. vault-storage
- **Test Framework:** Custom Docker test script (`run-docker-vault-tests.sh`)
- **Current State:** Tests skipped on `grails7-upgrade` branch
- **Workflow:** `.github/workflows/gradle.yml` (line 26 has conditional)
- **Required Image:** `rundeck/rundeck:SNAPSHOT` (Dockerfile uses this)
- **When Fixed:**
  - Remove `if: github.ref == 'refs/heads/main' || startsWith(github.ref, 'refs/tags/')` conditional
  - Ensure `test/docker/dockers/rundeckvault/Dockerfile` points to correct Grails 7 image
  - Verify tests pass in CI

**Next Steps:**
1. Publish Rundeck 6.0 Docker image to Docker Hub
2. Update test configurations with correct image tag
3. Re-enable functional tests on `grails7-upgrade` branch
4. Verify CI passes with full test coverage

---

## Contributing to This Documentation

When adding documentation:
- Use Markdown format
- Include dates and context
- Show code examples with before/after
- Explain the "why" behind decisions
- Keep it focused on technical patterns, not internal processes

**Important:** This is a public repository. Focus on technical patterns that are useful to the open-source community.

---

## Questions or Issues?

1. Check this documentation first
2. Search Git history for similar issues (`git log --grep="pattern"`)
3. Review `.github/copilot-instructions.md` files in each repo for additional context
4. Open an issue in the relevant repository
