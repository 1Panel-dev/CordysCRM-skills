# ⚙️ CLI 语义规范

本文件定义了 `cordys` CLI 的全部命令、参数规则和意图映射。
所有 AI 生成的命令必须遵循本规范。

---

## 1. 命令族总览

所有命令使用 `cordys.sh`（Shell CLI，推荐）执行，`cordys.py` 备用。

```text
cordys.sh crm page    <模块> [关键词|JSON]     分页查询
cordys.sh crm get     <模块> <ID>              获取详情
cordys.sh crm search  <模块> [关键词|JSON]     全局搜索
cordys.sh crm follow  plan|record <模块> <JSON>  跟进计划/记录
cordys.sh crm contact <模块> <ID>              联系人列表
cordys.sh crm product [关键词|JSON]            产品列表
cordys.sh crm org                             组织架构
cordys.sh crm members <JSON>                   部门成员
cordys.sh crm whoami                           当前用户信息
cordys.sh crm verify                           验证 API 密钥
cordys.sh raw          <METHOD> <PATH> [body]  原始 API 调用
```

> `cordys.sh` 前置路径为 `scripts/cordys.sh`，无需切换目录。
> Python 版本：将 `cordys.sh` 替换为 `cordys.py` 即可。

---

## 2. 分页默认结构

所有 page/search 命令使用统一的 JSON body 模板：

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

### viewId 说明

`viewId` 字段用于指定数据范围，支持两类视图：
- **内置系统视图**（本节下方自动匹配，无需调用 API）
- **自定义视图**（用户创建的筛选方案，通过 `crm view <module>` 查询）

详见本章第10节「内置视图与自定义视图」。

### 自动补全规则
| 条件 | 动作 |
|------|------|
| 只给关键词 | 放入 `keyword`，其余字段填默认值 |
| 给部分 JSON | 补全缺失字段，保留已有字段；若未给 `viewId` 则根据语义推断（见第10节） |
| 给完整 JSON | 原样传递，不修改 |
| 没给任何参数 | 全部默认值；`viewId` 按角色过滤规则推断（见第10节） |

---

## 3. 意图 → 命令映射

| 用户说 | 映射命令 | 备注 |
|--------|---------|------|
| 列表、分页查看、看看、有哪些 | `crm page <module>` | 自动追加角色过滤 |
| 搜索、筛选、找一下 | `crm search <module> <JSON>` | 关键词→keyword，条件→conditions |
| 详情、查看、打开这个 | `crm get <module> <ID>` | 若有名称无 ID，先搜索 |
| 跟进、跟进计划/记录 | `crm follow <plan\|record> <module> <JSON>` | 需 sourceId |
| 全部、拉全量、查完所有页 | 执行 page，遍历所有页 | 每页后询问是否继续 |
| 原始、自定义 | `craw <METHOD> <PATH>` | 仅限信任域名 |

---

## 4. 模块推断

| 用户说 | 模块 | 常用命令 |
|--------|------|---------|
| 线索、潜客 | `lead` | page, get, search, follow |
| 客户、公司、厂商 | `account` | page, get, search, follow, contact |
| 商机、机会 | `opportunity` | page, get, search, follow |
| 合同 | `contract` | page, get, search |
| 回款、回款计划 | `contract/payment-plan` | page |
| 回款记录 | `contract/payment-record` | page |
| 发票 | `invoice` | page |
| 报价单 | `opportunity/quotation` | page |
| 工商抬头 | `contract/business-title` | page |
| 产品 | 使用 `product` 命令 | product |
| 组织、部门 | `org` | org |
| 成员、人员 | `members` | members |
| 联系人 | `contact` | contact |
| 线索池 | `pool/lead` | page（需 poolId） |
| 公海 | `pool/account` | page（需 poolId） |

---

## 5. 动态时间过滤

在 `combineSearch.conditions` 中使用：

```json
{"value": "MONTH", "operator": "DYNAMICS", "name": "createTime", "type": "TIME_RANGE_PICKER"}
```

| 常量 | 含义 | | 常量 | 含义 |
|------|------|-|------|------|
| TODAY | 今天 | | YESTERDAY | 昨天 |
| WEEK | 本周 | | LAST_WEEK | 上周 |
| MONTH | 本月 | | LAST_MONTH | 上个月 |
| QUARTER | 本季度 | | LAST_QUARTER | 上季度 |
| YEAR | 本年度 | | LAST_YEAR | 上年度 |
| LAST_SEVEN | 过去7天 | | LAST_THIRTY | 过去30天 |
| ["CUSTOM,30,BEFORE_DAY"] | 前30天 | | [ts1, ts2] + BETWEEN | 时间戳区间 |

---

## 6. 过滤器语法

```json
{"field": "Stage", "operator": "equals", "value": "Closed Won"}
{"field": "createTime", "operator": "gte", "value": "2026-01-01"}
{"field": "ownerId", "operator": "equals", "value": "{userId}"}
```

### 常用操作符
| 操作符 | 用途 |
|--------|------|
| `equals` | 精确匹配 |
| `not equals` | 排除 |
| `contains` | 模糊匹配 |
| `gte` / `lte` | 时间/数字范围 |
| `DYNAMICS` + `TIME_RANGE_PICKER` | 动态时间 |

---

## 7. 动态参数替换（从 User.md 读取）

查询命令中的 `{userId}` 和 `{departmentId}` 是运行时占位符，执行命令时应替换为 User.md 中的实际值：

| 占位符 | 来源字段 | 示例值 |
|--------|---------|-------|
| `{userId}` | User.md 用户ID | `admin` |
| `{departmentId}` | User.md 部门ID | `dept_xxx` |

示例（前置替换）：
```json
// 过滤条件中的占位符
{"filters":[{"field":"ownerId","operator":"equals","value":"{userId}"}]}
// 实际执行时被替换为
{"filters":[{"field":"ownerId","operator":"equals","value":"admin"}]}
```

> 如果 User.md 中没有对应的 ID（如部门ID为空），则不追加该过滤条件。

---

## 8. 排序规则

```json
{"followTime": "desc"}
{"createTime": "asc"}
```

常用排序字段：`followTime`、`createTime`、`amount`、`stage`

---

## 9. 异常处理

| 响应 | 处理方式 |
|------|---------|
| HTTP 401/403 | 提示密钥可能失效，建议刷新身份 |
| code ≠ 100200 | 读取 message 字段并说明原因 |
| 数据空列表 | 确认是否真的无数据，还是过滤条件太严 |
| CLI 报错 | 检查环境变量和 .env |
| 接口超时 | 提示稍后重试或减小 pageSize（≤200） |

---

## 10. 内置视图与自定义视图

系统区分两类视图，**千万不能混淆**：

### 10.1 内置系统视图（直接使用，不在 view/list 中）

内置视图是系统预设的筛选方案，**不需要也不能**通过 `/{module}/view/list` 获取。直接写入 `viewId` 字段即可：

| viewId | 含义 | 适用模块 |
|--------|------|---------|
| `ALL` | 全部数据（默认） | 所有模块 |
| `SELF` | 我的数据 | `lead`, `account`, `opportunity`, `contract` |
| `CUSTOMER_COLLABORATION` | 协作客户 | `account` 仅 |

### 10.2 自定义视图（通过 view/list API 获取）

用户可在系统内创建自定义筛选方案，称为自定义视图。这些视图**不包含**内置视图（ALL、SELF 等）。

```bash
cordys.sh crm view <module>   # 仅返回用户创建的自定义视图，不含内置视图
```

### 10.3 viewId 匹配流程

当用户提到某个视图/视角时，按以下优先级匹配：

```
1. 是否匹配内置系统视图？
   ├─ "全部" / "所有" / "全量" → viewId: "ALL"
   ├─ "我的{模块}" / "我负责的" → viewId: "SELF"
   ├─ "协作客户" / "协作" → viewId: "CUSTOMER_COLLABORATION" (仅 account)
   └─ 命中 → 直接使用，无需调用 view/list API

2. 未命中内置视图 → 调用 `crm view <module>` 获取自定义视图列表
   └─ 从返回的列表中按名称模糊匹配，取对应 ID
```

### 10.4 典型语义映射

| 用户说 | viewId | 等价 filters（仅供理解） |
|--------|--------|------------------------|
| "全部线索" / "所有线索" | `ALL` | 不过滤 |
| "我的线索" / "我负责的线索" | `SELF` | `ownerId = {userId}` |
| "全部客户" | `ALL` | 不过滤 |
| "我的客户" | `SELF` | `ownerId = {userId}` |
| "协作客户" | `CUSTOMER_COLLABORATION` | 协作关系过滤 |
| "我的商机" | `SELF` | `ownerId = {userId}` |

> **注意**：`viewId: "SELF"` 的效果等价于 `{"filters":[{"field":"ownerId","operator":"equals","value":"{userId}"}]}`，但更简洁高效。优先使用 viewId 而非自己构造 filters。
