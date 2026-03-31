#!/bin/bash

# Cordys CRM Skill 加载时检查脚本
# 用途：检查配置状态并提醒用户

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
ENV_FILE="$ROOT_DIR/.env"
FIELDS_FILE="$ROOT_DIR/rules/platform/fields.md"

# 检查 .env 文件
if [ ! -f "$ENV_FILE" ]; then
    echo "⚠️  检测到未配置 API 密钥"
    echo ""
    echo "请运行以下命令配置："
    echo "  cp $ROOT_DIR/.env.example $ENV_FILE"
    echo "  vim $ENV_FILE"
    echo ""
fi

# 检查字段映射文件更新时间
if [ -f "$FIELDS_FILE" ]; then
    # 获取文件修改时间（天数）
    if command -v stat &> /dev/null; then
        # macOS
        MTIME=$(stat -f %m "$FIELDS_FILE" 2>/dev/null || echo "0")
    else
        # Linux
        MTIME=$(stat -c %Y "$FIELDS_FILE" 2>/dev/null || echo "0")
    fi
    
    NOW=$(date +%s)
    DAYS=$(( (NOW - MTIME) / 86400 ))
    
    if [ "$DAYS" -gt 30 ]; then
        echo "⚠️  字段映射文件已超过 ${DAYS} 天未更新"
        echo ""
        echo "建议运行同步脚本更新字段定义："
        echo "  $ROOT_DIR/scripts/sync-fields.sh"
        echo ""
        echo "或配置自动同步（推荐）："
        echo "  crontab $ROOT_DIR/scripts/cron-example"
        echo ""
    fi
fi

# 检查是否配置了定时任务
if ! crontab -l 2>/dev/null | grep -q "sync-fields.sh" && \
   ! systemctl is-active --quiet crm-fields-sync.timer 2>/dev/null; then
    echo "💡  提示：建议配置自动同步定时任务"
    echo ""
    echo "选择一种方式："
    echo "  1. Crontab:    crontab $ROOT_DIR/scripts/cron-example"
    echo "  2. systemd:    sudo systemctl enable crm-fields-sync.timer"
    echo "  3. OpenClaw:   openclaw cron add --file $ROOT_DIR/scripts/openclaw-cron.json"
    echo ""
fi
