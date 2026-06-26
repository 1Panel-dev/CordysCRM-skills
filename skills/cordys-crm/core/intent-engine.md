# 🧭 意图路由引擎

本文件定义了 AI 如何**理解用户意图**并**路由到正确的执行路径**。
不包含具体业务操作细节——那些在各 `profiles/{role}.md` 的「典型工作流」章节中。

---

## 1. 意图识别与路由

AI 收到用户输入后，按以下优先级匹配：

```
用户输入
  ├─ 优先级 1：显式模块 + 操作（"查线索"、"创建客户"）→ 直接路由到 cli-spec.md 对应命令
  ├─ 优先级 2：模糊工作指令（"今天做什么"、"这周怎么样"）→ 查 §3 意图映射表，加载对应 profile 的工作流
  ├─ 优先级 3：模糊搜索（"搜一下XX"）→ 触发全局模糊搜索（cli-spec.md §11）
  ├─ 优先级 4：L2C 链路追踪（"查查这笔单子"、"XX公司全景"）→ 触发 linkage-engine.md
  └─ 优先级 5：无法识别 → 提示用户细化意图
```

---

## 2. 路由策略

| 路由层级 | 处理方式 |
|---------|---------|
| **显式命令** | 直接从 cli-spec.md 构造命令，不经过工作流引擎 |
| **模糊指令** | 匹配 §3 映射表 → 加载对应 profile → 执行该 profile 中定义的工作流 |
| **写操作** | 路由到 write-engine.md，先取表单定义再执行 |
| **链路追踪** | 路由到 linkage-engine.md |
| **漏斗分析** | 路由到 funnel-engine.md |

### 写操作路由

| 用户说 | 路由 |
|--------|------|
| 创建/新建/添加 + 模块名 | `write-engine.md` → create 流程 |
| 修改/更新/编辑 + 模块名 | `write-engine.md` → update 流程 |
| 批量创建/批量导入 | `write-engine.md` → batch create 流程 |
| 线索转客户/线索转商机/转化 | `write-engine.md` → transition 流程 |

> 完整写操作规范见 `core/write-engine.md`。

---

## 3. 意图 → 工作流映射表

| 用户说 | 目标角色 | 加载 profile | 执行工作流章节 |
|--------|---------|-------------|--------------|
| "今天做什么" / "有什么要跟的" | 销售 | `sales.md` | 日常 §晨会速览 |
| "这周怎么样" / "周报" | 销售 | `sales.md` | 周常 §周回顾 |
| "先跟哪个" / "优先级" | 销售 | `sales.md` | 日常 §跟进排序 |
| "看看XX公司" | 全部 | `sales.md`（默认） | 日常 §客户深耕 |
| "本月做了多少" | 销售 | `sales.md` | 月常 §月度总结 |
| "团队今天" / "部门概览" | 经理 | `sales-manager.md` | 日常 §团队晨会 |
| "团队这周" / "部门周会" | 经理 | `sales-manager.md` | 周常 §周会数据 |
| "批一下" / "待审批" | 经理/财务 | 按当前角色 | 审批巡检 |
| "团队问题" / "风险巡检" | 经理 | `sales-manager.md` | 周常 §风险巡检 |
| "本月复盘" | 经理 | `sales-manager.md` | 月常 §月度复盘 |
| "下月预测" | 经理 | `sales-manager.md` | 月常 §管道预测 |
| "公司情况" / "经营数据" | 高管 | `executive.md` | 日常 §快照速览 |
| "目标怎么样" / "季度预测" | 高管 | `executive.md` | 月常 §季度预测 |
| "这周全公司" | 高管 | `executive.md` | 周常 §周度脉搏 |
| "人均产出" / "人效" | 高管 | `executive.md` | 月常 §人效分析 |
| "今天回款" / "回款情况" | 财务 | `finance.md` | 日常 §回款日报 |
| "欠款情况" / "催款" | 财务 | `finance.md` | 周常 §应收全景 |
| "开票情况" | 财务 | `finance.md` | 周常 §开票检查 |
| "合同回款进度" / "现金链路" | 财务 | `finance.md` | 月常 §合同→现金链 |
| "本月财报" | 财务 | `finance.md` | 月常 §月度财报 |
| "审批到哪了" / "合同审批" | 商务 | `contract-admin.md` | 日常 §合同审批追踪 |
| "今天签了什么" | 商务 | `contract-admin.md` | 日常 §今日待签 |
| "合同到期" / "续约" | 商务 | `contract-admin.md` | 周常 §到期预警 |
| "本月签约月报" | 商务 | `contract-admin.md` | 月常 §月度统计 |
| "查查这笔单子" / "链路追踪" | 全部 | — | `linkage-engine.md`（通用） |
| "搜一下XX" / "查找XX" | 全部 | — | cli-spec.md §11 全局搜索 |
| "创建线索" / "新建客户" | 全部 | — | `write-engine.md` |

---

## 4. 参数默认值表

| 场景 | viewId | 排序 | 时间范围 |
|------|--------|------|---------|
| 销售看自己 | `SELF` | `followTime:asc` | 不限 |
| 经理看团队 | `ALL` + departmentId | `createTime:desc` | 不限 |
| 高管看全公司 | `ALL` | `signTime:desc` | 不限 |
| 商务看合同 | `ALL` | `signTime:desc` | 不限 |
| 财务看回款 | `ALL` | `planPayTime:asc` | 不限 |
| 今日 | 按角色 | - | `TODAY` |
| 本周 | 按角色 | - | `WEEK` |
| 本月 | 按角色 | - | `MONTH` |

---

## 5. 通用 L2C 追踪工作流（跨角色）

### 5.1 全链路追踪（"查查这笔单子"）

```
用户说："查查合同 CRM-2026-001"

执行：
  1. cordys.sh crm page contract → 用 keyword="CRM-2026-001" 找到合同
  2. cordys.sh crm get contract {id} → 获取详情（含关联字段）
  3. 反向追溯：合同 → 商机 → 客户 → 线索
  4. 正向追踪：合同 → 回款计划 → 回款记录 → 发票
  5. 输出：完整 L2C 时间线
```

### 5.2 搜索即链路

当用户用全局模糊搜索时，除了分别展示各模块结果，还自动做关联分析：

```
1. 命中 account → 标注"该客户名下发现 N 个商机"
2. 命中 lead + account → 标注"线索XX可能已转化为该客户"
3. 命中 contract → 标注"回款进度 X%"
```

---

## 6. 引擎加载优先级

```
启动时必加载：
  core/role-engine.md        角色匹配

查询场景按需加载：
  core/cli-spec.md           构造命令（每次必用）
  core/output-engine.md      格式化输出（每次必用）
  core/intent-engine.md      意图路由（模糊指令时）
  core/risk-engine.md        扫描风险（展示数据后）
  core/cli-reference.md      字段类型映射（构造 conditions 时）
  core/linkage-engine.md     跨模块关联追踪（追踪链路时）
  core/funnel-engine.md      漏斗分析（看转化/管道时）

写入场景按需加载：
  core/write-engine.md       创建/更新/转换操作
  rules/form-rules/{module}.md  自定义表单规则（如存在）
  rules/field-mapping/{场景}.md  自定义字段映射（如存在）
  rules/business-rules/{模块}.md 自定义业务规则（如存在）
```
