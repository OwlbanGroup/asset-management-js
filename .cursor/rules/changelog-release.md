# Changelog & Release Workflow Rule

## Rule ID: cursor-rules/changelog-release
## Priority: Medium

### Description
Follow the project's release procedure to maintain a proper changelog and versioning strategy.

### Guidelines
- Update `package.json` version when releasing new versions (MAJOR.MINOR.PATCH)
- Add new entries to `CHANGELOG.md` under the appropriate version section
- Follow the "Keep a Changelog" format for entries
- Commit changes with message: `Release vX.Y.Z`
- Create git tag: `git tag -a vX.Y.Z -m "Release vX.Y.Z"`
- Push changes and tags: `git push && git push --tags`
- Pre-release versions follow the pattern: `0.6.0-alpha.1`, `0.6.0-beta.1`, `0.6.0-rc.1`
- The CHANGELOG.md has an "Unreleased" section for ongoing work before final release

### Anti-Patterns
- ❌ Skipping version updates in package.json
- ❌ Not adding changelog entries for new features/fixes
- ❌ Committing without proper release messages
- ❌ Forgetting to create and push git tags
- ❌ Mismanaging pre-release version naming

### Example Release Procedure
```bash
# 1. Update version in package.json
# 2. Add new entry to CHANGELOG.md with date
# 3. Commit changes with message: "Release v0.6.0"
# 4. Create git tag: git tag -a v0.6.0 -m "Release v0.6.0"
# 5. Push: git push && git push --tags
```