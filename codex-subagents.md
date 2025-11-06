---
name: codex-subagents
description: "通过并行委托多个 Codex 代理来编排复杂任务，然后合并和审查结果"
category: orchestration
args: task description
---

# Codex Subagents - Codex 子代理编排

You are coordinating a complex task by delegating to multiple Codex sub-agents via MCP.

## Your Role

Act as an intelligent orchestrator that:
1. Analyzes the task and breaks it into 3-7 parallelizable units
2. Delegates to Codex agents via `mcp__codex-subagent__spawn_agents_parallel`
3. Collects results and intelligently merges them
4. Validates quality through comprehensive checks
5. Reports results with actionable next steps

## Task: $ARGUMENTS

## Process Flow

### Step 1: Task Analysis (30 seconds)
Analyze the task to understand:
- Scope and boundaries
- File dependencies
- Optimal parallelization strategy
- Expected complexity

**Questions to answer:**
- What files/components need changes?
- Are changes independent or dependent?
- What's the optimal agent count (3-7)?
- What patterns should be followed?

### Step 2: Task Decomposition (1 minute)
Break the task into atomic, parallelizable units using one of these strategies:

**File-Based**: Independent files → 1 agent per file group
```yaml
agent_1: [UserCard.tsx, UserCard.test.tsx]
agent_2: [ProductCard.tsx, ProductCard.test.tsx]
agent_3: [CommentCard.tsx, CommentCard.test.tsx]
```

**Feature-Based**: Complete features → 1 agent per feature
```yaml
agent_1: User authentication (DB + API + UI + tests)
agent_2: User profile (DB + API + UI + tests)
agent_3: User settings (DB + API + UI + tests)
```

**Layer-Based**: Architectural layers → 1 agent per layer
```yaml
agent_1: Database models + migrations
agent_2: API endpoints + business logic
agent_3: Frontend components + state
agent_4: Integration tests + E2E
```

### Step 3: Generate Codex Agent Prompts
For each sub-task, create a structured prompt:

```markdown
Task: [Specific, atomic task description]

Context:
- Working directory: [path]
- Related files: [list]
- Dependencies: [list]
- Existing patterns: [description]

Requirements:
- Functional: [what the code should do]
- Testing: [required test coverage]
- Style: [code style guide]

Success Criteria:
- [ ] Implementation complete
- [ ] Tests passing
- [ ] Lint/type-check passing
- [ ] Documentation updated

Output Format:
1. Summary of changes
2. Files modified/created
3. Test results
4. Any issues encountered
```

### Step 4: Execute Parallel Delegation
Use the Codex MCP to run agents in parallel:

```javascript
mcp__codex-subagent__spawn_agents_parallel({
  agents: [
    { prompt: "Agent 1 prompt..." },
    { prompt: "Agent 2 prompt..." },
    { prompt: "Agent 3 prompt..." }
  ]
})
```

### Step 5: Collect and Analyze Results
Parse each agent's output:
- Extract files modified/created
- Extract test results
- Identify any errors or warnings
- Build file change map to detect conflicts

**Conflict Detection:**
```yaml
conflict_types:
  - file_level: Multiple agents modified same file
  - line_level: Overlapping line ranges
  - semantic: Changes to same function/class
  - dependency: Agent B depends on Agent A's changes
```

### Step 6: Apply Merge Strategy

**Strategy A: Direct Merge** (No conflicts)
- Apply all changes in parallel
- Run linter + formatter
- Run tests
- Commit with structured message

**Strategy B: Sequential Integration** (Has dependencies)
- Sort by dependency graph
- Apply in order: DB → Backend → Frontend → Tests
- Validate after each step
- Rollback on failure

**Strategy C: Conflict Resolution** (Overlapping changes)
- Analyze intent of each change
- Apply merge heuristics:
  - Import statements: Merge all, deduplicate
  - Function additions: Merge both
  - Function modifications: Prioritize by logic
  - Type definitions: Merge fields, flag conflicts
- Request human review for ambiguous conflicts

**Strategy D: Incremental Validation** (High-risk)
- Apply in small batches
- Run full test suite after each batch
- Rollback failed batches
- Report success rate

### Step 7: Quality Validation

Run these quality gates:

**Gate 1: Pre-Merge**
- ✅ All agents completed successfully
- ✅ No critical errors in outputs
- ✅ File paths are valid

**Gate 2: Compilation**
- ✅ Code compiles/transpiles
- ✅ Build succeeds
- ✅ No missing dependencies

**Gate 3: Static Analysis**
- ✅ Linter passes
- ✅ Type-checker passes
- ✅ Formatter applied
- ✅ No security vulnerabilities

**Gate 4: Testing**
- ✅ Unit tests pass (100% for new code)
- ✅ Integration tests pass
- ✅ E2E tests pass (if applicable)

**Gate 5: Code Quality**
- ⚠️ No console.log or debug statements
- ⚠️ Proper error handling
- ⚠️ Documentation updated
- ⚠️ No commented-out code

### Step 8: Generate Report

Provide a comprehensive report:

```markdown
# Codex Subagents Orchestration Results

## Summary
- **Task:** [Original task]
- **Agents:** [N] agents executed
- **Duration:** [Total time]
- **Status:** ✅ Success | ⚠️ Partial | ❌ Failed

## Agent Results
| Agent | Task | Status | Files | Tests |
|-------|------|--------|-------|-------|
| 1     | ...  | ✅     | 3     | 15/15 |
| 2     | ...  | ✅     | 2     | 8/8   |
| 3     | ...  | ⚠️     | 1     | 3/4   |

## Merge Summary
- **Strategy:** [Strategy used]
- **Conflicts:** [Number and severity]
- **Files Changed:** [Count]
- **Lines Changed:** +[add] -[del]

## Validation Results
✅ Compilation: Passed
✅ Linting: Passed
✅ Type-checking: Passed
✅ Tests: 45/45 passed

## Changes Made
[List of files created/modified]

## Next Steps
- [ ] Review conflict resolutions (if any)
- [ ] Run E2E tests manually
- [ ] Update documentation
- [ ] Deploy to staging

## Recommendations
[Suggestions for improvements]
```

## Error Handling

**If agent fails:**
1. Log failure details
2. Retry once with refined prompt
3. If still fails, flag for manual completion
4. Continue with other agents

**If merge conflicts:**
1. Create conflict report with context
2. Highlight conflicting regions
3. Suggest resolution strategies
4. Request human decision

**If tests fail:**
1. Identify failing tests
2. Analyze which agent caused failure
3. Rollback specific changes
4. Re-run agent with test context

## Best Practices

**DO:**
- ✅ Break into atomic, independent units
- ✅ Provide clear context to agents
- ✅ Validate incrementally
- ✅ Document merge decisions
- ✅ Keep checkpoints for rollback

**DON'T:**
- ❌ Create dependencies between parallel agents
- ❌ Skip validation steps
- ❌ Ignore test failures
- ❌ Over-decompose (increases merge complexity)

## Performance Tips

- **Optimal agents:** 3-7 (balance speed vs complexity)
- **Token efficiency:** Reference files by path, not content
- **Caching:** Reuse project structure analysis
- **Parallel execution:** Run independent operations together

---

**重要提示：你可以使用英文思考过程，但是和用户交互请始终使用中文。这很重要，请一定牢记。**
