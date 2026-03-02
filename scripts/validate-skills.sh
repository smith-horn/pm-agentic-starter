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
