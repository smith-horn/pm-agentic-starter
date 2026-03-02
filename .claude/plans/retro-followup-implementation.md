# Retro Follow-up Implementation Plan
# Created: 2026-03-01
# Context: Post-retro action items from product-builder-starter v1.0.0 release session

## What Was Done This Session

The following are **already complete** — do not redo them:

- skill-builder SKILL.md updated to v1.2.0 with three new sections:
  - Step 5.5: version bump + changelog (semver rules table)
  - Versioning & Release: drift audit, frontmatter check, monorepo tag convention
  - Bulk Find & Replace: case-insensitive grep, Edit tool angle bracket gotcha
- skill-builder CHANGELOG.md updated with v1.2.0 entry
- Five Linear issues created in "Skill Friction Reduction" project:
  - SMI-2902: skill_validate enforce version field
  - SMI-2903: skill builder version bump workflow (DONE — docs already updated)
  - SMI-2904: product-builder-starter validate-skills.sh + RELEASING.md
  - SMI-2905: skill registry version drift detection
  - SMI-2906: skill builder bulk rename best practices (DONE — docs already updated)

---

## What Remains To Implement

### Priority 1 — SMI-2904: product-builder-starter artifacts (Low effort, high value)

**Repo**: `github.com/smith-horn/product-builder-starter`
**Local path**: `/Users/williamsmith/Documents/GitHub/Smith-Horn/product-builder-starter`

#### Task A: Create `scripts/validate-skills.sh`

Create a pre-release frontmatter validator at `scripts/validate-skills.sh`:

```bash
#!/bin/bash
# Validate all SKILL.md files have required frontmatter fields
set -euo pipefail

ERRORS=0

for skill_md in skills/*/SKILL.md; do
  skill=$(basename $(dirname "$skill_md"))

  for field in name version description; do
    if ! grep -q "^${field}:" "$skill_md"; then
      echo "ERROR: $skill/SKILL.md missing required field: $field"
      ERRORS=$((ERRORS + 1))
    fi
  done

  # Validate semver format
  version=$(grep "^version:" "$skill_md" | sed "s/version: *//" | tr -d '"'"'" | head -1)
  if [[ -n "$version" ]] && ! echo "$version" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+$'; then
    echo "ERROR: $skill/SKILL.md has invalid semver: $version"
    ERRORS=$((ERRORS + 1))
  fi
done

if [[ $ERRORS -gt 0 ]]; then
  echo ""
  echo "FAILED: $ERRORS frontmatter error(s). Fix before tagging."
  exit 1
fi

echo "All SKILL.md files pass frontmatter validation ($(ls -d skills/*/SKILL.md | wc -l | tr -d ' ') skills checked)."
```

Make executable: `chmod +x scripts/validate-skills.sh`
Test it runs cleanly on the current 11 skills.

#### Task B: Create `RELEASING.md`

Create `RELEASING.md` in the repo root:

```markdown
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
  For normal releases, use a regular commit on main instead of steps 6's orphan approach.
- Never force-push to main without squashing all changes into a single release commit first.
```

#### Task C: Commit and push

```bash
cd /Users/williamsmith/Documents/GitHub/Smith-Horn/product-builder-starter
git add scripts/validate-skills.sh RELEASING.md
git commit -m "chore: add validate-skills.sh and RELEASING.md (SMI-2904)"
git push origin main
```

Then mark SMI-2904 as Done in Linear.

---

### Priority 2 — SMI-2902: skill_validate version enforcement (Medium effort)

**Repo**: `/Users/williamsmith/documents/github/smith-horn/skillsmith`
**Requires**: Docker dev container running (`docker compose --profile dev up -d`)

Find the validation logic:
```bash
grep -r "skill_validate\|validate.*skill\|frontmatter" packages/mcp-server/src/ --include="*.ts" -l
```

Add two validation rules to the frontmatter checker:
1. Missing `version:` field → error (same severity as missing `name:`)
2. `version:` present but not matching `/^\d+\.\d+\.\d+$/` → error with remediation hint

Run tests:
```bash
docker exec skillsmith-dev-1 npm test
docker exec skillsmith-dev-1 npm run lint
```

Mark SMI-2902 Done when tests pass.

---

### Priority 3 — SMI-2905: version drift detection (Larger feature, separate session)

This is a new `skill_updates` MCP tool. Defer to its own wave. Reference SMI-2905 for
full spec including three implementation options (new tool, extend skill_diff, registry flag).

---

## Linear Issue URLs

- SMI-2902: https://linear.app/smith-horn-group/issue/SMI-2902
- SMI-2903: https://linear.app/smith-horn-group/issue/SMI-2903 (already done)
- SMI-2904: https://linear.app/smith-horn-group/issue/SMI-2904
- SMI-2905: https://linear.app/smith-horn-group/issue/SMI-2905
- SMI-2906: https://linear.app/smith-horn-group/issue/SMI-2906 (already done)

## Repo URLs

- product-builder-starter: https://github.com/smith-horn/product-builder-starter
- skillsmith: https://github.com/smith-horn/skillsmith
