---
name: cordys-crm
description: "Cordys CRM CLI 指令映射技能，支持将自然语言高效转换为标准 `cordys crm` 命令，具备意图识别、模块匹配、参数补全及分页与全量查询处理能力"
version: 2.0.0
license: MIT
---

# Cordys CRM Skill

> 基于 Cordys CRM 平台的通用查询技能，支持线索/客户/商机/合同等模块的查询与搜索。

---

## 📦 能力边界

### ✅ 支持的功能

| 类型 | 功能 | 命令 |
|------|------|------|
| **分页查询** | 按条件查询列表 | `cordys crm page <module>` |
| **全局搜索** | 搜索名称/电话 | `cordys crm search <module>` |
| **查详情** | 获取单条记录 | `cordys crm get <module> <id>` |
| **跟进管理** | 查跟进计划/记录 | `cordys crm follow plan/record` |
| **特殊查询** | 产品/组织架构/联系人 | `cordys crm product/org/contact` |
| **原始 API** | 任意接口调用 | `cordys raw <METHOD> <PATH>` |

### ❌ 不支持的功能

| 功能 | 说明 | 替代方案 |
|------|------|---------|
| 数据写入 | 创建/更新/删除记录 | 使用 `raw` 命令手动调用 API |
| 批量操作 | 批量创建/更新 | 使用 `raw` 命令循环调用 |

---

## 🔧 使用条件

### 1. 环境要求

- **CLI 工具**：三选一
  - `cordys` (Shell) - **推荐**，依赖 `curl`
  - `cordys.js` (Node.js) - 跨平台，依赖 `Node.js`
  - `cordys.py` (Python) - 备用，依赖 `Python3`

- **环境变量**（必需）：
  ```bash
  ACCESS_KEY=your_access_key
  SECRET_KEY=your_secret_key
  CRM_DOMAIN=https://your-crm-domain.com
  ```

### 2. 配置说明

| 配置项 | 位置 | 说明 |
|--------|------|------|
| API 密钥 | `.env` | 从 CRM 系统获取 |
| 字段 ID | `rules/platform/fields.md` | 可定期同步更新 |
| 平台规则 | `rules/platform/` | 通用规则（如字段映射） |
| 公司规则 | `rules/company/` | 自定义规则（可选） |

---

## 📚 规则系统

### 规则层级

```
SKILL.md (边界定义)
    ├── rules/platform/         # 平台级规则（通用，任何公司适用）
    │   ├── fields.md           # 字段映射表
    │   └── sync.md             # 字段同步指南
    │
    └── rules/company/          # 公司级规则（可插拔，自定义）
        ├── README.md           # 自定义说明模板
        ├── region.md           # 区域映射
        ├── query-scenarios.md  # 查询场景
        └── glossary.md         # 术语映射
```

### 规则优先级

**公司规则 > 平台规则 > 默认规则**

- 平台规则：所有公司通用（如飞致云区域划分）
- 公司规则：覆盖平台规则（如自定义区域名称）

---

## 📋 命令格式

```bash
# 基础查询
cordys crm page <module> [params]      # 权限内高级查询
cordys crm search <module> [params]    # 全局搜索（固定字段）
cordys crm get <module> <id>           # 获取单条记录

# 跟进管理
cordys crm follow plan <module> [params]
cordys crm follow record <module> [params]

# 特殊查询
cordys crm product [keyword]
cordys crm org
cordys crm contact <module> <id>

# 原始 API
cordys raw <METHOD> <PATH> [body]
```

### search vs page 区别

| 命令 | 用途 | 权限 | 支持字段 |
|------|------|------|---------|
| `search` | 全局搜索 | 无权限限制 | 仅固定字段（名称/电话等） |
| `page` | 高级查询 | **个人权限内** | 任意字段（产品/区域/阶段等） |

**简单记：**
- `search` → 搜**固定字段**（公司名/手机号），全局搜索
- `page` → 查**个人权限内**数据，支持高级过滤

### 模块别名

| 别名 | 实际模块 | 说明 |
|------|---------|------|
| `lead` | `lead` | 线索 |
| `account` | `account` | 客户 |
| `opportunity` | `opportunity` | 商机 |
| `contract` | `contract` | 合同 |
| `pool` | `pool` | 客户池 |
| `product` | `product` | 产品 |
| `contact` | `contact` | 联系人 |

### 二级模块（子资源）

| 二级模块 | 说明 | API 路径 |
|---------|------|---------|
| `contract/payment-plan` | 回款计划 | `/contract/payment-plan/page` |
| `contract/payment-record` | 回款记录 | `/contract/payment-record/page` |
| `contract/business-title` | 工商抬头 | `/contract/business-title/page` |
| `contract/invoice` | 发票 | `/invoice/page` |
| `opportunity/quotation` | 报价单 | `/opportunity/quotation/page` |

**使用示例：**
```bash
cordys crm page contract/payment-plan '{"current":1,"pageSize":10}'
cordys crm page contract/payment-record '{"sourceId":"合同 ID"}'
```

---

## 🔄 字段同步

**首次使用建议配置自动同步**（字段定义可能更新）

**一键配置（推荐）：**
```bash
./scripts/setup-cron.sh
```

**手动配置（选一种）：**

```bash
# 方式 1: Crontab（简单通用）
crontab scripts/cron-example

# 方式 2: OpenClaw Cron
openclaw cron add --file scripts/openclaw-cron.json
```

**手动同步：**
```bash
./scripts/sync-fields.sh
```

**同步内容：** 字段 ID、字段名称、字段类型  
**输出文件：** `rules/platform/fields.md`  
**建议频率：** 每周一次

---

## 🗣️ 术语映射（公司规则）

**本技能包含飞致云（Fit2Cloud）的自定义术语映射**，位于 `rules/company/glossary.md`：

### 产品简称
| 简称 | 产品 |
|------|------|
| `js` / `jms` | JumpServer 企业版 |
| `mk` | MaxKB 专业版/企业版 |
| `ms` | MeterSphere 企业版 |
| `de` | DataEase 系列 |
| `1p` | 1Panel 专业版 |
| `oc` | OpenClaw 一体机 |

### 行业映射
| 用户输入 | 标准化行业 |
|---------|-----------|
| 汽车 | 制造 |
| 医院、医药 | 医疗（医药、医院、医学检测等） |
| 证券、基金、保险 | 非银金融 |
| 政府 | 政府和军工 |
| 互联网 | 高科技和互联网 |

### 商机阶段
| 用户用语 | CRM 阶段 |
|---------|---------|
| 赢单、下单、成交 | `SUCCESS` |
| 输单、丢单 | `FAILURE` |
| 新签 | ≠ "多期续费" |
| 续费 | 多期续费、维保、扩容、增购 |

> ⚠️ **其他公司使用时，请替换 `rules/company/` 下的文件为自己公司的规则！**

---

## 🔗 关联查询

**原则：能单模块就不关联**

某些查询需要跨模块关联（如"查 XX 行业客户的商机"），因为商机本身没有行业字段。

**关联查询步骤：**
```bash
# 步骤 1: 查政务行业客户，拿 customerId 列表
CUSTOMER_IDS=$(cordys crm page account '{
  "combineSearch":{"conditions":[{"value":["政府和军工"],"operator":"IN","name":"1751888184000005"}]}
}' | jq -r '.data.list[].id')

# 步骤 2: 转 JSON 数组
IDS_JSON=$(echo "$CUSTOMER_IDS" | jq -R . | jq -s .)

# 步骤 3: 查这些客户的商机（默认查已成交）
cordys crm page opportunity "{
  \"combineSearch\": {
    \"conditions\": [
      {\"value\": $IDS_JSON, \"operator\": \"IN\", \"name\": \"customerId\"},
      {\"value\": [\"SUCCESS\"], \"operator\": \"IN\", \"name\": \"stage\"}
    ]
  }
}"
```

**详细场景：** `rules/company/query-scenarios.md`

---

## 🛠️ jq 依赖

**部分高级功能需要 `jq` 工具**（JSON 处理）：

```bash
# 安装 jq
apt-get install jq      # Debian/Ubuntu
yum install jq          # CentOS/RHEL
brew install jq         # macOS
```

**常用命令：**
```bash
# 提取 ID 列表
jq -r '.data.list[].id'

# 转 JSON 数组
jq -R . | jq -s .

# 筛选金额大于 50 万
jq '[.data.list[] | select(.amount != null and .amount > 500000)]'
```

---

## 📖 文档导航

### 核心文档
| 文档 | 说明 |
|------|------|
| `references/crm-api.md` | **API 接口参考** + 查询语法 + **全量查询最佳实践** |
| `rules/platform/fields.md` | 字段映射说明 |
| `rules/platform/sync.md` | 字段同步配置指南 |
| `rules/company/README.md` | 公司级规则说明 |

### 公司规则（飞致云）
| 文档 | 说明 |
|------|------|
| `rules/company/region.md` | 区域映射（北/东/南区） |
| `rules/company/glossary.md` | 术语映射（产品简称/行业别名） |
| `rules/company/query-scenarios.md` | 关联查询场景 |

### 实战经验
| 文档 | 说明 |
|------|------|
| `docs/REPORT.md` | 功能验证报告 |
| `docs/PAGINATION-BEST-PRACTICE.md` | 全量查询实战案例（详细版） |

---

## 🚀 快速开始

### 首次使用必读

**当用户首次安装或配置此技能时，主动提醒以下内容：**

1. ⚠️ **配置 API 密钥**
   ```bash
   cp .env.example .env
   vim .env  # 填写 ACCESS_KEY 和 SECRET_KEY
   ```

2. ⚠️ **建议配置自动同步**（重要！）
   ```
   Cordys CRM 字段定义可能更新，建议配置定时任务定期同步字段映射。
   
   选择一种方式：
   - Crontab: crontab scripts/cron-example
   - systemd: sudo systemctl enable crm-fields-sync.timer
   - OpenClaw: openclaw cron add --file scripts/openclaw-cron.json
   
   或手动同步：./scripts/sync-fields.sh
   ```

3. ✅ **测试连接**
   ```bash
   cordys crm page lead
   ```

### 标准流程

```bash
# 1. 配置环境变量
cp .env.example .env
vim .env  # 填写 ACCESS_KEY 和 SECRET_KEY

# 2. 测试连接
cordys crm page lead

# 3. 同步字段（可选）
./scripts/sync-fields.sh

# 4. 开始使用
cordys crm search lead '{"keyword":"公司名"}'
```

---

## 📝 版本信息

- **Skill 版本**：2.0.0
- **最后更新**：2026-04-01
- **兼容 CRM 版本**：Cordys CRM 2026.x

### 更新日志

**v2.0.0 (2026-04-01)**
- ✅ 添加全量查询最佳实践（分页循环标准流程）
- ✅ 补充二级模块查询支持（回款计划/回款记录/发票等）
- ✅ 完善术语映射说明（产品简称/行业别名/商机阶段）
- ✅ 添加关联查询场景示例
- ✅ 补充 jq 依赖说明

**v1.0.0 (2026-03-31)**
- 初始版本发布

---

## 📞 支持

- **上游仓库**：https://github.com/hao65103940/CordysCRM-skills
- **问题反馈**：https://github.com/hao65103940/CordysCRM-skills/issues

---

## ⚠️ 重要提示

### 其他公司使用时

**本技能包含飞致云（Fit2Cloud）的自定义规则**，位于 `rules/company/` 目录：

| 文件 | 内容 | 是否需要替换 |
|------|------|-------------|
| `region.md` | 区域映射（北/东/南区） | ✅ **必须替换** |
| `glossary.md` | 术语映射（产品简称/行业） | ✅ **必须替换** |
| `query-scenarios.md` | 关联查询场景 | ✅ **建议替换** |

**最小化配置：** 如果不想用公司级规则，可以删除 `rules/company/` 目录所有文件，只使用通用规则（`references/` 和 `rules/platform/`）。

### 敏感配置

**请勿将以下文件提交到 Git 或分享到公开仓库：**

| 文件 | 内容 |
|------|------|
| `.env` | API 密钥（ACCESS_KEY/SECRET_KEY/CRM_DOMAIN） |

**建议：** 将 `.env` 加入 `.gitignore`，使用 `.env.example` 作为模板。
