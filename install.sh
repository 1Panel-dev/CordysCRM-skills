#!/bin/bash

# CordysCRM-skills 安装脚本
# 一键安装到 OpenClaw 技能目录
# 使用：bash <(curl -fsSL https://raw.githubusercontent.com/hao65103940/CordysCRM-skills/main/install.sh)

set -e

REPO_URL="https://github.com/hao65103940/CordysCRM-skills"
INSTALL_DIR="$HOME/.openclaw/skills/cordys-crm"
TEMP_DIR="/tmp/cordys-crm-install-$$"
BRANCH="${1:-main}"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

# 打印进度
print_step() {
    echo ""
    echo -e "${BLUE}════════════════════════════════════════${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}════════════════════════════════════════${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_command() {
    echo -e "${BOLD}   $1${NC}"
}

# 清理临时目录
cleanup() {
    if [ -d "$TEMP_DIR" ]; then
        rm -rf "$TEMP_DIR"
    fi
}
trap cleanup EXIT

# 开始
echo ""
echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   CordysCRM-skills 一键安装脚本        ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
echo ""
echo "   分支：$BRANCH"
echo "   目标：$INSTALL_DIR"
echo ""

# 步骤 1：检查依赖
print_step "步骤 1/5：检查系统依赖"

if ! command -v git &> /dev/null; then
    print_error "git 未安装，请先安装 git"
    echo "   Ubuntu/Debian: sudo apt-get install git"
    echo "   CentOS/RHEL:   sudo yum install git"
    echo "   macOS:         brew install git"
    exit 1
fi
print_success "git 已安装"

if ! command -v curl &> /dev/null; then
    print_error "curl 未安装，请先安装 curl"
    exit 1
fi
print_success "curl 已安装"

# 步骤 2：下载脚本
print_step "步骤 2/5：下载安装脚本"

echo "正在从 GitHub 下载..."
if ! curl -fsSL "$REPO_URL/tarball/$BRANCH" -o "$TEMP_DIR.tar.gz" 2>/dev/null; then
    print_error "下载失败，请检查网络连接"
    echo "   仓库地址：$REPO_URL"
    echo "   分支：$BRANCH"
    exit 1
fi
print_success "脚本下载完毕"

# 解压
echo "正在解压文件..."
mkdir -p "$TEMP_DIR"
tar -xzf "$TEMP_DIR.tar.gz" -C "$TEMP_DIR" --strip-components=1
rm -f "$TEMP_DIR.tar.gz"
print_success "文件解压完成"

# 步骤 3：检查目录结构
print_step "步骤 3/5：检查目录结构"

if [ ! -d "$TEMP_DIR/skills" ]; then
    print_error "仓库结构异常：未找到 skills/ 目录"
    echo "   请确认仓库结构正确，或尝试其他分支"
    echo "   当前分支：$BRANCH"
    exit 1
fi
print_success "目录结构检查通过"

# 步骤 4：安装文件
print_step "步骤 4/5：安装技能文件"

# 备份旧版本
if [ -d "$INSTALL_DIR" ]; then
    BACKUP_DIR="$INSTALL_DIR.backup.$(date +%Y%m%d%H%M%S)"
    print_warning "目标目录已存在，备份到：$BACKUP_DIR"
    mv "$INSTALL_DIR" "$BACKUP_DIR"
    print_success "备份完成"
fi

# 复制文件
echo "正在复制文件..."
mkdir -p "$(dirname "$INSTALL_DIR")"
cp -r "$TEMP_DIR/skills" "$INSTALL_DIR"
print_success "文件复制完成"

# 设置权限
echo "正在设置执行权限..."
find "$INSTALL_DIR/bin" -type f -exec chmod +x {} \; 2>/dev/null || true
find "$INSTALL_DIR/scripts" -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true
print_success "权限设置完成"

# 步骤 5：生成配置文件
print_step "步骤 5/5：生成配置指引"

# 复制 .env.example
if [ -f "$INSTALL_DIR/.env.example" ]; then
    cp "$INSTALL_DIR/.env.example" "$INSTALL_DIR/.env.example"
    print_success "环境变量模板已准备"
fi

# 生成下一步指引文件
cat > "$INSTALL_DIR/NEXT-STEPS.txt" << 'EOF'
==========================================
📋 安装完成！接下来这样做：
==========================================

步骤 1：配置环境变量
  cd ~/.openclaw/skills/cordys-crm
  cp .env.example .env
  vim .env

  填写以下内容：
    ACCESS_KEY=你的 AccessKey
    SECRET_KEY=你的 SecretKey
    CRM_DOMAIN=https://你的 crm 域名

步骤 2：测试连接
  cd ~/.openclaw/skills/cordys-crm
  ./bin/cordys crm page lead

  如果返回 JSON 数据，说明配置成功！

步骤 3：配置定时同步（强烈推荐）
  Cordys CRM 字段定义可能更新，定期同步避免查询失败。

  方式 1 - Crontab（推荐）：
    crontab -e
    添加：0 2 * * 0 ~/.openclaw/skills/cordys-crm/scripts/sync-fields.sh >> ~/crm-fields-sync.log 2>&1

  方式 2 - OpenClaw Cron：
    openclaw cron add --file ~/.openclaw/skills/cordys-crm/scripts/openclaw-cron.json

==========================================
📚 文档位置：
  - 使用说明：README.md
  - 技能定义：SKILL.md
  - API 参考：references/crm-api.md
  - 字段同步：rules/platform/sync.md
==========================================
EOF
print_success "配置指引已生成：$INSTALL_DIR/NEXT-STEPS.txt"

# 完成提示
echo ""
echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║           ✅ 安装完成！                ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}📌 下一步：配置环境变量${NC}"
echo ""
echo "请依次执行以下命令："
echo ""
print_command "cd ~/.openclaw/skills/cordys-crm"
print_command "cp .env.example .env"
print_command "vim .env"
echo ""
echo "在 .env 文件中填写以下内容："
echo ""
echo -e "   ${YELLOW}ACCESS_KEY=你的 AccessKey${NC}"
echo -e "   ${YELLOW}SECRET_KEY=你的 SecretKey${NC}"
echo -e "   ${YELLOW}CRM_DOMAIN=https://你的 crm 域名${NC}"
echo ""
echo -e "${BLUE}💡 提示：${NC}"
echo "   1. API 密钥从 Cordys CRM 后台获取（设置 → API 管理）"
echo "   2. 填写完成后保存文件"
echo "   3. 然后告诉我，我帮你测试连接"
echo ""
echo "查看配置指引："
print_command "cat ~/.openclaw/skills/cordys-crm/NEXT-STEPS.txt"
echo ""
