---
name: "Hive Workers"
version: "1.0.0"
description: "Execute tasks using hive mind orchestration with parallel agents, automatic code review, and documentation updates. Use for feature execution, epic completion, or complex multi-task work."
category: orchestration
tags:
  - hive-mind
  - orchestration
  - parallel-execution
  - multi-agent
author: Smith Horn
triggers:
  keywords:
    - execute with hive mind
    - run phase with hive mind
    - execute this epic
    - orchestrate these tasks
    - parallel execution with review
  explicit:
    - /hive-workers
composes:
  - governance
  - worktree-manager
  - linear
---

# Hive Workers Skill

Orchestrates complex task execution using claude-flow hive mind with automatic code review and documentation updates.

## Quick Start

```
0. EXPLORE: Search codebase for existing implementations (MANDATORY)
1. Read the task or issue
2. Initialize hive mind: swarm_init({ topology: "hierarchical" })
3. Create todos: TodoWrite with all tasks
4. Execute in parallel where possible
5. Run code review with Task agent
6. Fix any "Must Fix" items
7. Run governance audit
8. Create ADR if architectural decision
9. Update project status
10. Generate sprint report
11. Cleanup: swarm_destroy, mark issues done
```

## Execution

When triggered, **immediately**:

1. Read `agent-prompt.md` from this skill's directory (`./agent-prompt.md`)
2. Spawn a single Task with `subagent_type: "general-purpose"` passing the agent-prompt content as the prompt
3. Include in the prompt: the user's request, current working directory, and any arguments passed
4. Wait for the agent to complete
5. Present the agent's summary to the user

## Sub-Documentation

| Document | Contents |
|----------|----------|
| [agent-prompt.md](agent-prompt.md) | Full execution workflow, phase details, checklists |
| [context-persistence.md](context-persistence.md) | Maintaining context across sessions for long-running tasks |
| [CHEATSHEET.md](CHEATSHEET.md) | Quick reference for common operations |
| [templates/](templates/) | Workflow templates for task execution |

## Related Skills

- [governance](../governance/SKILL.md) - Standards enforcement
- [worktree-manager](../worktree-manager/SKILL.md) - Parallel development

## Prerequisites

- claude-flow configured (`claude mcp add claude-flow -- npx claude-flow@alpha mcp start`)
- Linear MCP (optional, for issue tracking)

For full execution details, see [agent-prompt.md](agent-prompt.md).
