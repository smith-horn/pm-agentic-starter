# Worktree Manager Troubleshooting

Common issues and their solutions.

---

## Worktree Creation Issues

### Issue: "fatal: 'path' is already checked out"

**Cause**: Trying to create worktree for branch that's already checked out
**Solution**:
```bash
# Check where it's checked out
git worktree list

# Either use that worktree or create new branch
git worktree add ../worktrees/new-name -b new-branch-name
```

### Issue: Cannot delete branch used by worktree

**Cause**: Branch is still associated with a worktree
**Solution**:
```bash
# Remove the worktree first
git worktree remove ../worktrees/feature-name

# Then delete the branch
git branch -d feature-name
```

### Issue: Stale worktree references

**Cause**: Worktree directory was deleted manually
**Solution**:
```bash
git worktree prune
```

---

## Merge Conflict Issues

### Issue: Massive conflicts in index.ts

**Cause**: Didn't use staggered exports strategy
**Solution**: Use cherry-pick recovery:

```bash
# 1. Note your unique commits
git log --oneline origin/main..HEAD

# 2. Create clean branch from current main
git checkout main && git pull
git checkout -b phase-2c-feature-clean

# 3. Cherry-pick your commits
git cherry-pick <commit1> <commit2>

# 4. Resolve conflicts during cherry-pick
# Then create new PR from clean branch
```

---

## Docker Issues

### Issue: "current working directory is outside of container mount namespace root"

**Cause**: Docker exec inherits the host's current directory, which doesn't exist in the container when running from a worktree
**Solution**: Always use `-w /app` flag with docker exec

```bash
# From a worktree directory, this will fail:
docker exec <project>-dev-1 npm test  # ERROR

# Use -w /app to specify the container working directory:
docker exec -w /app <project>-dev-1 npm test  # WORKS
```

**Note**: If your project uses git hooks (pre-push, pre-push-check.sh), update them to include `-w /app` automatically.

### Issue: Docker changes not visible in worktree

**Cause**: Docker container mounted from main repo path, not worktree path
**Solution**:
```bash
# Check current mounts
docker inspect <project>-dev-1 | grep -A5 '"Source"'

# Restart Docker from worktree directory
cd ../worktrees/my-feature
docker compose --profile dev down
docker compose --profile dev up -d
```

### Issue: Docker lint/typecheck verifies main repo, not worktree

**Cause**: Docker container mounts the main repo at `/app`, so `docker exec <project>-dev-1 npm run lint` checks main repo files, not your worktree changes.

**Solution**: Use the worktree-check script for local verification:

```bash
# Run lint/typecheck directly in worktree (no Docker needed)
./scripts/worktree-check.sh ../worktrees/my-feature

# Or from within the worktree
cd ../worktrees/my-feature
../../scripts/worktree-check.sh
```

**Note**: Lint, typecheck, and format checks don't require native modules, so they can run locally without Docker. For tests that need native modules (better-sqlite3, onnxruntime), push the branch and verify in CI.

**What the script runs**:
1. `npx tsc --noEmit` - TypeScript type checking
2. `npx eslint . --max-warnings 0` - Linting
3. `npx prettier --check ...` - Format checking

### Issue: Container won't start in worktree

**Cause**: Port conflicts with main repo container or missing volumes
**Solution**:
```bash
# Stop containers in main repo
cd /path/to/main/repo
docker compose --profile dev down

# Start in worktree
cd ../worktrees/my-feature
docker compose --profile dev up -d
```

---

## Claude Code Issues

### Issue: "requires valid session ID" when launching

**Cause**: Using `claude --resume` with a prompt instead of session ID
**Solution**:

**WRONG**:
```bash
claude --resume "Execute task..."  # --resume expects a UUID!
```

**CORRECT**:
```bash
cat << 'PROMPT'
================================================================================
SMI-XXX: Task Title
================================================================================
[Task details...]
================================================================================
PROMPT

claude
```

### Issue: Claude doesn't see files in worktree

**Cause**: Claude launched from wrong directory
**Solution**:
```bash
# Ensure you're in the worktree
cd ../worktrees/my-feature
pwd  # Verify path

# Then launch Claude
claude
```

---

## Session Coordination Issues

### Issue: Conflicting changes from parallel sessions

**Cause**: Sessions not rebasing before pushing
**Solution**:
```bash
# Always rebase before pushing
git fetch origin main
git rebase origin/main

# Then push
git push origin $(git branch --show-current)
```

### Issue: Session can't push due to diverged history

**Cause**: Another session pushed while you were working
**Solution**:
```bash
# Fetch and rebase
git fetch origin main
git rebase origin/main

# Resolve any conflicts
git add -A
git rebase --continue

# Push with force-with-lease (safer than --force)
git push --force-with-lease origin $(git branch --show-current)
```

---

## Performance Issues

### Issue: System running slow with multiple worktrees

**Cause**: Too many parallel agents consuming resources
**Solution**:
1. Check memory usage: `htop` or Activity Monitor
2. Reduce number of worktrees/agents
3. Use single worktree pattern for sequential work
4. Reference resource guidelines:

| Environment | Max Worktrees | Max Agents |
|-------------|---------------|------------|
| MacBook | 1 | 2-3 |
| Workstation | 1-2 | 4-6 |
| Server | Multiple | 8+ |

### Issue: Disk space low

**Cause**: Many worktrees with large node_modules
**Solution**:
```bash
# Remove completed worktrees
git worktree remove ../worktrees/completed-feature

# Prune stale references
git worktree prune

# Clean Docker if needed
docker system prune -a
```

---

## Quick Diagnostics

### Check Worktree Health

```bash
# List all worktrees and their status
git worktree list

# Check for stale references
git worktree prune --dry-run

# Verify current worktree
echo "Current directory: $(pwd)"
echo "Git root: $(git rev-parse --show-toplevel)"
echo "Current branch: $(git branch --show-current)"
```

### Check Docker Health

```bash
# List containers
docker ps --filter name=dev-1

# Check container health
docker inspect <project>-dev-1 --format='{{.State.Health.Status}}'

# Check mounts
docker inspect <project>-dev-1 | grep -A5 '"Source"'
```
