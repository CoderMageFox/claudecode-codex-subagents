# Codex Subagents - Claude Code Plugin

通过并行委托多个 Codex 代理来编排复杂任务，然后合并和审查结果的 Claude Code 插件。

## 功能特点

- 🚀 **并行处理**: 将复杂任务分解为 3-7 个可并行执行的单元
- 🤖 **智能委托**: 通过 MCP 服务器自动委托给多个 Codex 子代理
- 🔄 **智能合并**: 自动检测冲突并应用最佳合并策略
- ✅ **质量验证**: 包含编译、测试、代码质量等多重验证关卡
- 📊 **详细报告**: 生成全面的执行报告和改进建议

## 安装方法

### 方法 1: 手动安装

1. 下载 `codex-subagents.md` 文件
2. 将文件复制到 Claude Code 的命令目录：
   ```bash
   cp codex-subagents.md ~/.claude/commands/
   ```

### 方法 2: Git 克隆

```bash
git clone https://github.com/CoderMageFox/claudecode-codex-subagents.git
cd claudecode-codex-subagents
cp codex-subagents.md ~/.claude/commands/
```

### 方法 3: 使用 curl

```bash
curl -o ~/.claude/commands/codex-subagents.md \
  https://raw.githubusercontent.com/CoderMageFox/claudecode-codex-subagents/main/codex-subagents.md
```

## 前置要求

1. **安装 Claude Code CLI**

   参考 [Claude Code 官方文档](https://docs.claude.com/claude-code)

2. **配置 Codex Subagent MCP Server**

   需要在 Claude Code 中配置 `codex-subagent` MCP 服务器。在 `~/.claude/settings.local.json` 中添加：

   ```json
   {
     "permissions": {
       "allow": [
         "mcp__codex-subagent__spawn_agents_parallel"
       ]
     }
   }
   ```

## 使用方法

### 基本用法

```bash
/codex-subagents <任务描述>
```

### 示例

**示例 1: 创建 React 组件**
```bash
/codex-subagents 创建用户认证系统，包括登录、注册和密码重置功能
```

**示例 2: 重构代码**
```bash
/codex-subagents 将所有 React 类组件迁移到函数组件和 Hooks
```

**示例 3: 添加功能**
```bash
/codex-subagents 为博客系统添加评论、点赞和分享功能
```

## 工作流程

1. **任务分析** (30秒): 理解任务范围和依赖关系
2. **任务分解** (1分钟): 将任务拆分为 3-7 个并行单元
3. **生成提示**: 为每个子代理创建结构化提示
4. **并行执行**: 通过 MCP 服务器并行运行所有子代理
5. **收集结果**: 解析每个代理的输出并检测冲突
6. **应用合并策略**:
   - **直接合并**: 无冲突时
   - **顺序集成**: 有依赖关系时
   - **冲突解决**: 有重叠更改时
   - **增量验证**: 高风险时
7. **质量验证**: 运行编译、lint、类型检查和测试
8. **生成报告**: 提供全面的执行报告

## 任务分解策略

### 基于文件 (File-Based)
独立文件 → 每组文件一个代理
```yaml
agent_1: [UserCard.tsx, UserCard.test.tsx]
agent_2: [ProductCard.tsx, ProductCard.test.tsx]
```

### 基于功能 (Feature-Based)
完整功能 → 每个功能一个代理
```yaml
agent_1: 用户认证 (DB + API + UI + tests)
agent_2: 用户资料 (DB + API + UI + tests)
```

### 基于分层 (Layer-Based)
架构层 → 每层一个代理
```yaml
agent_1: 数据库模型 + 迁移
agent_2: API 端点 + 业务逻辑
agent_3: 前端组件 + 状态
agent_4: 集成测试 + E2E
```

## 质量验证关卡

1. **预合并检查**: 所有代理成功完成，无关键错误
2. **编译检查**: 代码编译/转译成功
3. **静态分析**: Lint、类型检查、格式化
4. **测试检查**: 单元测试、集成测试、E2E 测试
5. **代码质量**: 无调试语句、正确的错误处理、文档更新

## 最佳实践

**应该做的:**
- ✅ 将任务拆分为原子、独立的单元
- ✅ 为代理提供清晰的上下文
- ✅ 增量验证
- ✅ 记录合并决策
- ✅ 保留回滚检查点

**不应该做的:**
- ❌ 在并行代理间创建依赖
- ❌ 跳过验证步骤
- ❌ 忽略测试失败
- ❌ 过度分解任务（增加合并复杂度）

## 性能优化建议

- **最佳代理数**: 3-7（平衡速度与复杂度）
- **令牌效率**: 通过路径引用文件，而非内容
- **缓存**: 重用项目结构分析
- **并行执行**: 尽可能并行运行独立操作

## 故障排除

### 代理执行失败
1. 查看失败详情
2. 使用优化的提示重试一次
3. 如仍失败，标记为需手动完成
4. 继续执行其他代理

### 合并冲突
1. 创建包含上下文的冲突报告
2. 突出显示冲突区域
3. 建议解决策略
4. 请求人工决策

### 测试失败
1. 识别失败的测试
2. 分析是哪个代理导致的失败
3. 回滚特定更改
4. 使用测试上下文重新运行代理

## 贡献

欢迎提交 Issue 和 Pull Request！

## 许可证

MIT License

## 作者

CoderMageFox

## 链接

- [GitHub Repository](https://github.com/CoderMageFox/claudecode-codex-subagents)
- [Claude Code 官方文档](https://docs.claude.com/claude-code)
- [报告问题](https://github.com/CoderMageFox/claudecode-codex-subagents/issues)
