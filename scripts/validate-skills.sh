#!/bin/bash
# Validate all SKILL.md files have required frontmatter fields
set -euo pipefail

ERRORS=0

shopt -s nullglob
skill_files=(skills/*/SKILL.md)
if [[ ${#skill_files[@]} -eq 0 ]]; then
  echo "No SKILL.md files found under skills/. Nothing to validate."
  exit 0
fi

for skill_md in "${skill_files[@]}"; do
  skill=$(basename "$(dirname "$skill_md")")

  for field in name version description; do
    if ! grep -q "^${field}:" "$skill_md"; then
      echo "ERROR: $skill/SKILL.md missing required field: $field"
      ERRORS=$((ERRORS + 1))
    fi
  done

  # Check for duplicate version: keys
  version_count=$(grep -c "^version:" "$skill_md" || true)
  if [[ "$version_count" -gt 1 ]]; then
    echo "ERROR: $skill/SKILL.md has $version_count duplicate 'version:' keys"
    ERRORS=$((ERRORS + 1))
  fi

  # Validate semver format (|| true prevents set -e from firing when version: field is absent)
  version=$(grep "^version:" "$skill_md" | sed 's/version:[[:space:]]*//' | tr -d '"'"'" | tr -d '\r' | head -1 || true)
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

echo "All SKILL.md files pass frontmatter validation (${#skill_files[@]} skills checked)."
