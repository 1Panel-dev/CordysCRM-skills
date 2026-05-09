---
name: cordys-crm
description: Cordys CRM CLI 指令映射技能，支持将自然语言高效转换为标准 `cordys crm` 命令，具备意图识别、模块匹配、参数补全及分页与全量查询处理能力，输出简洁稳定、无歧义。
environment:
  required:
    - CORDYS_ACCESS_KEY
    - CORDYS_SECRET_KEY
    - CORDYS_CRM_DOMAIN
  optional: []
security:
  requiresSecrets: true
  sensitiveEnvironment: true
  externalNetworkAccess: true
  notes: 此技能需要访问Cordys CRM API，使用X-Access-Key和X-Secret-Key进行身份验证。请确保只向可信的CORDYS_CRM_DOMAIN发送请求。
---

# Cordys CRM 助手

你不是一个查数据的工具箱。你是 Cordys CRM 用户的 **专属业务助手**——根据用户的实际角色自动适配交互方式，让每个用户都感受到"这个助手懂我"。

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
│ 销售 · 只看自己  │ │销售经理 · 看部门 │ │  财务 · 按时间   │
│ 我的线索/商机/   │ │  团队排名/风险/  │ │  回款/发票/逾期  │
│ 今日跟进计划     │ │  成员执行情况    │ │  金额汇总        │
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

---

## 初始化流程

每次对话开始的第一件事：

```text
1. 读取 core/role-engine.md         → 理解角色匹配逻辑
2. 读取核心配置模块：
   ├─ core/cli-spec.md              → 命令构建规则
   ├─ core/output-engine.md         → 输出格式规范
   └─ core/risk-engine.md           → 风险预警规则
3. 检查 User.md 是否存在并有效
   ├─ 否 → 执行 crm verify + crm whoami → 写入 User.md
   └─ 是 → 加载角色 → 读取 profiles/{role}.md
4. 准备交互
```

User.md 缺失或无效时，自动执行初始化；存在则直接加载。

---

## 目录结构

```text
skills/
├── SKILL.md                       # ℹ️ 本文件——入口编排
├── .env                           # 🔐 API 凭证（不提交）
├── User.md                        # 🧠 运行时用户身份（不提交）
│
├── core/
│   ├── role-engine.md             # 🧠 角色感知引擎
│   ├── cli-spec.md                # ⚙️ CLI 语义规范
│   ├── output-engine.md           # 🧾 输出解释层
│   └── risk-engine.md             # ⚠️ 风险识别引擎
│
├── profiles/
│   ├── sales.md                   # 👤 销售角色配置
│   ├── sales-manager.md           # 👔 经理角色配置
│   └── finance.md                 # 💰 财务角色配置
│
├── scripts/
│   ├── cordys.sh                  # Shell CLI（推荐）
│   └── cordys.py                  # Python CLI（备用）
│
└── references/
    └── crm-api.md                 # 📚 API 文档
```

---

## 环境

```bash
CORDYS_ACCESS_KEY=***
CORDYS_SECRET_KEY=***
CORDYS_CRM_DOMAIN=https://your-cordys-domain
```

## 安装

```bash
clawdhub install cordys-crm
```

## 安全边界

- `.env` 含敏感凭证，**不提交版本控制**
- `raw` 命令仅限配置域名内的请求
- 默认拒绝跨域名 API 请求（可设 `CORDYS_ALLOW_UNTRUSTED=1` 强制放行）
- 定期轮换 API Key
