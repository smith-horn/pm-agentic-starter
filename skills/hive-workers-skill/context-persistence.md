# Context Persistence for Long-Running Tasks

Guidelines for maintaining context across sessions during complex, multi-day tasks.

---

## The Problem

Long-running tasks (spanning multiple context windows or sessions) often suffer from:

1. **Context loss** - Claude forgets prior decisions and progress
2. **Duplicate work** - Re-exploring already-understood code
3. **Inconsistent approach** - Different strategies across sessions
4. **Wasted time** - Re-establishing context at session start

---

## Solution: The 3-Layer Persistence Strategy

### Layer 1: Task List (TodoWrite)

**The most important layer.** Use TodoWrite aggressively to track granular progress.

```javascript
// At task start - create ALL tasks upfront
TodoWrite([
  { id: "wave-3a-1", content: "Implement feature A", status: "pending" },
  { id: "wave-3a-2", content: "Implement feature B", status: "pending" },
  { id: "wave-3a-3", content: "Write tests", status: "pending" },
  { id: "wave-3b-1", content: "Code review", status: "pending" },
  // ... all tasks
  { id: "review", content: "Run code review", status: "pending" },
  { id: "document", content: "Create documentation", status: "pending" },
])

// As you work - update status IMMEDIATELY
TodoRead()  // Check current state
// ... complete task ...
TodoWrite([{ id: "wave-3a-1", status: "completed" }])
```

**Rules**:
- Create tasks at START, not as you go
- Update status IMMEDIATELY when done
- Include enough detail for another session to understand
- Check TodoRead() at session start to see where you left off

### Layer 2: Git Checkpoints

Commit frequently with descriptive messages. Each commit is a checkpoint.

```bash
# After each logical unit of work
git add src/feature/
git commit -m "feat(feature): implement core module

- Add X, Y, Z
- Tests passing

Progress: 1/5 tasks complete"
```

**Key**: Include progress indicator in commit message (`Progress: X/Y complete`).

### Layer 3: Session Summaries

At session end, write a brief summary to `.claude/checkpoints/` or in the conversation.

```markdown
## Session Summary: [Feature] (YYYY-MM-DD Session 2)

### Completed
- Wave 1: feature-a, feature-b
- Wave 2: tests

### In Progress
- Wave 2: documentation (50% done)

### Next Steps
1. Complete documentation
2. Run governance audit
3. Create PR

### Decisions Made
- Using relative paths for sub-file links (not absolute)
- Commit after each feature for atomic rollback
- Single PR for all changes

### Blockers
- [Any blockers encountered]
```

---

## Session Continuation Pattern

When continuing a long-running task in a new session:

### Step 1: Read Task State

```javascript
// First action in new session
TodoRead()
```

This shows what's pending, in-progress, and completed.

### Step 2: Check Git State

```bash
git log --oneline -10  # Recent commits
git status             # Any uncommitted work
```

### Step 3: Read Session Summary (if exists)

```bash
cat .claude/checkpoints/summary-*.md | tail -50
```

### Step 4: Resume Work

```javascript
// Find first pending task
TodoWrite([{ id: "wave-3b-3", status: "in_progress" }])
// ... continue work
```

---

## Best Practices

### 1. Granular Tasks Over Coarse Tasks

```javascript
// ❌ BAD: Coarse tasks
TodoWrite([
  { content: "Complete Wave 3" },  // Too big, no progress visibility
])

// ✅ GOOD: Granular tasks
TodoWrite([
  { content: "Wave 3A: feature-builder" },
  { content: "Wave 3A: feature-manager" },
  { content: "Wave 3A: tests" },
  { content: "Wave 3B: code-review" },
  // ... each task is a separate item
])
```

### 2. Commit After Each Logical Unit

```bash
# ❌ BAD: One commit for entire wave
git commit -m "Complete Wave 3"

# ✅ GOOD: One commit per feature
git commit -m "feat: implement feature-builder"
git commit -m "feat: implement feature-manager"
```

### 3. Include Context in Task Descriptions

```javascript
// ❌ BAD: Minimal description
{ content: "Fix the bug" }

// ✅ GOOD: Actionable description
{ content: "Fix type errors in UserService.ts:514 - use createPreview() for v20+ API" }
```

### 4. Mark Decisions in Summaries

When you make a decision, document it:

```markdown
### Decisions Made
- **Path format**: Using relative paths (`./sub-file.md`) not absolute
- **Commit strategy**: One commit per feature for atomic rollback
- **PR strategy**: Single PR for all related changes
```

This prevents re-debating the same decisions in future sessions.

### 5. Use Linear for External Tracking

For multi-day work, update your issue tracker with progress:

```bash
# Add comment to Linear issue via MCP
mcp__linear__create_comment({
  issueId: "issue-uuid",
  body: "Session 2 complete: 6/11 tasks done. Next: feature-c"
})
```

---

## Quick Reference

| Situation | Action |
|-----------|--------|
| Starting long task | Create ALL tasks upfront with TodoWrite |
| Completing a task | Update status to "completed" IMMEDIATELY |
| End of session | Write summary, commit, push |
| Start of new session | TodoRead, check git log, read summary |
| Made a decision | Document in summary under "Decisions Made" |
| Hit a blocker | Document in summary under "Blockers" |
| Task taking multiple sessions | Add progress indicator to task description |

---

## Automated Session Hooks (Optional)

Configure Claude Code hooks to automate session management:

```json
// .claude/settings.json
{
  "hooks": {
    "SessionEnd": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "npx claude-flow hook session-end --export-metrics --generate-summary"
          }
        ]
      }
    ]
  }
}
```

---

**Created**: January 2026
