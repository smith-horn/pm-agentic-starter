---
name: Launchpad
version: 1.2.0
description: "End-to-end planning and execution orchestrator. Chains SPARC or wave-planner (Stage 1), plan-review, linear, and hive-workers-skill into a single workflow. Automatically routes infra changes through SPARC research instead of wave-planner. Use when starting a new initiative, executing a set of Linear issues, or running plan-to-deployment."
author: wrsmith108
triggers:
  keywords:
    - launchpad
    - plan and execute
    - end to end
    - full workflow
    - plan to execution
    - run the initiative
  explicit:
    - /launchpad
tools:
  - Read
  - Task
  - AskUserQuestion
composes:
  - sparc-methodology
  - wave-planner
  - plan-review
  - linear
  - hive-workers-skill
---

# Launchpad

End-to-end orchestrator that chains SPARC or wave-planner (Stage 1), plan-review (Stage 2), linear (Stage 3), and hive-workers-skill (Stage 4) into a single interruptible workflow.

**Stage 1 routing (ADR-109)**:
- **Infra changes** (Docker, CI, entrypoints, hooks, dev tooling) → SPARC researcher + architect → `docs/internal/implementation/{slug}.md`
- **Feature work** (application code, new endpoints, UI) → wave-planner → hive-mind YAML configs

## Execution

When triggered, **immediately**:

1. Read `./agent-prompt.md`
2. Spawn a single Task with `subagent_type: "general-purpose"` passing the agent-prompt content as the prompt
3. Include in the prompt: the user's request (issue IDs, project name, or description), current working directory, and any flags (`--from`, `--skip-review`, `--fresh`, `--infra`, `--feature`)
4. Wait for the agent to complete
5. Present the agent's summary to the user

Do NOT execute the workflow in this session. The subagent handles all stage sequencing, gate prompts, resume detection, and skill dispatching.

## Execution Context Requirements

This skill spawns a general-purpose subagent that coordinates stages via nested Task dispatches.

**Foreground execution required**: Yes. Interactive stage gates use AskUserQuestion which auto-denies in background mode.

**Dispatcher tools** (frontmatter): Read, Task, AskUserQuestion
**Subagent tools**: Read, Write, Edit, Bash, Grep, Glob, Task, AskUserQuestion, TodoWrite

**Reference**: [Subagent Tool Permissions](https://code.claude.com/docs/en/sub-agents)

## Sub-Documentation

| Document | Contents |
|----------|----------|
| [agent-prompt.md](agent-prompt.md) | Full coordinator logic: input parsing, Stage 0 infra detection, stage routing, resume detection, error handling |

## Related Skills

| Skill | Role |
|-------|------|
| [sparc-methodology](../sparc-methodology/SKILL.md) | Stage 1a (infra): SPARC researcher + architect → implementation plan |
| [wave-planner](../wave-planner/SKILL.md) | Stage 1b (feature): Generate wave plan + hive configs |
| [plan-review-skill](../plan-review-skill/SKILL.md) | Stage 2: VP review of plan (both paths) |
| [linear](../linear/SKILL.md) | Stage 3: Create Linear project + issues |
| [hive-workers-skill](../hive-workers-skill/SKILL.md) | Stage 4: Execute waves via claude-flow swarm |

## Infra Trigger Criteria (ADR-109)

Stage 1a (SPARC) is selected when scope includes any of:
- `docker-entrypoint.sh`, `Dockerfile`, `docker-compose.yml`
- `.github/workflows/*.yml`
- `.husky/*`, `pre-commit`, `pre-push` hook scripts
- `scripts/` files called by Docker/CI/hooks
- `package.json` `scripts` block changes
- Dev tooling config: `.eslintrc`, `vitest.config.ts`, `turbo.json`

Stage 1b (wave-planner) for everything else. Mixed scope → use Stage 1a.

Override with flags: `--infra` forces Stage 1a, `--feature` forces Stage 1b.

## Changelog

### v1.2.0 (2026-02-19)
- Section 2: Add MISSING/OK skill classification with explicit consent gate for optional skills
- Section 7: Replace silent Stage 4 fallback with explicit AskUserQuestion consent gate

### v1.1.0 (2026-02-18)
- Add Stage 0 infra detection routing (ADR-109)
- Add `sparc-methodology` to `composes` as Stage 1a for infra changes
- Add `--infra` / `--feature` override flags
- Update description and Related Skills table

### v1.0.0
- Initial release: 4-stage pipeline (Plan, Review, Issues, Execute)
- Interruptible stage gates with standardized 5-option prompts
- Resume detection via multi-signal artifact checks
- Skill existence checks with graceful fallbacks
