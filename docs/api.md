# Cordys CRM API 参考

> API 接口文档 + 查询语法说明

---

## 🔌 认证方式

### API Key 认证

所有请求需要携带以下请求头：

```http
X-Access-Key: your_access_key
X-Secret-Key: your_secret_key
Content-Type: application/json
```

### 获取 API Key

1. 登录 CRM 系统
2. 进入 设置 → API 管理
3. 创建新的 API Key
4. 保存 `ACCESS_KEY` 和 `SECRET_KEY`

---

## 📡 基础 URL

```
https://crm.fit2cloud.com
```

可通过环境变量 `CRM_DOMAIN` 自定义。

---

## 🔍 常用 HTTP 端点

| 方法 | 路径 | 说明 |
|------|------|------|
| `GET` | `/{module}/view/view` | 获取视图列表 |
| `GET` | `/{module}/{id}` | 获取单条记录详情 |
| `POST` | `/{module}/page` | **高级查询**：支持任意字段过滤 |
| `POST` | `/global/search/{module}` | **全局搜索**：仅搜索配置字段 |
| `GET` | `/personal/center/info` | 获取当前用户信息 |
| `GET` | `/search/config/get` | 获取搜索配置 |

> **模块名**：`lead`、`account`、`opportunity`、`contract`、`pool`、`product`、`contact`

---

## 📋 通用请求体结构

```json
{
  "current": 1,
  "pageSize": 30,
  "sort": {"createTime": "desc"},
  "combineSearch": {
    "searchMode": "AND",
    "conditions": []
  },
  "keyword": "",
  "viewId": "ALL",
  "filters": []
}
```

### 参数说明

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `current` | number | 否 | 页码（默认 1） |
| `pageSize` | number | 否 | 每页条数（默认 30） |
| `sort` | object | 否 | 排序，如 `{"createTime":"desc"}` |
| `combineSearch` | object | 否 | 组合搜索条件 |
| `keyword` | string | 否 | 全局关键词（模糊匹配） |
| `viewId` | string | 否 | 视图 ID（如 `ALL`、`MY`） |
| `filters` | array | 否 | 字段级过滤 |

---

## 🔎 search vs page 区别

| 特性 | `search` (`/global/search/{module}`) | `page` (`/{module}/page`) |
|------|-------------------------------------|--------------------------|
| **用途** | **全局搜索** - 快速查找 | **高级查询** - 精确过滤 |
| **搜索字段** | 仅限配置好的字段（名称、电话等） | **任意字段** |
| **keyword 参数** | ✅ 全局模糊匹配配置字段 | ✅ 单字段模糊匹配 |
| **filters 参数** | ✅ 支持 | ✅ 支持 |
| **combineSearch** | ✅ 支持 | ✅ 支持 |
| **使用场景** | 搜公司名、手机号 | 查"我的线索"、按产品/区域过滤 |

### 使用建议

| 场景 | 推荐接口 | 示例 |
|------|---------|------|
| 搜公司名/客户名 | `search` + `keyword` | `{"keyword":"诚泰融资租赁"}` |
| 搜手机号 | `search` + `keyword` | `{"keyword":"18616920752"}` |
| 查"我的线索" | `page` + `owner` | `{"owner":"1131998760411293"}` |
| 按产品过滤 | `page` + `filters` | `{"filters":[{"name":"products","operator":"IN","value":["MaxKB 专业版"]}]}` |
| 按区域过滤 | `page` + `filters` | `{"filters":[{"name":"1751888184000015","operator":"IN","value":["东区"]}]}` |
| 按时间范围 | `page` + `combineSearch` | `{"combineSearch":{"conditions":[{"operator":"DYNAMICS","value":"WEEK"}]}}` |

> 💡 **简单记：** `search` 用来**找人/找公司**（简单搜索），`page` 用来**查数据/做报表**（高级查询）。

---

## 🔧 组合搜索条件 (combineSearch)

### 基本结构

```json
{
  "combineSearch": {
    "searchMode": "AND",
    "conditions": [
      {
        "name": "字段 ID 或字段名",
        "operator": "操作符",
        "value": "值",
        "type": "字段类型"
      }
    ]
  }
}
```

### 支持的操作符

| 操作符 | 说明 | 示例 |
|--------|------|------|
| `EQUALS` | 等于 | `{"operator":"EQUALS","value":"东区"}` |
| `IN` | 包含（多值） | `{"operator":"IN","value":["东区","北区"]}` |
| `CONTAINS` | 包含（文本） | `{"operator":"CONTAINS","value":"科技"}` |
| `LIKE` | 模糊匹配 | `{"operator":"LIKE","value":"%上海%"}` |
| `BETWEEN` | 时间范围 | `{"operator":"BETWEEN","value":[1774540800000,1774627199000]}` |
| `DYNAMICS` | 动态时间 | `{"operator":"DYNAMICS","value":"WEEK"}` |
| `GREATER_THAN` | 大于 | `{"operator":"GREATER_THAN","value":100000}` |
| `LESS_THAN` | 小于 | `{"operator":"LESS_THAN","value":500000}` |

---

## ⏰ 动态时间常量 (DYNAMICS)

`operator: "DYNAMICS"` 时，`value` 支持以下常量：

| 常量 | 含义 |
|------|------|
| `TODAY` / `YESTERDAY` / `TOMORROW` | 今天/昨天/明天 |
| `WEEK` / `LAST_WEEK` / `NEXT_WEEK` | 本周/上周/下周 |
| `MONTH` / `LAST_MONTH` / `NEXT_MONTH` | 本月/上月/下月 |
| `LAST_SEVEN` / `SEVEN` / `THIRTY` | 过去 7 天/未来 7 天/未来 30 天 |
| `LAST_THIRTY` / `LAST_SIXTY` | 过去 30 天/过去 60 天 |
| `QUARTER` / `LAST_QUARTER` / `NEXT_QUARTER` | 本季度/上季度/下季度 |
| `YEAR` / `LAST_YEAR` / `NEXT_YEAR` | 本年/上年/下年 |
| `["CUSTOM", n, "BEFORE_DAY"]` | n 天前 |

### 示例

```json
// 本周创建的线索
{"operator":"DYNAMICS","value":"WEEK","name":"createTime"}

// 过去 30 天
{"operator":"DYNAMICS","value":"LAST_THIRTY","name":"createTime"}

// 30 天前
{"operator":"DYNAMICS","value":["CUSTOM",30,"BEFORE_DAY"],"name":"createTime"}
```

---

## 📊 响应结构

```json
{
  "code": 100200,
  "message": null,
  "messageDetail": null,
  "data": {
    "list": [...],
    "total": 74,
    "pageSize": 20,
    "current": 1
  }
}
```

### 响应码

| 响应码 | 说明 |
|--------|------|
| `100200` | ✅ 成功 |
| `ACCESS_DENIED` | ❌ 认证失败 |
| `INVALID_KEY` | ❌ 无效密钥 |
| `INVALID_REQUEST` | ❌ 请求参数错误 |
| `100500` | ❌ 服务器内部错误 |

---

## 🛠️ 原始 API 调用示例

```bash
# 查字段定义
cordys raw GET /settings/fields?module=opportunity

# 创建线索
cordys raw POST /lead '{"name":"xxx","phone":"138xxx"}'

# 更新商机阶段
cordys raw PUT /opportunity/334333371151151104 '{"stage":"SUCCESS"}'

# 创建跟进记录
cordys raw POST /lead/follow/record '{"sourceId":"xxx","content":"xxx","followMethod":"176776376843300000"}'

# 查回款计划
cordys raw POST /contract/payment-plan/page '{"sourceId":"xxx","current":1,"pageSize":20}'
```

---

## 📖 相关文档

- `docs/fields.md` - 字段映射说明
- `docs/sync.md` - 字段同步配置指南
- `rules/platform/region.md` - 区域映射规则
