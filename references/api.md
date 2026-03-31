# CORDYS CRM API 参考

此文档聚焦 Cordys CRM CLI 背后的原始 API，帮助 OpenClaw 理解请求结构、标准参数、模块定义、错误处理和最佳实践。
无论是让 OpenClaw 助手自动构建 `cordys crm` 命令，还是自己发起 `cordys raw` 请求，都能从这里快速查到细节。

---

## 1. 模块概览
| 模块 | 描述 |
| --- | --- |
| `lead` | 潜在客户（线索）记录，用于销售团队初步跟进。|
| `account` | 客户/公司基础信息，包含行业、地点、负责人等。|
| `opportunity` | 商机（机会）记录，表示销售流程中的具体案子。|
| `contract` | 合同及其回款、发票等子资源，用于追踪签署后的收款与交付状态。|
| `pool` | 公共资源池（可选），用于共享线索或商机。|
| 其他模块 | 可以根据 API 文档继续扩展，如 `task`、`contact`、`product` 等。|

你在自然语言中提到的模块名，扭转成命令时就能直接定位到本文档中所列的模块。

`contract` 模块还有几个常用的二级资源：`contract/payment-plan`（回款计划）、`invoice`、`contract/business-title`（工商抬头）、`contract/payment-record` 以及 `opportunity/quotation`，CLI 仍然沿用 `page`/json 的方式访问它们。

---

## 2. 通用请求结构
Cordys CRM 的分页和搜索均遵循以下 JSON 模板：

```json
{
  "current": 1,
  "pageSize": 30,
  "sort": {},
  "combineSearch": {
    "searchMode": "AND",
    "conditions": []
  },
  "keyword": "",
  "viewId": "ALL",
  "filters": []
}
```

**字段含义：**
- `current`：页码（从 1 开始），用于 `page` 命令。
- `pageSize`：每页条数，默认 30。
- `sort`：排序对象，例如 `{"followTime":"desc"}`。
- `combineSearch.conditions`：组合筛选条件，支持多个 `field/operator/value`。
- `keyword`：全局关键词，模糊匹配名称/说明/电话等。
- `viewId`：视图 ID（例如 `ALL`、`MY`），通常根据用户意图调用视图 API 获取对应 ID。
- `filters`：与 `conditions` 类似，但用于更加精细的字段级过滤，CLI 通常会同步构造。

CLI 会在你不提供某些字段时自动填默认值；如果你直接给出 JSON，OpenClaw 保持结构并补全缺省字段。

---

## 3. 常用 HTTP 端点
| 方法 | 路径 | 说明 |
| --- | --- | --- |
| `GET` | `/{module}/view/view` | 获取视图列表。 |
| `GET` | `/{module}/{id}` | 获取单条记录详情。 |
| `POST` | `/{module}/page` | **高级查询**：支持任意字段过滤、复杂条件组合。 |
| `POST` | `/global/search/{module}` | **全局搜索**：仅搜索配置好的基础字段（名称、电话等）。 |
| `GET` | `/personal/center/info` | **获取当前用户信息**（通过 API Key 认证）。 |
| `GET` | `/search/config/get` | **获取搜索配置**：查看各模块支持的全局搜索字段。 |

> `cordys raw {METHOD} {PATH}` 就是让你任意组合上述请求，并手动填写 body/headers。

---

## 3.3 `search` vs `page` 区别

| 特性 | `search` (`/global/search/{module}`) | `page` (`/{module}/page`) |
|------|-------------------------------------|--------------------------|
| **用途** | **全局搜索** - 快速查找 | **高级查询** - 精确过滤 |
| **搜索字段** | 仅限配置好的字段（名称、电话等） | **任意字段**（产品、区域、行业、负责人等） |
| **keyword 参数** | ✅ 全局模糊匹配配置字段 | ✅ 单字段模糊匹配 |
| **filters 参数** | ✅ 支持 | ✅ 支持 |
| **combineSearch** | ✅ 支持 | ✅ 支持 |
| **性能** | 较快（字段有限） | 取决于过滤条件复杂度 |
| **使用场景** | 搜公司名、手机号、联系人 | 查"我的线索"、按产品/区域/时间过滤 |

### 使用建议

| 场景 | 推荐接口 | 示例 |
|------|---------|------|
| 搜公司名/客户名 | `search` + `keyword` | `{"keyword":"诚泰融资租赁"}` |
| 搜手机号 | `search` + `keyword` | `{"keyword":"18616920752"}` |
| 查"我的线索" | `page` + `owner` | `{"owner":"1131998760411293"}` |
| 按产品过滤 | `page` + `filters` | `{"filters":[{"name":"products","operator":"IN","value":["MaxKB 专业版"]}]}` |
| 按区域过滤 | `page` + `filters` | `{"filters":[{"name":"1751888184000015","operator":"IN","value":["东区"]}]}` |
| 按时间范围 | `page` + `combineSearch` | `{"combineSearch":{"conditions":[{"operator":"DYNAMICS","value":"WEEK"}]}}` |
| 多条件组合 | `page` + `combineSearch` | 复杂 JSON |

> 💡 **简单记：** `search` 用来**找人/找公司**（简单搜索），`page` 用来**查数据/做报表**（高级查询）。

---

## 3.1 获取当前用户信息

**接口：** `GET /personal/center/info`

**用途：** 通过 API Key 获取当前认证用户的详细信息，包括用户 ID、姓名、部门、角色等。

**请求示例：**
```bash
curl -X GET "https://crm.fit2cloud.com/personal/center/info" \
  -H "X-Access-Key: YOUR_ACCESS_KEY" \
  -H "X-Secret-Key: YOUR_SECRET_KEY" \
  -H "Content-Type: application/json"

# 或用 cordys CLI
cordys raw GET /personal/center/info
```

**响应示例：**
```json
{
  "code": 100200,
  "message": null,
  "messageDetail": null,
  "data": {
    "id": "1131998760411294",
    "userId": "1131998760411293",
    "userName": "赵磊博",
    "enable": true,
    "gender": false,
    "phone": "17621628283",
    "email": "leibo.zhao@fit2cloud.com",
    "departmentId": "1131998760411192",
    "departmentName": "上海线下团队",
    "organizationId": "100001",
    "supervisorId": null,
    "supervisorName": null,
    "roles": [
      {"id": "5091958607765504", "name": "智能体使用"},
      {"id": "11057118425849856", "name": "销售主管 - 东区"}
    ],
    "employeeId": null,
    "position": "客户成功经理",
    "workCity": "310104",
    "onboardingDate": null
  }
}
```

**关键字段说明：**
| 字段 | 类型 | 说明 |
|------|------|------|
| `userId` | string | **用户唯一 ID**，用于 `owner` 字段过滤（如查询"我的线索"） |
| `userName` | string | 用户姓名 |
| `departmentName` | string | 所属部门名称 |
| `position` | string | 职位 |
| `roles` | array | 角色列表（含角色 ID 和名称） |
| `organizationId` | string | 组织 ID |

**使用场景：**
- 查询当前 API Key 绑定的用户身份
- 获取用户 ID 后用于 `owner` 字段精确过滤（如 `{"owner":"1131998760411293"}`）
- 验证 API Key 是否有效（返回 200 即有效）

---

## 4. 跟进计划与记录 API
| 方法 | 路径 | 说明 |
| --- | --- | --- |
| `POST` | `/{module}/follow/plan/page` | 查询某条资源的跟进计划，必须带 `sourceId`，支持 `status`、`myPlan`、`keyword` 等字段。|
| `POST` | `/{module}/follow/record/page` | 查询某条资源的跟进记录，以 `sourceId` 为主，并可额外筛 `keyword`。|

`module` 目前常用 `lead`、`account`、`opportunity` 等。需要查计划时请填 `status`（推荐 `ALL` / `UNFINISHED` / `FINISHED`），`myPlan` 表示是否只看本人创建的计划，`keyword` 和 `combineSearch` 仅用于模糊匹配；如果只传 `keyword` 将不带 `sourceId`，接口会返回空内容。

`page_payload` 只会补 `current` / `pageSize` / `sort` / `filters`，所以任何需要的 `sourceId` / `status` / `myPlan` 都必须在 JSON body 里显式提供。

---

## 5. 请求示例
### 分页列出商机（默认结构）
```bash
cordys crm page opportunity "{\"current\":1,\"pageSize\":20,\"keyword\":\"线索\"}"
```
会调用 `POST /opportunity/page`，body 同上。

### 二级模块支持
Cordys CRM 里有一些隐藏在 `contract`｜ `opportunity` 模块下的二级资源（比如回款计划、发票等），`cordys` CLI 通过接受包含斜杠路径的模块名来访问它们。

- `cordys crm page contract/payment-plan`：查询回款计划的分页列表，支持传入关键词/JSON body，实际上调用的是 `POST /contract/payment-plan/page`。
- `cordys crm page invoice`：查询发票的分页列表，通过 `POST /invoice/page` 获取，每个条件都可以通过 `filters` 精细控制。
- `cordys crm page contract/business-title`：检索工商抬头列表，同样支持关键词/filters。
- `cordys crm page contract/payment-record`：查看回款记录列表，可结合关键词、`filters` 或 `viewId` 进行精细筛选。
- `cordys crm page opportunity/quotation`：查看报价单列表，可结合关键词、`filters` 或 `viewId` 进行精细筛选。

对这些二级模块的查询依旧遵循 `page_payload` 结构（`current`/`pageSize`/`sort`/`filters`）和关键字补全，因此你只需提供想要筛选的字段，AI 会自动补上分页元数据。

需要更专业的筛选能力时，可以直接把完整 JSON body 透传给 `cordys crm page contract/payment-plan '{…}'`，也可以用 `cordys raw` 指定路径（例如 `cordys raw POST /contract/payment-record/page '{...}'`）来跳过 CLI 结构化限制。

### 高级 search（带 filters + sort）
```bash
cordys crm search account '{
  "current":1,
  "pageSize":40,
  "keyword":"云",
  "sort":{"followTime":"desc"},
  "combineSearch":{
    "searchMode":"AND",
    "conditions":[
      {"field":"industry","operator":"equals","value":"科技"}
    ]
  },
  "filters":[
    {"field":"province","operator":"equals","value":"广东"}
  ]
}'
```
CLI 会请求 `/search/account`，按关键词+filters 精确过滤。

### 高级 search（和时间相关的动态搜索）
```bash
cordys crm search account '{
  "current":1,
  "pageSize":40,
  "keyword":"云",
  "sort":{},
  "combineSearch":{
    "searchMode":"AND",
    "conditions":[
      {"value": "WEEK","operator": "DYNAMICS","name": "createTime","multipleValue": false,"type": "TIME_RANGE_PICKER"}
    ]
  },
  "filters":[]
}'
```
在 combineSearch.conditions 参数结构中，operator 为 DYNAMICS 时，value 为下列常量参数

| 常量 | 描述 |
| --- | --- |
| `TODAY` | 今天 |
| `YESTERDAY` | 昨天 |
| `TOMORROW` | 明天 |
| `WEEK` | 本周 | 
| `LAST_WEEK` | 上周 |
| `NEXT_WEEK` | 下周 |
| `MONTH` | 本月 |
| `LAST_MONTH` | 上个月 |
| `NEXT_MONTH` | 下个月 |
| `LAST_SEVEN` | 过去一周 |
| `SEVEN` | 未来一周 |
| `THIRTY` | 未来三十天内 |
| `LAST_THIRTY` | 过去三十天内 |
| `SIXTY` | 未来 60 天内 |
| `LAST_SIXTY` | 过去六十天内 |
| `QUARTER` | 本季度 |
| `LAST_QUARTER` | 上季度 |
| `NEXT_QUARTER` | 下季度 |
| `YEAR` | 本年度 |
| `LAST_YEAR` | 上年度 |
| `NEXT_YEAR` | 下年度 |

如果查询 n 天前，value 的值可以写成 `["CUSTOM,"+n+",BEFORE_DAY"]`。
如果要查询两个时间段中间的数据，value 可以写 `[较早的毫秒级时间戳，较晚的毫秒级时间戳]`，同时 operator 为 `BETWEEN`。

### 获取某条记录
```
cordys crm get lead 987654321
```
等价于 `GET /lead/987654321`。

---

### 跟进计划/记录请求示例
```bash
cordys crm raw POST /lead/follow/record/page '{"sourceId":"927627065163785","current":1,"pageSize":10,"keyword":"回访"}'
cordys crm raw POST /account/follow/plan/page '{"sourceId":"1751888184018919","current":1,"pageSize":10,"status":"ALL","myPlan":false}'
```
响应返回同样的分页结构，`data.list` 含 `planTime`、`status`、`ownerName`、`content` 等字段，例如：
```json
{
  "code":100200,
  "data":{
    "list":[
      {"id":"plan-1","planTime":"2026-02-28T14:00:00","status":"UNFINISHED","content":"跟进沟通需求"},
      {"id":"plan-2","planTime":"2026-02-26T10:00:00","status":"FINISHED","content":"确认资料"}
    ],
    "current":1,"pageSize":10,"total":2
  }
}
```

---

## 6. 响应解析
所有调用返回统一结构：
```json
{
  "code": 100200,
  "message": null,
  "messageDetail": null,
  "data": {
    "list": [ ... ],
    "total": 13,
    "pageSize": 30,
    "current": 1
  }
}
```
正常响应 `code=100200`。异常时会返回 `ACCESS_DENIED`、`INVALID_KEY`、`INVALID_REQUEST` 等，`message` 字段含具体原因。

---

## 7. 错误处理建议
1. **Token/密钥错误**：`INVALID_KEY`、`ACCESS_DENIED` → 检查 `ACCESS_KEY`/`SECRET_KEY`。
2. **参数问题**：`INVALID_REQUEST`、`INVALID_FILTER` → 检查 JSON 格式、字段名拼写。
3. **404/资源不存在**：要么 `id` 写错，要么没有访问权限。
4. **500+**：建议记录 `messageDetail` 并稍后重试。

对于任何非 `100200` 响应，我会把 `code`+`message` 反馈给你。

---

## 8. 最佳实践
- **分页不要太大**：大于 200 会容易超时。
- **关键词 + filters 组合**：先用 `keyword` 粗筛，再在 `combineSearch.conditions` 中加精确字段。
- **排序字段稳定**：使用 `sort` 降序 `followTime` 或 `createTime`，避免每次结果顺序浮动。
- **多条件用 `combineSearch`**：传多个 `conditions` 会自动 AND（或 OR，取决于 `searchMode`）。
- **控制层级**：JSON body 里按模块字段命名（大小写敏感）。

---

## 9. 附录：字段/filters 例子
| 字段 | 描述 | 示例值 |
| --- | --- | --- |
| `name` | 名称/标题 | `"Acme 商机"` |
| `stage` | 商机阶段 | `"Qualification"` |
| `owner` | 负责人 ID | `"user123"` |
| `industry` | 行业 | `"科技"` |
| `province` | 省份 | `"上海"` |

过滤示例：
```
{"field":"stage","operator":"equals","value":"Closed Won"}
```
更多字段可以在 CLI 输出的 `moduleFields` 里查看或用 `cordys raw GET /settings/fields?module={module}` 查询。

---

后续扩展，在 `rules/platform/` 下添加更多通用规则文件。

**字段映射表：** `rules/platform/fields.md`
