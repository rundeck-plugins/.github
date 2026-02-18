# Plugin Tagging Architecture
## Standardized Git Tag and Versioning Strategy for Rundeck Plugins

**Date:** January 8, 2026  
**Decision:** Use Axion scmVersion with NO "v" prefix  
**Status:** ✅ Adopted for all plugins  
**Applies to:** All Rundeck plugins in `rundeck-plugins` organization

---

## Executive Summary

**Standard Tag Format:** `X.Y.Z[-suffix]` (e.g., `4.0.16` or `4.1.0-rc.1`)  
**NO "v" prefix** (not `vX.Y.Z`)

**Axion Configuration:**
```gradle
scmVersion {
    tag {
        prefix = ''           // Empty string, not 'v'
        versionSeparator = ''
    }
}

version = scmVersion.version  // Dynamic version from git tags
```

**Note:** This document describes the long-term standard. Current Grails 7 migration uses temporary `-grails7` suffix (e.g., `4.0.16-grails7`) which will be removed at production release.

---

## Historical Context

### Previous State (Main/Master Branches)

**JAR Plugins:**
- Configuration: `prefix = 'v'`
- Tags: `v4.0.12`, `v4.0.11`, etc.
- Used Axion with "v" prefix

**ZIP Plugins:**
- Configuration: Said `prefix = 'v'` but actual tags had NO "v"
- Tags: `1.2.3`, `1.2.2` (inconsistent with config)
- Evidence: aws-s3-steps had `prefix = 'v'` in build.gradle but tags were `1.2.3`

**Result:** Inconsistent across plugin types, config didn't match reality

### Grails 7 Migration (Early State)

When migrating to Grails 7, we encountered Maven repository compatibility issues:
- Some Maven repositories required dependency strings to EXACTLY match git tag
- Tag `v1.0.0` → Must reference as `com.github.rundeck-plugins:plugin:v1.0.0`
- This created a "version prefix see-saw" problem:
  - Maven Local works with any version string (no "v" needed)
  - Some repositories REQUIRE "v" to match tag
  - **Cannot have both working simultaneously**

**Temporary Fix:** Hardcoded versions to bypass scmVersion entirely
```gradle
// project.version = scmVersion.version  // DISABLED
version = '4.0.16-grails7-upgrade-test'  // HARDCODED
```

This worked but lost dynamic versioning benefits.

---

## The Decision: NO "v" Prefix

### Primary Reason: Maven Repository Compatibility

Moving to standard Maven repository publishing eliminates the "v" prefix requirement:

**With "v" prefix:**
- ❌ Tag `v1.0.0` → Artifact version `v1.0.0` → Must reference as `plugin:v1.0.0`
- ❌ Non-standard Maven coordinates
- ❌ Some tools don't expect "v" in version strings

**Without "v" prefix:**
- ✅ Tag `1.0.0` → Artifact version `1.0.0` → Reference as `plugin:1.0.0`
- ✅ Standard Maven conventions
- ✅ Works identically to Maven Local and Maven Central

### Secondary Reasons:

#### 1. **Maven Convention Compliance**
- Maven Central artifacts rarely use "v" prefix in coordinates
- `org.springframework:spring-core:5.3.21` ← Standard format
- NOT `org.springframework:spring-core:v5.3.21` ← Non-standard
- Following industry standards improves ecosystem compatibility

#### 2. **Consistency Across Plugin Types**
- ZIP plugins already used no "v" prefix in practice
- JAR plugins claimed to use "v" but were inconsistent
- Standardizing eliminates confusion and special cases

#### 3. **Simpler Mental Model**
- Tag name = Version string = Maven coordinate version
- No translation needed between systems
- One source of truth

#### 4. **GitHub Actions/CI Simplicity**
```yaml
- name: Get Release Version
  run: VERSION=$(./gradlew currentVersion -q) && echo $VERSION
  # Outputs: 4.0.16-grails7 (clean, usable as-is)
  # NOT: v4.0.16-grails7 (would need to strip 'v')
```

#### 5. **Future-Proof for Maven Central**
If/when publishing to Maven Central:
- Coordinates: `com.rundeck.plugins:ansible-plugin:4.0.16`
- Follows standard Maven practices
- No special handling needed

---

## Implementation Details

### Standard scmVersion Configuration

Every plugin should use this exact configuration:

```gradle
plugins {
    id 'pl.allegro.tech.build.axion-release' version '1.17.2'
    // ... other plugins
}

scmVersion {
    ignoreUncommittedChanges = false  // Fail if dirty working directory
    
    tag {
        prefix = ''                    // NO "v" prefix
        versionSeparator = ''          // No separator between prefix and version
    }
    
    // Optional: Validate tag format
    tag {
        deserialize = { config, position, tagName ->
            // Only accept tags matching semver pattern
            if (tagName ==~ /\d+\.\d+\.\d+.*/) {
                return tagName
            }
            return null  // Ignore non-version tags
        }
    }
}

version = scmVersion.version  // Use dynamic version from git
```

### Tag Format Standards

**Production Releases:**
```
4.0.16
1.2.3
0.1.24
```

**Pre-release Formats (Optional Suffix):**
```
4.1.0-rc.1       # Release candidate
4.1.0-beta.1     # Beta release
4.1.0-alpha.1    # Alpha release
1.2.3-SNAPSHOT   # Development snapshot
```

**Format:** `MAJOR.MINOR.PATCH[-SUFFIX]`
- Follows semantic versioning (SemVer)
- Suffix is optional
- When used, suffix should follow SemVer pre-release conventions

**Current Migration (Temporary):**
- Grails 7 migration uses `-grails7` suffix (e.g., `4.0.16-grails7`)
- This will be removed when merged to main for Rundeck 6.0 release
- Final production tags will be clean versions: `4.1.0`, `5.0.0`, etc.

### GroupId Standards

**Standard groupId:**
```gradle
groupId = 'com.rundeck.plugins'
```

**Reason:** 
- `com.rundeck` is vendor-owned namespace
- Standard Maven package namespace convention
- Works with all Maven repositories

---

## Migration Impact

### For Plugin Developers

**Before (Main Branch):**
```bash
git tag v4.0.16
git push origin v4.0.16
# Axion reads tag, version becomes "v4.0.16" or "4.0.16" (inconsistent)
```

**After (Standardized):**
```bash
# Production release:
git tag 4.1.0
git push origin 4.1.0
# Axion reads tag, version becomes "4.1.0" (exact match)

# Pre-release (if needed):
git tag 4.1.0-rc.1
git push origin 4.1.0-rc.1
# Axion reads tag, version becomes "4.1.0-rc.1"
```

### For Dependencies

**Standard Maven dependency:**
```gradle
dependencies {
    implementation "com.rundeck.plugins:ansible-plugin:${ansiblePluginVersion}"
    // gradle.properties: ansiblePluginVersion=4.1.0
    //                                         ^ Clean production version, NO "v" prefix
}
```

### For GitHub Workflows

**No changes needed!** Workflows use `./gradlew currentVersion` which returns the tag value:
```yaml
- name: Get Release Version
  run: VERSION=$(./gradlew currentVersion -q -Prelease.quiet) && echo $VERSION
  # Works identically before/after, just outputs different format
```

---

## Benefits Summary

### Developer Experience
✅ **Predictable:** Tag name exactly matches version string everywhere  
✅ **Consistent:** All plugins follow identical pattern  
✅ **Simple:** No mental translation between tag and version  
✅ **Automated:** Axion handles version management, no hardcoding  

### Technical Benefits
✅ **Maven Compliant:** Follows industry standards  
✅ **Repository Agnostic:** Works with Maven Local and Maven Central  
✅ **CI/CD Friendly:** GitHub Actions workflows continue working  
✅ **Future-Proof:** Ready for public Maven Central publication  

### Operational Benefits
✅ **Less Confusion:** No special cases between plugin types  
✅ **Easier Debugging:** Version string matches tag exactly  
✅ **Faster Development:** No manual version updates needed  
✅ **Reduced Errors:** Axion prevents version mismatches  

---

## Edge Cases and Exceptions

### Multi-Module Projects

Multi-module projects (e.g., nixy-step-plugins) have slightly different configuration:

```gradle
// Root project
scmVersion {
    tag {
        prefix = ''
        versionSeparator = ''
    }
}

allprojects {
    version = rootProject.scmVersion.version  // Share version across modules
}
```

**Tag:** `1.2.14-grails7`  
**All modules:** `waitfor:1.2.14-grails7`, `file:1.2.14-grails7`, etc.

### Snapshot Builds

For development/snapshot builds (not tagged):

```gradle
scmVersion {
    versionCreator { versionFromTag, position ->
        // position.latestTag = "4.0.16-grails7"
        // position.branch = "grails7-upgrade"
        // Creates: "4.0.16-grails7-SNAPSHOT"
        "${versionFromTag}-SNAPSHOT"
    }
}
```

Axion automatically appends `-SNAPSHOT` for commits not on a tag.

---

## Verification Checklist

When adding scmVersion to a plugin, verify:

- [ ] `prefix = ''` (empty string, not 'v')
- [ ] `version = scmVersion.version` (not hardcoded)
- [ ] No hardcoded version strings anywhere
- [ ] Git tag matches expected format: `X.Y.Z-suffix`
- [ ] Test: `./gradlew currentVersion` outputs correct version
- [ ] Test: `./gradlew build` produces correctly-named artifact
- [ ] Publishing config uses `groupId = 'com.rundeck.plugins'`

---

## Common Mistakes

### Mistake 1: Mixed Tag Formats
```bash
# ❌ Wrong - mixing formats
git tag v4.0.15
git tag 4.0.16-grails7

# ✅ Correct - consistent format
git tag 4.0.15
git tag 4.0.16-grails7
```

### Mistake 2: Prefix Configuration Mismatch
```gradle
// ❌ Wrong - config doesn't match tags
scmVersion {
    tag { prefix = 'v' }  // But tags are '4.0.16', not 'v4.0.16'
}

// ✅ Correct - config matches reality
scmVersion {
    tag { prefix = '' }   // Tags are '4.0.16'
}
```

### Mistake 3: Hardcoded Version After Migration
```gradle
// ❌ Wrong - loses Axion benefits
version = '4.0.16-grails7'

// ✅ Correct - dynamic versioning
version = scmVersion.version
```

---

## Troubleshooting

### "Failed to parse version"
**Error:** `Failed to parse version: v4.0.14`  
**Cause:** Old tags with "v" prefix exist, but Axion configured with `prefix = ''`  
**Fix:** Create new tag with correct format on HEAD commit
```bash
git tag 4.0.19-grails7
git push origin 4.0.19-grails7
```

### "Tag already exists"
**Cause:** Trying to reuse a tag that already points to different commit  
**Fix:** Bump version number
```bash
# Instead of reusing 4.0.18-grails7, create 4.0.19-grails7
git tag 4.0.19-grails7
```

### Build produces wrong version
**Check:** `./gradlew currentVersion -q`  
**Likely cause:** Uncommitted changes or wrong branch  
**Fix:** Commit changes and verify you're on correct branch

---

## Conclusion

The elimination of the "v" prefix represents more than a formatting change—it's a strategic decision to:

1. **Improve reliability** by using standard Maven practices
2. **Reduce complexity** by standardizing across all plugins
3. **Follow conventions** by aligning with Maven ecosystem standards
4. **Enable growth** by preparing for Maven Central publication

This architecture serves Rundeck plugins through the 6.0 release and beyond.
