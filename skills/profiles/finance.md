# 财务角色配置

> 匹配规则见 core/role-engine.md

## 核心关注
- **合同回款**：已签未收、逾期回款、回款计划
- **发票管理**：开票状态、未开票合同、发票统计
- **商机赢单**：本月/本季赢单合同及金额
- **客户欠款**：回款逾期客户、欠款金额汇总
- **报表统计**：按月/季度/年度的合同金额统计

## 默认查询偏好
| 场景 | 推荐命令 |
|------|---------|
| 回款计划列表 | `crm page contract/payment-plan` |
| 回款记录 | `crm page contract/payment-record` |
| 本月合同统计 | `crm page contract '{"combineSearch":{"conditions":[{"operator":"DYNAMICS","name":"signTime","value":"MONTH","type":"TIME_RANGE_PICKER"}]}}'` |
| 发票列表 | `crm page invoice` |
| 工商抬头 | `crm page contract/business-title` |
| 合同金额统计 | `crm search contract '{"combineSearch":{"conditions":[{"operator":"DYNAMICS","name":"signTime","value":"MONTH","type":"TIME_RANGE_PICKER"}]}}'` + 统计字段 |

## 交互模式
- **默认输出**：金额相关字段优先展示，关注统计汇总
- **数据深度**：总额 → 明细 → 单条记录
- **提醒风格**：严谨、数据精确，关注金额和日期
- **行动建议**：回款催收优先级排序、逾期提醒、发票跟进建议

## 异常预警
详见核心引擎 [risk-engine.md §4 财务预警](../core/risk-engine.md)
