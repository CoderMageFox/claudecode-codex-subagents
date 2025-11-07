# Codex Subagents - Claude Code Plugin

[中文](./README-zh.md) | English

A Claude Code plugin for orchestrating complex tasks by delegating to multiple parallel Codex agents, then merging and reviewing results.

## Features

- 🚀 **Parallel Processing**: Break complex tasks into parallelizable units (max 3 agents per batch)
- 🔗 **Chain Processing**: Automatic chain batch processing when >3 tasks are needed
- 📊 **Real-time Progress**: Use TodoWrite to display task execution progress in real-time
- 📝 **Detailed Logging**: All subagent activities logged to `.codex-temp/[timestamp]/` directory
- 🤖 **Intelligent Delegation**: Automatically delegate to multiple Codex subagents via MCP server
- 🔄 **Smart Merging**: Automatically detect conflicts and apply optimal merge strategies
- ✅ **Quality Validation**: Multiple validation gates including compilation, testing, and code quality checks

## Installation

> **Language Selection**:
> - Default version is **Chinese** (`codex-subagents.md`)
> - For English version, install `codex-subagents-en.md`

### Method 1: Manual Installation

**Install English version:**
```bash
cp codex-subagents-en.md ~/.claude/commands/codex-subagents.md
# Or keep both versions
cp codex-subagents-en.md ~/.claude/commands/
```

**Install Chinese version (default):**
```bash
cp codex-subagents.md ~/.claude/commands/
```

### Method 2: Git Clone

**Install English version:**
```bash
git clone https://github.com/CoderMageFox/claudecode-codex-subagents.git
cd claudecode-codex-subagents
cp codex-subagents-en.md ~/.claude/commands/codex-subagents.md
```

**Install Chinese version:**
```bash
git clone https://github.com/CoderMageFox/claudecode-codex-subagents.git
cd claudecode-codex-subagents
cp codex-subagents.md ~/.claude/commands/
```

### Method 3: Using curl

**Install English version:**
```bash
curl -o ~/.claude/commands/codex-subagents.md \
  https://raw.githubusercontent.com/CoderMageFox/claudecode-codex-subagents/main/codex-subagents-en.md
```

**Install Chinese version:**
```bash
curl -o ~/.claude/commands/codex-subagents.md \
  https://raw.githubusercontent.com/CoderMageFox/claudecode-codex-subagents/main/codex-subagents.md
```

## Prerequisites

1. **Install Claude Code CLI**

   Refer to [Claude Code Official Documentation](https://docs.claude.com/claude-code)

2. **Configure Codex Subagent MCP Server**

   You need to configure the `codex-subagent` MCP server in Claude Code. Add to `~/.claude/settings.local.json`:

   ```json
   {
     "permissions": {
       "allow": [
         "mcp__codex-subagent__spawn_agents_parallel"
       ]
     }
   }
   ```

## Usage

### Basic Usage

```bash
/codex-subagents <task description>
```

### Examples

**Example 1: Create React Components**
```bash
/codex-subagents Create a user authentication system with login, registration, and password reset features
```

**Example 2: Refactor Code**
```bash
/codex-subagents Migrate all React class components to function components and Hooks
```

**Example 3: Add Features**
```bash
/codex-subagents Add comments, likes, and sharing features to the blog system
```

## Workflow

1. **Task Analysis** (30 seconds): Understand task scope and dependencies
2. **Task Decomposition** (1 minute): Break task into parallel units (max 3 per batch)
3. **Initialize Logging**: Create `.codex-temp/[timestamp]/` directory for recording
4. **Setup Progress Tracking**: Use TodoWrite to create task list
5. **Chain Execution**:
   - If ≤3 agents: Execute directly in parallel
   - If >3 agents: Execute in batches (3 per batch)
6. **Real-time Progress Updates**: Update TodoWrite and report to user after each batch
7. **Detailed Logging**: Each agent's output recorded to individual log file
8. **Collect Results**: Parse each agent's output and detect conflicts
9. **Apply Merge Strategy**:
   - **Direct Merge**: When no conflicts
   - **Sequential Integration**: When dependencies exist
   - **Conflict Resolution**: When overlapping changes
   - **Incremental Validation**: When high-risk
10. **Quality Validation**: Run compilation, lint, type-check, and tests
11. **Generate Report**: Provide comprehensive execution report (including log directory path)

## Task Decomposition Strategies

### File-Based
Independent files → 1 agent per file group
```yaml
agent_1: [UserCard.tsx, UserCard.test.tsx]
agent_2: [ProductCard.tsx, ProductCard.test.tsx]
```

### Feature-Based
Complete features → 1 agent per feature
```yaml
agent_1: User authentication (DB + API + UI + tests)
agent_2: User profile (DB + API + UI + tests)
```

### Layer-Based
Architectural layers → 1 agent per layer
```yaml
agent_1: Database models + migrations
agent_2: API endpoints + business logic
agent_3: Frontend components + state
agent_4: Integration tests + E2E
```

## Chain Processing & Logging

### Batch Processing Strategy
When tasks require more than 3 agents, the system automatically enables chain processing:

**Example: 7-agent task**
```yaml
Batch 1: [Agents 1-3] → Execute and log → Update progress → Report to user
Batch 2: [Agents 4-6] → Execute and log → Update progress → Report to user
Batch 3: [Agent 7]    → Execute and log → Update progress → Report to user
```

### Log Directory Structure
```
.codex-temp/
  └── 20251107_152300/          # Timestamp-based subdirectory
      ├── user-auth.log         # Function-based naming
      ├── user-profile.log      # One log file per agent
      ├── api-endpoints.log
      └── frontend-components.log
```

### Log Content Format
Each log file contains:
- Agent task description
- Complete prompt
- Agent output
- Modified file list
- Execution status and duration
- Error messages (if any)

### Progress Tracking
Use TodoWrite to display in real-time:
- Current batch execution status
- Each agent's completion status
- Overall task progress
- Status updates between batches

## Quality Validation Gates

1. **Pre-merge Check**: All agents completed successfully, no critical errors
2. **Compilation Check**: Code compiles/transpiles successfully
3. **Static Analysis**: Lint, type-check, formatting
4. **Test Check**: Unit tests, integration tests, E2E tests
5. **Code Quality**: No debug statements, proper error handling, documentation updates

## Best Practices

**DO:**
- ✅ Break tasks into atomic, independent units
- ✅ Max 3 agents per batch (avoid MCP content overflow)
- ✅ Use TodoWrite to track all tasks and batches
- ✅ Check detailed logs in `.codex-temp/[timestamp]/`
- ✅ Update progress after each batch
- ✅ Provide clear context to agents
- ✅ Perform incremental validation after each batch
- ✅ Document merge decisions
- ✅ Keep rollback checkpoints

**DON'T:**
- ❌ Execute >3 agents in a single batch
- ❌ Skip progress updates between batches
- ❌ Forget to log agent outputs
- ❌ Create dependencies between parallel agents
- ❌ Skip validation steps
- ❌ Ignore test failures
- ❌ Over-decompose tasks (increases merge complexity)

## Performance Optimization Tips

- **Batch Size**: Max 3 agents per batch (prevents MCP content overflow)
- **Chain Processing**: For >3 agents, execute in sequential batches of 3
- **Progress Tracking**: Use TodoWrite to show batch progress to user
- **Detailed Logging**: Store all outputs in `.codex-temp/[timestamp]/` for debugging
- **Token Efficiency**: Reference files by path, not content
- **Cache Reuse**: Reuse project structure analysis across batches
- **Batch-internal Parallelism**: Run independent operations in parallel within each batch

## Troubleshooting

### Agent Execution Failure
1. Review failure details
2. Retry once with optimized prompt
3. If still fails, flag for manual completion
4. Continue with other agents

### Merge Conflicts
1. Create conflict report with context
2. Highlight conflict areas
3. Suggest resolution strategies
4. Request human decision

### Test Failures
1. Identify failing tests
2. Analyze which agent caused the failure
3. Rollback specific changes
4. Re-run agent with test context

## Contributing

Issues and Pull Requests are welcome!

## License

MIT License

## Author

CoderMageFox

## Links

- [GitHub Repository](https://github.com/CoderMageFox/claudecode-codex-subagents)
- [Claude Code Official Documentation](https://docs.claude.com/claude-code)
- [Report Issues](https://github.com/CoderMageFox/claudecode-codex-subagents/issues)
