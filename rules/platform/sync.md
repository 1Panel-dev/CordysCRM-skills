# 字段同步指南

> 自动同步 CRM 字段定义，保持 `references/fields.md` 与系统一致

---

## 为什么需要同步

CRM 系统的字段定义可能会更新：
- 新增自定义字段
- 修改字段 ID
- 调整选项值

定期同步确保技能使用的字段映射是最新的。

---

## 同步脚本

**位置：** `scripts/sync-fields.sh`

**功能：**
1. 调用 CRM API 获取最新字段定义
2. 解析字段 ID、名称、选项值
3. 更新 `references/fields.md`

**使用方法：**
```bash
./scripts/sync-fields.sh
```

---

## 自动化方案

### 方案 1：Cron Job（Linux/macOS）

编辑 Crontab：
```bash
crontab -e
```

添加每周同步任务（每周日凌晨 2 点）：
```bash
0 2 * * 0 /root/.openclaw/skills/cordys-crm-new/scripts/sync-fields.sh
```

### 方案 2：systemd Timer（Linux）

**服务文件：** `scripts/systemd/crm-fields-sync.service`
**定时器：** `scripts/systemd/crm-fields-sync.timer`

**启用：**
```bash
sudo cp scripts/systemd/*.service /etc/systemd/system/
sudo cp scripts/systemd/*.timer /etc/systemd/system/
sudo systemctl enable crm-fields-sync.timer
sudo systemctl start crm-fields-sync.timer
```

### 方案 3：OpenClaw Cron

**配置：** `scripts/openclaw-cron.json`

**添加：**
```bash
openclaw cron add --file scripts/openclaw-cron.json
```

---

## 手动同步

如果自动同步失败，可以手动获取字段：

```bash
# 获取线索字段
cordys raw GET /settings/fields?module=lead

# 获取客户字段
cordys raw GET /settings/fields?module=account

# 获取商机字段
cordys raw GET /settings/fields?module=opportunity
```

将返回的 JSON 中的 `optionMap` 字段提取出来，更新到 `references/fields.md`。

---

## 同步频率建议

| 场景 | 频率 |
|------|------|
| 正常使用 | 每周 1 次 |
| 刚上线/字段频繁变更 | 每天 1 次 |
| 稳定期 | 每月 1 次 |

---

## 注意事项

1. **备份**：同步前自动备份旧版本到 `fields.md.bak`
2. **权限**：确保 API Key 有读取字段定义的权限
3. **验证**：同步后检查 `fields.md` 格式是否正确
