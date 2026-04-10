# Cordys CRM Skill for OpenClaw

像与人交谈一样与你的 **Cordys CRM 工作区**交互。  
商机、联系人、潜在客户 —— 全部通过自然对话与你的 AI 助理完成。

---

## ⚡ 5 分钟快速开始

### 1. 配置环境变量

```bash
cp .env.example .env
vim .env  # 填写 ACCESS_KEY 和 SECRET_KEY
```

**环境变量说明：**
```ini
ACCESS_KEY=你的 AccessKey
SECRET_KEY=你的 SecretKey
CRM_DOMAIN=https://your-crm-domain.com  # 你的 CRM 域名
```

### 2. 测试连接

```bash
cordys crm page lead
```

如果返回 JSON 数据说明配置成功。

### 3. 开始查询

```bash
# 查线索列表
cordys crm page lead

# 搜公司名
cordys crm search lead "公司名"

# 查我的商机
cordys crm page opportunity '{"owner":"你的用户 ID"}'
```

---

## 📁 项目结构

```
cordys-crm/
├── bin/                        # CLI 工具（Shell/Node.js/Python）
├── references/
│   └── crm-api.md              # API 接口参考
├── rules/
│   ├── platform/               # 平台级规则（通用）
│   │   ├── fields.md           # 字段映射表
│   │   └── sync.md             # 同步指南
│   └── company/                # 公司级规则（可替换）
│       ├── region.md           # 区域映射
│       ├── query-scenarios.md  # 查询场景
│       └── glossary.md         # 术语映射
├── scripts/
│   ├── sync-fields.sh          # 字段同步脚本
│   ├── setup-cron.sh           # 定时任务配置
│   └── get-search-fields.sh    # 搜索字段查询
├── SKILL.md                    # OpenClaw 技能定义
├── README.md                   # 使用说明
└── .env.example                # 环境变量模板
```

---

## 🏢 其他公司如何使用

**`rules/company/` 目录下的文件需要替换成你们自己的规则：**

1. `region.md` - 区域映射（如华北/华东/华南）
2. `query-scenarios.md` - 查询场景（如关联查询逻辑）
3. `glossary.md` - 术语映射（如产品简称）

**替换步骤：**
```bash
cd ~/.openclaw/skills/cordys-crm/rules/company
vim region.md
vim query-scenarios.md
vim glossary.md
```

---

## 🔧 CLI 工具

项目提供三个 CLI 版本：

| CLI | 推荐场景 | 依赖 |
|-----|---------|------|
| `cordys` (Shell) | **推荐** - Linux/macOS/CI | `curl` |
| `cordys.js` (Node.js) | 跨平台 | `Node.js` |
| `cordys.py` (Python) | 备用 | `Python3 + requests` |

**默认优先使用 Shell 版本。**

---

## 📚 常用命令

```bash
# 分页列表
cordys crm page lead
cordys crm page opportunity
cordys crm page account

# 关键词搜索
cordys crm search lead "公司名"

# 获取单条记录
cordys crm get lead "123456"

# 跟进计划/记录
cordys crm follow plan lead '{"sourceId":"xxx","status":"ALL"}'
cordys crm follow record account '{"sourceId":"xxx"}'

# 二级模块
cordys crm page contract/payment-plan
cordys crm page invoice

# 原始 API
cordys raw GET /settings/fields?module=account
```

---

## 🤖 自动同步（可选）

字段定义可能更新，建议配置自动同步：

**一键配置：**
```bash
./scripts/setup-cron.sh
```

**或手动配置（Crontab）：**
```bash
crontab -e
# 添加：0 2 * * 0 /path/to/cordys-crm/scripts/sync-fields.sh
```

**手动同步：**
```bash
./scripts/sync-fields.sh
```

---

## 📖 文档导航

| 文档 | 说明 |
|------|------|
| `references/crm-api.md` | API 接口参考 + search/page 规则 + "我的"查询 |
| `rules/platform/fields.md` | 字段映射表（线索/客户/商机/产品） |
| `rules/platform/sync.md` | 字段同步指南 |
| `rules/company/README.md` | 公司级规则替换说明 |
| `SKILL.md` | OpenClaw 技能定义 + CLI 命令映射 |

---

## 🚀 进阶使用

### 查询"我的线索"

```bash
# 步骤 1: 获取当前用户 ID
cordys raw GET /personal/center/info | jq '.data.userId'

# 步骤 2: 查我的线索
cordys crm page lead '{"owner":"你的用户 ID"}'
```

### 按时间范围查询

```bash
# 本周创建的线索
cordys crm page lead '{
  "combineSearch": {
    "conditions": [
      {"name": "createTime", "operator": "DYNAMICS", "value": "WEEK"}
    ]
  }
}'
```

### 全量查询（自动翻页）

当用户说"查全部线索"、"拉全量数据"时，CLI 会自动翻页直到查完所有数据。

---

## 📝 版本信息

- **Skill 版本**：2.0.0
- **最后更新**：2026-03-31
- **兼容 CRM 版本**：Cordys CRM 2026.x

---

## 📞 支持

- **上游仓库**：https://github.com/hao65103940/CordysCRM-skills
- **问题反馈**：https://github.com/hao65103940/CordysCRM-skills/issues
