# CORDYS CRM API 参考

## 概览
这是 cordys CRM API 的简要参考，主要涵盖线索（lead）、客户（account）、商机（opportunity）模块的常见用法。所有请求均需使用 `X-Access-Key` + `X-Secret-Key` 鉴权，并根据实际部署填入 `CORDYS_CRM_DOMAIN`。

## 模块清单
| 模块名称 | 描述 |
| --- | --- |
| `lead` | 线索（潜在客户）记录 |
| `account` | 客户/公司信息 |
| `opportunity` | 商机和商机阶段 |

## 请求通用参数
- `current`（必填）：页码，整数，从 1 开始
- `pageSize`（可选）：每页记录数，默认 30
- `keyword`：全局搜索关键词（名称、电话、描述等）
- `filters`：数组形式的字段过滤器（具体参照 API 文档）
- `combineSearch`：复合查询结构，可定义条件组合、排序等

## 请求示例：线索关键词查找
```json
{
  "current": 1,
  "pageSize": 30,
  "combineSearch": {
    "searchMode": "AND",
    "conditions": []
  },
  "keyword": "测试",
  "filters": []
}
```

## API 端点
| 方法 | 路径 | 说明 |
| --- | --- | --- |
| `GET` | `/{module}/view/list` | 分页列出模块记录 |
| `GET` | `/{module}/{id}` | 获取单条记录详情 |
| `POST` | `/global/search/{module}` | 搜索记录（推荐用于关键词 + 复杂条件） |

> 示例路径（默认域名已由环境变量提供）：`https://cordys.cn/global/search/lead`

## 排序与分页控制
- `sort_by`：排序字段（如 `createTime`、`name`）
- `sort_order`：`asc`（升序）或 `desc`（降序）
- 响应体的 `pageSize` / `current` 表示实际返回的分页信息
- 如果超过最大页码，`data.list` 可能为空，需检查 `total`

## 响应结构（成功）
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
`list` 中每条记录常见字段：`id`、`name`、`owner`、`ownerName`、`products`、`phone`、`moduleFields`、`followTime` 等；具体字段以 API 返回为准。

## 错误示例
```json
{
  "code": "INVALID_TOKEN",
  "message": "无效的访问令牌",
  "details": {}
}
```
常见错误码：`INVALID_KEY`、`ACCESS_DENIED`、`INVALID_REQUEST` 等，均会在 `message` 中给出说明。

## 参考链接
- [Cordys CRM 官方文档](https://cordys.cn/docs/)
