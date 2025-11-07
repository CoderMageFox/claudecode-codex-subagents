# Codex Subagents - Claude Code Plugin

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![GitHub Stars](https://img.shields.io/github/stars/CoderMageFox/claudecode-codex-subagents?style=social)](https://github.com/CoderMageFox/claudecode-codex-subagents)
[![GitHub Issues](https://img.shields.io/github/issues/CoderMageFox/claudecode-codex-subagents)](https://github.com/CoderMageFox/claudecode-codex-subagents/issues)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](https://github.com/CoderMageFox/claudecode-codex-subagents/pulls)

中文 | [English](./README-en.md)

通过并行委托多个 Codex 代理来编排复杂任务，然后合并和审查结果的 Claude Code 插件。

## 功能特点

- 🚀 **并行处理**: 将复杂任务分解为可并行执行的单元（每批最多3个代理）
- 🔗 **链式处理**: 超过3个任务时自动进行链式批量处理
- 📊 **实时进度**: 使用 TodoWrite 实时显示任务执行进度
- 📝 **详细日志**: 所有子代理活动记录到 `.codex-temp/[时间戳]/` 目录
- 🤖 **智能委托**: 通过 MCP 服务器自动委托给多个 Codex 子代理
- 🔄 **智能合并**: 自动检测冲突并应用最佳合并策略
- ✅ **质量验证**: 包含编译、测试、代码质量等多重验证关卡

## 快速安装

**一键安装（推荐）：**

```bash
git clone https://github.com/CoderMageFox/claudecode-codex-subagents.git
cd claudecode-codex-subagents
./install.sh
```

**安装脚本会自动完成：**
- ✅ 检测并自动安装缺失的依赖（Python 3, uv, Codex CLI）
- ✅ 安装 Plugin 到 `~/.claude/plugins/`
- ✅ 配置 MCP 服务器（无需手动安装）
- ✅ 自动安装中英文双版本命令
- ✅ 验证安装完整性

**前置要求：**
- Python 3 (macOS 通常自带，脚本会自动检测)
- uv (脚本会提示并自动安装)
- Codex CLI >= 0.46.0 (脚本会提示并自动安装)
- Claude Code CLI

> 💡 **提示**: 如果缺少依赖，安装脚本会自动检测并询问是否安装，无需手动准备！

安装完成后，重启 Claude Code 即可使用。

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
2. **任务分解** (1分钟): 将任务拆分为并行单元（每批最多3个）
3. **初始化日志**: 创建 `.codex-temp/[timestamp]/` 目录用于记录
4. **设置进度跟踪**: 使用 TodoWrite 创建任务列表
5. **链式执行**:
   - 如果 ≤3 个代理：直接并行执行
   - 如果 >3 个代理：分批链式执行（每批3个）
6. **实时进度更新**: 每批完成后更新 TodoWrite 并向用户报告
7. **详细日志记录**: 每个代理的输出记录到独立的日志文件
8. **收集结果**: 解析每个代理的输出并检测冲突
9. **应用合并策略**:
   - **直接合并**: 无冲突时
   - **顺序集成**: 有依赖关系时
   - **冲突解决**: 有重叠更改时
   - **增量验证**: 高风险时
10. **质量验证**: 运行编译、lint、类型检查和测试
11. **生成报告**: 提供全面的执行报告（包含日志目录路径）

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

## 链式处理与日志记录

### 批量处理策略
当任务需要超过3个代理时，系统会自动启用链式处理：

**示例：7个代理的任务**
```yaml
批次 1: [代理 1-3] → 执行并记录日志 → 更新进度 → 向用户报告
批次 2: [代理 4-6] → 执行并记录日志 → 更新进度 → 向用户报告
批次 3: [代理 7]   → 执行并记录日志 → 更新进度 → 向用户报告
```

### 日志目录结构
```
.codex-temp/
  └── 20251107_152300/          # 基于时间戳的子目录
      ├── user-auth.log         # 基于功能的命名
      ├── user-profile.log      # 每个代理一个日志文件
      ├── api-endpoints.log
      └── frontend-components.log
```

### 日志内容格式
每个日志文件包含：
- 代理任务描述
- 完整的提示词
- 代理输出内容
- 修改的文件列表
- 执行状态和时长
- 错误信息（如有）

### 进度跟踪
使用 TodoWrite 实时显示：
- 当前批次执行状态
- 每个代理的完成情况
- 总体任务进度
- 批次间的状态更新

## 质量验证关卡

1. **预合并检查**: 所有代理成功完成，无关键错误
2. **编译检查**: 代码编译/转译成功
3. **静态分析**: Lint、类型检查、格式化
4. **测试检查**: 单元测试、集成测试、E2E 测试
5. **代码质量**: 无调试语句、正确的错误处理、文档更新

## 最佳实践

**应该做的:**
- ✅ 将任务拆分为原子、独立的单元
- ✅ 每批最多3个代理（避免 MCP 内容溢出）
- ✅ 使用 TodoWrite 跟踪所有任务和批次
- ✅ 查看 `.codex-temp/[timestamp]/` 中的详细日志
- ✅ 每批完成后更新进度
- ✅ 为代理提供清晰的上下文
- ✅ 每批后进行增量验证
- ✅ 记录合并决策
- ✅ 保留回滚检查点

**不应该做的:**
- ❌ 单批执行超过3个代理
- ❌ 跳过批次间的进度更新
- ❌ 忘记记录代理输出
- ❌ 在并行代理间创建依赖
- ❌ 跳过验证步骤
- ❌ 忽略测试失败
- ❌ 过度分解任务（增加合并复杂度）

## 性能优化建议

- **批次大小**: 每批最多3个代理（防止 MCP 内容溢出）
- **链式处理**: 超过3个代理时，按批次顺序执行
- **进度跟踪**: 使用 TodoWrite 向用户显示批次进度
- **详细日志**: 将所有输出存储在 `.codex-temp/[timestamp]/` 用于调试
- **令牌效率**: 通过路径引用文件，而非内容
- **缓存复用**: 在批次间重用项目结构分析
- **批内并行**: 在每个批次内并行运行独立操作

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

## 社区与反馈

**微信问题反馈群：**

<div align="center">
  <img src="./assets/wechat-qrcode.jpg" alt="微信问题反馈群" width="200"/>
  <p><em>扫码加入微信群，获取帮助和反馈问题</em></p>
</div>
