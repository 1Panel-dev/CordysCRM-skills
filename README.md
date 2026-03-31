# Cordys CRM Skill for OpenClaw

像与人交谈一样与你的 **Cordys CRM 工作区**交互。  
商机、联系人、潜在客户 —— 全部通过自然对话与你的 AI 助理完成。

这个 Skill 将 **Cordys CRM CLI** 包装进 **OpenClaw 会话环境**：

1. 你用自然语言描述需求
2. AI 解析意图
3. 自动转换为 `cordys` CLI 命令
4. 执行 API 请求并返回结果

借助 Prompt 的动态调优机制，用户可以在 **不修改任何代码**的情况下控制：

- 输出格式
- 过滤条件
- 排序规则
- 分页逻辑

从而让 AI 更贴合真实 CRM 业务场景。

---

# 为什么这个 Skill 有用

| 系统视角 | 用户意图 | 输出 |
|---|---|---|
| 👂 监听自然语言 | 提供模块 / 条件 / 字段 | ⚙️ 转换为 CLI / API 请求 |
| 📦 简化重复任务 | 分页 / 搜索 / CRUD | ✅ 自动执行 |
| 📊 数据同步 | 查看销售管道 / 客户数据 | 🕓 可结合 cron 自动化 |

---

# 项目结构

```
CordysCRM-skills/
├── README.md              # 当前工程基本说明
├── SKILL.md               # 助手在 OpenClaw 会话里引用的 prompt/reference
├── bin/cordys             # 内置 CLI，可直接试用
└── references/
    └── crm-api.md         # API 字段和请求体 RFC
```

快速安装

```bash
git clone https://github.com/1Panel-dev/CordysCRM-skills ~/.openclaw/workspace/skills/cordys-crm
```

---

# 配置环境变量

创建 `.env`

```ini
CORDYS_ACCESS_KEY=你的AccessKey
CORDYS_SECRET_KEY=你的SecretKey
CORDYS_CRM_DOMAIN=https://你的域名
```

示例：

```
CORDYS_CRM_DOMAIN=https://crm.example.com
```

---

# CLI 版本说明

项目提供 **两个 CLI 实现**

| CLI | 推荐场景               | 特点     |
|---|--------------------|--------|
| Shell CLI (`cordys`) | Linux / macOS / CI | 默认 CLI |
| Python CLI (`cordys.py`) | 跨平台 / 复杂命令         | 灵活     |

默认 **优先使用 Shell CLI**。

如果 Shell CLI 不支持某些命令，会提示使用 Python CLI。

---

# Shell CLI（默认）

无需额外依赖，仅需要 `curl`，使用示例：

```bash
cordys crm page lead
cordys crm page opportunity
cordys crm org
cordys help
```

优势：

- 无需 Python
- 启动速度快
- 适合 Linux / macOS / CI

---

如果系统不支持 Bash ｜ Windows 环境 ｜ Shell CLI 不可用，则提示：
```
⚠️ 当前命令 Shell CLI 不支持

请使用 Python CLI：

python3 bin/cordys.py <command>
```

示例：

```
cordys crm search opportunity '{...}'

⚠️ 当前命令 Shell CLI 不支持

请使用：

python3 bin/cordys.py crm search opportunity '{...}'
```

---

# Python CLI（完整版本）

安装依赖：

```bash
pip install requests python-dotenv
```

使用示例：

```bash
python3 bin/cordys.py crm page lead
python3 bin/cordys.py crm org
python3 bin/cordys.py help
```

优势：
- 更好的错误处理
- 跨平台支持

---

# 验证安装

```bash
cordys help
```

或者

```bash
python3 bin/cordys.py help
```

如果返回帮助信息说明安装成功。

---

# CLI 常用命令

分页列表

```bash
cordys crm page lead
cordys crm page opportunity
cordys crm page account
```

关键词搜索

```bash
cordys crm page lead "测试"
```

获取单条记录

```bash
cordys crm get lead "123456"
```

复杂搜索

```bash
cordys crm search opportunity '{"cupytnt":1,"pageSize":30,"keyword":"测试"}'
```

组织架构

```bash
cordys crm org
```

部门成员

```bash
cordys crm members '{"current":1,"pageSize":50,"departmentIds":["dept1"]}'
```

联系人查询

```bash
# 查询 客户｜商机 联系人
cordys crm contact opportunity '商机id'
cordys crm contact account '客户id'
```

原始 API

```bash
cordys raw GET /settings/fields?cordys raw GET /setting---
```

# 跟进计划与记录（通用查询）

示例：

```bash
cordys crm follow plan lead '{"sourceId":"927627065163785","current":1,"pageSize":10,"keyword":"","status":"ALL","myPlan":false}'

cordys crm follow record account '{"sourceId":"1751888184018919","current":1,"pageSize":10,"keyword":"","myPlan":false}'
```

- `sourceId` 指向某条商机/客户/线索的唯一 ID，必须传入才能拉到与之关联的计划或记录；只提供 `keyword` 时只做关键字模糊搜索，无法替代 `sourceId`。
- `status` 面向 `plan` 接口，支持 `ALL`、`UNFINISHED`、`FINISHED` 等（以 Cordys 枚举为准），用来控制计划流转；`myPlan` 控制是否只看本人创建的计划。
- `page_payload` 默认只补齐 `current/pageSize/sort/filters`，所以当你希望筛选特定 `sourceId`/`status`/`myPlan`，必须以 JSON body 形式传入完整字段。

默认情况下，如果你只提供关键词，CLI 会自动补齐分页结构（current=1、pageSize=30、sort={}、filters=[]）。

---

# 二级模块支持

Cordys CRM 部分资源属于二级模块。

例如：

```
 `cordys crm page contract/payment-plan`：查询回款计划的分页列表，支持传入关键词/JSON body，实际上调用的是 `POST /contract/payment-plan/page`。
 `cordys crm page invoice`：查询发票的分页列表，通过 `POST /invoice/page` 获取，每个条件都可以通过 `filters` 精细控制。
 `cordys crm page contract/business-title`：检索工商抬头列表，同样支持关键词/filters。
 `cordys crm page contract/payment-record`：查看回款记录列表，可结合关键词、`filters` 或 `viewId` 进行精细筛选。
```

示例：

```bash
cordys crm page contract/payment-plan
```

回款记录：

```bash
cordys crm page contract/payment-record
```

发票：

```bash
cordys crm page invoice
```

---

# 深度 API 调用

查看字段

```bash
cordys raw GET /settings/fields?module=account
```

复杂过滤示例：

```bash
cordys crm search opportunity '{"filters":[{"field":"Stage","operator":"equals","value":"Closed Won"}]}'
```

详细结构参考：

```
references/crm-api.md
```

---

# 自动化

示例：

```python
cron.add({
  "name": "每天成交商机",
  "schedule": {"kind": "cron", "expr": "0 9 * * *"},
  "payload": {
    "kind": "agentTurn",
    "message": "c rdys crm page opportunity \"Closed Won\""
  }
})
```
