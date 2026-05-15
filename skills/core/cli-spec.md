# ⚙️ CLI 语义规范

本文件定义了 `cordys` CLI 的全部命令、参数规则和意图映射。
所有 AI 生成的命令必须遵循本规范。

> **目录**
>
> 1. [命令族总览](#1-命令族总览)
> 2. [分页默认结构](#2-分页默认结构)
> 3. [意图 → 命令映射](#3-意图--命令映射)
> 4. [模块推断](#4-模块推断)
> 5. [动态时间过滤](#5-动态时间过滤)
> 6. [过滤器语法](#6-过滤器语法)
> 7. [动态参数替换](#7-动态参数替换)
> 8. [排序规则](#8-排序规则)
> 9. [异常处理](#9-异常处理)
> 10. [内置视图与自定义视图](#10-内置视图与自定义视图)
> 11. [部门组织架构展开](#11-部门组织架构展开)
> 12. [全局模糊搜索（多模块并行）](#12-全局模糊搜索多模块并行)

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
| 搜索、筛选、找一下、找 xxx | `crm search <module> <JSON>` | 关键词→keyword，条件→conditions |
| **模糊搜索（未指定模块）** | **同时搜索 lead, pool/lead, account, opportunity, pool/account, contact** | **见 §12 全局模糊搜索** |
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

> **注意**：在涉及部门范围的查询中，`{departmentId}` 会被替换为展开后的部门ID数组（见第11节「部门组织架构展开」）。不是所有占位符都是单一字符串替换，`{departmentId}` 在 `conditions` 结构中可以替换为数组。

### 7.1 部门层级占位符规则

`{departmentId}` 默认代表当前用户的直属部门ID。当用户提到其他部门时（如"销售一部"）:

- 先调用 `crm org` 获取完整组织架构树
- 通过部门名称在树中查找对应部门的 ID
- **必须展开该部门的所有子部门**，将 `"value":"{departmentId}"` 替换为 `"value":["dept_a","dept_b",...]`（见第11节「部门组织架构展开」）

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

---

## 11. 部门组织架构展开（含子部门）

当用户按**部门范围**查询数据时（如"销售一部的本月开放商机"），**必须自动包含该部门下的所有子部门**，而非仅查询指定部门本身。

### 11.1 操作流程

```
1. 识别目标部门名称（如"销售一部"），在 User.departmentId 或通过 org 树查找 ID
2. 调用 `cordys.sh crm org` 获取完整组织架构树
3. 在树中定位该部门节点，递归遍历其所有子节点
4. 收集该部门及所有子孙部门的 ID 列表
5. 构造 departmentId 数组过滤器，替换原来的单值 departmentId 过滤
```

### 11.2 占位符

新增运行时占位符 `{departmentId}`，由 AI 在运行前通过 org 展开计算后填充：

| 占位符 | 来源 | 示例值 |
|--------|------|-------|
| `{departmentId}` | 通过 `crm org` 展开得到的部门ID数组 | `["dept_a","dept_b","dept_c"]` |

### 11.3 部门范围过滤器标准模式

涉及组织范围的查询，统一使用 `combineSearch.conditions` 中的 `departmentId` + `TREE_SELECT` 模式，**不再使用单值 `departmentId` 过滤**：

```json
{
  "combineSearch": {
    "searchMode": "AND",
    "conditions": [
      {
        "value": "{departmentId}",
        "operator": "IN",
        "name": "departmentId",
        "multipleValue": false,
        "type": "TREE_SELECT"
      }
    ]
  }
}
```

执行示例（替换后）：
```json
{
  "combineSearch": {
    "searchMode": "AND",
    "conditions": [
      {
        "value": ["dept_a", "dept_b", "dept_c"],
        "operator": "IN",
        "name": "departmentId",
        "multipleValue": false,
        "type": "TREE_SELECT"
      }
    ]
  }
}
```

### 11.4 行为规则

| 场景 | 行为 |
|------|------|
| 用户说"我部门"、"我们部门"、不指定部门 | 使用 User.md 中的 `{departmentId}`，**也必须展开其所有子部门** → 替换为 `{departmentId}` |
| 用户指定具体部门名（"销售一部"） | 通过 `crm org` 树按名称查找该部门ID，然后展开其所有子部门 |
| 用户说"全公司"、"全部" | 不使用部门过滤，viewId 用 `"ALL"` |
| 用户说"销售一部和销售三部" | 分别查找两个部门，各自展开子部门，合并去重后作为 `{departmentId}` |
| 部门没有子部门 | `{departmentId}` 就是该部门自己的ID数组 `["dept_x"]` |

### 11.5 实际查询示例

用户："销售一部的本月开放商机"

```bash
# 步骤1：获取组织架构树
tree=$(cordys.sh crm org)

# 步骤2：解析销售一部及其所有子部门ID（AI 内部逻辑）
# 假设结果：["dept_sales1", "dept_team_a", "dept_team_b"]

# 步骤3：构造查询（使用 combineSearch.conditions + TREE_SELECT 模式）
cordys.sh crm page opportunity '{
  "current": 1,
  "pageSize": 30,
  "sort": {},
  "combineSearch": {
    "searchMode": "AND",
    "conditions": [
      {
        "value": ["dept_sales1", "dept_team_a", "dept_team_b"],
        "operator": "IN",
        "name": "departmentId",
        "multipleValue": false,
        "type": "TREE_SELECT"
      },
      {
        "value": "MONTH",
        "operator": "DYNAMICS",
        "name": "stageUpdateTime",
        "type": "TIME_RANGE_PICKER"
      },
      {
        "value": ["Open"],
        "operator": "IN",
        "name": "stage",
        "multipleValue": false,
        "type": "SELECT"
      }
    ]
  },
  "keyword": "",
  "viewId": "ALL",
  "filters": []
}'
```

> **注意**：部门过滤条件位于 `combineSearch.conditions` 中，`name: "departmentId"`、`type: "TREE_SELECT"`、`operator: "IN"`（大写）。不要把部门过滤写在 `filters` 数组里。

### 11.6 结合 members 获取部门成员列表

如需获取展开后的部门所有成员（用于按人聚合统计）：

```bash
cordys.sh crm members '{
  "current": 1,
  "pageSize": 200,
  "departmentId": ["dept_sales1", "dept_team_a", "dept_team_b"]
}'
```

> **注意**：`members` 命令的 body 中 `departmentId` 是两个词拼写，指向同一字段；API 中统一使用 `departmentId`（单数，驼峰命名）。

### 11.7 Python 中展开子树的参考逻辑

```python
def collect_descendant_ids(tree_node):
    """递归收集所有子部门ID（含自身）"""
    ids = [tree_node["id"]]
    for child in tree_node.get("children", []):
        ids.extend(collect_descendant_ids(child))
    return ids
```

```python
def find_department(tree, name_keyword):
    """在组织架构树中按名称模糊查找部门节点"""
    if name_keyword in tree.get("name", ""):
        return collect_descendant_ids(tree)
    for child in tree.get("children", []):
        result = find_department(child, name_keyword)
        if result:
            return result
    return None
```

---

## 12. 全局模糊搜索（多模块并行）

### 12.1 适用场景

当用户**未明确指定模块**时（如

"查一下 xxx" / "搜索 xxx" / "找找 xxx" / "有没有 xxx" / 不含模块关键词的模糊查询)，应执行**多模块并行搜索**，在多个相关模块中同时查找匹配的数据，汇总为跨模块概览。

### 12.2 搜索模块列表

默认全局模糊搜索覆盖以下 6 个模块（按常用优先级排列）：

| 中文名 | 模块名 | 搜索方式 | 优先级 |
|--------|--------|---------|-------|
| 线索 | `lead` | `crm search lead '{"keyword":"xxx"}'` | 🔴 高 |
| 线索池 | `pool/lead` | `crm search pool/lead '{"keyword":"xxx"}'` | 🔴 高 |
| 客户 | `account` | `crm search account '{"keyword":"xxx"}'` | 🔴 高 |
| 商机 | `opportunity` | `crm search opportunity '{"keyword":"xxx"}'` | 🟡 中 |
| 公海 | `pool/account` | `crm search pool/account '{"keyword":"xxx"}'` | 🟡 中 |
| 联系人 | `contact` | `crm search contact '{"keyword":"xxx"}'` | 🟢 低 |

> **执行顺序**：为提升响应速度，应**并行**发起所有搜索请求（不等待上一个完成）。若用户角色为销售（SELF 视图），搜索时自动在 keywords 中追加 `viewId: "SELF"` 或通过 filters 限定范围。

### 12.3 搜索参数

每个模块使用统一的基础模板：

```json
{
  "current": 1,
  "pageSize": 10,
  "sort": {},
  "combineSearch": { "searchMode": "AND", "conditions": [] },
  "keyword": "<用户搜索词>",
  "viewId": "ALL",
  "filters": []
}
```

**关键参数说明：**
- `pageSize: 10` — 全局搜索每模块只取前 10 条，避免过多数据拖慢响应
- `keyword` — 用户输入的原生搜索词（公司名、人名、手机号等）
- `viewId` — 未指定时默认 `ALL`；若用户说"我的"、"我负责的"等，改为对应角色的 `SELF`

### 12.4 响应处理流程

```
启动搜索
  │
  ├─→ 并行发起 6 个模块的 search 请求
  │
  ├─→ 等待所有请求完成（或超时 15s）
  │    ├─ 成功 → 解析列表数据
  │    └─ 失败 → 记录该模块为"查询失败"，继续处理其他模块
  │
  ├─→ 合并结果，按模块汇总
  │
  └─→ 输出跨模块概览（格式见 output-engine.md §6 多模块搜索输出格式）
```

> **超时处理**：单个模块请求超过 15 秒时放弃该模块，不影响其他模块继续搜索。最终输出中标注"XXX 模块查询超时"。

### 12.5 模块明确性判定规则

当用户只说关键词但未显式指定模块时，按以下规则判定是否需要全模块搜索：

| 用户输入 | 判定 | 动作 |
|---------|------|------|
| "查一下 xxx 公司的线索" | ✅ 明确指定模块 | 只搜 `lead` |
| "查一下 xxx 公司" / "搜索 xxx" | ❌ 未指定模块 | **执行 §12 全局模糊搜索** |
| "有没有 xxx 相关的联系人" | ✅ 明确指定模块 | 只搜 `contact` |
| "找找 xxx" / "查查 xxx" | ❌ 未指定模块 | **执行 §12 全局模糊搜索** |
| "线索池里有没有 xxx" | ✅ 明确指定模块 | 只搜 `pool/lead` |
| "帮我查一下 xxx 这个人" | ❌ 未指定模块 | **执行 §12 全局模糊搜索** |
| "看看 xxx 项目的商机" | ✅ 明确指定模块 | 只搜 `opportunity` |
| "查手机号 138xxxx" / "搜邮箱" | ❌ 未指定模块 | **执行 §12 全局模糊搜索** |

**核心判定原则：**
- 用户输入中包含「线索/客户/商机/联系人/线索池/公海」等模块关键词 → 明确指定模块
- 仅包含公司名、人名、联系方式、编号等查询内容 → 未指定模块 → 执行全局模糊搜索
- 用户说"找找 xxx"但 xxx 后带明确模块词 → 明确指定模块（例："找找 xxx 公司的联系人" → 只搜 contact）

### 12.6 角色感知的搜索范围

| 角色 | 搜索范围偏好 | viewId 规则 |
|------|-------------|-------------|
| 销售 | 全部 6 个模块 | 默认 `ALL`；若含"我的"语义 → `SELF` |
| 销售经理 | 全部 6 个模块 | 默认 `ALL`；部门范围自动扩展 |
| 财务 | 仅 account, contract 相关 | 仅搜索客户 + 合同相关模块 |

> 角色配置在 profiles/{role}.md 中定义，修改角色的 globalSearchModules 即可。

### 12.7 实际执行示例

用户："查一下 华星科技"

```bash
# 并行发起（所有命令同时执行，无先后依赖）：
cordys.sh crm search lead '{"current":1,"pageSize":10,"keyword":"华星科技","viewId":"ALL"}'
cordys.sh crm search pool/lead '{"current":1,"pageSize":10,"keyword":"华星科技","viewId":"ALL"}'
cordys.sh crm search account '{"current":1,"pageSize":10,"keyword":"华星科技","viewId":"ALL"}'
cordys.sh crm search opportunity '{"current":1,"pageSize":10,"keyword":"华星科技","viewId":"ALL"}'
cordys.sh crm search pool/account '{"current":1,"pageSize":10,"keyword":"华星科技","viewId":"ALL"}'
cordys.sh crm search contact '{"current":1,"pageSize":10,"keyword":"华星科技","viewId":"ALL"}'
```

### 12.8 搜索结果样例预估

```
🔍 全局搜索："华星科技"
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📌 线索（8 条）
│ 名称 │ 公司 │ 电话 │ 负责人 │ 创建时间 │
│ ...  │ ...  │ ...  │ ...   │ ...     │

📌 线索池（8 条）
│ 名称 │ 公司 │ 电话 │ 负责人 │ 创建时间 │
│ ...  │ ...  │ ...  │ ...   │ ...     │

📌 客户（2 条）
│ 名称 │ 行业 │ 省份 │ 负责人 │ 创建时间 │
│ ...  │ ...  │ ...  │ ...   │ ...     │

📌 商机（2 条）
│ 名称 │ 金额 │ 阶段 │ 负责人 │ 创建时间 │
│ ...  │ ...  │ ...  │ ...   │ ...     │

📌 公海（0 条）
（无匹配结果）

📌 联系人（10 条）
│ 姓名 │ 公司 │ 手机 │ 邮箱 │
│ ...  │ ...  │ ...  │ ...  │

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 汇总：共找到 30 条匹配记录
```
