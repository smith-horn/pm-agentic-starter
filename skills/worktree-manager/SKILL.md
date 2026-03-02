---
name: "Worktree Manager"
version: 2.0.0
description: "Manage git worktrees for parallel development with conflict prevention and wave-aware execution strategy. Use when creating feature branches, starting parallel work sessions, merging worktree PRs, or coordinating multiple Claude sessions."
category: development
tags:
  - git
  - worktree
  - parallel-development
  - branching
  - workflow
author: Smith Horn
triggers:
  keywords:
    - create worktree
    - parallel development
    - worktree strategy
    - single worktree
    - multiple worktrees
  explicit:
    - /worktree
composes:
  - wave-planner
  - hive-workers-skill
  - linear
---

# Worktree Manager

Manage git worktrees for parallel development with conflict prevention and wave-aware execution strategy.

## Execution

When triggered, **immediately**:

1. Read `agent-prompt.md` from this skill's directory (`./agent-prompt.md`)
2. Spawn a single Task with `subagent_type: "general-purpose"` passing the agent-prompt content as the prompt
3. Include in the prompt: the user's request, current working directory, and any arguments passed
4. Wait for the agent to complete
5. Present the agent's summary to the user

Do NOT execute the worktree workflow in this session. The subagent handles everything including strategy selection (AskUserQuestion), worktree creation, and Docker setup.

## Changelog

### v2.0.0
- Refactor: Thin dispatcher pattern — full logic extracted to agent-prompt.md
- Skill runs in isolated subagent context, reducing post-compaction restoration from ~360 lines to ~50 lines

See agent-prompt.md for prior changelog entries.
