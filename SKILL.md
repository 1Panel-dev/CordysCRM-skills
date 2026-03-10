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
    - 支持二级模块（如 contract/payment-plan）

---

# Cordys CRM CLI 使用说明

该技能封装了 `cordys` 命令，帮助把自然语言转换成标准 CLI 调用。针对不同模块（lead/account/opportunity/pool 等）和常见操作（查询、分页、搜索、跟进计划/记录、原始接口）提供明确的映射策略。

## CLI 版本选择

本项目提供两个版本的 CLI 工具：

- **Python 版本**（`cordys.py`）：推荐使用，跨平台兼容性好，需要 Python 3 和 requests 库
- **Shell 版本**（`cordys`）：传统 bash 脚本，适合纯 Unix/Linux 环境

两个版本功能完全相同，命令格式一致。下文示例使用 `cordys.py`，如使用 Shell 版本请替换为 `cordys`。

## 基本流程
1. 明确意图：列出/搜索/获取/跟进。
2. 指定目标模块（如 `lead`、`opportunity`）。
3. 根据需求补充关键词、过滤条件、排序或分页参数。
4. 确认是否需要 JSON body（如 `search`、`follow plan`、`raw`）。
5. 说明期望的输出形式（简短摘要/全部字段/只要某字段）。

## 指令映射（常用）
| 场景 | 建议命令 | 备注 |
| --- | --- | --- |
| 列表或分页查看 | `cordys.py crm page <module> ["keyword"]` | 若用户只提关键词，会自动构造 `{keyword:..., current:1, pageSize:30}` |
| 搜索 | `cordys.py crm search <module> <JSON body>` | 需 `combineSearch`、`filters`、`sort`，可补全默认值 |
| 详情 | `cordys.py crm get <module> <id>` | 直接拉取记录 |
| 跟进计划/记录 | `cordys.py crm follow plan|record <module> <body>` | `body` 应包含 `sourceId`，计划还需要 `status`/`myPlan` |
| 原始接口 | `cordys.py raw <METHOD> <PATH> [<body>]` | 用于自定义端点或二级模块，如 `/contract/payment-plan` |

## 高级技巧
- 搜索命令需要完整 JSON，若用户只给关键词或简单条件，可自动补齐 `current=1`、`pageSize=30`、`combineSearch={...}`。
- 过滤器格式为 `{"field":"字段","operator":"equals","value":"值"}`，排序格式为 `{"field":"desc"}`。
- 支持二级模块（例如 `contract/payment-plan`、`contract/payment-record`），CLI 命令形式仍为 `cordys.py crm page <module>`。
- `cordys.py raw` 可以按原始 GET/POST 访问 `/settings/fields`、`/contract/business-title` 等非标准接口。

## 常用示例
```bash
# 分页列表（带关键词）
python3 bin/cordys.py crm page lead "测试"

# 搜索（完整 JSON）
python3 bin/cordys.py crm search opportunity '{"current":1,"pageSize":30,"combineSearch":{"searchMode":"AND","conditions":[]},"keyword":"电力","filters":[]}'

# 跟进计划
python3 bin/cordys.py crm follow plan account '{"sourceId":"123","current":1,"pageSize":10,"status":"UNFINISHED","myPlan":false}'

# 原始 API 调用
python3 bin/cordys.py raw GET /settings/fields?module=account

# 获取组织架构
python3 bin/cordys.py crm org

# 查询产品
python3 bin/cordys.py crm product "测试产品"

# 获取联系人
python3 bin/cordys.py crm contact account "927627065163785"
```

## 环境变量（必须）
```bash
CORDYS_ACCESS_KEY=xxx
CORDYS_SECRET_KEY=xxx
CORDYS_CRM_DOMAIN=https://your-cordys-domain
```

## 助手判断意图的提示词
- “列表”/“分页查看”：映射到 `page` 指令；可补上关键词或 filters
- “搜索”/“筛选”：使用 `search`，补齐 JSON body
- “查看详情”：用 `get` + 决定的 ID
- “跟进”：「跟进计划」→ `follow plan`，「跟进记录」→ `follow record`

## 日志与异常
- CLI 默认读取 `.env`，也可通过前置环境变量覆盖。
- 若返回 `code` 非 `100200`，要记录 `message` 并向用户说明。
