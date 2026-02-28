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
cordys crm follow plan lead '{"sourceId":"927627065163785","current":1,"pageSize":10,"keyword":"","status":"ALL","myPlan":false}'
cordys crm follow record account '{"sourceId":"1751888184018919","current":1,"pageSize":10,"keyword":"","myPlan":false}'
cordys raw GET /settings/fields?module=account
```

## 跟进计划与记录（自然语言 -> CLI）
当用户想要查看某条潜在客户、客户或商机的跟进计划/记录时，用 `follow plan|record`，示例命令如下：
```
cordys crm follow plan <module> '{"sourceId":"<resourceId>","current":1,"pageSize":10,"keyword":"","status":"ALL","myPlan":false}'
cordys crm follow record <module> '{"sourceId":"<resourceId>","current":1,"pageSize":10,"keyword":"","myPlan":false}'
```
- `sourceId` 必须指向目标模块的 ID，否则接口只会返回空列表。
- `status` 只对计划有效，可传 `ALL`、`UNFINISHED` 等，`myPlan` 控制是否只看本人创建。
- 默认只传关键词时 CLI 会当 keyword，自动补齐 `current=1,pageSize=30,sort={},filters=[]`；任何定制字段必须在 JSON body 中显式传入。

常见自然语言示例：
- “帮我看 lead 9276 的跟进记录。”
- “列出 account 1751 的所有未完成跟进计划。”
- “关键词‘合同’筛出与 opportunity 相关的跟进记录。”

如果用户以中文描述“跟进计划”“跟进记录”，优先将意图映射到 `cordys crm follow plan` 或 `follow record`，并补全 body（`sourceId`、`status`/`myPlan`）后再调用。

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
| 跟进计划/记录 | `cordys crm follow plan|record <module>` （补齐 `sourceId`、`status`、`myPlan`） |

推荐让用户明确 “sourceId” + “status/myPlan” 这类字段，而不是只说“跟进”。

## 兼容 JSON 请求示例
在用户给出 JSON 字符串时，保持原样传递，避免再次 escape；若已提供结构但缺部分字段，自动补齐 `current`、`pageSize`、`combineSearch` 等默认值。

## 调试 & 日志
- 设置 `CORDYS_DEBUG=true` 获取 CLI 原始请求。
- CLI 会默认读取 `.env`，也可以在命令前 `CORDYS_ACCESS_KEY=... CORDYS_SECRET_KEY=...` 临时覆盖。
- 遇到 `code` 非 `100200` 时，记录 `message` 并提示用户。
