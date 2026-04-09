# 全量查询最佳实践

> **实战日期：** 2026-04-01  
> **问题来源：** 商机按销售阶段统计，误把单页当全量  
> **数据规模：** 23,833 条商机，48 页  
> **权威文档：** [`references/crm-api.md`](../references/crm-api.md#8-全量查询分页循环)

---

## 📚 官方文档位置

**此实战经验的权威版本已收录到：** `references/crm-api.md` 第 8 节 "全量查询（分页循环）"

本文档保留完整实战案例、详细脚本和背景说明，适合深入阅读。  
**快速查阅标准流程请查看：** [`crm-api.md#8-全量查询分页循环`](../references/crm-api.md#8-全量查询分页循环)

---

## 🚨 问题案例

### 错误做法

```bash
# ❌ 只查单页，误以为数据完整
./bin/cordys crm page opportunity '{"current":1,"pageSize":500,...}'
# 返回 500 条，但实际有 23,833 条！
```

**错误统计结果（单页 500 条样本）：**
| 阶段 | 数量 | 占比 |
|------|------|------|
| 新建 | 208 | 41.4% |
| 成功 | 98 | 19.5% |
| 方案验证 | 69 | 13.7% |
| ... | ... | ... |

---

## ✅ 正确流程

### 第一步：获取总数

```bash
# ✅ 先查 1 条获取 total 总数
./bin/cordys crm page opportunity '{"current":1,"pageSize":1,...}'
```

**返回数据关键字段：**
```json
{
  "total": 23833,
  "pageSize": 1,
  "current": 1
}
```

**计算总页数：** `23833 / 500 ≈ 48 页`

---

### 第二步：循环拉取所有页

```bash
#!/bin/bash
pageSize=500
totalPages=$((23833 / pageSize + 1))

for ((current=1; current<=totalPages; current++)); do
    result=$(./bin/cordys crm page opportunity "{\"current\":$current,\"pageSize\":$pageSize,...}")
    # 处理返回数据...
done
```

---

### 第三步：大数据量优化

当 `total > 10000` 时，提供以下选项：

#### 选项 A：抽样统计（推荐）

```bash
# 拉取前 10 页（5000 条）做统计，比例可代表整体
for i in {1..10}; do
    ./bin/cordys crm page opportunity "{\"current\":$i,\"pageSize\":500,...}" | \
        grep -o '"stageName":"[^"]*"'
done | sort | uniq -c | sort -rn
```

**抽样统计结果（5000 条）：**
| 阶段 | 数量 | 占比 |
|------|------|------|
| 成功 | 1,861 | 37.2% |
| 新建 | 1,120 | 22.4% |
| 失败 | 1,081 | 21.6% |
| 立项汇报 | 317 | 6.3% |
| ... | ... | ... |

#### 选项 B：全量查询

```bash
# 告知用户预计耗时，确认后执行
echo "系统显示共 23,833 条记录，约 48 页，预计耗时 5-10 分钟。是否需要全量查询？"
```

#### 选项 C：增加筛选

```bash
# 建议用户添加时间/部门/状态等条件缩小范围
./bin/cordys crm page opportunity '{
  "current": 1,
  "pageSize": 500,
  "combineSearch": {
    "conditions": [{"name": "createTime", "operator": "DYNAMICS", "value": "MONTH"}]
  }
}'
# 只查询本月数据，大幅减少数据量
```

---

## ⚠️ 常见陷阱

### 陷阱 1：用"本页数量 < pageSize"判断结束

**现象：** Cordys API 每页固定返回 714 条，最后一页也是 714 条，导致无限循环。

**错误代码：**
```bash
# ❌ 错误逻辑
while true; do
    count=$(get_page | grep -o '"id":"' | wc -l)
    [ "$count" -lt "$pageSize" ] && break  # 永远不成立！
    current=$((current + 1))
done
```

**正确做法：** 依赖 API 返回的 `total` 字段计算总页数，循环固定次数。

---

### 陷阱 2：只拉单页当全量

**现象：** 查询返回 500 条，以为数据完整，实际有 23,833 条。

**正确做法：** 先查 `pageSize=1` 获取 `total` 字段。

---

### 陷阱 3：大数据量直接全拉

**现象：** 23,833 条数据循环 48 页，耗时过长，用户不知道进度。

**正确做法：**
1. 先告知预计页数和耗时
2. 提供抽样统计选项
3. 建议用户添加筛选条件

---

## 📋 标准执行模板

### 1) 启动全量查询时

```text
已开始全量查询：opportunity
筛选条件：按销售阶段统计
系统显示共 23,833 条记录，约 48 页，预计耗时 5-10 分钟。

是否需要：
A) 抽样统计（前 10 页/5000 条，快速获得分布比例）
B) 全量查询（完整数据，耗时较长）
C) 增加筛选（如只查本月/本部门）
```

### 2) 每页回传模板

```text
【第 10/48 页】
- 本页条数：500
- 累计条数：5,000
- 关键摘要：
  1) 新增成功：186 条
  2) 新增新建：112 条
  3) 新增失败：108 条
```

### 3) 最终完成模板

```text
✅ 全部查询完成
- 模块：opportunity
- 总页数：48
- 总条数：23,833
- 查询条件：按销售阶段统计

按销售阶段统计结果：
| 阶段 | 数量 | 占比 |
|------|------|------|
| 成功 | 8,866 | 37.2% |
| 新建 | 5,339 | 22.4% |
| 失败 | 5,148 | 21.6% |
| ... | ... | ... |

如需导出为清单（按字段整理），可以继续处理。
```

### 4) 中途失败模板

```text
⚠️ 全量查询在第 25 页失败
- 已完成页数：24
- 已获取条数：12,000
- 失败原因：网络超时

是否从第 25 页继续重试？
```

---

## 🔧 实用脚本

### 脚本 1：快速统计分布（抽样）

```bash
#!/bin/bash
# 快速统计商机阶段分布（前 10 页样本）

for i in {1..10}; do
    ./bin/cordys crm page opportunity "{\"current\":$i,\"pageSize\":500}" 2>/dev/null | \
        grep -o '"stageName":"[^"]*"'
done | sort | uniq -c | sort -rn | \
awk '{printf "%-20s %d\n", $2, $1}'
```

### 脚本 2：全量查询并统计

```bash
#!/bin/bash
# 全量查询并统计（带进度显示）

total=23833
pageSize=500
totalPages=$((total / pageSize + 1))
declare -A stages

for ((current=1; current<=totalPages; current++)); do
    result=$(./bin/cordys crm page opportunity "{\"current\":$current,\"pageSize\":$pageSize}" 2>/dev/null)
    
    count=$(echo "$result" | grep -o '"id":"' | wc -l)
    [ "$count" -eq 0 ] && break
    
    while IFS= read -r stage; do
        stages["$stage"]=$((${stages["$stage"]:-0} + 1))
    done < <(echo "$result" | grep -o '"stageName":"[^"]*"' | sed 's/"stageName":"//g' | sed 's/"//g')
    
    if [ $((current % 10)) -eq 0 ]; then
        echo "已处理第 $current/$totalPages 页" >&2
    fi
done

echo ""
echo "=== 全量统计结果 ==="
for stage in "${!stages[@]}"; do
    printf "%-20s %d\n" "$stage" "${stages[$stage]}"
done | sort -t' ' -k2 -rn
```

---

## 📚 相关文档

- [REPORT.md](REPORT.md) - 功能验证报告
- [rules/platform/fields.md](../rules/platform/fields.md) - 字段映射表
- [rules/platform/sync.md](../rules/platform/sync.md) - 字段同步指南

---

*最后更新：2026-04-01*
