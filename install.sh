#!/bin/bash

# Codex Subagents Plugin - 一键安装脚本
# 自动安装 Plugin 和 MCP 服务器

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  Codex Subagents Plugin 一键安装${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# 检查必要的命令
check_command() {
    if ! command -v $1 &> /dev/null; then
        echo -e "${RED}✗ 错误: 未找到 $1 命令${NC}"
        echo -e "${YELLOW}  请先安装 $1${NC}"
        exit 1
    fi
}

echo -e "${YELLOW}[1/5] 检查依赖...${NC}"
check_command "node"
check_command "npm"
echo -e "${GREEN}✓ 依赖检查通过${NC}"
echo ""

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
PLUGINS_DIR="$CLAUDE_DIR/plugins"
MCP_SETTINGS="$CLAUDE_DIR/mcp_settings.json"

# 创建必要的目录
echo -e "${YELLOW}[2/5] 创建目录结构...${NC}"
mkdir -p "$PLUGINS_DIR"
echo -e "${GREEN}✓ 目录创建完成${NC}"
echo ""

# 安装 Plugin（符号链接）
echo -e "${YELLOW}[3/5] 安装 Plugin...${NC}"
if [ -L "$PLUGINS_DIR/codex-subagents" ]; then
    echo -e "${YELLOW}  已存在安装，删除旧版本...${NC}"
    rm -f "$PLUGINS_DIR/codex-subagents"
fi
ln -s "$SCRIPT_DIR" "$PLUGINS_DIR/codex-subagents"
echo -e "${GREEN}✓ Plugin 已安装到: $PLUGINS_DIR/codex-subagents${NC}"
echo ""

# 配置 MCP 服务器
echo -e "${YELLOW}[4/5] 配置 MCP 服务器...${NC}"

# 读取或创建 mcp_settings.json
if [ -f "$MCP_SETTINGS" ]; then
    echo -e "${YELLOW}  已存在 mcp_settings.json，更新配置...${NC}"

    # 使用 node 合并 JSON
    node -e '
    const fs = require("fs");
    const existing = JSON.parse(fs.readFileSync("'"$MCP_SETTINGS"'", "utf8"));

    if (!existing.mcpServers) {
        existing.mcpServers = {};
    }

    existing.mcpServers["codex-subagent"] = {
        "command": "npx",
        "args": ["-y", "codex-as-mcp@latest"],
        "transport": "stdio"
    };

    fs.writeFileSync("'"$MCP_SETTINGS"'", JSON.stringify(existing, null, 2));
    '
else
    echo -e "${YELLOW}  创建新的 mcp_settings.json...${NC}"
    cat > "$MCP_SETTINGS" << 'EOF'
{
  "mcpServers": {
    "codex-subagent": {
      "command": "npx",
      "args": ["-y", "codex-as-mcp@latest"],
      "transport": "stdio"
    }
  }
}
EOF
fi

echo -e "${GREEN}✓ MCP 服务器配置完成${NC}"
echo ""

# 验证安装
echo -e "${YELLOW}[5/5] 验证安装...${NC}"

# 检查 Plugin 结构
if [ -f "$PLUGINS_DIR/codex-subagents/.claude-plugin/plugin.json" ]; then
    echo -e "${GREEN}✓ Plugin 结构正确${NC}"
else
    echo -e "${RED}✗ Plugin 结构异常${NC}"
    exit 1
fi

# 检查命令文件
if [ -f "$PLUGINS_DIR/codex-subagents/commands/codex-subagents.md" ]; then
    echo -e "${GREEN}✓ 命令文件存在${NC}"
else
    echo -e "${RED}✗ 命令文件缺失${NC}"
    exit 1
fi

# 检查 MCP 配置
if grep -q "codex-subagent" "$MCP_SETTINGS"; then
    echo -e "${GREEN}✓ MCP 服务器已配置${NC}"
else
    echo -e "${RED}✗ MCP 配置异常${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ 安装完成！${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${YELLOW}📦 安装位置：${NC}"
echo -e "   Plugin: $PLUGINS_DIR/codex-subagents"
echo -e "   MCP配置: $MCP_SETTINGS"
echo ""
echo -e "${YELLOW}🎯 使用方法：${NC}"
echo -e "   ${GREEN}/codex-subagents${NC} <任务描述>     # 中文版"
echo -e "   ${GREEN}/codex-subagents-en${NC} <任务描述>  # 英文版"
echo ""
echo -e "${YELLOW}💡 提示：${NC}"
echo -e "   - MCP 服务器使用 npx 自动运行，无需手动安装"
echo -e "   - 首次使用时会自动下载必要的依赖"
echo -e "   - 重启 Claude Code 以加载 Plugin"
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
