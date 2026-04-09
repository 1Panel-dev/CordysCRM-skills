#!/bin/bash

# Cordys CRM 字段同步脚本
# 用途：从 CRM 系统同步字段定义到 Markdown 文件
# 使用：./scripts/sync-fields.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
OUTPUT_FILE="$ROOT_DIR/rules/platform/fields.md"
ENV_FILE="$ROOT_DIR/.env"
TEMP_DIR=$(mktemp -d)

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

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

# 检查环境变量（支持两种格式）
ACCESS_KEY="${ACCESS_KEY:-$CORDYS_ACCESS_KEY}"
SECRET_KEY="${SECRET_KEY:-$CORDYS_SECRET_KEY}"

# CRM_DOMAIN 优先用 CRM_DOMAIN，其次 CORDYS_CRM_DOMAIN，最后默认值
if [ -n "$CRM_DOMAIN" ]; then
    CRM_DOMAIN="$CRM_DOMAIN"
elif [ -n "$CORDYS_CRM_DOMAIN" ]; then
    CRM_DOMAIN="$CORDYS_CRM_DOMAIN"
else
    CRM_DOMAIN="https://your-crm-domain.com"
fi

if [ -z "$ACCESS_KEY" ] || [ -z "$SECRET_KEY" ]; then
    echo -e "${RED}错误：ACCESS_KEY 或 SECRET_KEY 未配置${NC}"
    exit 1
fi

echo ""
echo -e "${YELLOW}CRM 域名：${NC}$CRM_DOMAIN"
echo -e "${YELLOW}输出文件：${NC}$OUTPUT_FILE"
echo ""

# 备份现有文件
if [ -f "$OUTPUT_FILE" ]; then
    BACKUP_FILE="$OUTPUT_FILE.backup.$(date +%Y%m%d%H%M%S)"
    cp "$OUTPUT_FILE" "$BACKUP_FILE"
    echo -e "${YELLOW}已备份现有文件：${NC}$BACKUP_FILE"
fi

# 通用请求函数
fetch_option_map() {
    local module=$1
    local output_file=$2
    
    curl -s -X POST "$CRM_DOMAIN/$module/page" \
        -H "X-Access-Key: $ACCESS_KEY" \
        -H "X-Secret-Key: $SECRET_KEY" \
        -H "Content-Type: application/json" \
        -d '{"current":1,"pageSize":1}' | jq '.data.optionMap' > "$output_file"
}

# 写入 Markdown 头部
cat > "$OUTPUT_FILE" << 'EOF'
# Cordys CRM 字段映射表

> 最后更新：
EOF
echo "$(date +%Y-%m-%d)" >> "$OUTPUT_FILE"
cat >> "$OUTPUT_FILE" << 'EOF'
> 用途：将字段 ID 转换为可读的字段名和选项值

---

## 📌 说明

本文件由同步脚本自动生成，包含 CRM 系统各模块的字段定义和选项值映射。

**同步命令：**
```bash
./scripts/sync-fields.sh
```

---

EOF

# 同步各模块字段
MODULES=("lead" "account" "opportunity" "contract")
MODULE_NAMES=("线索" "客户" "商机" "合同")

for i in "${!MODULES[@]}"; do
    module="${MODULES[$i]}"
    module_name="${MODULE_NAMES[$i]}"
    
    echo -e "${YELLOW}正在同步 ${module_name} (${module}) 模块...${NC}"
    
    OPTION_FILE="$TEMP_DIR/${module}_option.json"
    
    if fetch_option_map "$module" "$OPTION_FILE"; then
        echo -e "${GREEN}  ✓ ${module} 模块同步成功${NC}"
        
        # 解析 optionMap 并生成 Markdown
        echo "## ${module_name} ($module)" >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
        
        # 提取所有字段
        jq -r 'to_entries[] | "### \(.key)\n\n\(.value | if type == "array" then "| ID | 名称 |\n|-----|------|\n" + (.[] | "| \(.id) | \(.name) |") else . end)\n"' "$OPTION_FILE" >> "$OUTPUT_FILE" 2>/dev/null || true
        
        echo "---" >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
    else
        echo -e "${RED}  ✗ ${module} 模块同步失败${NC}"
    fi
done

# 写入尾部说明
cat >> "$OUTPUT_FILE" << 'EOF'
## 📝 注意事项

1. **时间戳格式**：所有时间字段都是毫秒级时间戳 (JavaScript 格式)
2. **字段 ID**：自定义字段必须使用字段 ID，不能用字段名
3. **选项值**：下拉框字段存储的是选项 ID，不是显示名称
4. **金额单位**：所有金额字段单位是**元**（不是万元）

---

## 🔧 手动获取字段

```bash
# 获取线索字段
cordys crm page lead '{"current":1,"pageSize":1}' | jq '.data.optionMap'

# 获取客户字段
cordys crm page account '{"current":1,"pageSize":1}' | jq '.data.optionMap'

# 获取商机字段
cordys crm page opportunity '{"current":1,"pageSize":1}' | jq '.data.optionMap'
```
EOF

# 清理临时文件
rm -rf "$TEMP_DIR"

echo ""
echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}  同步完成！${NC}"
echo -e "${GREEN}================================${NC}"
echo ""
echo -e "${YELLOW}输出文件：${NC}$OUTPUT_FILE"
echo -e "${YELLOW}更新时间：${NC}$(date +%Y-%m-%d)"
echo ""

# 提示检查变更
if command -v git &> /dev/null && git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${YELLOW}Git 变更检查：${NC}"
    git diff --stat "$OUTPUT_FILE" 2>/dev/null || echo "无变更"
fi

echo ""
echo -e "${GREEN}✅ 字段同步完成！${NC}"
