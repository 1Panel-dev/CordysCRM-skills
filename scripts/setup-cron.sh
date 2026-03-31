#!/bin/bash

# Cordys CRM 定时任务配置脚本
# 用途：一键配置字段自动同步
# 使用：./scripts/setup-cron.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
SYNC_SCRIPT="$ROOT_DIR/scripts/sync-fields.sh"

# 颜色输出
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}  Cordys CRM 定时任务配置${NC}"
echo -e "${GREEN}================================${NC}"
echo ""

# 检查 .env 文件
if [ ! -f "$ROOT_DIR/.env" ]; then
    echo -e "${RED}错误：.env 文件不存在${NC}"
    echo "请先配置 API 密钥："
    echo "  cp $ROOT_DIR/.env.example $ROOT_DIR/.env"
    echo "  vim $ROOT_DIR/.env"
    exit 1
fi

echo "选择配置方式："
echo ""
echo "  1) Crontab（推荐，简单通用）"
echo "  2) OpenClaw Cron（需要 OpenClaw 支持）"
echo "  3) 取消配置"
echo ""
read -p "请选择 [1-3] " CHOICE

case $CHOICE in
    1)
        echo ""
        echo -e "${YELLOW}配置 Crontab 定时任务...${NC}"
        
        # 创建临时 crontab 文件
        TEMP_CRON=$(mktemp)
        crontab -l 2>/dev/null > "$TEMP_CRON" || true
        
        # 添加新任务
        echo "" >> "$TEMP_CRON"
        echo "# Cordys CRM 字段同步 - 每周日凌晨 2 点" >> "$TEMP_CRON"
        echo "0 2 * * 0 $SYNC_SCRIPT >> $HOME/crm-fields-sync.log 2>&1" >> "$TEMP_CRON"
        
        # 安装 crontab
        crontab "$TEMP_CRON"
        rm -f "$TEMP_CRON"
        
        echo ""
        echo -e "${GREEN}✓ Crontab 配置完成${NC}"
        echo ""
        echo "同步频率：每周日凌晨 2 点"
        echo "查看配置：crontab -l"
        echo "查看日志：tail -f $HOME/crm-fields-sync.log"
        echo ""
        echo -e "${YELLOW}手动运行同步：${NC}$SYNC_SCRIPT"
        ;;
        
    2)
        echo ""
        echo -e "${YELLOW}配置 OpenClaw Cron...${NC}"
        
        CRON_FILE="$ROOT_DIR/scripts/openclaw-cron.json"
        
        if command -v openclaw &> /dev/null; then
            if openclaw cron add --file "$CRON_FILE" 2>/dev/null; then
                echo ""
                echo -e "${GREEN}✓ OpenClaw Cron 配置完成${NC}"
                echo ""
                echo "同步频率：每周日凌晨 2 点"
                echo "查看任务：openclaw cron list"
                echo ""
            else
                echo -e "${RED}✗ 配置失败${NC}"
                exit 1
            fi
        else
            echo -e "${RED}✗ OpenClaw 未安装${NC}"
            exit 1
        fi
        ;;
        
    3)
        echo "已取消配置"
        exit 0
        ;;
        
    *)
        echo -e "${RED}无效选择${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}  配置完成！${NC}"
echo -e "${GREEN}================================${NC}"
