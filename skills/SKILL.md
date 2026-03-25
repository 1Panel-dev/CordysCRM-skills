---
name: cordys-crm
description: |
   Cordys CRM CLI 指令映射技能，本技能用于将自然语言需求精准转换为可执行的 `cordys crm` 标准命令，确保输出稳定、可预测、无歧义。
    
    【核心能力】
    - 自动识别用户意图（列表 / 搜索 / 详情 / 跟进 / 原始接口）
    - 自动识别模块（lead / account / opportunity / contract 等）
    - 自动补全 JSON 参数
    - 自动构造 filters / sort / combineSearch
    - 自动补充分页默认值
    - 支持“查询全部/全部导出/拉全量”等语义下的自动翻页拉取
    - 支持二级模块（如 contract/payment-plan,pool/account,pool/lead）

---

# Cordys CRM CLI 使用说明

该技能封装了 `cordys` 命令，帮助把自然语言转换成标准 CLI 调用。针对不同模块（lead/account/opportunity/pool 等）和常见操作（查询、分页、搜索、跟进计划/记录、原始接口）提供明确的映射策略。

## CLI 版本选择

# CLI 版本选择（优先 Shell）

本项目提供两个版本 CLI：

| 版本 | 推荐程度 | 说明 |
|----|----|----|
| **Shell 版本 `cordys`** |  推荐 | 无需 Python，执行更轻量 |
| Python 版本 `cordys.py` | 备用 | 需要 Python3 + requests |

目录结构里，`scripts/` 目录存放这两个 CLI 实现，标准化排列为：

```
scripts/
├── cordys       # 优先的 Shell 可执行脚本
└── cordys.py    # 不支持 Shell 时可选择 Python 实现
```

**默认优先使用 Shell 版本。**

Python 版本仅在以下情况使用：

- 系统不支持 Bash
- Windows 环境
- Shell CLI 不可用

## 基本流程
1. 明确意图：列出/搜索/获取/跟进。
2. 指定目标模块（如 `lead`、`opportunity`）。
3. 根据需求补充关键词、过滤条件、排序或分页参数。
4. 确认是否需要 JSON body（如 `search`、`follow plan`、`raw`）。
5. 说明期望的输出形式（简短摘要/全部字段/只要某字段）。

## 指令映射（常用）
| 场景       | 建议命令                                              | 备注                                                     |
|----------|---------------------------------------------------|--------------------------------------------------------|
| 列表或分页查看  | `cordys crm page <module> ["keyword"]`            | 若用户只提关键词，会自动构造 `{keyword:..., current:1, pageSize:30}` |
| 全局搜索     | `cordys crm search <module> <JSON body>`          | 需 `combineSearch`、`filters`、`sort`，可补全默认值              |
| 详情       | `cordys crm get <module> <id>`                    | 直接拉取记录                                                 |
| 跟进计划或记录  | `cordys crm follow plan 或 record <module> <body>` | `body` 应包含 `sourceId`，计划还需要 `status`/`myPlan` |
| 原始接口     | `cordys raw <METHOD> <PATH> [<body>]`             | 用于自定义端点或二级模块，如 `/contract/payment-plan`                |

## 分页查询交互优化
为了避免分页查询的交互断层，优先执行一次识别出的指令并返回结果：
1. **分页控制**：默认 `current=1`、`pageSize=50`，根据响应判断是否有多页，如果有则提示用户是否要翻下一页。
2. **字段与输出范围**：默认全部字段、摘要、特定字段组合。
3. **默认格式**：表格或列表形式展示，除非用户特别说明要 JSON 或其他格式。

## 高级技巧
- 搜索命令需要完整 JSON，若用户只给关键词或简单条件，可自动补齐 `current=1`、`pageSize=30`、`combineSearch={...}`。
- 过滤器格式为 `{"field":"字段","operator":"equals","value":"值"}`，排序格式为 `{"field":"desc"}`。
- 支持二级模块（例如 `contract/payment-plan`、`contract/payment-record`），CLI 命令形式仍为 `cordys crm page <module>`。
- `cordys raw` 可以按原始 GET/POST 访问 `/settings/fields`、`/contract/business-title` 等非标准接口。


## 常用示例
```bash
# 分页列表（带关键词）
cordys crm page lead "测试"

# 搜索（完整 JSON）
cordys crm search opportunity '{"current":1,"pageSize":30,"combineSearch":{"searchMode":"AND","conditions":[]},"keyword":"电力","filters":[]}'

# 跟进计划
cordys crm follow plan account '{"sourceId":"123","current":1,"pageSize":10,"status":"UNFINISHED","myPlan":false}'

# 获取组织架构
cordys crm org

# 查询产品
cordys crm product "测试产品"

# 获取联系人
cordys crm contact account "927627065163785"

```

## 二级模块支持

Cordys CRM 部分资源属于二级模块。

例如：

```bash

 #查询回款计划的分页列表，支持传入关键词/JSON body，实际上调用的是 POST /contract/payment-plan/page。
 cordys crm page contract/payment-plan
 
 #查询发票的分页列表，通过 POST /invoice/page 获取，每个条件都可以通过 filters 精细控制。
 cordys crm page invoice 
 
 #检索工商抬头列表，同样支持关键词/filters。
 cordys crm page contract/business-title 
 
 #查看回款记录列表，可结合关键词、filters 或 viewId 进行精细筛选。
 cordys crm page contract/payment-record 
 
 # 查看线索池中的线索，可结合关键词、filters 或 viewId 进行精细筛选，必填属性是 poolId 通过 lead-pool 接口获取。
 cordys crm page pool/lead '{"current":1,"pageSize":30,"sort":{},"combineSearch":{"searchMode":"AND","conditions":[]},"keyword":"","poolId":"必填项，通过 lead-pool API 获取","viewId":"ALL","filters":[]}'
 
 #查看线索池中的线索，可结合关键词、filters 或 viewId 进行精细筛选，必填属性是 poolId 通过 account-pool 接口获取。
 cordys crm page pool/account '{"current":1,"pageSize":30,"sort":{},"combineSearch":{"searchMode":"AND","conditions":[]},"keyword":"","poolId":"必填项，通过 account-pool API 获取","viewId":"ALL","filters":[]}'

 
```

## 深度 API 调用

查看字段

```bash
cordys raw GET /settings/fields?module=account
```

复杂过滤示例：

```bash
cordys crm search opportunity '{"filters":[{"field":"Stage","operator":"equals","value":"Closed Won"}]}'
```

## 环境变量（必须）
```bash
# 从 `.env` 文件或环境变量中读取，包含访问 Cordys CRM API 的必要信息：
CORDYS_ACCESS_KEY=xxx
CORDYS_SECRET_KEY=xxx
CORDYS_CRM_DOMAIN=https://your-cordys-domain
```

## 助手判断意图的提示词
- “列表”/“分页查看”：映射到 `page` 指令；可补上关键词或 filters
- “查询全部”/“全部数据”/“拉全量”/“查完所有页”：自动补充上翻页参数，并根据响应提示用户是否继续翻页
- “搜索”/“筛选”：使用 `search`，补齐 JSON body
- “查看详情”：用 `get` + 决定的 ID
- “跟进”：「跟进计划」→ `follow plan`，「跟进记录」→ `follow record`

## 日志与异常
- CLI 默认读取 `.env`，也可通过前置环境变量覆盖。
- 若返回 `code` 非 `100200`，要记录 `message` 并向用户说明。
- 若返回 401 或 403，提示用户检查认证信息。
