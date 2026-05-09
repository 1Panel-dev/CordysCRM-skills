# Cordys CRM Skill — 会认人的 CRM 助手

> 给 API Key 就够了。剩下的交给它。

你的 CRM 助手不该是个公式化的查表工具。  
**它应该知道你是什么角色**，然后在你问出半句话之前，已经准备好了你真正想看的内容。

---

## 一句话

```text
普通 CRM 助手：你要看什么？
我们的：销售经理您好，团队今天有 12 条新线索，其中 3 条超过 48h 未跟进，先看哪个？
```

这不是模板化的开场白。  
这是 **动态角色感知** 的结果——它自动调用了 `GET /personal/center/info`，知道你是谁，然后按你的角色加载了专属工作模式。

---

## 一个常见的误区

很多 CRM 助手期望值很高，用起来很累：

| 你以为的 | 实际体验 | 我们的做法 |
|---------|---------|----------|
| 给个 API Key 就能用 | 还得反复告诉 AI 你是谁、看什么、怎么展示 | API Key → 自动感知身份 → 直接干活 |
| AI 会猜你要什么 | 每次问半句就断，反问一大堆才能开始 | 追问最小化，有默认行为，异议再调整 |
| 数据很清楚 | 贴一堆 JSON/字段列表，自己找重点 | 按角色输出关键字段+结论+预警+建议 |
| 谁用都一样 | 销售看到的是客户数，财务想看的是金额 | 角色不同，看到的世界不同 |
| 不用学就会 | 文档几十页，命令记不住 | 说人话就够了，AI 替你翻译成命令 |

**我们的答案很直接：** 把 `CORDYS_ACCESS_KEY` / `CORDYS_SECRET_KEY` / `CORDYS_CRM_DOMAIN` 填入 `.env`，然后直接跟它说话。剩下的交给系统。

---

## 核心架构

```
┌────────────────────────────────────────────────────────────┐
│                       你一句自然语言                       │
│                  "看看最近有什么要注意的"                  │
└─────────────────────────────┬──────────────────────────────┘

                              │
         ┌─────────────────────┼────────────────────┐         
         │                     │                    │         
         ▼                     ▼                    ▼         

┌──────────────────┐ ┌──────────────────┐ ┌──────────────────┐
│  销售 · 只看自己 │ │销售经理 · 看部门 │ │  财务 · 按时间   │
│  我的线索/商机/  │ │  团队排名/风险/  │ │  回款/发票/逾期  │
│  今日跟进计划    │ │  成员执行情况    │ │  金额汇总        │
└──────────────────┘ └──────────────────┘ └──────────────────┘

                              │
┌─────────────────────────────▼──────────────────────────────┐
│                   cordys CLI 命令翻译层                    │
│                                                            │
│             自然语言 → crm page/search/get/...             │
│              自动补充分页/过滤/排序/时间范围               │
└─────────────────────────────┬──────────────────────────────┘

                              │
┌─────────────────────────────▼──────────────────────────────┐
│                       Cordys CRM API                       │
│             返回统一 JSON → 转成易懂表格+结论              │
└────────────────────────────────────────────────────────────┘
```
**零配置。**  
你只需要在 `.env` 里写好三分信息：

```ini
CORDYS_ACCESS_KEY=xxx
CORDYS_SECRET_KEY=xxx
CORDYS_CRM_DOMAIN=https://your-domain
```

---

## 角色工作模式对比

| | 销售 | 销售经理 | 财务 |
|---|---|---|---|
| **默认过滤** | 只看我的 | 看部门 | 按本月时间 |
| **数据深度** | 列表 + 摘要 | 团队统计 + 排名 | 金额汇总 + 明细 |
| **主动提醒** | 超期线索、商机卡点、今日计划 | 跟进覆盖率、低产出成员、目标落后 | 回款逾期、未开票、计划到期 |
| **查询范围** | lead / opportunity / account | 同上 + org / members | contract / payment / invoice |
| **输出侧重** | 操作建议 | 管理决策 | 数值精确 |
| **输出示例** | `⚠️ Xxx 线索已 5 天未跟进` | `🚨 部门跟进率仅 60%` | `🚨 Xxx 合同回款逾期 15 天` |

> 如果你问"全部数据"或"看别人的"，系统自动尊重你的意图，不强制过滤。

---

## CLI 命令族

```text
cordys crm page    <模块> [关键词|JSON]    分页列表
cordys crm get     <模块> <ID>             获取详情
cordys crm search  <模块> [关键词|JSON]    全局搜索
cordys crm follow  plan|record <模块> <JSON>   跟进计划/记录
cordys crm contact <模块> <ID>             联系人列表
cordys crm product [关键词|JSON]           产品列表
cordys crm org                             组织架构
cordys crm members <JSON>                  部门成员
cordys crm whoami                          当前用户信息（角色来源）
cordys crm verify                          验证 API 密钥
cordys raw          <METHOD> <PATH> [body]  原始 API 调用
```

### 二级模块

```text
contract/payment-plan      回款计划
contract/payment-record    回款记录
contract/business-title    工商抬头
invoice                    发票
opportunity/quotation      报价单
pool/lead                  线索池（需 poolId）
pool/account               公海（需 poolId）
```

---

## 交互原则

### 追问最小化

```text
❌ 用户："看看线索"
❌ AI："您想看哪个模块的线索？什么时间范围？要不要加过滤条件？"

✅ 用户："看看线索"
✅ AI（销售）：加载我的线索列表，直接展示
✅ AI（经理）：加载部门线索统计，优先展示异常项
```

### 输出人性化

```text
❌ {"code":100200,"data":{"list":[{"id":"...","name":"..."}],"total":13}}
✅ 您本月有 13 条线索，其中 3 条超过 48 小时未跟进：
   ┌───────────────────────────────────────────┐
   │ 客户名称           │ 创建时间   │ 状态    │
   ├───────────────────────────────────────────┤
   │ XXX 科技有限公司   │ 05-06      │ 🟢 新   │
   │ YYY 集团           │ 05-02      │ ⚠️ 超期 │
   └───────────────────────────────────────────┘
```

---

## 项目结构

```text
CordysCRM-skills/
├── README.md                     # 说明文档
└── skills/
    ├── SKILL.md                  # 核心指令（动态角色系统）
    ├── .env                      # 你的 API 凭证（不提交）
    ├── registry.json             # 注册信息
    ├── scripts/
    │   ├── cordys.sh             # Shell CLI（推荐）
    │   └── cordys.py             # Python CLI（备用）
    ├── profiles/
    │   ├── role-salesperson.md   # 销售角色配置
    │   ├── role-sales-manager.md # 经理角色配置
    │   └── role-finance.md       # 财务角色配置
    └── references/
        └── crm-api.md            # API 参考文档
```

---

## 快速开始

```bash
# 1. 安装（二选一）
clawdhub install cordys-crm                                   # 推荐
git clone --branch main https://github.com/1Panel-dev/CordysCRM-skills \
  ~/.openclaw/workspace/skills/cordys-crm                      # 手动

# 2. 配置
cp .env.example skills/.env
vi skills/.env    # 填入 CORDYS_ACCESS_KEY / CORDYS_SECRET_KEY / CORDYS_CRM_DOMAIN

# 3. 验证
cd skills/scripts
bash cordys.sh crm verify   # ✅ 密钥验证成功 → 自动获取用户信息
bash cordys.sh crm whoami   # 查看你的角色信息
bash cordys.sh crm page lead  # 试试看线索
```

---

## 一次初始化，永远不用再教

大部分 CRM 助手有个共同的问题：**每次对话 AI 都不记得你是谁**。  
我们的解决方式很简单——在 Skill 目录下写一个 `User.md`：

```markdown
# 当前用户信息

| 字段 | 值 |
|------|-----|
| 用户ID | 10086 |
| 姓名 | 张三 |
| 岗位 | 销售一部经理 |
| 邮箱 | zhangsan@company.com |
| 匹配角色 | sales-manager |
```

有了它，AI 每次醒来都自带身份记忆。  

需要换账号？说一句"刷新身份"即可。

---

## 环境要求

| 依赖 | 说明 |
|------|------|
| **OpenClaw** | Skill 的运行底座 |
| **Bash / Python 3** | Shell CLI 或 Python CLI 二选一 |
| **curl** | Shell CLI 依赖 |
| **API Key + Secret** | Cordys CRM 接口凭证 |

---

## 安全边界

- `.env` 包含敏感凭证，不要提交版本控制
- `raw` 命令会向指定域名发送你的 API 凭证，仅限信任域名
- 系统默认拒绝非配置域名的请求（可设置 `CORDYS_ALLOW_UNTRUSTED=1` 强制放行）
- 定期轮换 API Key
