#!/bin/bash

# CordysCRM-skills 安装脚本
# 一键安装到 OpenClaw 技能目录

set -e

REPO_URL="https://github.com/hao65103940/CordysCRM-skills"
INSTALL_DIR="$HOME/.openclaw/skills/cordys-crm"
TEMP_DIR="/tmp/cordys-crm-install-$$"

# 获取分支（参数或默认 main）
BRANCH="${1:-main}"

echo "🚀 开始安装 CordysCRM-skills"
echo "   分支：$BRANCH"
echo "   目标：$INSTALL_DIR"
echo ""

# 清理临时目录
rm -rf "$TEMP_DIR"
trap "rm -rf $TEMP_DIR" EXIT

# 克隆仓库
echo "📦 克隆仓库..."
git clone --depth 1 --branch "$BRANCH" "$REPO_URL" "$TEMP_DIR"

# 检查目录结构
if [ ! -d "$TEMP_DIR/skills" ]; then
    echo "❌ 错误：仓库中没有找到 skills/ 目录"
    echo "   请确认仓库结构正确"
    exit 1
fi

echo "✅ 找到 skills/ 目录"

# 如果目标目录已存在，备份
if [ -d "$INSTALL_DIR" ]; then
    BACKUP_DIR="$INSTALL_DIR.backup.$(date +%Y%m%d%H%M%S)"
    echo "⚠️  目标目录已存在，备份到：$BACKUP_DIR"
    mv "$INSTALL_DIR" "$BACKUP_DIR"
fi

# 复制 skills 目录
echo "📋 安装技能文件..."
mkdir -p "$(dirname $INSTALL_DIR)"
cp -r "$TEMP_DIR/skills" "$INSTALL_DIR"

# 设置执行权限
echo "🔧 设置执行权限..."
find "$INSTALL_DIR/bin" -type f -exec chmod +x {} \; 2>/dev/null || true
find "$INSTALL_DIR/scripts" -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true

# 复制 .env.example 到根目录（方便用户配置）
if [ -f "$INSTALL_DIR/.env.example" ]; then
    cp "$INSTALL_DIR/.env.example" "$INSTALL_DIR/.env.example"
fi

# 清理临时目录（trap 自动处理）

# 完成提示
echo ""
echo "=========================================="
echo "✅ 安装完成！"
echo "=========================================="
echo ""
echo "📝 下一步：配置环境变量"
echo ""
echo "   1. 复制环境变量模板："
echo "      cp $INSTALL_DIR/.env.example $INSTALL_DIR/.env"
echo ""
echo "   2. 编辑配置文件："
echo "      vim $INSTALL_DIR/.env"
echo ""
echo "   3. 填写必要信息："
echo "      ACCESS_KEY=你的 AccessKey"
echo "      SECRET_KEY=你的 SecretKey"
echo "      CRM_DOMAIN=https://your-crm-domain.com"
echo ""
echo "🧪 测试连接："
echo ""
echo "   cd $INSTALL_DIR"
echo "   ./bin/cordys crm page lead"
echo ""
echo "   如果返回 JSON 数据，说明配置成功！"
echo ""
echo "📚 文档位置："
echo "   - 使用说明：$INSTALL_DIR/README.md"
echo "   - 技能定义：$INSTALL_DIR/SKILL.md"
echo "   - 最佳实践：$INSTALL_DIR/docs/PAGINATION-BEST-PRACTICE.md"
echo ""
echo "=========================================="
