# Cordys CRM Skill for OpenClaw

像与人交谈一样与你的 **Cordys CRM 工作区**交互。  
商机、联系人、潜在客户 —— 全部通过自然对话与你的 AI 助理完成。

这个 Skill 将 **Cordys CRM CLI** 包装进 **OpenClaw 会话环境**：

1. 你用自然语言描述需求
2. AI 解析意图
3. 自动转换为 `cordys` CLI 命令
4. 执行 API 请求并返回结果

借助 Prompt 的动态调优机制，用户可以在 **不修改任何代码**的情况下控制：

- 输出格式
- 过滤条件
- 排序规则
- 分页逻辑

从而让 AI 更贴合真实 CRM 业务场景。

---

# 为什么这个 Skill 有用

| 系统视角 | 用户意图 | 输出 |
|---|---|---|
| 👂 监听自然语言 | 提供模块 / 条件 / 字段 | ⚙️ 转换为 CLI / API 请求 |
| 📦 简化重复任务 | 分页 / 搜索 / CRUD | ✅ 自动执行 |
| 📊 数据同步 | 查看销售管道 / 客户数据 | 🕓 可结合 cron 自动化 |

---
# 项目结构

```
CordysCRM-skills/
├── README.md             # 当前说明
└── skills/               # 可直接打包的 skill 内容
    ├── SKILL.md          # Skill 的元数据与使用说明
    ├── references/       # 额外的 API/领域文档
    │   └── crm-api.md    # Cordys CRM 的字段/请求体规范
    └── scripts/          # 可执行的 CLI 脚本（Shell + Python）
        ├── cordys
        └── cordys.py
```

## 快速开始

```bash
curl -fsSL https://raw.githubusercontent.com/1Panel-dev/CordysCRM-skills/main/install.sh | bash
```
## 手动安装

```bash
# 克隆 CordysCRM-skills 仓库到 OpenClaw 的 skills 目录 （如果已有同名目录请先备份或删除）版本号可根据需要调整
git clone --branch main https://github.com/1Panel-dev/CordysCRM-skills ~/.openclaw/workspace/skills/CordysCRM-skills
# 将克隆的目录重命名为 cordys-crm
mv ~/.openclaw/workspace/skills/CordysCRM-skills/skills ~/.openclaw/workspace/skills/cordys-crm
# 删除克隆的仓库目录
rm -rf ~/.openclaw/workspace/skills/CordysCRM-skills

```
## 环境配置

```bash 
# 将克隆的目录重命名为 cordys-crm
mv ~/.openclaw/workspace/skills/cordys-crm/.env.example ~/.openclaw/workspace/skills/cordys-crm/.env

# 编辑 .env 文件，配置 Cordys CRM 的 API 访问地址和认证信息

# 示例：
# CORDYS_BASE_URL=https://your-cordys-instance.com
# CORDYS_API_KEY=your_api_key
# CORDYS_API_SECRET=your_api_secret

```

## 验证

```bash

cd ~/.openclaw/workspace/skills/cordys-crm

# 运行 CLI 脚本，查看帮助信息
./scripts/cordys help

# 运行示例命令，查看线索列表
./scripts/cordys crm page lead

```