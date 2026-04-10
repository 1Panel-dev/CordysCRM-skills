# 常见查询场景（飞致云）

> 飞致云常见的 CRM 查询场景和关联查询逻辑

---

## 原则：能单模块就不关联

**✅ 优先单模块查询：**

```bash
# 查东区商机（商机有自己的区域字段）
cordys crm page opportunity '{
  "combineSearch":{"conditions":[{"value":["东区"],"operator":"IN","name":"1751888184000030"}]}
}'
```

---

## 必须关联的场景

### 场景 1：查 XX 行业客户的商机

**原因：** 商机无行业字段，需通过客户关联

**步骤：**
```bash
# 步骤 1: 查政务行业客户，拿 customerId 列表
CUSTOMER_IDS=$(cordys crm page account '{
  "combineSearch":{"conditions":[{"value":["政府和军工"],"operator":"IN","name":"1751888184000005"}]}
}' | jq -r '.data.list[].id')

# 步骤 2: 转 JSON 数组
IDS_JSON=$(echo "$CUSTOMER_IDS" | jq -R . | jq -s .)

# 步骤 3: 查商机（默认查已成交 SUCCESS 阶段）
cordys crm page opportunity "{
  \"combineSearch\": {
    \"conditions\": [
      {\"value\": $IDS_JSON, \"operator\": \"IN\", \"name\": \"customerId\"},
      {\"value\": [\"SUCCESS\"], \"operator\": \"IN\", \"name\": \"stage\"}
    ]
  }
}"
```

### 场景 2：查 XX 省市的商机

**原因：** 商机无省市字段，需通过客户关联

**步骤：**
```bash
# 步骤 1: 查浙江省客户
CUSTOMER_IDS=$(cordys crm page account '{
  "combineSearch":{"conditions":[{"value":["东区"],"operator":"IN","name":"1751888184000009"}]}
}' | jq -r '.data.list[].id')

# 步骤 2: 查这些客户的商机
IDS_JSON=$(echo "$CUSTOMER_IDS" | jq -R . | jq -s .)
cordys crm page opportunity "{
  \"combineSearch\": {
    \"conditions\": [
      {\"value\": $IDS_JSON, \"operator\": \"IN\", \"name\": \"customerId\"}
    ]
  }
}"
```

### 场景 3：查 XX 产品的客户

**原因：** 客户无产品字段，需通过商机关联

**步骤：**
```bash
# 步骤 1: 查包含 MaxKB 专业版的商机
OPPORTUNITY_IDS=$(cordys crm page opportunity '{
  "filters":[{"name":"products","operator":"IN","value":["MaxKB 专业版"]}]
}' | jq -r '.data.list[].customerId')

# 步骤 2: 去重后查客户
CUSTOMER_IDS=$(echo "$OPPORTUNITY_IDS" | sort -u)
IDS_JSON=$(echo "$CUSTOMER_IDS" | jq -R . | jq -s .)
cordys crm page account "{
  \"combineSearch\": {
    \"conditions\": [
      {\"value\": $IDS_JSON, \"operator\": \"IN\", \"name\": \"id\"}
    ]
  }
}"
```

---

## 重要规则

### 默认查已成交商机

查询"XX 行业客户"或"XX 省市客户"的商机时，默认加 `stage = SUCCESS`（已成交）。

**原因：** 避免把正在跟进的商机算进去，导致数据不准确。

---

## jq 常用命令

```bash
# 提取 ID 列表（纯文本，每行一个）
jq -r '.data.list[].id'

# 转 JSON 数组（供下一步使用）
jq -R . | jq -s .

# 筛选金额大于 50 万的记录
jq '[.data.list[] | select(.amount != null and .amount > 500000)]'

# 筛选包含某产品的记录
jq '[.data.list[] | select(.products | if . == null then false else (. | map(. | tostring) | any(. == "1751888184000091")) end)]'
```

---

## 📝 自定义查询场景

如果公司有特殊的查询逻辑，在此添加。

---

## 📖 相关文档

- `references/crm-api.md` - API 接口参考
- `rules/platform/fields.md` - 字段映射表
- `rules/company/region.md` - 区域映射规则
