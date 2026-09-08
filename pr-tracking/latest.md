# PR Report - 2026-09-08

## Summary

| Repository | Open PRs | Open Issues | Needs Attention |
|------------|----------|-------------|-----------------|
| [git-plugin](https://github.com/rundeck-plugins/git-plugin/pulls) | 2 | [2](https://github.com/rundeck-plugins/git-plugin/issues) | **1** |
| [docker](https://github.com/rundeck-plugins/docker/pulls) | 0 | [1](https://github.com/rundeck-plugins/docker/issues) | 0 |
| [ansible-plugin](https://github.com/rundeck-plugins/ansible-plugin/pulls) | 2 | [0](https://github.com/rundeck-plugins/ansible-plugin/issues) | **1** |
| [attribute-match-node-enhancer](https://github.com/rundeck-plugins/attribute-match-node-enhancer/pulls) | 1 | [0](https://github.com/rundeck-plugins/attribute-match-node-enhancer/issues) | 0 |
| [aws-s3-model-source](https://github.com/rundeck-plugins/aws-s3-model-source/pulls) | 2 | [0](https://github.com/rundeck-plugins/aws-s3-model-source/issues) | **1** |
| [http-notification](https://github.com/rundeck-plugins/http-notification/pulls) | 2 | [0](https://github.com/rundeck-plugins/http-notification/issues) | **1** |
| [http-step](https://github.com/rundeck-plugins/http-step/pulls) | 1 | [0](https://github.com/rundeck-plugins/http-step/issues) | 0 |
| [jq-json-logfilter](https://github.com/rundeck-plugins/jq-json-logfilter/pulls) | 2 | [0](https://github.com/rundeck-plugins/jq-json-logfilter/issues) | **1** |
| [multiline-regex-datacapture-filter](https://github.com/rundeck-plugins/multiline-regex-datacapture-filter/pulls) | 1 | [0](https://github.com/rundeck-plugins/multiline-regex-datacapture-filter/issues) | 0 |
| [pagerduty-notification](https://github.com/rundeck-plugins/pagerduty-notification/pulls) | 1 | [0](https://github.com/rundeck-plugins/pagerduty-notification/issues) | 0 |
| [rundeck-azure-plugin](https://github.com/rundeck-plugins/rundeck-azure-plugin/pulls) | 3 | [0](https://github.com/rundeck-plugins/rundeck-azure-plugin/issues) | **1** |
| [rundeck-ec2-nodes-plugin](https://github.com/rundeck-plugins/rundeck-ec2-nodes-plugin/pulls) | 2 | [0](https://github.com/rundeck-plugins/rundeck-ec2-nodes-plugin/issues) | **1** |
| [rundeck-s3-log-plugin](https://github.com/rundeck-plugins/rundeck-s3-log-plugin/pulls) | 1 | [0](https://github.com/rundeck-plugins/rundeck-s3-log-plugin/issues) | 0 |
| [salt-step](https://github.com/rundeck-plugins/salt-step/pulls) | 2 | [0](https://github.com/rundeck-plugins/salt-step/issues) | **1** |
| [slack-incoming-webhook-plugin](https://github.com/rundeck-plugins/slack-incoming-webhook-plugin/pulls) | 2 | [0](https://github.com/rundeck-plugins/slack-incoming-webhook-plugin/issues) | **1** |
| [sshj-plugin](https://github.com/rundeck-plugins/sshj-plugin/pulls) | 2 | [0](https://github.com/rundeck-plugins/sshj-plugin/issues) | **1** |
| [vault-storage](https://github.com/rundeck-plugins/vault-storage/pulls) | 3 | [0](https://github.com/rundeck-plugins/vault-storage/issues) | **1** |

**Total Open PRs:** 29 across 16 repositories
**Total Open Issues:** 3 across 2 repositories
**PRs Needing Attention:** 11

---

## PRs Needing Attention

PRs where community has most recent activity (comment or commit):

- **sshj-plugin #161**: [RUN-0000] Update Node.js to v24.20.0
  - Last activity: opened by @app/renovate
  - Link: https://github.com/rundeck-plugins/sshj-plugin/pull/161

- **ansible-plugin #467**: [RUN-0000] Update dependency org.yaml:snakeyaml to v2.7
  - Last activity: opened by @app/renovate
  - Link: https://github.com/rundeck-plugins/ansible-plugin/pull/467

- **slack-incoming-webhook-plugin #75**: [RUN-0000] Update dependency org.freemarker:freemarker to v2.3.35
  - Last activity: reviewed by @luismalamoc
  - Link: https://github.com/rundeck-plugins/slack-incoming-webhook-plugin/pull/75

- **vault-storage #110**: [RUN-0000] Update gradle minor/patch dependencies to v1.18.13
  - Last activity: opened by @app/renovate
  - Link: https://github.com/rundeck-plugins/vault-storage/pull/110

- **aws-s3-model-source #48**: [RUN-0000] Update dependency net.bytebuddy:byte-buddy to v1.18.13
  - Last activity: opened by @app/renovate
  - Link: https://github.com/rundeck-plugins/aws-s3-model-source/pull/48

- **rundeck-azure-plugin #96**: [RUN-0000] Update dependency net.bytebuddy:byte-buddy to v1.18.13
  - Last activity: opened by @app/renovate
  - Link: https://github.com/rundeck-plugins/rundeck-azure-plugin/pull/96

- **git-plugin #89**: [RUN-0000] Update dependency net.bytebuddy:byte-buddy to v1.18.13
  - Last activity: opened by @app/renovate
  - Link: https://github.com/rundeck-plugins/git-plugin/pull/89

- **salt-step #58**: [RUN-0000] Update dependency org.yaml:snakeyaml to v2.7
  - Last activity: opened by @app/renovate
  - Link: https://github.com/rundeck-plugins/salt-step/pull/58

- **rundeck-ec2-nodes-plugin #229**: [RUN-0000] Update dependency software.amazon.awssdk:bom to v2.54.1
  - Last activity: reviewed by @luismalamoc
  - Link: https://github.com/rundeck-plugins/rundeck-ec2-nodes-plugin/pull/229

- **http-notification #53**: [RUN-0000] Update dependency net.bytebuddy:byte-buddy to v1.18.13
  - Last activity: opened by @app/renovate
  - Link: https://github.com/rundeck-plugins/http-notification/pull/53

- **jq-json-logfilter #38**: [RUN-0000] Update dependency net.thisptr:jackson-jq to v1.6.3
  - Last activity: opened by @app/renovate
  - Link: https://github.com/rundeck-plugins/jq-json-logfilter/pull/38


---

## Release Drift

Plugins tagged `versioned-plugins` with commits on their default branch beyond the latest GitHub Release - candidates for a release before the next Rundeck/Rundeckpro GA.

| Repository | Latest Release | Commits Ahead | Status |
|------------|-----------------|----------------|--------|
| [sshj-plugin](https://github.com/rundeck-plugins/sshj-plugin/compare/1.0.8...main) | 1.0.8 | 10 | **NEEDS RELEASE** |
| [rundeck-azure-plugin](https://github.com/rundeck-plugins/rundeck-azure-plugin/compare/2.0.5...main) | 2.0.5 | 3 | **NEEDS RELEASE** |
| ansible-plugin | 5.1.1 | 0 | OK |
| salt-step | 1.0.4 | 0 | OK |
| rundeck-s3-log-plugin | 3.0.5 | 0 | OK |
| rundeck-ec2-nodes-plugin | 2.0.5 | 0 | OK |
| yaml-text-source | 3.0.2 | 0 | OK |
| vault-storage | 2.0.4 | 0 | OK |
| http-notification | 2.0.5 | 0 | OK |
| nixy-step-plugins | 2.2.0 | 0 | OK |
| py-winrm-plugin | 3.3.0 | 0 | OK |
| slack-incoming-webhook-plugin | 2.0.3 | 0 | OK |
| rundeck-azure-storage-plugin | 2.0.2 | 0 | OK |
| puppet-apply-step | 3.0.2 | 0 | OK |
| pagerduty-notification | 2.0.3 | 0 | OK |
| openssh-node-execution | 3.0.2 | 0 | OK |
| multiline-regex-datacapture-filter | 2.0.3 | 0 | OK |
| kubernetes | 3.0.5 | 0 | OK |
| jq-json-logfilter | 2.0.3 | 0 | OK |
| http-step | 2.0.5 | 0 | OK |
| git-plugin | 2.0.3 | 0 | OK |
| docker | 2.0.2 | 0 | OK |
| aws-s3-steps | 2.0.2 | 0 | OK |
| aws-s3-model-source | 2.0.3 | 0 | OK |
| attribute-match-node-enhancer | 1.0.5 | 0 | OK |

**Plugins needing a release:** 2 ; **Unknown:** 0
