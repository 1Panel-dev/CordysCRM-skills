#!/bin/bash

# 查询各模块支持的全局搜索字段
# 使用：./scripts/get-search-fields.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
ENV_FILE="$ROOT_DIR/.env"

# 颜色输出
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 加载环境变量
if [ -f "$ENV_FILE" ]; then
    set -a
    source "$ENV_FILE"
    set +a
fi

# CRM_DOMAIN 优先级：CRM_DOMAIN > CORDYS_CRM_DOMAIN > 默认值
if [ -n "${CRM_DOMAIN:-}" ]; then
    : # 已设置，保持不变
elif [ -n "${CORDYS_CRM_DOMAIN:-}" ]; then
    CRM_DOMAIN="$CORDYS_CRM_DOMAIN"
else
    CRM_DOMAIN="https://your-crm-domain.com"
fi

ACCESS_KEY="${ACCESS_KEY:-$CORDYS_ACCESS_KEY}"
SECRET_KEY="${SECRET_KEY:-$CORDYS_SECRET_KEY}"

echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}  CRM 全局搜索字段配置${NC}"
echo -e "${GREEN}================================${NC}"
echo ""

# 获取搜索配置
RESPONSE=$(curl -s -X GET "$CRM_DOMAIN/search/config/get" \
    -H "X-Access-Key: $ACCESS_KEY" \
    -H "X-Secret-Key: $SECRET_KEY" \
    -H "Content-Type: application/json")

# 检查响应
if ! echo "$RESPONSE" | jq -e '.code == 100200' > /dev/null 2>&1; then
    echo -e "${RED}请求失败：${NC}$RESPONSE"
    exit 1
fi

# 解析并显示
echo -e "${YELLOW}各模块支持的全局搜索字段：${NC}"
echo ""

echo "$RESPONSE" | jq -r '
.data.searchFields | to_entries[] | 
"### \(.key | sub("^searchAdvanced"; "") | ascii_downcase)

字段 ID: \(.value | join(", "))"
'

echo ""
echo -e "${YELLOW}提示：${NC}"
echo "字段 ID 需要通过 /settings/fields?module={模块} 查询具体字段名"
echo ""
echo -e "${GREEN}示例：${NC}"
echo "  cordys raw GET /settings/fields?module=lead"
echo ""
