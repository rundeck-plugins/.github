# Common Grails 7 Migration Issues

**Last Updated:** February 18, 2026

---

## Netty Version Conflicts

### Problem
```
java.lang.ClassNotFoundException: io.netty.channel.nio.NioIoHandler
```

### Root Cause
- Micronaut 4.9+ requires Netty 5.x (4.2.x series)
- Forced Netty to 4.1.x for CVE fixes
- `NioIoHandler` only exists in Netty 5.x

### Solution
Remove Netty version forcing and trust the framework BOM:

**Before:**
```gradle
configurations.all {
    resolutionStrategy {
        eachDependency { details ->
            if (details.requested.group == 'io.netty') {
                details.useVersion '4.1.129.Final'
            }
        }
    }
}
```

**After:**
```gradle
// Trust Micronaut Platform BOM for Netty versions
// Micronaut 4.9.2 provides Netty 4.2.7.Final which includes CVE fixes
```

### Verification
```bash
./gradlew dependencies --configuration runtimeClasspath | grep netty
# All modules should show same version (e.g., 4.2.7.Final)
```

---

## Axion Version Parsing Failures

### Problem
```
Failed to parse version: v4.0.14
expecting '[DIGIT]'
```

### Root Cause
- Axion configured with `prefix = ''` (no "v")
- Old tags exist with "v" prefix
- Axion tries to parse "v4.0.14" expecting digit, finds "v"

### Solution
Create new tag with correct format on current HEAD:

```bash
# Check existing tags
git tag -l | sort -V | tail -5

# Create new tag with correct format (no "v")
git tag 4.0.19-grails7
git push origin 4.0.19-grails7

# Build should now work
./gradlew currentVersion -q
# Output: 4.0.19-grails7
```

### Prevention
Use consistent tag format from the start - no "v" prefix.

---

## Groovy Compilation Errors After Merge

### Problem
```
Could not compile build file 'build.gradle'
Unexpected input: '{' @ line 53, column 14
```

### Root Cause
Conflict markers still in file, breaking Groovy syntax:

```groovy
dependencies {  // Line 53
<<<<<<< HEAD
    implementation "library:1.0"
=======
    implementation "library:2.0"
>>>>>>> main
```

### Solution

1. **Find the markers:**
   ```bash
   grep -n "<<<<<\|>>>>>" build.gradle
   ```

2. **Remove them:**
   ```bash
   sed -i '' '/<<<<<<< HEAD/d; /=======/d; />>>>>>> main/d' build.gradle
   ```

3. **Choose which version to keep** (edit file manually)

4. **Test:**
   ```bash
   ./gradlew compileGroovy
   ```

---

## Test Dependency Duplication

### Problem
Build fails with:
```
Could not find org.grails:grails-web-testing-support:.
```

### Root Cause
During merge conflict resolution, kept BOTH dependency versions:
```groovy
testImplementation "org.apache.grails:grails-testing-support-web"  // Has version
testImplementation "org.grails:grails-web-testing-support"          // No version!
```

### Solution
**Keep only one version** - preferably the one that includes version in its declaration or matches your target framework.

For Grails 7, keep the `org.apache.grails:*` coordinates:
```groovy
testImplementation "org.apache.grails:grails-testing-support-web"
testImplementation "cglib:cglib:2.2"
// Removed: org.grails:grails-web-testing-support
```

---

## Plugin ZIP-to-JAR Migration

### Background
Some plugins migrated from ZIP packaging to JAR packaging for Grails 7.

### Issue
Legacy code may expect `.zip` files but receive `.jar` files with ZIP contents (ZIP-as-JAR).

### Solution
Ensure plugin scanners handle both extensions:

```java
// Accept both .zip and .jar files
if (file.getName().endsWith(".zip") || file.getName().endsWith(".jar")) {
    // Check if it's a ZIP plugin (has plugin.yaml, not compiled classes)
    if (isZipPlugin(file)) {
        processScriptPlugin(file);
    }
}
```

### Verification
```bash
# Check that JAR doesn't have Rundeck-Plugin-Classnames manifest entry
unzip -p plugin.jar META-INF/MANIFEST.MF | grep Rundeck-Plugin-Classnames
# Should return nothing for ZIP-as-JAR plugins
```

---

## Missing Test Tasks for ZIP Plugins

### Problem
```
Task 'test' not found in root project 'kubernetes'
```

### Root Cause
ZIP plugins (script-based) don't have Java test tasks.

### Solution
Build without test:
```bash
./gradlew clean build -x test
```

Or check plugin type first:
```bash
# If plugin has src/test/java or src/test/groovy
./gradlew clean build test

# If plugin only has resources/plugin.yaml
./gradlew clean build
```

---

## Git Submodule Merge Conflicts

### Problem
Parent repo references submodule commit, submodule itself has conflicts.

### Resolution Order
1. **Fix submodule conflicts first**
2. **Commit and push submodule**
3. **Update parent repo submodule reference**
4. **Commit and push parent repo**

### Commands
```bash
# In submodule
cd path/to/submodule
git checkout grails7-upgrade
# ... resolve conflicts ...
git commit -m "Fix conflicts"
git push origin grails7-upgrade

# In parent
cd ..
git add path/to/submodule
git commit -m "Update submodule to <commit-hash>"
git push origin grails7-upgrade
```

---

## Quick Reference

### Conflict Marker Scan
```bash
git grep -n "^<<<<<<< \|^=======$\|^>>>>>>> "
```

### Remove Markers (After Manual Resolution)
```bash
sed -i '' '/<<<<<<< HEAD/d; /=======/d; />>>>>>> main/d' <file>
```

### Test Build
```bash
./gradlew clean build -x test
```

### Force Push (When Local is Clean)
```bash
git push --force-with-lease origin grails7-upgrade
```

### Verify All Plugin Repos
```bash
for dir in */; do
    cd "$dir"
    echo "=== $(basename $PWD) ==="
    git status -sb 2>/dev/null || echo "Not a git repo"
    cd ..
done
```

---

## Best Practices

### 1. Small, Focused Merges
- Merge `main` → `grails7-upgrade` regularly
- Don't let branches diverge too far
- Smaller merges = simpler conflicts

### 2. Test Immediately After Resolution
```bash
# Always run this sequence:
git add <resolved-files>
./gradlew build
git commit
```

### 3. Document Unusual Resolutions
If you make a non-obvious choice during conflict resolution, add a comment:
```groovy
// Kept grails7-upgrade version - main's version incompatible with Grails 7
testImplementation "org.apache.grails:grails-testing-support-web"
```

### 4. Scan Before Pushing
```bash
# Pre-push checklist:
git grep "<<<<<<< "     # Should find nothing
./gradlew clean build   # Should pass
git status              # Should be clean
git push
```

---

## When to Seek Help

If you encounter:
- ✋ Conflicts in 10+ files
- ✋ Conflicts in core framework configuration
- ✋ Repeated conflicts in same files across multiple merge attempts
- ✋ Build fails after conflict resolution but no markers found

Don't struggle alone - these indicate deeper architectural conflicts that may need team discussion.
