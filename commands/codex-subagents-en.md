---
name: codex-subagents
description: "Orchestrate complex tasks by delegating to multiple parallel Codex agents, then merge and review results"
category: orchestration
args: task description
---

# Codex Subagents - Codex Agent Orchestration

You are coordinating a complex task by delegating to multiple Codex sub-agents via MCP.

## Your Role

Act as an intelligent orchestrator that:
1. Analyzes the task and breaks it into parallelizable units
2. Delegates to Codex agents via `mcp__codex-subagent__spawn_agents_parallel` (max 3 agents per batch)
3. Chains execution if >3 agents needed, with progress tracking using TodoWrite
4. Logs all subagent activities to `.codex-temp/[timestamp]/[function-name].log`
5. Collects results and intelligently merges them
6. Validates quality through comprehensive checks
7. Reports results with actionable next steps

## Task: $ARGUMENTS

## Process Flow

### Step 0: Ensure .gitignore Setup (5 seconds)

**IMPORTANT: Prevent committing temporary files**

Before starting, ensure the project has proper .gitignore configuration:

```bash
# Check if .gitignore exists
if [ ! -f .gitignore ]; then
  echo "Creating .gitignore to prevent committing temporary files..."
  cat > .gitignore << 'EOF'
# Codex Subagents temporary files
.codex-temp/

# Common temporary files
*.log
.DS_Store
EOF
  echo "✓ Created .gitignore"
else
  # Check if .codex-temp/ is already ignored
  if ! grep -q "\.codex-temp/" .gitignore; then
    echo "Adding .codex-temp/ to .gitignore..."
    echo "" >> .gitignore
    echo "# Codex Subagents temporary files" >> .gitignore
    echo ".codex-temp/" >> .gitignore
    echo "✓ Updated .gitignore"
  fi
fi
```

**Why this matters:**
- `.codex-temp/` contains agent logs and temporary files
- These files are project-specific and should NOT be committed
- Ensures clean git history without temporary artifacts

### Step 1: Task Analysis (30 seconds)
Analyze the task to understand:
- Scope and boundaries
- File dependencies
- Optimal parallelization strategy
- Expected complexity

**Questions to answer:**
- What files/components need changes?
- Are changes independent or dependent?
- What's the optimal agent count?
- What patterns should be followed?

### Step 2: Task Decomposition (1 minute)
Break the task into atomic, parallelizable units using one of these strategies:

**Important Constraints:**
- Maximum 3 agents per batch (to avoid MCP content overflow)
- If >3 agents needed, use chain processing (execute in batches of 3)
- Track all tasks using TodoWrite to show progress
- Log each agent's work to `.codex-temp/[timestamp]/[function-name].log`

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

**Chain Processing**: If >3 agents needed
```yaml
# Example: 7 agents total
batch_1: [agent_1, agent_2, agent_3]  # Execute first
batch_2: [agent_4, agent_5, agent_6]  # Execute after batch_1 completes
batch_3: [agent_7]                     # Execute after batch_2 completes
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

### Step 4: Setup Logging Infrastructure
Before executing agents, prepare the logging system:

**Create logging directory:**
```bash
# Generate timestamp-based directory
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_DIR=".codex-temp/${TIMESTAMP}"
mkdir -p "${LOG_DIR}"
```

**Log file naming convention:**
```
.codex-temp/
  └── 20251107_152300/          # Timestamp-based subdirectory
      ├── user-auth.log         # Function-based naming
      ├── user-profile.log
      ├── api-endpoints.log
      └── frontend-components.log
```

### Step 5: Initialize TodoWrite Progress Tracking
Create a comprehensive todo list showing all tasks (including chain batches):

```markdown
TodoWrite([
  { content: "Execute batch 1: agents 1-3", status: "pending", activeForm: "Executing batch 1" },
  { content: "Agent 1: User authentication", status: "pending", activeForm: "Working on user authentication" },
  { content: "Agent 2: User profile", status: "pending", activeForm: "Working on user profile" },
  { content: "Agent 3: API endpoints", status: "pending", activeForm: "Working on API endpoints" },
  { content: "Execute batch 2: agents 4-6", status: "pending", activeForm: "Executing batch 2" },
  { content: "Agent 4: Frontend components", status: "pending", activeForm: "Working on frontend" },
  { content: "Agent 5: State management", status: "pending", activeForm: "Working on state" },
  { content: "Agent 6: Integration tests", status: "pending", activeForm: "Working on tests" },
  { content: "Merge and validate results", status: "pending", activeForm: "Merging results" }
])
```

### Step 6: Execute Parallel Delegation with Chain Processing
Use chain processing for >3 agents:

**For ≤3 agents (Direct execution):**
```javascript
mcp__codex-subagent__spawn_agents_parallel({
  agents: [
    { prompt: "Agent 1 prompt..." },
    { prompt: "Agent 2 prompt..." },
    { prompt: "Agent 3 prompt..." }
  ]
})
```

**For >3 agents (Chain processing):**
```javascript
// Batch 1 (agents 1-3)
TodoWrite: Mark "Execute batch 1" as in_progress
const batch1_results = await mcp__codex-subagent__spawn_agents_parallel({
  agents: [
    { prompt: "Agent 1 prompt..." },
    { prompt: "Agent 2 prompt..." },
    { prompt: "Agent 3 prompt..." }
  ]
})
// Log results to .codex-temp/[timestamp]/agent-1.log, agent-2.log, agent-3.log
TodoWrite: Mark batch 1 agents as completed, mark "Execute batch 1" as completed

// Display progress update to user
Report: "✅ Batch 1 completed (3/7 agents) - User auth, profile, API done"

// Batch 2 (agents 4-6)
TodoWrite: Mark "Execute batch 2" as in_progress
const batch2_results = await mcp__codex-subagent__spawn_agents_parallel({
  agents: [
    { prompt: "Agent 4 prompt..." },
    { prompt: "Agent 5 prompt..." },
    { prompt: "Agent 6 prompt..." }
  ]
})
// Log results to .codex-temp/[timestamp]/agent-4.log, agent-5.log, agent-6.log
TodoWrite: Mark batch 2 agents as completed, mark "Execute batch 2" as completed

// Display progress update to user
Report: "✅ Batch 2 completed (6/7 agents) - Frontend, state, tests done"

// Batch 3 (agent 7)
TodoWrite: Mark "Execute batch 3" as in_progress
const batch3_results = await mcp__codex-subagent__spawn_agents_parallel({
  agents: [
    { prompt: "Agent 7 prompt..." }
  ]
})
// Log results to .codex-temp/[timestamp]/agent-7.log
TodoWrite: Mark batch 3 agents as completed, mark "Execute batch 3" as completed

// Display final progress
Report: "✅ All batches completed (7/7 agents)"
```

**Logging format for each agent:**
```markdown
=== Agent: [function-name] ===
Start Time: [timestamp]
Task: [description]

--- Prompt ---
[Full prompt sent to agent]

--- Output ---
[Agent's complete output]

--- Files Modified ---
[List of modified files]

--- Status ---
Success: [true/false]
End Time: [timestamp]
Duration: [seconds]

--- Errors (if any) ---
[Error messages]
```

### Step 7: Collect and Analyze Results
After each batch completion, parse agent outputs:
- Extract files modified/created
- Extract test results
- Identify any errors or warnings
- Build file change map to detect conflicts
- Write detailed logs to `.codex-temp/[timestamp]/[agent-name].log`

**Conflict Detection:**
```yaml
conflict_types:
  - file_level: Multiple agents modified same file
  - line_level: Overlapping line ranges
  - semantic: Changes to same function/class
  - dependency: Agent B depends on Agent A's changes
```

### Step 8: Apply Merge Strategy

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

### Step 9: Quality Validation

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

### Step 10: Generate Report

Provide a comprehensive report:

```markdown
# Codex Subagents Orchestration Results

## Summary
- **Task:** [Original task]
- **Agents:** [N] agents executed in [B] batches
- **Duration:** [Total time]
- **Status:** ✅ Success | ⚠️ Partial | ❌ Failed
- **Logs:** `.codex-temp/[timestamp]/` (contains detailed logs for each agent)

## Batch Execution Progress
| Batch | Agents | Status | Duration |
|-------|--------|--------|----------|
| 1     | 1-3    | ✅     | 45s      |
| 2     | 4-6    | ✅     | 38s      |
| 3     | 7      | ✅     | 15s      |

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
- ✅ Limit to 3 agents per batch (chain if >3 needed)
- ✅ Use TodoWrite to track all tasks and batches
- ✅ Log all agent activities to `.codex-temp/[timestamp]/`
- ✅ Update progress after each batch completion
- ✅ Provide clear context to agents
- ✅ Validate incrementally after each batch
- ✅ Document merge decisions
- ✅ Keep checkpoints for rollback

**DON'T:**
- ❌ Execute >3 agents in a single batch
- ❌ Skip progress updates between batches
- ❌ Forget to log agent outputs
- ❌ Create dependencies between parallel agents
- ❌ Skip validation steps
- ❌ Ignore test failures
- ❌ Over-decompose (increases merge complexity)

## Performance Tips

- **Batch size:** Max 3 agents per batch (prevents MCP content overflow)
- **Chain processing:** For >3 agents, execute in sequential batches of 3
- **Progress tracking:** Use TodoWrite to show batch progress to user
- **Logging:** Store all outputs in `.codex-temp/[timestamp]/` for debugging
- **Token efficiency:** Reference files by path, not content
- **Caching:** Reuse project structure analysis across batches
- **Parallel execution:** Run independent operations within each batch

---

**Important Note: Always communicate with users in their preferred language. Adapt your responses based on context.**
