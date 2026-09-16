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
| ansible-plugin | `ansiblePluginVersion` | `ansiblePluginVersion` (corePlugins bundle + testbuild.groovy) | VIA-SUBMODULE |
| aws-s3-model-source | `awsS3ModelSourceVersion` | `awsS3ModelSourceVersion` (corePlugins bundle + testbuild.groovy) | - |
| py-winrm-plugin | `pyWinrmPluginVersion` | `pyWinrmPluginVersion` (corePlugins bundle + testbuild.groovy) | VIA-SUBMODULE |
| openssh-node-execution | `opensshNodeExecutionVersion` | `opensshNodeExecutionVersion` (corePlugins bundle + testbuild.groovy) | VIA-SUBMODULE |
| multiline-regex-datacapture-filter | `multilineRegexDatacaptureFilterVersion` | `multilineRegexDatacaptureFilterVersion` (corePlugins bundle + testbuild.groovy) | - |
| attribute-match-node-enhancer | `attributeMatchNodeEnhancerVersion` | `attributeMatchNodeEnhancerVersion` (corePlugins bundle + testbuild.groovy) | - |
| sshj-plugin | `sshjPluginVersion` | `sshjPluginVersion` (corePlugins bundle + testbuild.groovy) | VIA-SUBMODULE |
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
- **rundeckpro's Core-overlap props are NOT vestigial** (`ansiblePluginVersion`, `sshjPluginVersion`, `opensshNodeExecutionVersion`, `pyWinrmPluginVersion`, `awsS3ModelSourceVersion`, `multilineRegexDatacaptureFilterVersion`, `attributeMatchNodeEnhancerVersion`) - all seven are genuinely read twice: by `testbuild.groovy`'s expected-plugin-version map, and by a real `corePlugins` dependency list in rundeckpro's root `build.gradle` (`"org.rundeck.plugins:<artifact>:${<prop>}"`, mirroring Core's own bundling, comment references RUN-4569) that actually bundles the jars. A prior version of this note claimed only `ansiblePluginVersion` was real and the rest were vestigial; that was wrong and caused `bump-versions-pr.sh` to skip 5 real bumps in a rundeckpro PR (caught 2026-09-16). Bump these in rundeckpro whenever their Core value changes, same as any other consumed prop.
- **ua-runner bundles ansible-plugin, py-winrm-plugin, openssh-node-execution, and sshj-plugin via the submodule only - there is no independent ua-runner property.** `runner-agent/build.gradle`'s `bundledCorePlugins` map (line ~91) reads the version straight out of the nested `rundeck/` submodule's `gradle.properties` at build time (`file("${rootProject.projectDir}/rundeck/gradle.properties")`), loaded into its own separate `Properties` object - it never reads ua-runner's own top-level `gradle.properties` for these 4. On 2026-09-17 a same-named property was added to ua-runner's `gradle.properties` on the theory that an explicit, independently-bumpable property is always better than an implicit submodule read; that property was dead on arrival (verified by reading `bundledCorePlugins` itself) and got silently dropped by a `bump-versions-pr.sh` rebuild before anyone noticed it did nothing. Reverted the same day: `mapping.tsv`'s ua-runner column for these 4 is `VIA-SUBMODULE` again. **The real, build-affecting version is whatever commit ua-runner's `rundeck/` submodule is pinned to** - `.gitmodules`' `branch = main` is metadata only used by an explicit `git submodule update --remote`, which nothing in ua-runner's CI (`gradle-ci-build.yaml`, `release.yml`, `release-alpha.yml` - all plain `actions/checkout` with `submodules: true`) runs; the pinned commit can and does lag behind `rundeck`'s live `main`. Neither `check-versions.sh` nor `bump-versions-pr.sh` inspects that pinned commit today, so drift here (ua-runner bundling a stale ansible-plugin/py-winrm-plugin/openssh-node-execution/sshj-plugin because the submodule pointer is old) is a real, currently-unmonitored gap - see the mapping.tsv header comment for the same note.
- **nixy-step-plugins is multi-module:** one release drives `nixystepVersion`, which feeds four artifacts (`waitfor`, `file`, `local-script`, `command`).
- **rundeck-azure-plugin** is consumed in `rundeckpro/plugins/azure-plugins/build.gradle` (not `enterprise/build.gradle`), but its property still lives in `rundeckpro/gradle.properties`.
- **rundeck-ec2-nodes-plugin** is consumed in `rundeckpro/plugins/cloud-aws-plugins/build.gradle` as a real `pluginLibs` dependency (verified 2026-08-18, grep for `rundeck-ec2-nodes-plugin` in that file). It is not vestigial - keep it in the operative dependency list.

## Property name != repo name

Notable renames to watch: `slack-incoming-webhook-plugin`->`slackWebhookVersion`, `puppet-apply-step`->`puppetApplyVersion`, `rundeck-azure-storage-plugin`->`azureStorageVersion`, `rundeck-azure-plugin`->`rundeckAzurePluginVersion`, `rundeck-ec2-nodes-plugin`->`rundeckEc2NodesPluginVersion`.

## Maintaining this mapping

When a plugin is added/removed or a property is renamed, update [`mapping.tsv`](mapping.tsv) and this table. Verify by grepping the consuming repos for `org.rundeck.plugins:<artifact>` and for the property name. `scripts/check-versions.sh` doubles as a validator: a plugin showing `-` in every column is not wired up.
