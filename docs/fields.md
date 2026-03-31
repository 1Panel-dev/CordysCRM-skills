# 字段映射说明

> Cordys CRM 标准字段 ID 参考

---

## 📋 字段配置位置

| 配置类型 | 文件 | 说明 |
|----------|------|------|
| **机器配置** | `config/fields.json` | CLI 工具读取的配置文件 |
| **人类可读** | `docs/fields.md` | 本文档，供查阅参考 |

---

## 🔄 字段同步

字段 ID 可能随 CRM 系统更新而变化，建议定期同步：

```bash
# 手动同步
./scripts/sync-fields.sh

# 自动同步（选择一种）
crontab scripts/cron-example
sudo systemctl enable crm-fields-sync.timer
openclaw cron add --file scripts/openclaw-cron.json
```

同步后检查变更：
```bash
git diff config/fields.json
```

---

## 📦 线索模块 (lead)

| 字段名 | 字段 ID | 类型 | 说明 |
|--------|--------|------|------|
| `name` | - | string | 线索名称 |
| `owner` | - | string | 负责人 ID |
| `ownerName` | - | string | 负责人名称 |
| `contact` | - | string | 联系人名称 |
| `phone` | - | string | 联系电话 |
| `products` | - | array | 意向产品列表 |
| `stage` | - | string | 线索阶段 |
| `createTime` | - | integer | 创建时间（时间戳） |
| `区域` | `1751888184000015` | select | 东区/北区/南区/KA |
| `来源` | `1751888184000018` | select | 线上/线下 |
| `来源细分` | `1751888184000019` | select | 安装包下载/400 电话等 |
| `行业` | `1751888184000005` | select | 制造/高科技和互联网等 |
| `线索状态` | `1751888184000025` | select | 是/否 |

---

## 📦 客户模块 (account)

| 字段名 | 字段 ID | 类型 | 说明 |
|--------|--------|------|------|
| `name` | - | string | 客户名称 |
| `owner` | - | string | 负责人 ID |
| `区域` | `1751888184000009` | select | 东区/北区/南区/KA |
| `行业` | `1751888184000005` | select | 制造/高科技和互联网等 |

---

## 📦 商机模块 (opportunity)

| 字段名 | 字段 ID | 类型 | 说明 |
|--------|--------|------|------|
| `name` | - | string | 商机名称 |
| `customerId` | - | string | 关联客户 ID |
| `amount` | `1751888184000041` | number | 商机金额 |
| `stage` | - | string | 商机阶段 |
| `区域` | `1751888184000030` | select | 东区/北区/南区/KA |
| `products` | - | array | 关联产品列表 |

### 商机阶段

| 阶段值 | 说明 |
|--------|------|
| `CREATE` | 新建 |
| `CLEAR_REQUIREMENTS` | 需求明确 |
| `SCHEME_VALIDATION` | 方案验证 |
| `PROJECT_PROPOSAL_REPORT` | 立项汇报 |
| `BUSINESS_PROCUREMENT` | 商务采购 |
| `SUCCESS` | 成功（赢单） |
| `FAILURE` | 失败（输单） |

---

## 📦 合同模块 (contract)

| 字段名 | 字段 ID | 类型 | 说明 |
|--------|--------|------|------|
| `name` | - | string | 合同名称 |
| `amount` | - | number | 合同金额 |
| `products` | - | array | 关联产品列表 |

### 二级模块

| 模块路径 | 说明 |
|----------|------|
| `contract/payment-plan` | 回款计划 |
| `contract/payment-record` | 回款记录 |
| `contract/business-title` | 工商抬头 |

---

## 📦 产品模块 (product)

| 产品名 | 产品 ID | 说明 |
|--------|--------|------|
| `JumpServer 企业版` | `1751888184000091` | 堡垒机产品 |
| `MaxKB 专业版` | `1751888184000102` | 知识库产品 |
| `MaxKB 企业版` | `8327632349528064` | 知识库企业版 |
| `DataEase 专业版` | `1751888184000092` | BI 工具 |
| `DataEase 企业版` | `1751888184000101` | BI 企业版 |
| `SQLBot 专业版` | `8366853990875136` | SQL 助手 |
| `MeterSphere 企业版` | `1751888184000098` | 测试平台 |
| `1Panel OpenClaw 一体机` | `329298398169903104` | 一体机硬件 |
| `1Panel 专业版` | `1751888184000088` | 服务器管理面板 |

---

## 🔍 获取字段 ID 的方法

### 方法一：通过 API 查询

```bash
cordys raw GET "/settings/fields?module=lead"
```

### 方法二：查看配置文件

```bash
cat config/fields.json
```

### 方法三：从查询结果中提取

```bash
cordys crm page lead | jq '.data.list[0].moduleFields[] | {fieldId, fieldValue}'
```

---

## 📖 相关文档

- `docs/api.md` - API 接口参考
- `docs/sync.md` - 字段同步配置指南
- `config/fields.json` - 字段配置文件
