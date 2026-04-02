# Snyk Scan Workflow Update Impact

**Last Updated:** January 28, 2026  
**Related PR:** https://github.com/rundeck-plugins/.github/pull/3

---

## Overview

The reusable Snyk scan workflow has been updated to use Java 17 (from 11) and zulu distribution (from temurin) to support Grails 7 migration work.

**Impact:** When the `.github` PR is merged to `main`, all repositories using the shared Snyk workflow will automatically switch to Java 17 for security scans.

---

## Repositories Affected by Java 17 Default Change

### Production Plugins (Migrated - No Impact)
These 25 repositories are part of the Grails 7 migration and already compatible with Java 17:
- ansible-plugin
- attribute-match-node-enhancer
- aws-s3-model-source
- aws-s3-steps
- docker
- git-plugin
- http-notification
- http-step
- jq-json-logfilter
- kubernetes
- multiline-regex-datacapture-filter
- nixy-step-plugins
- openssh-node-execution
- pagerduty-notification
- puppet-apply-step
- py-winrm-plugin
- rundeck-azure-plugin
- rundeck-azure-storage-plugin
- rundeck-ec2-nodes-plugin
- rundeck-s3-log-plugin
- salt-step
- slack-incoming-webhook-plugin
- sshj-plugin
- vault-storage
- yaml-text-source

### Non-Production Repositories (Potential Impact)
These 10 repositories use the Snyk workflow but were not part of the Grails 7 migration. Snyk scans may fail after `.github` PR is merged:

| Repository | Type | Java Compatibility | Action Needed |
|------------|------|-------------------|---------------|
| awsworkshop | Workshop/Demo | Unknown | None - demo code |
| build-zip | Build Utility | N/A | Verify or add explicit java-version: '11' |
| h2-v2-migration | Migration Tool | Unknown | Verify or add explicit java-version: '11' |
| java-keytool-steps | Plugin | Java 11 | May need Java 17 migration or explicit override |
| rundeck-plugin-examples | Examples | Unknown | None - example code |
| ssh-session | Plugin | Java 11 | May need Java 17 migration or explicit override |
| terraform-workflow-step | Plugin | Java 11 | May need Java 17 migration or explicit override |
| ui-job-metrics | UI Plugin | N/A | Likely JavaScript/Node.js based |
| ui-plugin-examples | Examples | N/A | None - example code |
| ui-roi-summary | UI Plugin | N/A | Likely JavaScript/Node.js based |

---

## Mitigation Strategy

### Before Merging `.github` PR

**Option 1 - Do Nothing (Recommended):**
- Most affected repos are examples, demos, or non-critical utilities
- Snyk scan failures on these repos won't block production work
- Can be addressed individually if they become important

**Option 2 - Add Explicit Java 11 Override:**
For any critical non-migrated repos, update their `snyk-scan.yml` to explicitly pass Java 11:
```yaml
jobs:
  security:
    uses: rundeck-plugins/.github/.github/workflows/snyk-scan-reusable.yml@main
    with:
      java-version: '11'
      java-distribution: 'temurin'
    secrets:
      SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
      SNYK_ORG_ID: ${{ secrets.SNYK_ORG_ID }}
```

### After Merging `.github` PR

Monitor these repos for Snyk scan failures on `main`/`master` branches and address individually as needed.

---

## Merge Order Recommendation

1. Merge `.github` PR first
2. Monitor for any critical failures in the 10 non-migrated repos
3. Merge plugin PRs (Snyk scans will pass with Java 17)
4. Address any non-migrated repo issues individually

This approach prioritizes getting the Grails 7 work ready while deferring non-critical repo fixes.
