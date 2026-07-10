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
| ansible-plugin | `ansiblePluginVersion` | - (testbuild only) | - |
| aws-s3-model-source | `awsS3ModelSourceVersion` | - | - |
| py-winrm-plugin | `pyWinrmPluginVersion` | - | - |
| openssh-node-execution | `opensshNodeExecutionVersion` | - | - |
| multiline-regex-datacapture-filter | `multilineRegexDatacaptureFilterVersion` | - | - |
| attribute-match-node-enhancer | `attributeMatchNodeEnhancerVersion` | - | - |
| sshj-plugin | `sshjPluginVersion` | - | - |
| http-step | - | `httpStepVersion` | `httpStepVersion` |
| slack-incoming-webhook-plugin | - | `slackWebhookVersion` | - |
| aws-s3-steps | - | `awsS3StepsVersion` | `awsS3StepsVersion` |
| puppet-apply-step | - | `puppetApplyVersion` | - |
| nixy-step-plugins | - | `nixystepVersion` | `nixystepVersion` |
| pagerduty-notification | - | `pagerdutyNotificationVersion` | - |
| rundeck-azure-storage-plugin | - | `azureStorageVersion` | `azureStorageVersion` |
| rundeck-azure-plugin | - | `rundeckAzurePluginVersion` | - |
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
- **rundeckpro also carries vestigial Core-overlap props** (`sshjPluginVersion`, `opensshNodeExecutionVersion`, `pyWinrmPluginVersion`, `awsS3ModelSourceVersion`, `multilineRegexDatacaptureFilterVersion`, `attributeMatchNodeEnhancerVersion`); only `ansiblePluginVersion` is used, and only by `testbuild.groovy`.
- **nixy-step-plugins is multi-module:** one release drives `nixystepVersion`, which feeds four artifacts (`waitfor`, `file`, `local-script`, `command`).
- **rundeck-azure-plugin** is consumed in `rundeckpro/plugins/azure-plugins/build.gradle` (not `enterprise/build.gradle`), but its property still lives in `rundeckpro/gradle.properties`.

## Property name != repo name

Notable renames to watch: `slack-incoming-webhook-plugin`->`slackWebhookVersion`, `puppet-apply-step`->`puppetApplyVersion`, `rundeck-azure-storage-plugin`->`azureStorageVersion`, `rundeck-azure-plugin`->`rundeckAzurePluginVersion`, `rundeck-ec2-nodes-plugin`->`rundeckEc2NodesPluginVersion` (defined in rundeckpro but currently not in the operative dependency list).

## Maintaining this mapping

When a plugin is added/removed or a property is renamed, update [`mapping.tsv`](mapping.tsv) and this table. Verify by grepping the consuming repos for `org.rundeck.plugins:<artifact>` and for the property name. `scripts/check-versions.sh` doubles as a validator: a plugin showing `-` in every column is not wired up.
