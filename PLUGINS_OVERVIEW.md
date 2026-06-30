# Rundeck Plugins Overview

Reference for the open-source plugins in the `rundeck-plugins` org: inventory, plugin types, and the build/release patterns that apply now that the Rundeck 6.0 (Grails 7 / Java 17) baseline has shipped.

For working agreements and org conventions, see [`CLAUDE.md`](CLAUDE.md).

> Historical migration logs (JitPack -> PackageCloud, Grails 6 -> 7) are archived in the local `.temp/` scratch area and are not maintained here.

---

## Baseline (steady state)

- Platform: Rundeck 6.0 on Grails 7 / Spring Boot 3 / Java 17.
- Artifacts: group `com.rundeck.plugins`, published to PackageCloud.
- Versioning: Axion from git tags, `prefix = ''` (tags like `1.2.3`, no `v`).
- Default branch: `main` for all active repos.

## Plugin types

### JAR plugins
Compiled Java/Groovy plugins that depend on `rundeck-core`.
- Build on Java 17.
- Bundle dependencies under `lib/` in the jar; declare plugin classes in the manifest (`Rundeck-Plugin-Classnames`).

### ZIP plugins
Script-based plugins (Bash/Python/Groovy) that do not compile, but are packaged as jars for Maven compatibility:
- Gradle task uses `type: Jar` with `archiveExtension = 'zip'`.
- Publication uses `extension = 'jar'` and `pom.packaging = 'jar'`.
- `plugin.yaml` tokens are processed with `ReplaceTokens` (not `expand`), so runtime `${config.*}` placeholders survive.

### Multi-module
`nixy-step-plugins` shares one root version across four independently published submodules: `waitfor`, `file`, `local-script`, `command`.

## Inventory

Active plugin repos (all default to `main`). Type column: J = JAR, Z = ZIP.

| Plugin | Type | Notes |
|--------|------|-------|
| ansible-plugin | J | |
| attribute-match-node-enhancer | J | Axion maps both `main`/`master` to simple version |
| aws-s3-model-source | J | |
| aws-s3-steps | Z | |
| docker | Z | |
| git-plugin | J | Publishes to Maven Central via `snapshot-release.yml` (triggers on `main`) |
| http-notification | J | Depends on http-step; needs Groovy + httpclient deps to compile |
| http-step | J | |
| jq-json-logfilter | J | |
| kubernetes | Z | |
| multiline-regex-datacapture-filter | J | Default branch was previously misconfigured; corrected to `main` |
| nixy-step-plugins | Z | Multi-module: waitfor, file, local-script, command |
| openssh-node-execution | Z | |
| pagerduty-notification | J | |
| puppet-apply-step | Z | |
| py-winrm-plugin | Z | |
| rundeck-azure-plugin | J | artifactId is `rundeck-azure-plugin` |
| rundeck-azure-storage-plugin | Z | |
| rundeck-ec2-nodes-plugin | J | |
| rundeck-s3-log-plugin | J | |
| salt-step | J | "Salt master" in build/docs is a SaltStack term, not a branch |
| slack-incoming-webhook-plugin | J | |
| sshj-plugin | J | |
| vault-storage | J | |
| yaml-text-source | Z | |

Other active repos in the org (examples, demos, tooling, infra): `awsworkshop`, `build-zip`, `h2-v2-migration`, `java-keytool-steps`, `rundeck-plugin-examples`, `ssh-session`, `terraform-workflow-step`, `ui-job-metrics`, `ui-plugin-examples`, `ui-roi-summary`, `vault-cert-extraction-issue-demo`, and `.github` (this repo).

## Common gotchas

- ZIP plugin publishes failing with 422: ensure `type: Jar` + `extension = 'jar'`, and remove any `@zip` qualifiers in consumers.
- Unprocessed `@version@`/`@author@` tokens in `plugin.yaml`: the build is missing the `ReplaceTokens` filter.
- Groovy-based JAR plugin produces a jar with no `.class` files: missing the `groovy` Gradle plugin and `groovy-all` dependency.
- SNAPSHOT versions from Axion: uncommitted changes were present at build time; commit/tag first.
- PackageCloud auth: set `PKGCLD_READ_TOKEN` (or the `pkgcldReadToken` property).

## Related docs

- Org engineering guide: [`CLAUDE.md`](CLAUDE.md)
- Snyk scanning: `snyk-scan-info.md`
- Rundeck core/architecture (local): `~/Documents/GitHub/rundeckpro/architecture`
