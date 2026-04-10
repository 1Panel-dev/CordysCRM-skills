# CordysCRM-skills 安装指南

---

## 🚀 一键安装

**执行命令：**
```bash
git clone --depth 1 https://github.com/hao65103940/CordysCRM-skills.git /tmp/cordys-crm-temp
cp -r /tmp/cordys-crm-temp/skills ~/.openclaw/skills/cordys-crm
rm -rf /tmp/cordys-crm-temp
```

**或者指定分支：**
```bash
git clone --depth 1 --branch v2.0-general https://github.com/hao65103940/CordysCRM-skills.git /tmp/cordys-crm-temp
cp -r /tmp/cordys-crm-temp/skills ~/.openclaw/skills/cordys-crm
rm -rf /tmp/cordys-crm-temp
```

---

## 📋 安装流程说明

### 步骤 1：检查是否已安装

```bash
ls -la ~/.openclaw/skills/cordys-crm/
```

**如果目录不存在** → 首次安装，直接执行步骤 2

**如果目录已存在** → 需要确认是否覆盖：
```
⚠️ CordysCRM-skills 已安装，是否覆盖？
   - 覆盖：继续执行步骤 2（会备份旧版本）
   - 取消：终止安装
```

### 步骤 2：克隆仓库

```bash
git clone --depth 1 https://github.com/hao65103940/CordysCRM-skills.git /tmp/cordys-crm-temp
```

### 步骤 3：复制到技能目录

```bash
cp -r /tmp/cordys-crm-temp/skills ~/.openclaw/skills/cordys-crm
```

### 步骤 4：设置权限

```bash
chmod +x ~/.openclaw/skills/cordys-crm/bin/*
chmod +x ~/.openclaw/skills/cordys-crm/scripts/*.sh
```

### 步骤 5：清理临时文件

```bash
rm -rf /tmp/cordys-crm-temp
```

---

## ⚙️ 安装后配置

### 1. 配置环境变量

```bash
cd ~/.openclaw/skills/cordys-crm
cp .env.example .env
vim .env
```

**填写以下内容：**
```bash
ACCESS_KEY=你的 AccessKey
SECRET_KEY=你的 SecretKey
CRM_DOMAIN=https://你的 crm 域名
```

**获取 API 密钥：**
- 登录 Cordys CRM 后台
- 进入「设置」→「API 管理」
- 创建或查看现有的 AccessKey/SecretKey

### 2. 测试连接

```bash
~/.openclaw/skills/cordys-crm/bin/cordys crm page lead
```

**成功响应：**
```json
{
  "code": "100200",
  "data": { "list": [], "total": 0 },
  "message": "success"
}
```

### 3. 配置字段自动同步（推荐）

**Cordys CRM 字段定义可能更新，定期同步避免查询失败。**

**方式 1 - Crontab（推荐）：**
```bash
(crontab -l 2>/dev/null; echo "0 2 * * 0 ~/.openclaw/skills/cordys-crm/scripts/sync-fields.sh >> ~/crm-fields-sync.log 2>&1") | crontab -
```

**方式 2 - OpenClaw Cron：**
```bash
openclaw cron add --file ~/.openclaw/skills/cordys-crm/scripts/openclaw-cron.json
```

---

## 🔍 验证安装

```bash
# 检查文件是否存在
ls -la ~/.openclaw/skills/cordys-crm/bin/cordys

# 检查权限
~/.openclaw/skills/cordys-crm/bin/cordys --help

# 测试查询
~/.openclaw/skills/cordys-crm/bin/cordys crm page lead
```

---

## 📚 文档位置

| 文档 | 说明 |
|------|------|
| `README.md` | 使用说明 |
| `SKILL.md` | 技能定义 |
| `references/crm-api.md` | API 接口参考 |
| `rules/platform/fields.md` | 字段映射表 |
| `rules/company/glossary.md` | 术语映射（飞致云） |

---

## ❓ 故障排查

### 问题 1：git clone 失败

**错误：** `Failed to connect to github.com`

**解决：**
```bash
# 检查网络
ping github.com

# 手动下载
curl -fsSL https://github.com/hao65103940/CordysCRM-skills/archive/main.tar.gz -o cordys-crm.tar.gz
tar -xzf cordys-crm.tar.gz
cp -r CordysCRM-skills-main/skills ~/.openclaw/skills/cordys-crm
```

### 问题 2：命令找不到

**错误：** `bash: cordys: command not found`

**解决：**
```bash
# 使用完整路径
~/.openclaw/skills/cordys-crm/bin/cordys crm page lead

# 或添加到 PATH
export PATH="$HOME/.openclaw/skills/cordys-crm/bin:$PATH"
```

### 问题 3：API 连接失败

**错误：** `401 Unauthorized`

**解决：**
```bash
# 检查 .env 文件
cat ~/.openclaw/skills/cordys-crm/.env

# 确认：
# 1. ACCESS_KEY 和 SECRET_KEY 是否正确
# 2. CRM_DOMAIN 是否包含 https:// 前缀
# 3. 没有多余的空格或引号
```

---

## 📝 版本信息

- **技能版本**：2.0.0
- **最后更新**：2026-04-10
- **仓库地址**：https://github.com/hao65103940/CordysCRM-skills
