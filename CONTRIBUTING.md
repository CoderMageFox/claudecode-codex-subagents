# 贡献指南 | Contributing Guide

[English](#english) | [中文](#中文)

---

## 中文

感谢你考虑为 Codex Subagents 做出贡献！我们欢迎所有形式的贡献。

### 如何贡献

#### 报告问题

如果你发现了 bug 或有功能建议：

1. 首先检查 [Issues](https://github.com/CoderMageFox/claudecode-codex-subagents/issues) 确保问题未被报告
2. 创建一个新的 Issue，使用相应的模板
3. 提供尽可能详细的信息：
   - 清晰的标题和描述
   - 重现步骤（针对 bug）
   - 期望行为和实际行为
   - 系统环境信息
   - 相关的日志或截图

#### 提交代码

1. **Fork 仓库**
   ```bash
   git clone https://github.com/你的用户名/claudecode-codex-subagents.git
   cd claudecode-codex-subagents
   ```

2. **创建功能分支**
   ```bash
   git checkout -b feature/你的功能名称
   # 或者
   git checkout -b fix/你的修复名称
   ```

3. **进行修改**
   - 遵循现有的代码风格
   - 更新相关文档
   - 如果添加新功能，请同时更新中英文文档

4. **提交更改**
   ```bash
   git add .
   git commit -m "类型: 简短描述

   详细说明你的更改

   Closes #issue编号（如果适用）"
   ```

   提交类型：
   - `feat`: 新功能
   - `fix`: Bug 修复
   - `docs`: 文档更新
   - `style`: 代码格式（不影响功能）
   - `refactor`: 重构
   - `test`: 测试相关
   - `chore`: 构建过程或辅助工具的变动

5. **推送到你的 Fork**
   ```bash
   git push origin feature/你的功能名称
   ```

6. **创建 Pull Request**
   - 在 GitHub 上创建 PR
   - 填写 PR 模板
   - 等待 review

### 文档贡献

文档改进同样重要：

- 修正拼写或语法错误
- 改进说明的清晰度
- 添加使用示例
- 翻译文档

**注意**：更新文档时请同时更新中英文版本。

### 代码审查流程

1. 维护者会审查你的 PR
2. 可能会要求进行修改
3. 一旦获得批准，你的代码将被合并
4. 你的贡献将在 CHANGELOG 中列出

### 开发规范

#### 文件组织

- 命令文件：`codex-subagents.md`（中文）、`codex-subagents-en.md`（英文）
- 文档文件：`README.md`、`README-en.md`、`README-zh.md`
- 日志目录：`.codex-temp/` (gitignored)

#### 文档风格

- 使用清晰、简洁的语言
- 提供实际的代码示例
- 使用 Markdown 格式
- 保持中英文版本同步

### 行为准则

请阅读并遵守我们的 [行为准则](CODE_OF_CONDUCT.md)。

### 需要帮助？

- 查看 [Issues](https://github.com/CoderMageFox/claudecode-codex-subagents/issues) 寻找 `good first issue` 标签
- 在 Discussions 中提问
- 查看现有的 Pull Requests 了解最佳实践

---

## English

Thank you for considering contributing to Codex Subagents! We welcome all forms of contributions.

### How to Contribute

#### Reporting Issues

If you find a bug or have a feature suggestion:

1. First check [Issues](https://github.com/CoderMageFox/claudecode-codex-subagents/issues) to ensure it hasn't been reported
2. Create a new Issue using the appropriate template
3. Provide as much detail as possible:
   - Clear title and description
   - Steps to reproduce (for bugs)
   - Expected vs actual behavior
   - System environment information
   - Relevant logs or screenshots

#### Submitting Code

1. **Fork the Repository**
   ```bash
   git clone https://github.com/your-username/claudecode-codex-subagents.git
   cd claudecode-codex-subagents
   ```

2. **Create a Feature Branch**
   ```bash
   git checkout -b feature/your-feature-name
   # or
   git checkout -b fix/your-fix-name
   ```

3. **Make Your Changes**
   - Follow existing code style
   - Update relevant documentation
   - If adding new features, update both EN/ZH documentation

4. **Commit Your Changes**
   ```bash
   git add .
   git commit -m "type: brief description

   Detailed explanation of your changes

   Closes #issue-number (if applicable)"
   ```

   Commit types:
   - `feat`: New feature
   - `fix`: Bug fix
   - `docs`: Documentation update
   - `style`: Code formatting (no functional changes)
   - `refactor`: Refactoring
   - `test`: Test related
   - `chore`: Build process or auxiliary tools

5. **Push to Your Fork**
   ```bash
   git push origin feature/your-feature-name
   ```

6. **Create a Pull Request**
   - Create PR on GitHub
   - Fill in the PR template
   - Wait for review

### Documentation Contributions

Documentation improvements are equally important:

- Fix typos or grammar
- Improve clarity of explanations
- Add usage examples
- Translate documentation

**Note**: When updating documentation, please update both EN/ZH versions.

### Code Review Process

1. Maintainers will review your PR
2. Changes may be requested
3. Once approved, your code will be merged
4. Your contribution will be listed in the CHANGELOG

### Development Guidelines

#### File Organization

- Command files: `codex-subagents.md` (Chinese), `codex-subagents-en.md` (English)
- Documentation: `README.md`, `README-en.md`, `README-zh.md`
- Log directory: `.codex-temp/` (gitignored)

#### Documentation Style

- Use clear, concise language
- Provide practical code examples
- Use Markdown formatting
- Keep EN/ZH versions synchronized

### Code of Conduct

Please read and follow our [Code of Conduct](CODE_OF_CONDUCT.md).

### Need Help?

- Look for `good first issue` labels in [Issues](https://github.com/CoderMageFox/claudecode-codex-subagents/issues)
- Ask questions in Discussions
- Check existing Pull Requests for best practices

---

Thank you for contributing! 感谢贡献！
