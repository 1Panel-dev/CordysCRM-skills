# 字段同步配置

> 定期同步 CRM 字段定义，保持本地配置与 CRM 系统一致

---

## ❓ 为什么需要同步？

CRM 系统的字段定义可能会更新：
- 新增自定义字段
- 修改字段 ID
- 调整字段类型

定期同步确保本地 `config/fields.json` 与 CRM 保持一致，避免查询失败。

---

## 🔄 同步方式

### 方式一：Cron Job（推荐 - 个人电脑/普通服务器）

**步骤：**

```bash
# 1. 编辑定时任务
crontab -e

# 2. 添加以下内容（每周日凌晨 2:00 同步）
0 2 * * 0 /root/.openclaw/skills/cordys-crm/scripts/sync-fields.sh >> /var/log/crm-fields-sync.log 2>&1

# 3. 保存退出

# 4. 查看已安装的任务
crontab -l
```

**日志位置：** `/var/log/crm-fields-sync.log`

---

### 方式二：systemd Timer（推荐 - Linux 服务器/生产环境）

**步骤：**

```bash
# 1. 复制配置文件到 systemd 目录
sudo cp scripts/systemd/crm-fields-sync.* /etc/systemd/system/

# 2. 重新加载 systemd 配置
sudo systemctl daemon-reload

# 3. 启用并启动定时器
sudo systemctl enable --now crm-fields-sync.timer

# 4. 查看状态
sudo systemctl status crm-fields-sync.timer
sudo systemctl list-timers | grep crm-fields-sync
```

**日志查看：**
```bash
journalctl -u crm-fields-sync.service -f
```

---

### 方式三：OpenClaw Cron（推荐 - OpenClaw 内置）

**步骤：**

```bash
# 1. 添加定时任务
cd /root/.openclaw/skills/cordys-crm
openclaw cron add --file scripts/openclaw-cron.json

# 2. 查看已添加的任务
openclaw cron list

# 3. 手动触发一次测试
openclaw cron run <job-id>
```

**日志查看：** OpenClaw 会话日志

---

### 方式四：手动同步（测试/临时）

```bash
cd /root/.openclaw/skills/cordys-crm
./scripts/sync-fields.sh
```

---

## 📋 同步脚本说明

**位置：** `scripts/sync-fields.sh`

**功能：**
1. 读取 `.env` 中的 API 密钥
2. 调用 CRM API 获取各模块字段定义
3. 更新 `config/fields.json`
4. 添加版本号和同步时间戳

**同步内容：**
- 字段 ID (`fieldId`)
- 字段名称 (`fieldName`)
- 字段类型 (`fieldType`)

**输出文件：** `config/fields.json`

---

## 📊 同步日志

| 同步方式 | 日志位置 | 查看命令 |
|----------|---------|---------|
| **Cron Job** | `/var/log/crm-fields-sync.log` | `tail -f /var/log/crm-fields-sync.log` |
| **systemd** | `journalctl` | `journalctl -u crm-fields-sync.service -f` |
| **OpenClaw** | OpenClaw 会话日志 | `openclaw cron runs <job-id>` |
| **手动** | 终端输出 | 直接查看 |

---

## ⚠️ 注意事项

1. **API 密钥有效** - 同步需要有效的 `ACCESS_KEY` 和 `SECRET_KEY`
2. **公司配置保护** - `config/company.json` 不会被覆盖（如存在）
3. **Git 版本管理** - 建议同步后检查变更：`git diff config/fields.json`
4. **同步频率** - 建议每周一次，过于频繁可能触发 API 限流

---

## 🔧 故障排查

### 问题：同步失败，提示认证错误

**原因：** API 密钥无效或过期

**解决：**
```bash
# 检查 .env 文件
cat .env

# 重新配置
cp .env.example .env
vim .env  # 填写正确的 ACCESS_KEY 和 SECRET_KEY
```

---

### 问题：同步成功但字段 ID 为空

**原因：** CRM 系统返回格式变化

**解决：**
1. 检查 `config/fields.json` 内容
2. 手动调用 API 验证：`cordys raw GET "/settings/fields?module=lead"`
3. 更新同步脚本适配新格式

---

### 问题：定时任务未执行

**Cron Job 排查：**
```bash
# 检查 cron 服务状态
sudo systemctl status cron

# 查看 cron 日志
grep CRON /var/log/syslog | tail -20
```

**systemd 排查：**
```bash
# 检查定时器状态
sudo systemctl status crm-fields-sync.timer

# 查看定时器详情
sudo systemctl cat crm-fields-sync.timer
```

---

## 📖 相关文档

- `docs/api.md` - API 接口参考
- `docs/fields.md` - 字段映射说明
- `config/fields.json` - 字段配置文件
- `scripts/sync-fields.sh` - 同步脚本
