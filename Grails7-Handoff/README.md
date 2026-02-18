# Grails 7 Migration Handoff Documentation

**Status:** In Progress  
**Target Release:** Rundeck 6.0  
**Last Updated:** February 18, 2026

---

## Overview

This directory contains technical documentation for the ongoing Grails 6 → Grails 7 migration effort. These docs capture patterns, solutions, and architectural decisions made during the migration to help engineers working on the project.

---

## Workspace Setup for Engineers

### Step 1: Create Base Directory

Create a local workspace directory for all plugin repositories:

```bash
mkdir -p ~/rundeck-plugins
cd ~/rundeck-plugins
```

### Step 2: Clone All Plugin Repositories

Clone all repositories from the `rundeck-plugins` GitHub organization:

```bash
# Core execution plugins
git clone https://github.com/rundeck-plugins/ansible-plugin.git
git clone https://github.com/rundeck-plugins/openssh-node-execution.git
git clone https://github.com/rundeck-plugins/py-winrm-plugin.git
git clone https://github.com/rundeck-plugins/sshj-plugin.git

# Cloud provider plugins
git clone https://github.com/rundeck-plugins/kubernetes.git
git clone https://github.com/rundeck-plugins/docker.git
git clone https://github.com/rundeck-plugins/rundeck-azure-plugin.git
git clone https://github.com/rundeck-plugins/rundeck-azure-storage-plugin.git
git clone https://github.com/rundeck-plugins/rundeck-ec2-nodes-plugin.git
git clone https://github.com/rundeck-plugins/aws-s3-model-source.git
git clone https://github.com/rundeck-plugins/aws-s3-steps.git
git clone https://github.com/rundeck-plugins/rundeck-s3-log-plugin.git

# Workflow step plugins
git clone https://github.com/rundeck-plugins/http-step.git
git clone https://github.com/rundeck-plugins/git-plugin.git
git clone https://github.com/rundeck-plugins/salt-step.git
git clone https://github.com/rundeck-plugins/puppet-apply-step.git
git clone https://github.com/rundeck-plugins/nixy-step-plugins.git

# Notification plugins
git clone https://github.com/rundeck-plugins/http-notification.git
git clone https://github.com/rundeck-plugins/slack-incoming-webhook-plugin.git
git clone https://github.com/rundeck-plugins/pagerduty-notification.git

# Storage and utility plugins
git clone https://github.com/rundeck-plugins/vault-storage.git
git clone https://github.com/rundeck-plugins/yaml-text-source.git
git clone https://github.com/rundeck-plugins/jq-json-logfilter.git
git clone https://github.com/rundeck-plugins/multiline-regex-datacapture-filter.git
git clone https://github.com/rundeck-plugins/attribute-match-node-enhancer.git

# Clone shared documentation repo
git clone https://github.com/rundeck-plugins/.github.git
```

### Step 3: Checkout Standard Branch

**All Grails 7 work is on the `grails7-upgrade` branch:**

```bash
# Checkout grails7-upgrade on all repos
for dir in */; do
    if [ -d "$dir/.git" ]; then
        cd "$dir"
        echo "=== $(basename $PWD) ==="
        git checkout grails7-upgrade 2>/dev/null || echo "No grails7-upgrade branch"
        cd ..
    fi
done
```

### Step 4: Verify Setup

```bash
# Verify all repos are on grails7-upgrade branch
for dir in */; do
    if [ -d "$dir/.git" ]; then
        cd "$dir"
        branch=$(git branch --show-current 2>/dev/null)
        if [ "$branch" = "grails7-upgrade" ]; then
            echo "✅ $(basename $PWD): grails7-upgrade"
        else
            echo "⚠️  $(basename $PWD): $branch"
        fi
        cd ..
    fi
done
```

### Step 5: Access Shared Documentation

Shared documentation lives in the `.github` repository:

```bash
cd .github
git checkout grails7-upgrade
cd Grails7-Handoff

# Available docs:
ls -1
# README.md (this file)
# PLUGIN_TAGGING_ARCHITECTURE.md
# PLUGIN_VERSIONS.md
# MERGE_CONFLICT_PATTERNS.md
# COMMON_MIGRATION_ISSUES.md
```

### AI Agent Setup Prompt

Use this prompt to set up your AI coding agent for Grails 7 work:

```
I'm working on the Rundeck Grails 7 migration. My workspace is organized as follows:

- Base directory: ~/rundeck-plugins/
- All plugin repos cloned as subdirectories
- Standard branch: grails7-upgrade
- Shared docs: ~/rundeck-plugins/.github/Grails7-Handoff/

Key principles:
1. All work happens on grails7-upgrade branch
2. Use Axion scmVersion with NO "v" prefix for tags
3. Version format: X.Y.Z-grails7 (temporary suffix)
4. GroupId: com.rundeck.plugins
5. Java 17 required for JAR plugins
6. Reference the Grails7-Handoff docs for patterns

Please read ~/rundeck-plugins/.github/Grails7-Handoff/README.md to understand
the migration context, then check PLUGIN_VERSIONS.md for current versions.
```

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
