# 销售经理角色配置

> 匹配规则见 core/role-engine.md

## 核心关注
- **团队看板**：部门线索总量、商机漏斗、签约进度
- **成员执行力**：跟进覆盖率、转化率、排名
- **目标达成**：团队目标进度、个人排名对比
- **风险巡检**：长期未跟进客户、商机卡点、团队短板
- **数据下钻**：从团队概览 → 个人详情 → 具体记录

## 默认查询偏好
| 场景 | 推荐命令 |
|------|---------|
| 团队线索总览 | `crm page lead '{"combineSearch":{"searchMode":"AND","conditions":[{"value":"{departmentId}","operator":"IN","name":"departmentId","multipleValue":false,"type":"TREE_SELECT"}]}}'` |
| 团队商机漏斗 | `crm page opportunity '{"combineSearch":{"searchMode":"AND","conditions":[{"value":"{departmentId}","operator":"IN","name":"departmentId","multipleValue":false,"type":"TREE_SELECT"}]}}'` |
| 部门组织架构 | `crm org` |
| 部门成员列表 | `crm members '{"departmentId":"{departmentId}"}'` |
| 团队成员跟进情况 | `crm follow plan lead '{"status":"ALL","myPlan":false}'` + 遍历成员 |
| 本月签约合同 | `crm search contract '{"combineSearch":{"conditions":[{"operator":"DYNAMICS","name":"signTime","value":"MONTH","type":"TIME_RANGE_PICKER"}]}}'` |

> **注意**：`{departmentId}` 是占位符，实际运行时 AI 会调用 `crm org` 获取组织架构树，递归展开所有子部门，替换为部门ID数组，详见 cli-spec.md 第11节「部门组织架构展开」。

## 交互模式
- **默认输出**：团队层面统计优先，附个人排名，允许下钻到个人
- **数据深度**：团队全貌 → 个人详情，提供多层下钻路径
- **提醒风格**：关注结构性问题和团队整体风险
- **行动建议**：定位到具体成员和具体问题，给出管理决策建议

## 异常预警
详见核心引擎 [risk-engine.md §3 经理预警](../core/risk-engine.md)
