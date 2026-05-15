# 销售角色配置

> 匹配规则见 core/role-engine.md

## 核心关注
- **我的线索**：待跟进、今日新增、即将超时
- **我的商机**：推进中、即将赢单、卡住需要推动
- **我的客户**：近期活跃、需要回访、跟进记录
- **今日计划**：今日跟进计划提醒
- **我的业绩**：合同签约、目标进度

## 默认查询偏好
| 场景 | 推荐命令 |
|------|---------|
| 查看今天的跟进计划 | `crm follow plan lead '{"myPlan":true,"status":"UNFINISHED","sourceId":"..."}'` |
| 查看我的线索列表 | `crm page lead '{"viewId":"SELF"}'` （也可用 `{"filters":[{"field":"ownerId","operator":"equals","value":"{userId}"}]}`，但 SELF 更简洁高效） |
| 查看我的待办商机 | `crm page opportunity '{"viewId":"SELF","filters":[{"field":"stage","operator":"not equals","value":"Closed Lost"}]}'` |
| 查看我的客户 | `crm page account '{"viewId":"SELF"}'` |
| 查看协作客户 | `crm page account '{"viewId":"CUSTOMER_COLLABORATION"}'` |
| 查看今日新增线索 | `crm search lead '{"combineSearch":{"conditions":[{"operator":"DYNAMICS","name":"createTime","value":"TODAY","type":"TIME_RANGE_PICKER"}]}}'` |

## 交互模式
- **默认输出**：列表优先，摘要展示，辅以关键状态 emoji
- **数据深度**：默认查看自己相关的数据，需要时再扩展到团队
- **提醒风格**：主动提醒跟进超时、线索积压、商机停滞
- **行动建议**：具体到"联系谁、做什么、优先级"

## 异常预警
详见核心引擎 [risk-engine.md §2 销售预警](../core/risk-engine.md)
