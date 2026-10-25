# PR Report - 2026-10-25

## Summary

| Repository | Open PRs | Open Issues | Needs Attention |
|------------|----------|-------------|-----------------|
| [git-plugin](https://github.com/rundeck-plugins/git-plugin/pulls) | 0 | [1](https://github.com/rundeck-plugins/git-plugin/issues) | 0 |
| [kubernetes](https://github.com/rundeck-plugins/kubernetes/pulls) | 1 | [1](https://github.com/rundeck-plugins/kubernetes/issues) | 0 |
| [py-winrm-plugin](https://github.com/rundeck-plugins/py-winrm-plugin/pulls) | 3 | [1](https://github.com/rundeck-plugins/py-winrm-plugin/issues) | **2** |
| [rundeck-s3-log-plugin](https://github.com/rundeck-plugins/rundeck-s3-log-plugin/pulls) | 1 | [1](https://github.com/rundeck-plugins/rundeck-s3-log-plugin/issues) | 0 |
| [ansible-plugin](https://github.com/rundeck-plugins/ansible-plugin/pulls) | 2 | [0](https://github.com/rundeck-plugins/ansible-plugin/issues) | 0 |
| [attribute-match-node-enhancer](https://github.com/rundeck-plugins/attribute-match-node-enhancer/pulls) | 1 | [0](https://github.com/rundeck-plugins/attribute-match-node-enhancer/issues) | 0 |
| [aws-s3-model-source](https://github.com/rundeck-plugins/aws-s3-model-source/pulls) | 2 | [0](https://github.com/rundeck-plugins/aws-s3-model-source/issues) | **1** |
| [aws-s3-steps](https://github.com/rundeck-plugins/aws-s3-steps/pulls) | 1 | [0](https://github.com/rundeck-plugins/aws-s3-steps/issues) | 0 |
| [docker](https://github.com/rundeck-plugins/docker/pulls) | 1 | [0](https://github.com/rundeck-plugins/docker/issues) | 0 |
| [http-notification](https://github.com/rundeck-plugins/http-notification/pulls) | 1 | [0](https://github.com/rundeck-plugins/http-notification/issues) | 0 |
| [http-step](https://github.com/rundeck-plugins/http-step/pulls) | 1 | [0](https://github.com/rundeck-plugins/http-step/issues) | 0 |
| [jq-json-logfilter](https://github.com/rundeck-plugins/jq-json-logfilter/pulls) | 1 | [0](https://github.com/rundeck-plugins/jq-json-logfilter/issues) | 0 |
| [multiline-regex-datacapture-filter](https://github.com/rundeck-plugins/multiline-regex-datacapture-filter/pulls) | 1 | [0](https://github.com/rundeck-plugins/multiline-regex-datacapture-filter/issues) | 0 |
| [nixy-step-plugins](https://github.com/rundeck-plugins/nixy-step-plugins/pulls) | 1 | [0](https://github.com/rundeck-plugins/nixy-step-plugins/issues) | 0 |
| [openssh-node-execution](https://github.com/rundeck-plugins/openssh-node-execution/pulls) | 1 | [0](https://github.com/rundeck-plugins/openssh-node-execution/issues) | 0 |
| [pagerduty-notification](https://github.com/rundeck-plugins/pagerduty-notification/pulls) | 1 | [0](https://github.com/rundeck-plugins/pagerduty-notification/issues) | 0 |
| [puppet-apply-step](https://github.com/rundeck-plugins/puppet-apply-step/pulls) | 1 | [0](https://github.com/rundeck-plugins/puppet-apply-step/issues) | 0 |
| [rundeck-azure-plugin](https://github.com/rundeck-plugins/rundeck-azure-plugin/pulls) | 2 | [0](https://github.com/rundeck-plugins/rundeck-azure-plugin/issues) | 0 |
| [rundeck-azure-storage-plugin](https://github.com/rundeck-plugins/rundeck-azure-storage-plugin/pulls) | 1 | [0](https://github.com/rundeck-plugins/rundeck-azure-storage-plugin/issues) | 0 |
| [rundeck-ec2-nodes-plugin](https://github.com/rundeck-plugins/rundeck-ec2-nodes-plugin/pulls) | 2 | [0](https://github.com/rundeck-plugins/rundeck-ec2-nodes-plugin/issues) | **1** |
| [slack-incoming-webhook-plugin](https://github.com/rundeck-plugins/slack-incoming-webhook-plugin/pulls) | 1 | [0](https://github.com/rundeck-plugins/slack-incoming-webhook-plugin/issues) | 0 |
| [sshj-plugin](https://github.com/rundeck-plugins/sshj-plugin/pulls) | 1 | [0](https://github.com/rundeck-plugins/sshj-plugin/issues) | 0 |
| [vault-storage](https://github.com/rundeck-plugins/vault-storage/pulls) | 2 | [0](https://github.com/rundeck-plugins/vault-storage/issues) | **1** |
| [yaml-text-source](https://github.com/rundeck-plugins/yaml-text-source/pulls) | 1 | [0](https://github.com/rundeck-plugins/yaml-text-source/issues) | 0 |

**Total Open PRs:** 30 across 23 repositories
**Total Open Issues:** 4 across 4 repositories
**PRs Needing Attention:** 5

---

## PRs Needing Attention

PRs where community has most recent activity (comment or commit):

- **aws-s3-model-source #60**: [RUN-0000] Update dependency net.bytebuddy:byte-buddy to v1.18.15-jdk5
  - Last activity: opened by @app/renovate
  - Link: https://github.com/rundeck-plugins/aws-s3-model-source/pull/60

- **rundeck-ec2-nodes-plugin #246**: [RUN-0000] Update dependency software.amazon.awssdk:bom to v2.56.0
  - Last activity: opened by @app/renovate
  - Link: https://github.com/rundeck-plugins/rundeck-ec2-nodes-plugin/pull/246

- **vault-storage #123**: [RUN-0000] Update gradle minor/patch dependencies to v1.18.15-jdk5
  - Last activity: opened by @app/renovate
  - Link: https://github.com/rundeck-plugins/vault-storage/pull/123

- **py-winrm-plugin #145**: Fail instead of appending when the copy destination already exists
  - Last activity: reviewed by @skywalkw3r
  - Link: https://github.com/rundeck-plugins/py-winrm-plugin/pull/145

- **py-winrm-plugin #135**: Add support for client certificate based authentication
  - Last activity: commented by @sideshowcecil
  - Link: https://github.com/rundeck-plugins/py-winrm-plugin/pull/135


---

## Release Drift

Plugins tagged `versioned-plugins` with commits on their default branch beyond the latest GitHub Release - candidates for a release before the next Rundeck/Rundeckpro GA.

| Repository | Latest Release | Commits Ahead | Status |
|------------|-----------------|----------------|--------|
| [sshj-plugin](https://github.com/rundeck-plugins/sshj-plugin/compare/1.0.10...main) | 1.0.10 | 24 | **NEEDS RELEASE** |
| [ansible-plugin](https://github.com/rundeck-plugins/ansible-plugin/compare/5.1.3...main) | 5.1.3 | 18 | **NEEDS RELEASE** |
| [rundeck-ec2-nodes-plugin](https://github.com/rundeck-plugins/rundeck-ec2-nodes-plugin/compare/2.1.2...main) | 2.1.2 | 11 | **NEEDS RELEASE** |
| [git-plugin](https://github.com/rundeck-plugins/git-plugin/compare/2.0.4...main) | 2.0.4 | 11 | **NEEDS RELEASE** |
| [aws-s3-model-source](https://github.com/rundeck-plugins/aws-s3-model-source/compare/2.0.5...main) | 2.0.5 | 8 | **NEEDS RELEASE** |
| [http-step](https://github.com/rundeck-plugins/http-step/compare/2.0.7...main) | 2.0.7 | 7 | **NEEDS RELEASE** |
| [vault-storage](https://github.com/rundeck-plugins/vault-storage/compare/2.0.6...main) | 2.0.6 | 8 | **NEEDS RELEASE** |
| [rundeck-azure-plugin](https://github.com/rundeck-plugins/rundeck-azure-plugin/compare/2.0.7...main) | 2.0.7 | 15 | **NEEDS RELEASE** |
| [kubernetes](https://github.com/rundeck-plugins/kubernetes/compare/3.0.5...main) | 3.0.5 | 24 | **NEEDS RELEASE** |
| [py-winrm-plugin](https://github.com/rundeck-plugins/py-winrm-plugin/compare/3.3.0...main) | 3.3.0 | 26 | **NEEDS RELEASE** |
| [salt-step](https://github.com/rundeck-plugins/salt-step/compare/1.0.5...main) | 1.0.5 | 4 | **NEEDS RELEASE** |
| [aws-s3-steps](https://github.com/rundeck-plugins/aws-s3-steps/compare/2.0.2...main) | 2.0.2 | 9 | **NEEDS RELEASE** |
| [nixy-step-plugins](https://github.com/rundeck-plugins/nixy-step-plugins/compare/2.2.0...main) | 2.2.0 | 7 | **NEEDS RELEASE** |
| [docker](https://github.com/rundeck-plugins/docker/compare/2.0.4...main) | 2.0.4 | 5 | **NEEDS RELEASE** |
| [rundeck-azure-storage-plugin](https://github.com/rundeck-plugins/rundeck-azure-storage-plugin/compare/2.0.2...main) | 2.0.2 | 9 | **NEEDS RELEASE** |
| [yaml-text-source](https://github.com/rundeck-plugins/yaml-text-source/compare/3.0.2...main) | 3.0.2 | 9 | **NEEDS RELEASE** |
| [http-notification](https://github.com/rundeck-plugins/http-notification/compare/2.0.6...main) | 2.0.6 | 7 | **NEEDS RELEASE** |
| [jq-json-logfilter](https://github.com/rundeck-plugins/jq-json-logfilter/compare/2.0.4...main) | 2.0.4 | 7 | **NEEDS RELEASE** |
| [attribute-match-node-enhancer](https://github.com/rundeck-plugins/attribute-match-node-enhancer/compare/1.0.7...main) | 1.0.7 | 3 | **NEEDS RELEASE** |
| [rundeck-s3-log-plugin](https://github.com/rundeck-plugins/rundeck-s3-log-plugin/compare/3.0.6...main) | 3.0.6 | 7 | **NEEDS RELEASE** |
| [pagerduty-notification](https://github.com/rundeck-plugins/pagerduty-notification/compare/2.0.5...main) | 2.0.5 | 5 | **NEEDS RELEASE** |
| [slack-incoming-webhook-plugin](https://github.com/rundeck-plugins/slack-incoming-webhook-plugin/compare/2.0.4...main) | 2.0.4 | 7 | **NEEDS RELEASE** |
| [multiline-regex-datacapture-filter](https://github.com/rundeck-plugins/multiline-regex-datacapture-filter/compare/2.0.5...main) | 2.0.5 | 5 | **NEEDS RELEASE** |
| [puppet-apply-step](https://github.com/rundeck-plugins/puppet-apply-step/compare/3.0.2...main) | 3.0.2 | 5 | **NEEDS RELEASE** |
| [openssh-node-execution](https://github.com/rundeck-plugins/openssh-node-execution/compare/3.0.2...main) | 3.0.2 | 5 | **NEEDS RELEASE** |

**Plugins needing a release:** 25 ; **Unknown:** 0
