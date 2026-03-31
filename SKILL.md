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
  CRM_DOMAIN=https://crm.fit2cloud.com
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
cordys crm page <module> [params]
cordys crm search <module> [params]
cordys crm get <module> <id>

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

---

## 🔄 字段同步

CRM 字段定义可能更新，建议定期同步：

```bash
# 手动同步
./scripts/sync-fields.sh

# 自动同步（选择一种）
crontab scripts/cron-example              # Cron Job
sudo systemctl enable crm-fields-sync.timer  # systemd
openclaw cron add --file scripts/openclaw-cron.json  # OpenClaw
```

**同步内容：** 字段 ID、字段名称、字段类型  
**输出文件：** `rules/platform/fields.md`

---

## 📖 文档导航

| 文档 | 说明 |
|------|------|
| `references/api.md` | API 接口参考 + 查询语法 |
| `rules/platform/fields.md` | 字段映射说明 |
| `rules/platform/sync.md` | 字段同步配置指南 |
| `rules/company/README.md` | 公司级规则说明 |

---

## 🚀 快速开始

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
- **最后更新**：2026-03-31
- **兼容 CRM 版本**：Cordys CRM 2026.x

---

## 📞 支持

- **上游仓库**：https://github.com/hao65103940/CordysCRM-skills
- **问题反馈**：https://github.com/hao65103940/CordysCRM-skills/issues
