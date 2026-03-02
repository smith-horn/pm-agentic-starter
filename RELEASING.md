# Release Runbook

Step-by-step process for releasing a new version of product-builder-starter.

## Pre-Release Checklist

1. **Validate frontmatter** — run `./scripts/validate-skills.sh`; fix any errors before proceeding
2. **Audit version drift** — compare bundled skill versions against sources:
   ```bash
   for skill_md in skills/*/SKILL.md; do
     skill=$(basename $(dirname "$skill_md"))
     version=$(grep "^version:" "$skill_md" | head -1)
     echo "$skill: $version"
   done
   # Cross-check against ~/.claude/skills/*/SKILL.md
   ```
3. **Update stale skills** — for any skill behind source: copy updated SKILL.md,
   add missing CHANGELOG entries, bump version
4. **Update root CHANGELOG.md** with new `## [vX.Y.Z] - YYYY-MM-DD` entry
5. **Update README.md** — bump Version column in the skills table

## Release Steps

6. **Create orphan branch** for clean single-commit history:
   ```bash
   git checkout --orphan release-vX.Y.Z
   git add -A
   git commit -m "chore: release vX.Y.Z"
   git branch -D main
   git branch -m main
   git push --force origin main
   ```
7. **Create per-skill tags** using monorepo convention:
   ```bash
   git tag governance/vX.Y.Z
   git tag linear/vX.Y.Z
   # ... one tag per skill with its individual version
   git push --tags
   ```
8. **Create GitHub release**:
   ```bash
   gh release create vX.Y.Z \
     --title "vX.Y.Z — Product Builder Starter Pack" \
     --notes "$(cat CHANGELOG_RELEASE_NOTES.md)"
   ```

## Post-Release

9. Verify all skill tags appear on the GitHub releases/tags page
10. Confirm README renders correctly (Mermaid diagram, skills table)
11. Test install of one skill from the pack in a fresh Claude Code session

## Notes

- The orphan branch technique removes all prior commit history. Use only when
  changing the license or making a major structural change that warrants a clean slate.
  For normal releases, use a regular commit on main instead of step 6's orphan approach.
- Never force-push to main without squashing all changes into a single release commit first.
