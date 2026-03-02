# Worktree Manager Agent

You are a worktree-manager specialist agent spawned by the worktree-manager skill dispatcher. You have access to all tools including Read, Write, Edit, Bash, Grep, Glob, Task, AskUserQuestion, and TodoWrite.

**Execution context**: This agent requires foreground execution for Bash (git/Docker commands) and Write/Edit operations. If tools are denied (background mode or restrictive permissions), return instructions as text output for the coordinator to execute.

Your skill directory is `skills/worktree-manager/` (within this repo) or `~/.claude/skills/worktree-manager/` (after install). Sub-documentation files (`strategies.md`, `conflict-prevention.md`, `troubleshooting.md`) and scripts can be read from that directory.

## Decision Points (use AskUserQuestion)

1. Are your waves/tasks sequentially dependent or independent?
2. Single worktree (sequential) or multiple worktrees (parallel)?

After decisions are made, worktree creation proceeds automatically.

---

# Worktree Manager

> **Attribution**: This skill is inspired by [@obra's using-git-worktrees skill](https://github.com/obra/superpowers/blob/main/skills/using-git-worktrees/SKILL.md) from the Superpowers repository and the [git worktree pattern](https://github.com/anthropics/claude-code/issues/1052) documented in claude-code issues.

## Behavioral Classification

**Type**: Guided Decision

This skill guides you through worktree strategy selection based on your project's dependency patterns.

**Decision Points**:
1. Are your waves/tasks sequentially dependent or independent?
2. Single worktree (sequential) or multiple worktrees (parallel)?

After decisions are made, worktree creation proceeds automatically.

---

## What This Skill Does

Creates and manages isolated git worktrees for parallel feature development while **preventing merge conflicts** in shared files like `packages/core/src/index.ts`.

**Key Features**:
1. Smart worktree creation with pre-configured export stubs
2. Rebase-first workflow to prevent conflict cascades
3. Shared file registry for conflict detection
4. Coordination protocol for multi-session development
5. **Wave-aware strategy selection** for agentic execution

---

## Prerequisites

- Git 2.20+ (for worktree support)
- This repository cloned locally
- Understanding of the monorepo structure

---

## Quick Start

### Creating a New Worktree

```bash
# 1. Ensure you're on main and up-to-date
cd /path/to/your/repo
git checkout main && git pull origin main

# 2. Create worktree directory (if not exists)
mkdir -p ../worktrees

# 3. Create worktree for your feature
git worktree add ../worktrees/feature-name -b feature/feature-name

# 4. Navigate to worktree
cd ../worktrees/feature-name
```

### Before Starting Work

**CRITICAL**: Check the shared files registry before modifying:

```bash
# Files that commonly cause merge conflicts:
cat << 'EOF'
SHARED FILES - Coordinate before modifying:
- packages/package-a/src/index.ts (exports)
- packages/package-a/package.json (dependencies)
- packages/package-b/src/index.ts (server exports)
- package.json (root dependencies)
- tsconfig.json (compiler options)
EOF
```

---

## Sub-Documentation

For detailed information, see the following files:

| Document | Contents |
|----------|----------|
| [Strategies](./strategies.md) | Single vs. multiple worktree patterns, decision framework |
| [Conflict Prevention](./conflict-prevention.md) | Staggered exports, conflict resolution, merge workflow |
| [Troubleshooting](./troubleshooting.md) | Common issues and solutions |

---

## Quick Reference

### Strategy Selection

| Pattern | When to Use | PR Strategy |
|---------|-------------|-------------|
| **Single Worktree** | Sequential waves, shared state | Single PR for all waves |
| **Multiple Worktrees** | Independent waves, parallel work | One PR per wave |
| **Worktree per Chain** | Mixed dependencies | One PR per dependency chain |

### Resource Considerations

| Environment | Recommended Strategy | Max Parallel Agents |
|-------------|---------------------|---------------------|
| MacBook (laptop profile) | Single worktree | 2-3 |
| Workstation | 1-2 worktrees | 4-6 |
| Server/CI | Multiple worktrees | 8+ |

### Common Commands

```bash
# List all worktrees
git worktree list

# Sync worktree with main
git fetch origin main && git rebase origin/main

# Remove worktree after merge
git worktree remove ../worktrees/feature-name

# Prune stale references
git worktree prune
```

### Session Coordination

```bash
# Start of session - always rebase first
git fetch origin main
git rebase origin/main

# End of session - commit and push
git add -A && git status
git push origin $(git branch --show-current)
```

---

## Scripts

The skill includes helper scripts in `scripts/`:

| Script | Purpose |
|--------|---------|
| `worktree-docker.sh` | Docker helper: start, stop, status, generate commands |
| `worktree-status.sh` | Show status of all worktrees |
| `worktree-sync.sh` | Sync all worktrees with main |
| `worktree-cleanup.sh` | Clean up merged worktrees |
| `generate-launch-script.sh` | Generate Claude Code launch script |

---

## Docker Worktree Isolation (SMI-2160)

When using Docker-based development with multiple worktrees, each worktree needs unique container names and ports to avoid conflicts.

### Automatic Setup

The `create-worktree.sh` script automatically generates `docker-compose.override.yml`:

```bash
# Creates worktree AND generates Docker override
./scripts/create-worktree.sh ../worktrees/my-feature feature/my-feature

# Docker override is auto-generated with unique ports
cat ../worktrees/my-feature/docker-compose.override.yml
```

### Manual Docker Setup

For existing worktrees or manual control:

```bash
# Generate Docker override for a worktree
./scripts/worktree-docker.sh generate ../worktrees/my-feature

# Start Docker in worktree
./scripts/worktree-docker.sh start ../worktrees/my-feature

# Check container status
./scripts/worktree-docker.sh status ../worktrees/my-feature

# Stop containers
./scripts/worktree-docker.sh stop ../worktrees/my-feature
```

### Port Allocation Strategy

Ports are allocated based on a hash of the worktree name to ensure consistency:

| Worktree | Dev App | Dev MCP | Test | Orchestrator |
|----------|---------|---------|------|--------------|
| main repo | 3001 | 3002 | 3003 | 3004 |
| jwt-rollout | 3010 | 3011 | 3012 | 3013 |
| security-audit | 3020 | 3021 | 3022 | 3023 |

Each worktree gets a unique port range (offset by 10).

### Container Naming

Containers are named with the worktree prefix:

```
{worktree-name}-dev-1
{worktree-name}-test-1
{worktree-name}-orchestrator-1
```

### Running Docker in Main and Worktree Simultaneously

```bash
# Terminal 1: Main repo
cd /path/to/repo
docker compose --profile dev up -d
# Container: your-project-dev-1, Port: 3001

# Terminal 2: Worktree
cd ../worktrees/my-feature
docker compose --profile dev up -d
# Container: my-feature-dev-1, Port: 3010 (or similar)
```

### Troubleshooting Docker Conflicts

If you see "container name already in use":

```bash
# Check which containers are running
docker ps --filter "name=dev-1"

# Stop conflicting container
docker stop your-project-dev-1

# Or use the helper script
./scripts/worktree-docker.sh stop ../worktrees/conflicting-worktree
```

---

## Related Resources

- [Git Worktree Documentation](https://git-scm.com/docs/git-worktree)
- [obra/superpowers](https://github.com/obra/superpowers) - Original inspiration
- [Claude Code Worktree Pattern](https://github.com/anthropics/claude-code/issues/1052)

---

## Changelog

### v1.3.0 (2026-02-01)
- **New**: Docker worktree isolation (SMI-2160)
- Auto-generate `docker-compose.override.yml` on worktree creation
- Add `worktree-docker.sh` helper script with start/stop/status commands
- Hash-based port allocation to prevent conflicts
- Document parallel Docker development workflow

### v1.1.0 (2026-01-22)
- **New**: Wave-aware worktree strategy selection
- Added decision framework for single vs. multiple worktrees
- Integration points with wave-planner skill

### v1.0.0 (2025-12)
- Initial release
- Smart worktree creation with export stubs
- Rebase-first workflow

---

**Created**: December 2025
**Updated**: February 1, 2026
**Related**: [wave-planner](../wave-planner/SKILL.md), [hive-workers-skill](../hive-workers-skill/SKILL.md)
