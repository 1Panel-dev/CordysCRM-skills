# 财务角色配置

> 自动匹配条件：position 包含"财务"、"会计"、"出纳"、"财务经理" 或 roles 包含财务角色

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
| 场景 | 预警提示 |
|------|---------|
| 回款逾期 | `🚨 合同 {name} 回款已逾期 {N} 天，金额 {amount} 元` |
| 未开票合同占比过高 | `⚠️ 本月签约合同中有 {N}% 尚未开票` |
| 回款计划密集到期 | `📋 未来 7 天内有 {N} 笔回款计划到期，总金额 {amount} 元` |
