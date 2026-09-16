# PR Report - 2026-09-16

## Summary

| Repository | Open PRs | Open Issues | Needs Attention |
|------------|----------|-------------|-----------------|
| [git-plugin](https://github.com/rundeck-plugins/git-plugin/pulls) | 0 | [2](https://github.com/rundeck-plugins/git-plugin/issues) | 0 |
| [ansible-plugin](https://github.com/rundeck-plugins/ansible-plugin/pulls) | 1 | [1](https://github.com/rundeck-plugins/ansible-plugin/issues) | 0 |
| [rundeck-s3-log-plugin](https://github.com/rundeck-plugins/rundeck-s3-log-plugin/pulls) | 1 | [1](https://github.com/rundeck-plugins/rundeck-s3-log-plugin/issues) | 0 |
| [attribute-match-node-enhancer](https://github.com/rundeck-plugins/attribute-match-node-enhancer/pulls) | 1 | [0](https://github.com/rundeck-plugins/attribute-match-node-enhancer/issues) | 0 |
| [aws-s3-model-source](https://github.com/rundeck-plugins/aws-s3-model-source/pulls) | 1 | [0](https://github.com/rundeck-plugins/aws-s3-model-source/issues) | 0 |
| [aws-s3-steps](https://github.com/rundeck-plugins/aws-s3-steps/pulls) | 1 | [0](https://github.com/rundeck-plugins/aws-s3-steps/issues) | 0 |
| [docker](https://github.com/rundeck-plugins/docker/pulls) | 1 | [0](https://github.com/rundeck-plugins/docker/issues) | 0 |
| [http-notification](https://github.com/rundeck-plugins/http-notification/pulls) | 1 | [0](https://github.com/rundeck-plugins/http-notification/issues) | 0 |
| [http-step](https://github.com/rundeck-plugins/http-step/pulls) | 1 | [0](https://github.com/rundeck-plugins/http-step/issues) | 0 |
| [jq-json-logfilter](https://github.com/rundeck-plugins/jq-json-logfilter/pulls) | 1 | [0](https://github.com/rundeck-plugins/jq-json-logfilter/issues) | 0 |
| [kubernetes](https://github.com/rundeck-plugins/kubernetes/pulls) | 1 | [0](https://github.com/rundeck-plugins/kubernetes/issues) | 0 |
| [multiline-regex-datacapture-filter](https://github.com/rundeck-plugins/multiline-regex-datacapture-filter/pulls) | 1 | [0](https://github.com/rundeck-plugins/multiline-regex-datacapture-filter/issues) | 0 |
| [nixy-step-plugins](https://github.com/rundeck-plugins/nixy-step-plugins/pulls) | 1 | [0](https://github.com/rundeck-plugins/nixy-step-plugins/issues) | 0 |
| [openssh-node-execution](https://github.com/rundeck-plugins/openssh-node-execution/pulls) | 1 | [0](https://github.com/rundeck-plugins/openssh-node-execution/issues) | 0 |
| [pagerduty-notification](https://github.com/rundeck-plugins/pagerduty-notification/pulls) | 1 | [0](https://github.com/rundeck-plugins/pagerduty-notification/issues) | 0 |
| [puppet-apply-step](https://github.com/rundeck-plugins/puppet-apply-step/pulls) | 1 | [0](https://github.com/rundeck-plugins/puppet-apply-step/issues) | 0 |
| [py-winrm-plugin](https://github.com/rundeck-plugins/py-winrm-plugin/pulls) | 1 | [0](https://github.com/rundeck-plugins/py-winrm-plugin/issues) | 0 |
| [rundeck-azure-plugin](https://github.com/rundeck-plugins/rundeck-azure-plugin/pulls) | 3 | [0](https://github.com/rundeck-plugins/rundeck-azure-plugin/issues) | 0 |
| [rundeck-azure-storage-plugin](https://github.com/rundeck-plugins/rundeck-azure-storage-plugin/pulls) | 1 | [0](https://github.com/rundeck-plugins/rundeck-azure-storage-plugin/issues) | 0 |
| [rundeck-ec2-nodes-plugin](https://github.com/rundeck-plugins/rundeck-ec2-nodes-plugin/pulls) | 3 | [0](https://github.com/rundeck-plugins/rundeck-ec2-nodes-plugin/issues) | **2** |
| [slack-incoming-webhook-plugin](https://github.com/rundeck-plugins/slack-incoming-webhook-plugin/pulls) | 1 | [0](https://github.com/rundeck-plugins/slack-incoming-webhook-plugin/issues) | 0 |
| [sshj-plugin](https://github.com/rundeck-plugins/sshj-plugin/pulls) | 3 | [0](https://github.com/rundeck-plugins/sshj-plugin/issues) | **2** |
| [vault-storage](https://github.com/rundeck-plugins/vault-storage/pulls) | 2 | [0](https://github.com/rundeck-plugins/vault-storage/issues) | 0 |
| [yaml-text-source](https://github.com/rundeck-plugins/yaml-text-source/pulls) | 1 | [0](https://github.com/rundeck-plugins/yaml-text-source/issues) | 0 |

**Total Open PRs:** 30 across 23 repositories
**Total Open Issues:** 4 across 3 repositories
**PRs Needing Attention:** 4

---

## PRs Needing Attention

PRs where community has most recent activity (comment or commit):

- **sshj-plugin #166**: [RUN-0000] Update Node.js to v24.21.0
  - Last activity: opened by @app/renovate
  - Link: https://github.com/rundeck-plugins/sshj-plugin/pull/166

- **sshj-plugin #165**: [RUN-0000] Update dependency @types/node to v24.13.4
  - Last activity: opened by @app/renovate
  - Link: https://github.com/rundeck-plugins/sshj-plugin/pull/165

- **rundeck-ec2-nodes-plugin #234**: [RUN-0000] Update gradle minor/patch dependencies
  - Last activity: opened by @app/renovate
  - Link: https://github.com/rundeck-plugins/rundeck-ec2-nodes-plugin/pull/234

- **rundeck-ec2-nodes-plugin #232**: [RUN-4954] Fix resource leaks and silent error handling in EC2ResourceModelSource
  - Last activity: reviewed by @ddarby-hike
  - Link: https://github.com/rundeck-plugins/rundeck-ec2-nodes-plugin/pull/232


---

## Release Drift

Plugins tagged `versioned-plugins` with commits on their default branch beyond the latest GitHub Release - candidates for a release before the next Rundeck/Rundeckpro GA.

| Repository | Latest Release | Commits Ahead | Status |
|------------|-----------------|----------------|--------|
| [ansible-plugin](https://github.com/rundeck-plugins/ansible-plugin/compare/5.1.2...main) | 5.1.2 | 4 | **NEEDS RELEASE** |
| [multiline-regex-datacapture-filter](https://github.com/rundeck-plugins/multiline-regex-datacapture-filter/compare/2.0.3...main) | 2.0.3 | 4 | **NEEDS RELEASE** |
| [http-step](https://github.com/rundeck-plugins/http-step/compare/2.0.5...main) | 2.0.5 | 4 | **NEEDS RELEASE** |
| [attribute-match-node-enhancer](https://github.com/rundeck-plugins/attribute-match-node-enhancer/compare/1.0.5...main) | 1.0.5 | 4 | **NEEDS RELEASE** |
| [aws-s3-model-source](https://github.com/rundeck-plugins/aws-s3-model-source/compare/2.0.3...main) | 2.0.3 | 8 | **NEEDS RELEASE** |
| [pagerduty-notification](https://github.com/rundeck-plugins/pagerduty-notification/compare/2.0.3...main) | 2.0.3 | 4 | **NEEDS RELEASE** |
| [sshj-plugin](https://github.com/rundeck-plugins/sshj-plugin/compare/1.0.8...main) | 1.0.8 | 16 | **NEEDS RELEASE** |
| [rundeck-ec2-nodes-plugin](https://github.com/rundeck-plugins/rundeck-ec2-nodes-plugin/compare/2.0.5...main) | 2.0.5 | 6 | **NEEDS RELEASE** |
| [rundeck-s3-log-plugin](https://github.com/rundeck-plugins/rundeck-s3-log-plugin/compare/3.0.5...main) | 3.0.5 | 3 | **NEEDS RELEASE** |
| [slack-incoming-webhook-plugin](https://github.com/rundeck-plugins/slack-incoming-webhook-plugin/compare/2.0.3...main) | 2.0.3 | 5 | **NEEDS RELEASE** |
| [vault-storage](https://github.com/rundeck-plugins/vault-storage/compare/2.0.4...main) | 2.0.4 | 6 | **NEEDS RELEASE** |
| [docker](https://github.com/rundeck-plugins/docker/compare/2.0.2...main) | 2.0.2 | 2 | **NEEDS RELEASE** |
| [salt-step](https://github.com/rundeck-plugins/salt-step/compare/1.0.4...main) | 1.0.4 | 4 | **NEEDS RELEASE** |
| [jq-json-logfilter](https://github.com/rundeck-plugins/jq-json-logfilter/compare/2.0.3...main) | 2.0.3 | 4 | **NEEDS RELEASE** |
| [http-notification](https://github.com/rundeck-plugins/http-notification/compare/2.0.5...main) | 2.0.5 | 4 | **NEEDS RELEASE** |
| [rundeck-azure-plugin](https://github.com/rundeck-plugins/rundeck-azure-plugin/compare/2.0.6...main) | 2.0.6 | 2 | **NEEDS RELEASE** |
| [git-plugin](https://github.com/rundeck-plugins/git-plugin/compare/2.0.3...main) | 2.0.3 | 4 | **NEEDS RELEASE** |
| kubernetes | 3.0.5 | 0 | OK |
| yaml-text-source | 3.0.2 | 0 | OK |
| nixy-step-plugins | 2.2.0 | 0 | OK |
| py-winrm-plugin | 3.3.0 | 0 | OK |
| rundeck-azure-storage-plugin | 2.0.2 | 0 | OK |
| puppet-apply-step | 3.0.2 | 0 | OK |
| openssh-node-execution | 3.0.2 | 0 | OK |
| aws-s3-steps | 2.0.2 | 0 | OK |

**Plugins needing a release:** 17 ; **Unknown:** 0
