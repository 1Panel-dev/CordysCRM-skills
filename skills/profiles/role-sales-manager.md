# 销售经理角色配置

> 自动匹配条件：position 包含"经理"、"总监"、"主管"、"负责人"、"leader" 或 roles 包含管理角色

## 核心关注
- **团队看板**：部门线索总量、商机漏斗、签约进度
- **成员执行力**：跟进覆盖率、转化率、排名
- **目标达成**：团队目标进度、个人排名对比
- **风险巡检**：长期未跟进客户、商机卡点、团队短板
- **数据下钻**：从团队概览 → 个人详情 → 具体记录

## 默认查询偏好
| 场景 | 推荐命令 |
|------|---------|
| 团队线索总览 | `crm page lead '{"filters":[{"field":"departmentId","operator":"equals","value":"{departmentId}"}]}'` |
| 团队商机漏斗 | `crm page opportunity '{"filters":[{"field":"departmentId","operator":"equals","value":"{departmentId}"}]}'` |
| 部门组织架构 | `crm org` |
| 部门成员列表 | `crm members '{"departmentIds":["{departmentId}"]}'` |
| 团队成员跟进情况 | `crm follow plan lead '{"status":"ALL","myPlan":false}'` + 遍历成员 |
| 本月签约合同 | `crm search contract '{"combineSearch":{"conditions":[{"operator":"DYNAMICS","name":"signTime","value":"MONTH","type":"TIME_RANGE_PICKER"}]}}'` |

## 交互模式
- **默认输出**：团队层面统计优先，附个人排名，允许下钻到个人
- **数据深度**：团队全貌 → 个人详情，提供多层下钻路径
- **提醒风格**：关注结构性问题和团队整体风险
- **行动建议**：定位到具体成员和具体问题，给出管理决策建议

## 异常预警
| 场景 | 预警提示 |
|------|---------|
| 团队线索跟进率低于阈值 | `🚨 团队本周线索跟进率仅 {N}%，低于 {M}% 警戒线` |
| 某成员连续低产出 | `⚠️ {成员} 连续 2 周商机转化率为 0，建议 1v1 沟通` |
| 部门目标进度落后 | `📊 部门目标完成 {N}%，时间过半但进度未过半，需加大推进` |
| 长期未跟进客户集中 | `🚨 超过 {N} 天未跟进的客户有 {M} 个，集中在 {成员} 名下` |
