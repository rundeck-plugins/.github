# Merge Conflict Patterns - Grails 7 Migration

**Last Updated:** February 18, 2026

---

## Overview

Common merge conflict patterns encountered during the Grails 7 migration, along with resolution strategies and verification techniques.

---

## Pattern 1: Nested Conflict Markers

### Problem

When pulling/pushing branches, you encounter **nested conflict markers** - conflicts within conflicts:

```groovy
testImplementation "org.mockito:mockito-core"
<<<<<<< HEAD
testImplementation "org.apache.grails:grails-testing-support-web"
testImplementation "cglib:cglib:2.2"
=======
<<<<<<< HEAD
testImplementation "org.apache.grails:grails-testing-support-web"
testImplementation "cglib:cglib:2.2"
=======
testImplementation "org.grails:grails-web-testing-support"
>>>>>>> main
>>>>>>> 29121e268f
```

### Root Cause

Someone previously resolved a merge conflict but didn't remove the conflict markers before committing and pushing. When you try to merge with that remote, Git creates nested markers.

### Resolution

1. **Abort the broken merge:**
   ```bash
   git merge --abort
   ```

2. **Verify your local commit is clean:**
   ```bash
   # Scan entire repo for conflict markers
   git grep -n "^<<<<<<< \|^=======$\|^>>>>>>> "
   ```

3. **If local is clean and remote is broken, force push:**
   ```bash
   git push --force-with-lease origin <branch>
   ```

### Key Lesson

**Never trust `git status` alone for conflict resolution!**

Even when Git says "All conflicts fixed", always verify:
```bash
# Check for leftover headers/markers
git grep "^<<<<<<< \|^=======$\|^>>>>>>> "

# Or in a specific file
grep -n "<<<<<\|>>>>>" path/to/file
```

---

## Pattern 2: Build File Dependency Conflicts

### Problem

Merging `main` into `grails7-upgrade` creates conflicts in `build.gradle` dependency sections:

```groovy
<<<<<<< HEAD
testImplementation "org.apache.grails:grails-testing-support-web"
testImplementation "cglib:cglib:2.2"
=======
testImplementation "org.grails:grails-web-testing-support"
>>>>>>> main
```

### Understanding the Conflict

- **grails7-upgrade branch:** Uses Grails 7 dependency coordinates (`org.apache.grails:*`)
- **main branch:** Uses older dependency coordinates (`org.grails:*`)
- Both are test dependencies for the same functionality

### Resolution Strategy

**Choose the grails7-upgrade version** (not both!):

```groovy
// ✅ Correct - keep grails7-upgrade dependencies
testImplementation "org.apache.grails:grails-testing-support-web"
testImplementation "cglib:cglib:2.2"

// ❌ Wrong - don't keep both
testImplementation "org.apache.grails:grails-testing-support-web"
testImplementation "cglib:cglib:2.2"
testImplementation "org.grails:grails-web-testing-support"  // Missing version, will fail
```

### Why This Matters

- **Keeping both** often causes build failures (missing versions, duplicate functionality)
- **Grails 7 coordinates** are the correct ones for the target platform
- **main branch changes** are often not applicable to grails7-upgrade

### Verification

After resolving, always test:
```bash
./gradlew :grails-repository:compileTestGroovy -x test
```

---

## Pattern 3: "All Conflicts Fixed" But Build Fails

### Symptom

```bash
$ git status
All conflicts fixed but you are still merging.

$ ./gradlew build
FAILURE: Build failed with an exception.
Could not compile build file 'build.gradle'.
> Unexpected input: '{' @ line 53
```

### Root Cause

Conflict markers are still in the file, causing Groovy syntax errors. `git status` only checks that conflict markers aren't *preventing* staging, not that they're completely removed.

### Detection

```bash
# Will show conflict markers even if git status looks clean
grep -n "<<<<<\|>>>>>" build.gradle
```

### Resolution

1. **Remove ALL conflict markers:**
   ```bash
   sed -i '' '/<<<<<<< HEAD/d; /=======/d; />>>>>>> main/d' build.gradle
   ```

2. **Verify removal:**
   ```bash
   git grep "^<<<<<<< \|^=======$\|^>>>>>>> "
   ```

3. **Test the build:**
   ```bash
   ./gradlew build
   ```

4. **Only then commit:**
   ```bash
   git add build.gradle
   git commit
   ```

---

## Pattern 4: Conflicting Grails 7 Dependency Updates

### Problem

Both branches updated dependencies, but to different versions:

```groovy
<<<<<<< HEAD
implementation "org.yaml:snakeyaml:2.0"
=======
implementation "org.yaml:snakeyaml:2.3"
>>>>>>> main
```

### Resolution Strategy

1. **Check which version Grails 7 BOM provides:**
   ```bash
   ./gradlew dependencies | grep snakeyaml
   ```

2. **Use the newer version** (usually safe for patch updates)

3. **Or defer to the BOM** by removing explicit version:
   ```groovy
   implementation "org.yaml:snakeyaml"  // Let Grails BOM manage version
   ```

---

## Comprehensive Verification Checklist

After resolving ANY merge conflict:

### 1. Scan for Markers
```bash
git grep -n "^<<<<<<< \|^=======$\|^>>>>>>> "
# Should return nothing
```

### 2. Check Specific Files
```bash
grep -r "<<<<<\|>>>>>" --include="*.gradle" --include="*.groovy" --include="*.java"
```

### 3. Test Compilation
```bash
./gradlew compileGroovy compileJava compileTestGroovy
```

### 4. Full Build
```bash
./gradlew clean build -x test
```

### 5. Verify Git State
```bash
git status
# Should show "nothing to commit, working tree clean"
```

### 6. Check Diff
```bash
git diff HEAD
# Should show no unexpected changes
```

---

## Force Push Safety

When you have a clean commit and remote has conflict markers:

### Safe Force Push Procedure

1. **Verify local is clean:**
   ```bash
   git grep "^<<<<<<< \|^=======$\|^>>>>>>> "
   ./gradlew build
   ```

2. **Use `--force-with-lease`** (safer than `--force`):
   ```bash
   git push --force-with-lease origin grails7-upgrade
   ```

3. **Verify push succeeded:**
   ```bash
   git status -sb
   # Should show: ## grails7-upgrade...origin/grails7-upgrade
   ```

### When NOT to Force Push

- ❌ Multiple people working on the branch (coordinate first)
- ❌ You're not certain local is cleaner than remote
- ❌ CI/CD is actively running builds against that commit

---

## Prevention Strategies

### 1. Always Verify Before Committing
```bash
# Add to your pre-commit routine:
git grep "<<<<<<< "  # Should find nothing
./gradlew build      # Should pass
```

### 2. Use Automated Checks
Add to `.git/hooks/pre-commit`:
```bash
#!/bin/sh
if git grep -q "^<<<<<<< \|^>>>>>>> "; then
    echo "ERROR: Conflict markers found in repository"
    git grep -n "^<<<<<<< \|^>>>>>>> "
    exit 1
fi
```

### 3. Build Before Push
Always run full build before pushing:
```bash
./gradlew clean build && git push origin grails7-upgrade
```

---

## Real-World Example

### Scenario
Merging `main` into `grails7-upgrade` creates conflicts in `build.gradle`:

### Before Resolution
```groovy
testImplementation "org.mockito:mockito-core"
<<<<<<< HEAD
testImplementation "org.apache.grails:grails-testing-support-web"
testImplementation "cglib:cglib:2.2"
=======
testImplementation "org.grails:grails-web-testing-support"
>>>>>>> main
```

### After Incorrect Resolution
```groovy
// ❌ Kept both - will fail
testImplementation "org.mockito:mockito-core"
testImplementation "org.apache.grails:grails-testing-support-web"
testImplementation "cglib:cglib:2.2"
testImplementation "org.grails:grails-web-testing-support"  // No version!
```

### After Correct Resolution
```groovy
// ✅ Kept grails7-upgrade version only
testImplementation "org.mockito:mockito-core"
testImplementation "org.apache.grails:grails-testing-support-web"
testImplementation "cglib:cglib:2.2"
```

### Verification Steps Taken
```bash
# 1. Removed markers
sed -i '' '/<<<<<<< HEAD/d; /=======/d; />>>>>>> main/d' grails-repository/build.gradle

# 2. Scanned repo
git grep "^<<<<<<< \|^>>>>>>> "  # Found nothing

# 3. Tested build
./gradlew :grails-repository:compileTestGroovy  # PASSED

# 4. Committed
git add grails-repository/build.gradle
git commit -m "Fix merge conflict in test dependencies"

# 5. Pushed
git push origin grails7-upgrade
```

---

## Quick Reference Commands

### Scan for conflict markers
```bash
git grep -n "^<<<<<<< \|^=======$\|^>>>>>>> "
```

### Remove markers (after manual resolution)
```bash
sed -i '' '/<<<<<<< HEAD/d; /=======/d; />>>>>>> main/d' <file>
```

### Verify specific file
```bash
grep -n "<<<<<\|>>>>>" <file>
```

### Test build subsystem
```bash
./gradlew :<module>:compileGroovy
```

### Safe force push
```bash
git push --force-with-lease origin <branch>
```

---

## Summary

Merge conflicts during Grails 7 migration are common but manageable:

1. ✅ **Always scan for markers** - don't trust `git status` alone
2. ✅ **Choose grails7-upgrade versions** - not both
3. ✅ **Test before committing** - builds should pass
4. ✅ **Force push when appropriate** - if your local is cleaner
5. ✅ **Document patterns** - help future engineers avoid same issues
