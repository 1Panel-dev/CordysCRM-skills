# Cordys CRM 技能 for OpenClaw

像与人交谈一样与你的 Cordys CRM 工作区交互。商机、联系人、潜在客户 — 全部通过自然对话与你的AI助手完成。

无需在 Cordys CRM 标签页间切换。只需询问。

## 功能

此技能让你的 OpenClaw 助手直接访问 Cordys CRM：

**CRM** — 搜索、创建和更新商机、联系人、潜在客户以及任何其他模块。你的助手读取你的销售管道并采取行动。

## 目标用例-规划中

- "本月成交了多少商机？" → 助手查询 CRM，给你摘要
- "显示所有来线上/线下的潜在客户" → 使用正确的过滤器搜索 CRM
- "创建一个新的客户，名称为‘Acme Corp’，行业为‘制造业’" → 助手在 CRM 中创建记录
- "更新商机‘Big ’的阶段为‘进行中’" → 助手找到并更新记录
- "列出所有上周联系过的客户" → 助手查询并返回结果

## 包含内容

```
CordysCRM-skills/
├── SKILL.md              # 助手使用说明（如何使用CLI）
├── bin/cordys            # CLI 工具
└── references/
    └── crm-api.md        # CRM字段定义和API参考
```

## 快速开始

### 1. 通过 ClawdHub 安装

```bash
clawdhub install cordys-crm
```

### 2. 注册 CORDYS API 应用

访问 [CordysCRM API 文档](https://你的地址/) → 查看对应 API。

### 3. 获取访问令牌

登录 Cordys CRM 打开个人信息-> API Keys。

### 4. 配置 `.env`

在技能目录中创建 `.env` 文件：

```bash
CORDYS_ACCESS_KEY=你的 Access Key
CORDYS_SECRET_KEY=你的 Secret Key
CORDYS_CRM_DOMAIN=你的 CRM 域名 URL
```

## CLI 使用

`CordysCRM` CLI也可以独立使用 — 你不需要 OpenClaw 就能使用它。

```bash
cordys help                                  # 所有命令
cordys crm view account                        # 列出列表视图
cordys crm page lead "测试关键词"           # 自动构造分页/过滤结构并调用 /lead/page
cordys crm page lead '{"current":1,"pageSize":30,"sort":{},"combineSearch":{"searchMode":"AND","conditions":[]},"keyword":"","viewId":"ALL","filters":[]}'
cordys crm search account '{"current":1,"pageSize":30,"sort":{},"combineSearch":{"searchMode":"AND","conditions":[]},"keyword":"xxx","viewId":"ALL","filters":[]}'
cordys raw GET /settings/fields?module=account # 原始 API 调用
```

### 搜索模式
 `crm page` 列表页搜索支持两种调用方式：
1. **单个关键词**（例如 `cordys crm page lead "测试"`）：CLI 会自动构造标准请求体，包含 `current`/`pageSize`/`sort`/`combineSearch`/`viewId`/`filters`，并调用 `/lead/page`。
2. **完整 JSON**：如果你需要自定义条件（分页、视图、filters、排序等），直接传完整 JSON 请求体（确保包含 `viewId` 和 `filters`）。

`crm search` 全局搜索
**仅支持完整 JSON**：（例如 `'{"current":1,"pageSize":30,"sort":{},"combineSearch":{"searchMode":"AND","conditions":[]},"keyword":"","viewId":"ALL","filters":[]}'`）：CLI 会自动构造标准请求体，包含 `current`/`pageSize`/`sort`/`combineSearch`/`viewId`/`filters`，并调用 `/lead/page`。



