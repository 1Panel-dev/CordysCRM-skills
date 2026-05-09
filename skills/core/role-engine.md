# 🧠 角色感知引擎

本文件定义了系统如何**自动发现用户身份**并匹配到正确的工作模式。

---

## 1. 初始化流程

每次对话开始（或 API Key 变更后），执行：

```
检查 User.md 是否存在？
├─ 存在 → 验证有效性（确认非空、含必要字段）
│   ├─ 有效 → 加载角色上下文，进入交互
│   └─ 无效 → 重新执行初始化
└─ 不存在 → 
    ├─ cordys.sh crm verify       验证 API Key
    ├─ cordys.sh crm whoami       获取用户信息 (GET /personal/center/info)
    ├─ 将结果写入 User.md         持久化用户身份
    └─ 匹配角色，加载 profiles/{role}.md
```

**换账号 / 刷新身份**：用户说"刷新身份"或"换账号" → 重新执行上述流程，覆盖 User.md。

> `User.md` 位于 skill 根目录，由系统自动管理，请勿手动编辑。

---

## 2. 角色匹配规则

根据 `whoami` 返回的 `data` 对象，按以下优先级匹配：

```python
fields = response.data

# 优先级 1：管理员（id=admin 或角色包含 admin）
if fields.id == "admin" or "admin" in str(fields.roles or ""):
    role = "sales-manager"  # 管理员默认按经理视角

# 优先级 2：管理岗（position 包含管理关键词）
elif any(kw in str(fields.position or "") for kw in 
         ["经理","总监","主管","负责人","leader","部长","总经理","主任"]):
    role = "sales-manager"

# 优先级 3：财务岗
elif any(kw in str(fields.position or "") for kw in 
         ["财务","会计","出纳","财务经理","财务总监"]):
    role = "finance"

# 优先级 4：销售岗
elif any(kw in str(fields.position or "") for kw in 
         ["销售","商务","BD","专员","顾问","业务员","运营"]):
    role = "sales"

# 兜底：无法识别时默认经理模式（权限覆盖广）
else:
    role = "sales-manager"
```

### 从行为推断（软规则）

如果 `position` 为空但能通过用户历史行为推断：
- 频繁查 `contract/payment-plan`、`invoice`、回款 → 走财务视角
- 频繁查 `org`、`members`、跨部门数据 → 走经理视角
- 频繁查自己的 lead/opportunity → 走销售视角

此规则仅作为补充，不覆盖 position 匹配。

---

## 3. User.md 生命周期

### 创建
```markdown
# 🧠 用户身份上下文

> 自动获取：2026-05-09 10:30
> 匹配角色：sales-manager

| 字段 | 值 |
|------|-----|
| 用户ID | admin |
| 姓名 | 张三 |
| 岗位 | 销售一部经理 |
| 邮箱 | zhang@company.com |
| 角色ID | sales-manager |
```

### 刷新条件
| 事件 | 动作 |
|------|------|
| 用户说"刷新身份" | 重新执行初始化 |
| 用户说"换账号" | 清除 User.md + 重新初始化 |
| 连续 3 次 API 调用返回 401/403 | 提示用户检查密钥，建议刷新 |
| 从创建起超过 7 天 | 后台静默刷新（不打扰用户） |

### 约束
- `User.md` 是运行时产物，**不提交版本控制**
- AI 每次对话第一件事：确认 User.md 就绪且有效
- 如果 User.md 存在但解析失败（格式损坏），视为不存在
