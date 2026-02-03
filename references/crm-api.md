# CORDYS CRM API 参考

## 概览
这是 Cordys CRM API 的简要参考，涵盖线索（lead）、客户（account）、商机（opportunity）模块的常见用法。所有请求均需通过 `X-Access-Key` + `X-Secret-Key` 鉴权，并以你的 `CORDYS_CRM_DOMAIN` 为基准域名。

## 模块清单
| 模块名称 | 描述 |
| --- | --- |
| `lead` | 线索（潜在客户）记录 |
| `account` | 客户/公司信息 |
| `opportunity` | 商机数据 |

## 通用请求体结构
```json
{
  "current": 1,
  "pageSize": 30,
  "sort": {},
  "combineSearch": {
    "searchMode": "AND",
    "conditions": []
  },
  "keyword": "测试",
  "viewId": "ALL",
  "filters": []
}
```
字段解释：
- `current`：页码，从 1 开始
- `pageSize`：每页记录数
- `sort`：排序对象（例如 `{"createTime":"desc"}`）
- `combineSearch`：组合查询结构，可定义多个条件
- `keyword`：全局关键词（名称、电话、说明等）
- `viewId`：视图 ID，默认 `ALL`
- `filters`：具体字段筛选器（数组形式）

## API 端点
| 方法       | 路径                        | 说明 |
|----------|---------------------------| --- |
| `POST`   | `/{module}/page`          | 分页列出模块记录 |
| `GET`    | `/{module}/{id}`          | 获取单条记录详情 |
| `POST`   | `/global/search/{module}` | 搜索记录（关键词+复杂条件） |

> 示例完整 URL：`https://cordys-crm.fit2cloud.cn/global/search/lead`

## 搜索示例
### 关键词查询（默认结构）
```bash

cordys crm search lead '{"current":1,"pageSize":50,"sort":{"followTime":"desc"},"combineSearch":{"searchMode":"AND","conditions":[{"field":"phone","operator":"equals","value":"18900001234"}]},"keyword":"","viewId":"ALL","filters":[]}'

```
CLI 会自动填充 `current/pageSize/sort/combineSearch/viewId/filters`，只需要提供关键词即可。

### 自定义请求体
```bash
cordys crm search account '{"current":1,"pageSize":50,"sort":{"followTime":"desc"},"combineSearch":{"searchMode":"AND","conditions":[{"field":"phone","operator":"equals","value":"18900001234"}]},"keyword":"","viewId":"ALL","filters":[]}'
```

## 响应结构
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
`list` 中每条记录常见字段：`id`、`name`、`owner`、`ownerName`、`products`、`phone`、`moduleFields`、`followTime`，以实际返回为准。

## 错误示例
```json
{
  "code": "INVALID_KEY",
  "message": "无效的 Access Key",
  "details": {}
}
```
常见错误码还有 `ACCESS_DENIED`、`INVALID_REQUEST` 等，`message` 会说明原因。

## 最佳实践
1. **分页**：处理大数据时用 `current/pageSize` 控制，避免一次拉取太多。
2. **关键词 + filters 组合**：先用关键词粗筛，再用 `filters` 精细过滤。
3. **排序**：通过 `sort` 让结果稳定（如按 `followTime` 降序）。
4. **错误处理**：对 `code` 非 `100200` 的响应做重试或报警。
5. **密钥管理**：不要把 `Access Key`/`Secret Key` 提交到版本库。

## 参考链接
- [Cordys CRM 官方文档](https://cordys.cn/docs/)
