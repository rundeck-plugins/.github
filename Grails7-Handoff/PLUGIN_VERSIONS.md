# Rundeck Plugins - Grails 7 Versions

**Last Updated:** February 18, 2026  
**Status:** In Development  
**Purpose:** Reference guide for plugin versions and Grails 7 compatibility

---

## Current Plugin Versions (grails7-upgrade branch)

### JAR Plugins (Compiled)

| Plugin | Latest Version | Java | Notes |
|--------|---------------|------|-------|
| ansible-plugin | 4.0.19-grails7 | 17 | Updated Feb 17: NPE + auth fixes |
| attribute-match-node-enhancer | 0.2.8-grails7 | 17 | |
| aws-s3-model-source | 1.0.15-grails7 | 17 | |
| git-plugin | 1.0.8-grails7 | 17 | |
| http-notification | 1.0.23-grails7 | 17 | |
| http-step | 1.1.20-grails7 | 17 | Updated Feb 17: CVE fixes |
| jq-json-logfilter | 1.0.14-grails7 | 17 | |
| multiline-regex-datacapture-filter | 1.1.9-grails7 | 17 | |
| pagerduty-notification | 1.3.7-grails7 | 17 | |
| rundeck-azure-plugin | 1.0.32-grails7 | 17 | |
| rundeck-ec2-nodes-plugin | 1.8.7-grails7 | 17 | |
| rundeck-s3-log-plugin | 2.0.8-grails7 | 17 | |
| salt-step | 0.5.0-grails7 | 17 | |
| slack-incoming-webhook-plugin | 1.3.10-grails7 | 17 | |
| sshj-plugin | 0.1.25-grails7 | 17 | |
| vault-storage | 1.3.21-grails7 | 17 | |

**Total JAR plugins:** 16

### ZIP Plugins (Script-Based)

| Plugin | Latest Version | Notes |
|--------|---------------|-------|
| aws-s3-steps | 1.2.5-grails7 | |
| docker | 1.5.0-grails7 | |
| kubernetes | 2.0.19-grails7 | Updated Feb 17: CVE-2026-21441 |
| openssh-node-execution | 2.0.12-grails7 | |
| puppet-apply-step | 2.0.6-grails7 | |
| py-winrm-plugin | 2.1.8-grails7 | |
| rundeck-azure-storage-plugin | 1.0.13-grails7 | Updated Feb 17: CVE + RUN-4064 |
| yaml-text-source | 2.0.4-grails7 | |

**Total ZIP plugins:** 8

### Multi-Module Projects

**nixy-step-plugins** (1.2.14-grails7) - Updated Feb 17
- waitfor: 1.2.14-grails7
- file: 1.2.14-grails7
- local-script: 1.2.14-grails7
- command: 1.2.14-grails7

**Total plugins:** 25 (16 JAR + 8 ZIP + 1 multi-module with 4 artifacts)

---

## Maven Coordinates

### Standard Dependencies

**JAR Plugins:**
```groovy
implementation 'com.rundeck.plugins:ansible-plugin:4.0.19-grails7'
implementation 'com.rundeck.plugins:http-step:1.1.20-grails7'
```

**ZIP Plugins:**
```groovy
// Note: ZIP plugins published as .jar files for Maven compatibility
implementation 'com.rundeck.plugins:kubernetes:2.0.19-grails7'
implementation 'com.rundeck.plugins:docker:1.5.0-grails7'
```

**Nixy Submodules:**
```groovy
implementation 'com.rundeck.plugins:waitfor:1.2.14-grails7'
implementation 'com.rundeck.plugins:file:1.2.14-grails7'
implementation 'com.rundeck.plugins:local-script:1.2.14-grails7'
implementation 'com.rundeck.plugins:command:1.2.14-grails7'
```

---

## Plugin Types Explained

### JAR Plugins
Compiled Java/Groovy plugins that depend on `rundeck-core`.

**Requirements for Grails 7:**
- Java 17 (minimum)
- Dependencies on `rundeck-core:6.0.0` or compatible
- Groovy 4.x (if using Groovy)
- Standard JAR packaging

### ZIP Plugins
Script-based plugins (Bash, Python, Groovy scripts) that don't compile.

**Requirements for Grails 7:**
- No Java version requirement (script-based)
- Must include `plugin.yaml` with plugin metadata
- Published as `.jar` files to Maven repositories (internally still ZIP archives)
- Uses `type: Jar` with `archiveExtension = 'zip'` in Gradle

### Multi-Module Projects
Projects like `nixy-step-plugins` that contain multiple plugin submodules.

**Characteristics:**
- Root project defines version (shared by all submodules)
- Each submodule publishes independently
- Single Git tag applies to all submodules
- All submodules share the same version number

---

## Version Suffix Strategy

### Development Phase (Current)
**Suffix:** `-grails7`  
**Example:** `4.0.19-grails7`

**Purpose:**
- Indicates compatibility with Grails 7 / Java 17
- Allows parallel development without affecting stable releases
- Temporary suffix during migration phase

### Production Release (Future)
**Suffix:** None  
**Example:** `4.1.0`

**When:**
- After Grails 7 migration is complete
- When merged to main/master branches
- At Rundeck 6.0 release

---

## Grails 7 Compatibility Requirements

### Framework Versions
- **Grails:** 7.x
- **Groovy:** 4.x
- **Spring Boot:** 3.x
- **Java:** 17 (minimum)

### Package Migration
- **javax.*** → **jakarta.***
- Example: `javax.servlet.*` → `jakarta.servlet.*`

### Build Requirements
- Gradle 7.x or 8.x
- Groovy compiler 4.x (for compiled plugins)
- Java 17 JDK

---

## Common Build Issues

### Issue 1: ZIP Plugin Maven Publication

**Problem:** ZIP plugins fail to publish to Maven repositories.

**Solution:** Use `type: Jar` with specific configuration:

```groovy
task pluginZip(type: Jar) {  // Use Jar type, not Zip!
    archiveExtension = 'zip'
    // ... contents ...
}

publishing {
    publications {
        mavenZip(MavenPublication) {
            artifact(pluginZip) {
                extension = 'jar'  // Publish as .jar
            }
            pom {
                packaging = 'jar'
            }
        }
    }
}
```

**Why:** Maven repositories expect standard artifact types. ZIP plugins are internally ZIP archives but published as JAR artifacts.

### Issue 2: Unprocessed Gradle Tokens

**Problem:** Plugin fails to load with YAML parsing error: `found character '@' that cannot start any token`

**Root Cause:** `plugin.yaml` contains `@version@` placeholders that weren't replaced during build.

**Solution:** Add token replacement to build:

```groovy
import org.apache.tools.ant.filters.ReplaceTokens

pluginZip.doFirst {
    def tokens = [
        version: project.version.toString(),
        author: 'Author Name',
        url: 'https://github.com/...'
    ]

    copy {
        from('plugin.yaml') {
            filter(ReplaceTokens, tokens: tokens)
        }
        into(layout.buildDirectory.dir('zip-contents'))
    }
}
```

### Issue 3: Java 17 Module Access

**Problem:** Tests fail with reflection errors on Java 17.

**Solution:** Add JVM args for module access:

```groovy
test {
    jvmArgs = [
        '--add-opens=java.base/java.lang=ALL-UNNAMED',
        '--add-opens=java.base/java.util=ALL-UNNAMED',
        '--add-opens=java.base/java.lang.reflect=ALL-UNNAMED'
    ]
}
```

### Issue 4: Missing Groovy Plugin

**Problem:** Groovy source files don't compile, JAR has no `.class` files.

**Solution:** Add Groovy plugin and dependency:

```groovy
plugins {
    id 'groovy'
    id 'java'
}

dependencies {
    implementation 'org.apache.groovy:groovy-all:4.0.29'
}
```

---

## Build & Publish Commands

### JAR Plugin
```bash
# Build
./gradlew clean build test

# Publish to Maven Local (for testing)
./gradlew publishToMavenLocal

# Publish to remote Maven repository
./gradlew publish
```

### ZIP Plugin
```bash
# Build (no test task for script plugins)
./gradlew clean build

# Publish to Maven Local
./gradlew publishToMavenLocal

# Publish to remote Maven repository
./gradlew publish
```

### Multi-Module Project
```bash
# Build all submodules
./gradlew clean build

# Publish all submodules
./gradlew publish
```

---

## Version Lookup Quick Reference

**Latest versions by plugin type:**

**Node Execution & Inventory:**
- ansible-plugin: 4.0.19-grails7
- openssh-node-execution: 2.0.12-grails7
- py-winrm-plugin: 2.1.8-grails7
- sshj-plugin: 0.1.25-grails7
- rundeck-ec2-nodes-plugin: 1.8.7-grails7
- aws-s3-model-source: 1.0.15-grails7

**Workflow Steps:**
- http-step: 1.1.20-grails7
- docker: 1.5.0-grails7
- kubernetes: 2.0.19-grails7
- aws-s3-steps: 1.2.5-grails7
- salt-step: 0.5.0-grails7
- puppet-apply-step: 2.0.6-grails7
- git-plugin: 1.0.8-grails7
- nixy-step-plugins: 1.2.14-grails7 (waitfor, file, local-script, command)

**Notifications:**
- http-notification: 1.0.23-grails7
- slack-incoming-webhook-plugin: 1.3.10-grails7
- pagerduty-notification: 1.3.7-grails7

**Storage:**
- vault-storage: 1.3.21-grails7
- rundeck-azure-storage-plugin: 1.0.13-grails7
- rundeck-s3-log-plugin: 2.0.8-grails7

**Utilities:**
- jq-json-logfilter: 1.0.14-grails7
- multiline-regex-datacapture-filter: 1.1.9-grails7
- attribute-match-node-enhancer: 0.2.8-grails7
- yaml-text-source: 2.0.4-grails7

**Cloud Integration:**
- rundeck-azure-plugin: 1.0.32-grails7

---

## Migration Status

### Completed ✅
All 25 plugins have been migrated to Grails 7 compatibility:
- Java 17 upgrade (JAR plugins)
- Package namespace update (javax → jakarta)
- Maven artifact repository migration
- Build standardization
- Version management with Axion

### In Progress 🔄
- Integration testing with Rundeck 6.0
- Functional testing across all plugin types
- Documentation refinement

### Pending 📋
- Remove `-grails7` suffix at production release
- Final CVE verification
- Maven Central publication (future consideration)

---

## Testing Guidelines

### Plugin-Level Testing
```bash
# JAR plugins
./gradlew clean build test

# ZIP plugins (no test task)
./gradlew clean build
```

### Integration Testing
1. Build plugin locally
2. Publish to Maven Local
3. Update consuming application to reference local version
4. Run application functional tests
5. Verify plugin loads and functions correctly

### Verification Checklist
- [ ] Plugin builds without errors
- [ ] Artifact contains expected files (.class for JAR, scripts for ZIP)
- [ ] Maven metadata generated correctly (POM file)
- [ ] Version matches Git tag
- [ ] Plugin loads in Rundeck 6.0
- [ ] Basic plugin functionality works

---

## Key Technical Patterns

### Axion scmVersion Configuration
```gradle
plugins {
    id 'pl.allegro.tech.build.axion-release' version '1.17.2'
}

scmVersion {
    ignoreUncommittedChanges = false
    tag {
        prefix = ''           // NO "v" prefix
        versionSeparator = ''
    }
}

version = scmVersion.version
```

### ZIP Plugin Publication
```groovy
task pluginZip(type: Jar) {
    archiveBaseName = 'plugin-name'
    archiveExtension = 'zip'
    
    from('resources') {
        include '**/*'
    }
}

publishing {
    publications {
        mavenZip(MavenPublication) {
            groupId = 'com.rundeck.plugins'
            artifactId = 'plugin-name'
            
            artifact(pluginZip) {
                extension = 'jar'  // Maven compatibility
            }
            
            pom {
                packaging = 'jar'
            }
        }
    }
}
```

### Multi-Module Version Sharing
```groovy
// Root build.gradle
scmVersion {
    tag { prefix = '' }
}

allprojects {
    version = rootProject.scmVersion.version
}

// Submodule build.gradle
publishing {
    publications {
        mavenZip(MavenPublication) {
            groupId = 'com.rundeck.plugins'
            artifactId = project.name  // waitfor, file, etc.
        }
    }
}
```

---

## Migration from Old Versions

### Finding Current Version
Check the plugin's `build.gradle` or run:
```bash
./gradlew currentVersion -q
```

### Updating Dependencies
**Old (pre-Grails 7):**
```groovy
dependencies {
    implementation 'com.github.rundeck-plugins:ansible-plugin:4.0.16'
}
```

**New (Grails 7):**
```groovy
dependencies {
    implementation 'com.rundeck.plugins:ansible-plugin:4.0.19-grails7'
}
```

### Version Property Pattern
Centralize versions in `gradle.properties`:
```properties
ansiblePluginVersion=4.0.19-grails7
httpStepVersion=1.1.20-grails7
kubernetesVersion=2.0.19-grails7
```

Then reference in build files:
```groovy
dependencies {
    implementation "com.rundeck.plugins:ansible-plugin:${ansiblePluginVersion}"
}
```

---

## Recent Updates (Feb 2026)

### Feb 17, 2026 - Upstream Merge Wave
Five plugins merged upstream changes (CVE fixes, bug fixes):

1. **kubernetes** (2.0.18 → 2.0.19-grails7)
   - CVE-2026-21441 fix
   
2. **rundeck-azure-storage-plugin** (1.0.12 → 1.0.13-grails7)
   - RUN-4064 bug fix
   - CVE updates
   
3. **http-step** (1.1.19 → 1.1.20-grails7)
   - Multiple CVE fixes
   
4. **ansible-plugin** (4.0.18 → 4.0.19-grails7)
   - NPE fix
   - Authentication improvements
   
5. **nixy-step-plugins** (1.2.13 → 1.2.14-grails7)
   - Version bump for consistency

**Strategy:** Merge upstream `main`/`master` → `grails7-upgrade`, rebuild, retag, republish

---

## Critical: Java 17 Requirement

### Why Java 17 is Required (Not Optional)

**Grails 7 → Spring Boot 3 → Java 17**
- Grails 7 is built on Spring Boot 3.x
- Spring Boot 3.x requires Java 17 minimum
- `rundeck-core:6.0.0` is compiled with Java 17 (bytecode version 61)
- All JAR plugins must match core's Java version

**Impact:**
- All 16 JAR plugins require Java 17
- Cannot mix Java 11 plugins with Java 17 core
- One-time forced rebuild for all plugins
- After 6.0 release, plugins can remain stable for months/years

---

## Quick Commands Reference

### Check Plugin Version
```bash
./gradlew currentVersion -q
```

### Build Plugin
```bash
# JAR plugins
./gradlew clean build test

# ZIP plugins
./gradlew clean build
```

### Create Version Tag
```bash
# Check latest tags
git tag -l | sort -V | tail -5

# Create new tag (no "v" prefix)
git tag 4.0.20-grails7
git push origin 4.0.20-grails7
```

### Verify Artifact Contents
```bash
# JAR plugin - check for compiled classes
unzip -l build/libs/plugin-4.0.19-grails7.jar | grep '\.class$'

# ZIP plugin - check for scripts
unzip -l build/libs/plugin-2.0.19-grails7.zip | grep '\.sh$\|\.py$'
```

---

## Troubleshooting

### Build Fails with "Task 'test' not found"
**Cause:** ZIP plugins don't have test tasks  
**Fix:** Use `./gradlew clean build` (no `test`)

### Version Shows as "SNAPSHOT"
**Cause:** Uncommitted changes present  
**Fix:** Commit all changes before building

### "Failed to parse version: v4.0.14"
**Cause:** Old tags with "v" prefix conflict with Axion config  
**Fix:** Create new tag with correct format: `git tag 4.0.20-grails7`

### Artifact Missing from Maven Repository
**Cause:** Publish task may have failed silently  
**Fix:** Check build logs, verify authentication, re-run publish task

---

## Related Documentation

- [Plugin Tagging Architecture](./PLUGIN_TAGGING_ARCHITECTURE.md) - Git tagging and versioning standards
- [Merge Conflict Patterns](./MERGE_CONFLICT_PATTERNS.md) - Handling upstream merges
- [Common Migration Issues](./COMMON_MIGRATION_ISSUES.md) - Troubleshooting guide

---

## Contributing

When updating plugin versions:
1. Update this document with new version numbers
2. Include date and reason for update (CVE, bug fix, feature)
3. Update related integration docs if dependencies changed
4. Test the plugin builds successfully
5. Verify version appears correctly in `./gradlew currentVersion`
