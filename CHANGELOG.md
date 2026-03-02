# Changelog

All notable changes to this project are documented here.

Format: [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)

---

## [1.0.0] — 2026-03-01

Initial public release of the Product Builder Starter Pack.

**11 Claude Code skills for product builders shipping with agentic AI.**

Copyright 2026 Smith Horn Group Ltd. — Apache 2.0

---

### Skills

#### `governance` v1.4.0

Code review, retrospectives, and zero-deferral standards enforcement.

- **v1.4.0** (2026-01-28): Zero Deferral Policy — all code review findings fixed immediately; removed Linear ticket creation for deferred issues; all severities require immediate fix
- **v1.3.0** (2026-01-27): `edge-function-test.md` subskill; `/edge-test` command; `vi.hoisted()` pattern for Deno mocks
- **v1.2.0** (2026-01-24): Split templates into sub-docs; `code-review-template.md`; `retro-template.md`
- **v1.1.0** (2026-01-24): Enhanced code review report template; structured YAML frontmatter triggers; `/governance`, `/review`, `/retro` commands
- **v1.0.0** (2025-12): Initial release — code review workflow, severity guide, pre-commit checklist

---

#### `plan-review-skill` v2.0.0

Multi-perspective plan review — VP Product, VP Engineering, VP Design.

- **v2.0.0**: Thin dispatcher pattern — full logic extracted to `agent-prompt.md`; isolated subagent context
- **v1.0.0**: Initial release — three VP perspectives, blocker detection, anti-pattern identification

---

#### `launchpad` v1.2.0

End-to-end orchestrator: plan → review → Linear issues → execute.

- **v1.2.0** (2026-02-19): MISSING/OK skill classification with explicit consent gate for optional skills; explicit AskUserQuestion consent gate for Stage 4
- **v1.1.0** (2026-02-18): Stage 0 infra detection routing; `sparc-methodology` as Stage 1a; `--infra` / `--feature` override flags
- **v1.0.0**: Initial release — 4-stage pipeline, interruptible stage gates, resume detection, skill existence checks

---

#### `wave-planner` v2.0.0

Break Linear projects into waves with token estimates and agent assignments.

- **v2.0.0**: Thin dispatcher pattern — full logic extracted to `agent-prompt.md`
- **v1.7.0** (2026-01-28): Implementation Verification phase (MANDATORY) — check if issues are already implemented before wave planning
- **v1.6.0** (2026-01-28): Test file size estimation; heuristics for unit/integration/E2E line counts; split recommendations for files >400 lines
- **v1.5.0** (2026-01-23): Dependency Upgrade Waves section; Inter-Wave Preflight; atomic commit pattern
- **v1.4.0** (2026-01-23): Decompose into sub-files (execution.md, preflight.md, reference.md)
- **v1.3.0** (2026-01-23): Artifact Discovery phase (MANDATORY) — check for existing plans before creating
- **v1.2.0** (2026-01-21): Pre-Flight Checks; Automated Code Review Trigger; Wave Completion Checklist
- **v1.1.0** (2026-01-21): Risk Analysis phase — predict blockers, auto-generate mitigations
- **v1.0.0** (2026-01-21): Initial release — Linear adapter, dynamic token estimation, TDD workflow, hive mind config generation

---

#### `hive-workers-skill` v1.0.0

Execute waves using claude-flow multi-agent swarms.

- **v1.0.0** (2026-03): Initial public release — 11-step execution workflow, claude-flow MCP integration, governance audit, context persistence

---

#### `worktree-manager` v2.0.0

Parallel git worktrees with Docker isolation and conflict prevention.

- **v2.0.0**: Thin dispatcher pattern — full logic extracted to `agent-prompt.md`
- **v1.3.0** (2026-02-01): Docker worktree isolation; `worktree-docker.sh` helper; hash-based port allocation; parallel Docker development workflow
- **v1.1.0** (2026-01-22): Wave-aware worktree strategy selection; decision framework for single vs. multiple worktrees
- **v1.0.0** (2025-12): Initial release — smart worktree creation, rebase-first workflow, shared file conflict registry

---

#### `linear` v2.2.3

Issue, project, and initiative management via MCP or CLI.

- **v2.2.3** (2026-02-10): Varlock environment schema; replace all hardcoded `~/.claude/skills/linear` paths with relative paths
- **v2.2.0** (2026-01-24): Add semantic-release for automated versioning
- **v2.1.1** (2026-01-24): CI/CD GitHub Actions; TypeScript fixes for Linear SDK v68
- **v2.1.0** (2026-01-23): `Linear-specialist` subagent for parallel bulk operations
- **v2.0.0** (2026-01-18): Restructured for Claude Code skill discovery; all files at root level
- **v1.7.0** (2026-01-16): Domain-based label taxonomy; `labels validate/suggest/agents` commands
- **v1.6.0** (2026-01-11): `project-status`, `link-initiative`, `unlink-initiative` commands
- **v1.5.0** (2025-12-28): Migrate to official Linear MCP server at `mcp.linear.app`
- **v1.4.0** (2025-12-26): First-time setup script; `linear-ops.ts` high-level CLI
- **v1.0.0** (2025-12-20): Initial release — MCP integration, GraphQL API fallback, SDK automation

---

#### `varlock` v1.0.0

Secrets management — no API keys in terminal output.

- **v1.0.0** (2025-12): Initial release — security rules, `.env.schema` type annotations, `varlock load` / `varlock run` patterns, CI/CD and Docker integration

---

#### `docker` v1.1.0

Container-first development environment baseline.

- **v1.1.0** (2026-01-23): Decompose into sub-files; `setup.md` for first-time setup; `health-checks.md` for monitoring
- **v1.0.0** (2025-01): Initial release — Docker-first enforcement, container architecture, troubleshooting guide

---

#### `session-cleanup` v1.2.0

End-of-session git hygiene and housekeeping.

- **v1.2.0** (2026-02): Pre-dispatch clean-check; two-dot diff gate; `--no-verify` consent rule; abort-gracefully on user cancel
- **v1.1.0** (2026-01): Thin dispatcher pattern; cherry-pick to main for docs-only commits; worktree cleanup phase; squash-merge artifact filtering
- **v1.0.0** (2025-12): Initial release — five-phase workflow, guided decision pattern, remote sync

---

#### `claude-md-optimizer` v1.1.1

Progressive disclosure for oversized CLAUDE.md files.

- **v1.1.1** (2026-02-13): Pattern 8 (Terse Agent Hint) — compress multi-line code blocks into single-line command references
- **v1.1.0** (2026-01-27): CI Machine-Readable Content detection; force-classify Essential rule for CI-scanned content
- **v1.0.0** (2026-01-25): Initial release — 7 progressive disclosure patterns, 6-phase guided workflow, encryption-aware extraction, zero information loss validation

---

[1.0.0]: https://github.com/smith-horn/product-builder-starter/releases/tag/v1.0.0
