# Cordys CRM 技能 for OpenClaw

像与人交谈一样与你的 Cordys CRM 工作区交互。商机、联系人、潜在客户 — 全部通过自然对话与你的 AI 助手完成。

这个技能把 Cordys CRM CLI 包装在 OpenClaw 会话里：你说，助手听、解析、把意图映射到 Cordys CRM 命令，再把结果返回给你。

借助 Prompt 的动态调优机制，用户可以在不修改任何底层代码的情况下，灵活控制 OpenClaw 的输出格式、筛选逻辑和分页规则，让 AI 更贴合实际业务需求，显著提升交互效率与使用体验。

## 为什么这个技能有用

| 系统视角 | 用户意图 | 输出形式 |
| --- | --- | --- |
| 👂 监听自然语言 | 提供关键信息（模块、操作、条件、字段） | ⚙️ 转换为 `cordys` CLI、原始 API 或更复杂的 JSON 请求 |
| 📦 简化重复任务 | 需要分页、搜索、创建/更新/删除记录 | ✅ 直接执行并返回结果 |
| 📊 同步报告 | 希望定期看销售管道、潜在客户、客户活动 | 🕓 可与 cron 或脚本组合 |

## 项目结构
```
CordysCRM-skills/
├── README.md              # 当前工程基本说明
├── SKILL.md               # 助手在 OpenClaw 会话里引用的 prompt/reference
├── bin/cordys             # 内置 CLI，可直接试用
└── references/
    └── crm-api.md         # API 字段和请求体 RFC
```

## 🚀 快速开始

### 方式一：通过 ClawdHub 安装（推荐）

```bash
clawdhub install cordys-crm
```

### 方式二：手动安装

#### 克隆仓库

```bash
git clone https://github.com/1Panel-dev/CordysCRM-skills ~/.openclaw/skills/cordys-crm
```

### 创建环境变量文件

在项目根目录创建 `.env` 文件：

```ini
CORDYS_ACCESS_KEY=你的 Access Key
CORDYS_SECRET_KEY=你的 Secret Key
CORDYS_CRM_DOMAIN=https://{你的域名}
```

4. 运行 `cordys help` 确认 CLI 可用
5. 你也可以直接在仓库根目录运行 `./bin/cordys`（会继承 `.env`）来验证连接是否成功，若 domain 包含非标准路径（例如 `https://crm.example.com/api`），请在 `.env` 中完整写出。
6. 在 OpenClaw 会话中以自然语言告诉我你想要做什么，我会把它翻译成命令

## CLI 常用命令
```
# 分页列表
cordys crm page lead
cordys crm page opportunity
cordys crm page account

(支持 keyword 参数，如 `cordys crm page lead "测试"`，会把关键词填入 body 的 `keyword` 字段。)
# 获取单条记录
cordys crm get lead "1234567890"

# 搜索（需要完整 JSON body）
cordys crm search opportunity '{"current":1,"pageSize":30,"combineSearch":{"searchMode":"AND","conditions":[]},"keyword":"测试","filters":[]}'

# 获取组织架构，需要有系统管理权限才能调用
cordys crm org

# 获取部门成员列表
cordys crm members '{"current":1,"pageSize":50,"combineSearch":{"searchMode":"AND","conditions":[]},"keyword":"","departmentIds":["deptId1","deptId2"],"filters":[]}'

# 跟进计划/记录查询
cordys crm follow plan lead '{"sourceId":"927627065163785","current":1,"pageSize":10,"keyword":"","status":"ALL","myPlan":false}'
cordys crm follow record account '{"sourceId":"1751888184018919","current":1,"pageSize":10,"keyword":"","myPlan":false}'

# 查询 客户｜商机 联系人
cordys crm contact opportunity '商机id'
cordys crm contact account '客户id'

# 原始 API 调用
cordys raw GET /settings/fields?module=account
```

## 跟进计划与记录（通用查询）
商机、客户、潜在客户的跟进计划和跟进记录都可以复用同一套接口。
```
cordys crm follow plan <module> '{"sourceId":"<resourceId>","current":1,"pageSize":10,"keyword":"","status":"ALL","myPlan":false}'
cordys crm follow record <module> '{"sourceId":"<resourceId>","current":1,"pageSize":10,"keyword":"","myPlan":false}'
```

- `sourceId` 指向某条商机/客户/线索的唯一 ID，必须传入才能拉到与之关联的计划或记录；只提供 `keyword` 时只做关键字模糊搜索，无法替代 `sourceId`。
- `status` 面向 `plan` 接口，支持 `ALL`、`UNFINISHED`、`FINISHED` 等（以 Cordys 枚举为准），用来控制计划流转；`myPlan` 控制是否只看本人创建的计划。
- `page_payload` 默认只补齐 `current/pageSize/sort/filters`，所以当你希望筛选特定 `sourceId`/`status`/`myPlan`，必须以 JSON body 形式传入完整字段。

默认情况下，如果你只提供关键词，CLI 会自动补齐分页结构（current=1、pageSize=30、sort={}、filters=[]）。

## 如何告诉 AI 你的意图（让提示词更清晰）

| 意图类别 | 示例
| --- | --- |
| 列表/分页 | “帮我列出本月新增的商机，按金额排序，每页 20 条。” |
| 全局搜索 | “搜索所有账户，关键词是‘铁塔’，只看跟进中状态。” |
| 获取详情 | “打开编号 xxx 客户的潜在客户详情。” |
| 跟进计划/记录 | “帮我找出 lead 9276 相关的未完成计划，按创建时间倒序。” |

> 推荐模板：
> 1. 明确“做什么”（列表/搜索/创建/更新/删除/跟进）
> 2. 指定“哪个模块”（lead/account/opportunity/其他）
> 3. 说明“条件/过滤/关键词”或要修改的字段
> 4. 说明“分页/命令”信息（例如 `current`、`pageSize`、`follow plan` 等）
>
> 如果要调用跟进接口，记得带上 `sourceId`，并指明是否需要 `status`-类过滤或只查看自己的计划/记录（`myPlan`）。

### 例子（Assistant 可直接转换成命令）
- “查看本周创建的所有潜在客户，分页 30 条，按创建时间倒序。”
- “搜索 opportunity 中名称里包含‘征信’的记录，只返回前 10 条。”
- “把商机 112233 的阶段改为‘商务洽谈’，金额更新为 180000。”
- “列出所有上海地区客户并导出手机号。”
- “帮我看 lead 9276 相关的跟进记录。”

## 键值映射（提示词 → 实际命令）
| 用户说法 | CLI/API 推理 |
| --- | --- |
| “列出商机” | `cordys crm page opportunity`（追加 filters/sort/keyword） |
| “搜索账户” + “关键词” | `cordys crm search account {…}`，把关键词设置在 JSON 里 |
| “查看 lead #ID” | `cordys crm get lead ID` |
| “创建联系人” | `cordys crm create Contacts '{"data":[{…}]}'` |
| “查看某条线索的跟进计划” | `cordys crm follow plan lead '{"sourceId":"...","status":"ALL"}'` |

如果你是技术佬也可以直接给出 JSON body，让 OpenClaw 原样传给 `search`/`page`；也可以要求先构造基础 structure 再根据你的 “条件” 细化。

## 二级模块支持
Cordys CRM 里有一些隐藏在 `contract` 模块下的二级资源（比如回款计划、发票等），`cordys` CLI 通过接受包含斜杠路径的模块名来访问它们。

- `cordys crm page contract/payment-plan`：查询回款计划的分页列表，支持传入关键词/JSON body，实际上调用的是 `POST /contract/payment-plan/page`。
- `cordys crm page invoice`：查询发票的分页列表，通过 `POST /invoice/page` 获取，每个条件都可以通过 `filters` 精细控制。
- `cordys crm page contract/business-title`：检索工商抬头列表，同样支持关键词/filters。
- `cordys crm page contract/payment-record`：查看回款记录列表，可结合关键词、`filters` 或 `viewId` 进行精细筛选。

对这些二级模块的查询依旧遵循 `page_payload` 结构（`current`/`pageSize`/`sort`/`filters`）和关键字补全，因此你只需提供想要筛选的字段，AI 会自动补上分页元数据。

需要更专业的筛选能力时，可以直接把完整 JSON body 透传给 `cordys crm page contract/payment-plan '{…}'`，也可以用 `cordys raw` 指定路径（例如 `cordys raw POST /contract/payment-record/page '{...}'`）来跳过 CLI 结构化限制。

## 深度操作参考
- 查看 module 字段定义：`cordys raw GET /settings/fields?module={模块}`
- 调整排序/过滤：在 `filters` 里填 `[{"field":"Stage","operator":"equals","value":"Closed Won"}]`
- 分页参数：`current`, `pageSize`, `viewId`, `keyword`

详细结构请参考 `references/crm-api.md`。

## 进一步自动化
你可以把自然语言请求封装成 cron 任务或脚本：
```python
# 每天早上 9 点看今天成交商机
cron.add({
  "name": "每天成交商机",
  "schedule": {"kind": "cron", "expr": "0 9 * * *"},
  "sessionTarget": "isolated",
  "payload": {
    "kind": "agentTurn",
    "message": "cd /work/CordysCRM-skills && cordys crm page opportunity \"{\"current\":1,\"pageSize\":30,\"keyword\":\"Closed Won\"}\""
  }
})
```
