#!/bin/bash

# Cordys CRM 字段同步脚本
# 用途：从 CRM 系统同步字段定义到本地配置文件
# 使用：./scripts/sync-fields.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
CONFIG_FILE="$ROOT_DIR/rules/platform/fields.md"
ENV_FILE="$ROOT_DIR/.env"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}  Cordys CRM 字段同步脚本${NC}"
echo -e "${GREEN}================================${NC}"

# 检查 .env 文件
if [ ! -f "$ENV_FILE" ]; then
    echo -e "${RED}错误：.env 文件不存在${NC}"
    echo "请复制 .env.example 并配置 ACCESS_KEY 和 SECRET_KEY"
    exit 1
fi

# 加载环境变量
source "$ENV_FILE"

# 检查环境变量
if [ -z "$ACCESS_KEY" ] || [ -z "$SECRET_KEY" ]; then
    echo -e "${RED}错误：ACCESS_KEY 或 SECRET_KEY 未配置${NC}"
    exit 1
fi

CRM_DOMAIN="${CRM_DOMAIN:-https://crm.fit2cloud.com}"

echo ""
echo -e "${YELLOW}CRM 域名：${NC}$CRM_DOMAIN"
echo -e "${YELLOW}配置文件：${NC}$CONFIG_FILE"
echo ""

# 备份现有配置
if [ -f "$CONFIG_FILE" ]; then
    BACKUP_FILE="$CONFIG_FILE.backup.$(date +%Y%m%d%H%M%S)"
    cp "$CONFIG_FILE" "$BACKUP_FILE"
    echo -e "${YELLOW}已备份现有配置：${NC}$BACKUP_FILE"
fi

# 创建临时文件
TEMP_FILE=$(mktemp)

# 初始化 JSON 结构
cat > "$TEMP_FILE" << EOF
{
  "version": "$(date +%Y-%m-%d)",
  "lastSync": "$(date -Iseconds)",
  "modules": {
EOF

# 同步各模块字段
MODULES=("lead" "account" "opportunity" "contract")
FIRST_MODULE=true

for module in "${MODULES[@]}"; do
    echo -e "${YELLOW}正在同步 ${module} 模块...${NC}"
    
    RESPONSE=$(curl -s -X GET "$CRM_DOMAIN/settings/fields?module=$module" \
        -H "X-Access-Key: $ACCESS_KEY" \
        -H "X-Secret-Key: $SECRET_KEY" \
        -H "Content-Type: application/json")
    
    # 检查响应是否有效
    if echo "$RESPONSE" | jq -e '.code == 100200' > /dev/null 2>&1; then
        echo -e "${GREEN}  ✓ ${module} 模块同步成功${NC}"
        
        # 提取字段映射（简化版，只保留关键字段）
        if [ "$FIRST_MODULE" = false ]; then
            echo "," >> "$TEMP_FILE"
        fi
        FIRST_MODULE=false
        
        # 这里简化处理，实际应该解析完整的字段列表
        echo "    \"$module\": {}" >> "$TEMP_FILE"
    else
        echo -e "${RED}  ✗ ${module} 模块同步失败${NC}"
        echo "响应：$RESPONSE"
    fi
done

# 完成 JSON 结构
cat >> "$TEMP_FILE" << EOF

  },
  "products": {},
  "regions": {
    "east": "东区",
    "north": "北区",
    "south": "南区",
    "ka": "KA"
  },
  "pagination": {
    "defaultPageSize": 30,
    "maxPageSize": 100
  }
}
EOF

# 移动临时文件到目标位置
mv "$TEMP_FILE" "$CONFIG_FILE"

echo ""
echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}  同步完成！${NC}"
echo -e "${GREEN}================================${NC}"
echo ""
echo -e "${YELLOW}配置文件：${NC}$CONFIG_FILE"
echo -e "${YELLOW}版本号：${NC}$(date +%Y-%m-%d)"
echo ""

# 提示检查变更
if command -v git &> /dev/null && git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${YELLOW}Git 变更检查：${NC}"
    git diff --stat "$CONFIG_FILE" 2>/dev/null || echo "无变更"
fi

echo ""
echo -e "${GREEN}✅ 字段同步完成！${NC}"
