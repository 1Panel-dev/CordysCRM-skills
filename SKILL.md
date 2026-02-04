# Cordys CRM 集成

## 快速指引（OpenClaw 助手用）

这个技能包装了 `CordysCRM` CLI。你的提问会被我转换成 `cordys` 命令，必要时会补全 JSON body。

### 基本流程
1. 明确操作：**列表/搜索/获取/创建/更新/删除**
2. 指定模块：`lead`、`account`、`opportunity`、`pool` 等
3. 补充条件：关键词、过滤器、排序、字段
4. 给出 pagination 或 JSON body（可选）
5. 说明输出形式（简短汇总、全部字段、只要某个字段）

### 样例构造提示词
- “列出本周提交的潜在客户，按创建时间倒序，每页 30 条。”
- “搜索账户模块，关键词‘电力’，只返回电话和跟进人。”
- “获取商机 998877 详情。”
- “创建一个新客户：名称`极光科技`，行业`新能源`，负责人`高敬`。”
- “更新 lead 554433 的状态为“已跟进”。”

你也可以说 “帮我写出需要的 filters JSON”。

## CLI 参考（常用命令）
```
cordys help
cordys crm page lead
cordys crm page opportunity
cordys crm page account
cordys crm page pool
cordys crm get lead 1234567890
cordys crm search opportunity '{"current":1,"pageSize":30,"combineSearch":{"searchMode":"AND","conditions":[]},"keyword":"测试","filters":[]}'
cordys raw GET /settings/fields?module=account
```

## 环境变量（必须）
```bash
CORDYS_ACCESS_KEY=xxx
CORDYS_SECRET_KEY=xxx
CORDYS_CRM_DOMAIN=https://your-cordys-domain
```

## 进阶提示
- **搜索**：`cordys crm search {module}` 需要完整 JSON；你可以只提供关键词，我会帮你构造 JSON。
- **分页**：默认 `current=1`, `pageSize=30`；可根据 `PerPage` 要求调整。
- **过滤器**：`filters` 数组，格式 `{"field":"字段","operator":"equals","value":"值"}`。
- **排序**：在 `sort` 里写 `{"field":"desc"}`。
- **raw**：当需要直接操作 API（比如自定义 endpoint、字段）时使用 `cordys raw {METHOD} {PATH}`。

## 助手应该怎么理解用户意图
| 关键词 | 推理 |
| --- | --- |
| 列出/分页/分页查看 | `corsys crm page {module}`，填 `keyword` 或 `filters` |
| 搜索/查找/筛选 | `cordys crm search {module}`（构造 `combineSearch`） |
| 查看/打开/详情 | `cordys crm get {module} {id}` |
| 创建/添加/新建 | `cordys crm create {module} '{"data":[{...}]}'` |
| 更新/改变/修改 | `cordys crm update {module} {id} '{"data":[{...}]}'` |
| 删除/移除 | `cordys crm delete {module} {id}` |

## 兼容 JSON 请求示例
在用户给出 JSON 字符串时，保持原样传递，避免再次 escape；若已提供结构但缺部分字段，自动补齐 `current`、`pageSize`、`combineSearch` 等默认值。

## 调试 & 日志
- 设置 `CORDYS_DEBUG=true` 获取 CLI 原始请求。
- CLI 会默认读取 `.env`，也可以在命令前 `CORDYS_ACCESS_KEY=... CORDYS_SECRET_KEY=...` 临时覆盖。
- 遇到 `code` 非 `100200` 时，记录 `message` 并提示用户。
