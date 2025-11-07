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

# 检查依赖并记录缺失项
MISSING_DEPS=()

check_dependency() {
    if ! command -v $1 &> /dev/null; then
        MISSING_DEPS+=("$1")
        echo -e "${RED}✗ 未找到: $1${NC}"
        return 1
    else
        echo -e "${GREEN}✓ 已安装: $1${NC}"
        return 0
    fi
}

echo -e "${YELLOW}[1/6] 检查依赖...${NC}"
check_dependency "python3"
check_dependency "uvx"
check_dependency "codex"
echo ""

# 如果有缺失的依赖，提供安装指引
if [ ${#MISSING_DEPS[@]} -gt 0 ]; then
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${RED}  发现缺失的依赖${NC}"
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    for dep in "${MISSING_DEPS[@]}"; do
        case $dep in
            python3)
                echo -e "${YELLOW}📦 Python 3${NC}"
                echo -e "   将自动查找已安装的 Python 3 版本"
                echo -e "   如未找到，请使用 Homebrew 安装:"
                echo -e "   ${GREEN}brew install python3${NC}"
                echo ""
                ;;
            uvx)
                echo -e "${YELLOW}📦 uv (Python 包管理器)${NC}"
                echo -e "   将自动安装 uv"
                echo ""
                ;;
            codex)
                echo -e "${YELLOW}📦 Codex CLI${NC}"
                echo -e "   将自动安装 Codex CLI"
                echo -e "   需要 npm (Node.js 包管理器)"
                echo ""
                ;;
        esac
    done

    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}是否自动安装缺失的依赖? (y/n)${NC}"
    read -r response

    if [[ "$response" =~ ^[Yy]$ ]]; then
        echo ""
        echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${BLUE}  开始自动安装依赖${NC}"
        echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""

        INSTALL_SUCCESS=true
        NEED_CODEX_LOGIN=false

        for dep in "${MISSING_DEPS[@]}"; do
            case $dep in
                python3)
                    echo -e "${YELLOW}[Python 3] 检测中...${NC}"
                    # 尝试查找 Python 3
                    if command -v python3.11 &> /dev/null; then
                        echo -e "${GREEN}✓ 找到 Python 3.11${NC}"
                        ln -sf $(which python3.11) /usr/local/bin/python3 2>/dev/null || true
                    elif command -v python3.10 &> /dev/null; then
                        echo -e "${GREEN}✓ 找到 Python 3.10${NC}"
                        ln -sf $(which python3.10) /usr/local/bin/python3 2>/dev/null || true
                    elif command -v python3.9 &> /dev/null; then
                        echo -e "${GREEN}✓ 找到 Python 3.9${NC}"
                        ln -sf $(which python3.9) /usr/local/bin/python3 2>/dev/null || true
                    else
                        echo -e "${RED}✗ 未找到任何 Python 3 版本${NC}"
                        echo -e "${YELLOW}请使用 Homebrew 安装:${NC}"
                        echo -e "${GREEN}brew install python3${NC}"
                        INSTALL_SUCCESS=false
                    fi
                    echo ""
                    ;;
                uvx)
                    echo -e "${YELLOW}[uv] 正在安装...${NC}"
                    if curl -LsSf https://astral.sh/uv/install.sh | sh; then
                        # 重新加载环境变量
                        export PATH="$HOME/.local/bin:$PATH"

                        # 验证安装
                        if command -v uvx &> /dev/null; then
                            UVX_VERSION=$(uvx --version 2>&1 | head -1)
                            echo -e "${GREEN}✓ uv 安装成功: $UVX_VERSION${NC}"
                        else
                            echo -e "${YELLOW}⚠ uv 已安装但未在 PATH 中${NC}"
                            echo -e "${YELLOW}请运行: ${GREEN}source ~/.bashrc${NC} 或 ${GREEN}source ~/.zshrc${NC}"
                            echo -e "${YELLOW}然后重新运行此脚本${NC}"
                            INSTALL_SUCCESS=false
                        fi
                    else
                        echo -e "${RED}✗ uv 安装失败${NC}"
                        INSTALL_SUCCESS=false
                    fi
                    echo ""
                    ;;
                codex)
                    echo -e "${YELLOW}[Codex CLI] 正在安装...${NC}"

                    # 检查是否有 npm
                    if ! command -v npm &> /dev/null; then
                        echo -e "${RED}✗ 未找到 npm${NC}"
                        echo -e "${YELLOW}请先安装 Node.js:${NC}"
                        echo -e "${GREEN}brew install node${NC}"
                        INSTALL_SUCCESS=false
                    else
                        if npm install -g @openai/codex@latest; then
                            if command -v codex &> /dev/null; then
                                CODEX_VERSION=$(codex --version 2>&1 | head -1)
                                echo -e "${GREEN}✓ Codex CLI 安装成功: $CODEX_VERSION${NC}"
                                NEED_CODEX_LOGIN=true
                            else
                                echo -e "${RED}✗ Codex CLI 安装失败${NC}"
                                INSTALL_SUCCESS=false
                            fi
                        else
                            echo -e "${RED}✗ Codex CLI 安装失败${NC}"
                            INSTALL_SUCCESS=false
                        fi
                    fi
                    echo ""
                    ;;
            esac
        done

        echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

        if [ "$INSTALL_SUCCESS" = true ]; then
            echo -e "${GREEN}✅ 所有依赖安装成功！${NC}"
            echo ""

            if [ "$NEED_CODEX_LOGIN" = true ]; then
                echo -e "${YELLOW}⚠️  重要提示：${NC}"
                echo -e "${YELLOW}请先运行以下命令登录 Codex CLI:${NC}"
                echo -e "${GREEN}codex login${NC}"
                echo ""
                echo -e "${YELLOW}登录完成后，本脚本将继续安装...${NC}"
                echo ""
                read -p "按 Enter 键继续..."
            fi

            echo -e "${BLUE}继续 Plugin 安装流程...${NC}"
            echo ""
        else
            echo -e "${RED}❌ 部分依赖安装失败${NC}"
            echo -e "${YELLOW}请根据上述提示手动安装失败的依赖，然后重新运行此脚本${NC}"
            exit 1
        fi
    else
        echo ""
        echo -e "${RED}安装已取消${NC}"
        echo -e "${YELLOW}请手动安装以上依赖后重新运行此脚本${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}✓ 所有依赖检查通过${NC}"
    echo ""
fi

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
PLUGINS_DIR="$CLAUDE_DIR/plugins"
MCP_SETTINGS="$CLAUDE_DIR/mcp_settings.json"

# 创建必要的目录
echo -e "${YELLOW}[2/6] 创建目录结构...${NC}"
mkdir -p "$PLUGINS_DIR"
echo -e "${GREEN}✓ 目录创建完成${NC}"
echo ""

# 安装 Plugin（符号链接）
echo -e "${YELLOW}[3/6] 安装 Plugin...${NC}"
if [ -L "$PLUGINS_DIR/codex-subagents" ]; then
    echo -e "${YELLOW}  已存在安装，删除旧版本...${NC}"
    rm -f "$PLUGINS_DIR/codex-subagents"
fi
ln -s "$SCRIPT_DIR" "$PLUGINS_DIR/codex-subagents"
echo -e "${GREEN}✓ Plugin 已安装到: $PLUGINS_DIR/codex-subagents${NC}"
echo ""

# 同时复制命令到全局 commands 目录以确保直接可用
echo -e "${YELLOW}[3.5/5] 安装命令到全局目录...${NC}"
COMMANDS_DIR="$CLAUDE_DIR/commands"
mkdir -p "$COMMANDS_DIR"

# 复制命令文件
cp "$SCRIPT_DIR/commands/codex-subagents.md" "$COMMANDS_DIR/"
cp "$SCRIPT_DIR/commands/codex-subagents-en.md" "$COMMANDS_DIR/"
echo -e "${GREEN}✓ 命令已复制到: $COMMANDS_DIR${NC}"
echo ""

# 配置 MCP 服务器
echo -e "${YELLOW}[4/6] 配置 MCP 服务器...${NC}"

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
        "command": "uvx",
        "args": ["codex-as-mcp@latest"],
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
      "command": "uvx",
      "args": ["codex-as-mcp@latest"],
      "transport": "stdio"
    }
  }
}
EOF
fi

echo -e "${GREEN}✓ MCP 服务器配置完成${NC}"
echo ""

# 验证安装
echo -e "${YELLOW}[5/6] 验证安装...${NC}"

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
echo -e "   - MCP 服务器使用 uvx 自动运行 (基于 Python)"
echo -e "   - 首次使用时会自动下载 codex-as-mcp 依赖"
echo -e "   - 确保 Codex CLI 已登录: ${GREEN}codex login${NC}"
echo -e "   - 重启 Claude Code 以加载 Plugin"
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
