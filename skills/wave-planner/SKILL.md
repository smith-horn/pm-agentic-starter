---
name: wave-planner
version: 2.0.0
description: Transform project issues into execution-ready implementation plans with risk prediction, wave-based organization, specialist agents, and TDD workflow
author: William Smith
triggers:
  keywords:
    - plan the work
    - break this down
    - create waves
    - implementation plan
    - plan the implementation
    - organize into waves
    - sprint planning
    - wave structure
  explicit:
    - /wave-planner
    - /plan
tools:
  - Read
  - Task
composes:
  - linear
  - hive-workers-skill
  - governance
---

# Wave Planner

Transform project issues into execution-ready implementation plans with wave-based organization, specialist agent assignments, token estimates, and TDD workflow.

## Execution

When triggered, **immediately**:

1. Read `./agent-prompt.md`
2. Spawn a single Task with `subagent_type: "general-purpose"` passing the agent-prompt content as the prompt
3. Include in the prompt: the user's request, current working directory, and any arguments passed
4. Wait for the agent to complete
5. Present the agent's summary to the user

Do NOT execute the planning workflow in this session. The subagent handles everything including user interaction (AskUserQuestion), artifact generation, and Linear queries.

## Execution Context Requirements

This skill spawns a general-purpose subagent that performs file write operations (implementation plans, ADRs, hive configs).

**Foreground execution required**: Yes. Background execution auto-denies unapproved Write/Edit tools, causing silent failures when creating artifacts.

**Required tools**: Read, Write, Edit, Bash, Grep, Glob, Task, AskUserQuestion, TodoWrite

**Fallback**: If Write/Edit tools are denied, the subagent returns the plan content as text output for the coordinator to write to disk.

**Reference**: [Subagent Tool Permissions Research](https://code.claude.com/docs/en/sub-agents)

## Changelog

### v2.0.0
- Refactor: Thin dispatcher pattern — full logic extracted to agent-prompt.md
- Skill runs in isolated subagent context, reducing post-compaction restoration from ~400 lines to ~50 lines

See agent-prompt.md for prior changelog entries.
