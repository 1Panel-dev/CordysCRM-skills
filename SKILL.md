# Cordys CRM 集成

## 快速开始

使用 `CordysCRM` CLI工具。

```bash
cordys help          # 显示所有命令
```

### 配置环境变量

在技能目录中创建 `.env` 文件：

```bash
CORDYS_ACCESS_KEY=你的 Access Key
CORDYS_SECRET_KEY=你的 Secret Key
CORDYS_CRM_DOMAIN=你的 CRM 域名 URL
```

## CRM命令

```bash
# 列出任何模块的记录
cordys crm list lead
cordys crm list opportunity
cordys crm list account
cordys crm list pool

# 获取特定记录
cordys crm get lead "1234567890"

# 使用条件搜索
cordys crm search opportunity "{"current":1,"pageSize":30,"combineSearch":{"searchMode":"AND","conditions":[]},"keyword":"测试","filters":[]}"

```

### CRM模块
可以通过 API 文档查看所有模块和字段定义。

### 搜索运算符
equals（等于）, not_equal（不等于）, starts_with（以...开头）, contains（包含）, not_contains（不包含）, in（在...中）, not_in（不在...中）, between（在...之间）, greater_than（大于）, less_than（小于）

## 原始 API 调用

```bash
# 获取组织信息
cordys raw GET /xxx

# 获取模块字段定义
cordys raw GET /xxx?module=lead

```

## 使用示例

### 销售分析查询等
```bash
# 列出一页客户
cordys crm list account

# 根据名称搜索商机
cordys crm search opportunity "{"current":1,"pageSize":30,"combineSearch":{"searchMode":"AND","conditions":[]},"keyword":"测试","filters":[]}"

# 自定义 raw API 请求
cordys raw GET /opportunity/view/list

```