#!/bin/bash

# Cordys CRM Skill 安装脚本
# 支持两种安装模式：OpenClaw 和 WorkBuddy

set -euo pipefail

REPO_URL="https://github.com/1Panel-dev/CordysCRM-skills"
OPENCLAW_INSTALL_DIR="$HOME/.openclaw/workspace/skills/cordys-crm"
TEMP_DIR="$HOME/.openclaw/workspace/skills"

# 获取最新的 Git 标签
LATEST_TAG=$(curl -s https://api.github.com/repos/1Panel-dev/CordysCRM-skills/releases/latest | jq -r .tag_name 2>/dev/null || echo "")

if [ "${LATEST_TAG:-}" == "null" ] || [ -z "${LATEST_TAG:-}" ]; then
  echo "无法获取最新的版本标签，将使用 main 分支。"
  LATEST_TAG="main"
fi

echo "最新版本：$LATEST_TAG"

# ── OpenClaw 安装 ─────────────────────────────────────────────────
install_openclaw() {
  echo ">> 安装到 OpenClaw..."

  if [ -d "$OPENCLAW_INSTALL_DIR" ]; then
    echo "目标目录已存在，正在删除并覆盖..."
    rm -rf "$OPENCLAW_INSTALL_DIR"
  fi

  echo "正在克隆仓库..."
  git clone --branch "$LATEST_TAG" "$REPO_URL" "$TEMP_DIR"

  if [ ! -d "$TEMP_DIR/skills/cordys-crm" ]; then
    echo "错误：克隆的仓库中没有找到 skills/cordys-crm 目录。"
    exit 1
  fi

  cp -R "$TEMP_DIR/skills/cordys-crm" "$OPENCLAW_INSTALL_DIR"
  rm -rf "$TEMP_DIR"

  echo ""
  echo "✅ OpenClaw 安装完成！"
  echo "   配置：vi $OPENCLAW_INSTALL_DIR/.env"
  echo "   .env 内容："
  echo "     CORDYS_ACCESS_KEY=你的AccessKey"
  echo "     CORDYS_SECRET_KEY=你的SecretKey"
  echo "     CORDYS_CRM_DOMAIN=https://你的域名"
  echo ""
}

# ── WorkBuddy 安装 ─────────────────────────────────────────────────
install_workbuddy() {
  echo ">> 安装到 WorkBuddy..."
  echo "   WorkBuddy 专家通过 .zip 包上架安装。"
  echo "   请将整个 CordysCRM-skills 目录打包为 .zip 提交到专家市场。"
  echo ""
  echo "   打包命令："
  echo "     zip -r cordys-crm.zip CordysCRM-skills/"
  echo ""
  echo "   安装后请在 WorkBuddy 中配置 API 凭据。"
}

# ── 主逻辑 ─────────────────────────────────────────────────────────
if [ "${1:-}" == "--workbuddy" ]; then
  install_workbuddy
else
  install_openclaw
fi
