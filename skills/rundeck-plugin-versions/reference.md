# Reference: plugin version mapping and edit rules

Machine-readable source of truth: [`mapping.tsv`](mapping.tsv). This file is the human-readable companion. Keep them in sync.

## Where versions live in each consuming repo

| Repo | Operative version location | How it is consumed |
|------|----------------------------|--------------------|
| `rundeck` (Core) | `gradle.properties` - `<prop>=<version>` | `build.gradle` interpolates the `*PluginVersion` props into `bundledPlugins`; `testbuild.groovy` reads them |
| `rundeckpro` (Enterprise) | `gradle.properties` - `<prop>=<version>` | Referenced in `enterprise/build.gradle`, `plugins/azure-plugins/build.gradle`, `testbuild.groovy` |
| `ua-runner` | `gradle.properties` - `<prop>=<version>` | Referenced in `runner-agent/build.gradle` |

## Mapping (plugin repo -> version location per consuming repo)

| Plugin repo | Core prop (`gradle.properties`) | rundeckpro prop | ua-runner prop |
|-------------|--------------------------------|-----------------|----------------|
| ansible-plugin | `ansiblePluginVersion` | `ansiblePluginVersion` (testbuild.groovy) | - |
| aws-s3-model-source | `awsS3ModelSourceVersion` | `awsS3ModelSourceVersion` (testbuild.groovy) | - |
| py-winrm-plugin | `pyWinrmPluginVersion` | `pyWinrmPluginVersion` (testbuild.groovy) | - |
| openssh-node-execution | `opensshNodeExecutionVersion` | `opensshNodeExecutionVersion` (testbuild.groovy) | - |
| multiline-regex-datacapture-filter | `multilineRegexDatacaptureFilterVersion` | `multilineRegexDatacaptureFilterVersion` (testbuild.groovy) | - |
| attribute-match-node-enhancer | `attributeMatchNodeEnhancerVersion` | `attributeMatchNodeEnhancerVersion` (testbuild.groovy) | - |
| sshj-plugin | `sshjPluginVersion` | `sshjPluginVersion` (testbuild.groovy) | - |
| http-step | - | `httpStepVersion` | `httpStepVersion` |
| slack-incoming-webhook-plugin | - | `slackWebhookVersion` | - |
| aws-s3-steps | - | `awsS3StepsVersion` | `awsS3StepsVersion` |
| puppet-apply-step | - | `puppetApplyVersion` | - |
| nixy-step-plugins | - | `nixystepVersion` | `nixystepVersion` |
| pagerduty-notification | - | `pagerdutyNotificationVersion` | - |
| rundeck-azure-storage-plugin | - | `azureStorageVersion` | `azureStorageVersion` |
| rundeck-azure-plugin | - | `rundeckAzurePluginVersion` | - |
| rundeck-ec2-nodes-plugin | - | `rundeckEc2NodesPluginVersion` | - |
| vault-storage | - | `vaultStorageVersion` | `vaultStorageVersion` |
| jq-json-logfilter | - | `jqJsonLogfilterVersion` | - |
| http-notification | - | `httpNotificationVersion` | - |
| yaml-text-source | - | `yamlTextSourceVersion` | `yamlTextSourceVersion` |
| kubernetes | - | `kubernetesVersion` | `kubernetesPluginVersion` |
| docker | - | `dockerVersion` | `dockerVersion` |
| rundeck-s3-log-plugin | - | `rundeckS3LogPluginVersion` | - |

## Gotchas (verified)

- **Core reads plugin versions from `gradle.properties`.** `rundeck/gradle.properties` defines `ansiblePluginVersion`, `awsS3ModelSourceVersion`, `pyWinrmPluginVersion`, `opensshNodeExecutionVersion`, `multilineRegexDatacaptureFilterVersion`, `attributeMatchNodeEnhancerVersion`, `sshjPluginVersion`. `build.gradle` interpolates these into `bundledPlugins` and `testbuild.groovy` reads them; `build.yaml` no longer carries versions (it is a pointer comment). Update the property.
- **kubernetes property name differs by repo:** `kubernetesVersion` in rundeckpro, `kubernetesPluginVersion` in ua-runner. rundeckpro also defines `kubernetesPluginVersion`, which is vestigial there.
- **rundeckpro's Core-overlap props are NOT vestigial** (`ansiblePluginVersion`, `sshjPluginVersion`, `opensshNodeExecutionVersion`, `pyWinrmPluginVersion`, `awsS3ModelSourceVersion`, `multilineRegexDatacaptureFilterVersion`, `attributeMatchNodeEnhancerVersion`) - all seven are genuinely read by `testbuild.groovy`'s expected-plugin-version map (verified 2026-09-16, grep each prop name in that file: each appears exactly once, in the same map `ansiblePluginVersion` is in). A prior version of this note claimed only `ansiblePluginVersion` was real and the rest were vestigial; that was wrong and caused `bump-versions-pr.sh` to skip 5 real bumps in a rundeckpro PR. Bump these in rundeckpro whenever their Core value changes, same as any other consumed prop.
- **nixy-step-plugins is multi-module:** one release drives `nixystepVersion`, which feeds four artifacts (`waitfor`, `file`, `local-script`, `command`).
- **rundeck-azure-plugin** is consumed in `rundeckpro/plugins/azure-plugins/build.gradle` (not `enterprise/build.gradle`), but its property still lives in `rundeckpro/gradle.properties`.
- **rundeck-ec2-nodes-plugin** is consumed in `rundeckpro/plugins/cloud-aws-plugins/build.gradle` as a real `pluginLibs` dependency (verified 2026-08-18, grep for `rundeck-ec2-nodes-plugin` in that file). It is not vestigial - keep it in the operative dependency list.

## Property name != repo name

Notable renames to watch: `slack-incoming-webhook-plugin`->`slackWebhookVersion`, `puppet-apply-step`->`puppetApplyVersion`, `rundeck-azure-storage-plugin`->`azureStorageVersion`, `rundeck-azure-plugin`->`rundeckAzurePluginVersion`, `rundeck-ec2-nodes-plugin`->`rundeckEc2NodesPluginVersion`.

## Maintaining this mapping

When a plugin is added/removed or a property is renamed, update [`mapping.tsv`](mapping.tsv) and this table. Verify by grepping the consuming repos for `org.rundeck.plugins:<artifact>` and for the property name. `scripts/check-versions.sh` doubles as a validator: a plugin showing `-` in every column is not wired up.
