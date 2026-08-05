# ✏️ 写入操作引擎

本文件定义了 Cordys CRM 中的**创建、更新、转换**操作规范。
支持模块：`lead`（线索）、`account`（客户）、`opportunity`（商机）、`account/contact`（联系人）、`follow/plan`（跟进计划）、`follow/record`（跟进记录）、`opportunity/quotation`（报价单）、`contract`（合同）、`contract/payment-plan`（回款计划）、`contract/payment-record`（回款记录）、`invoice`（发票记录）、`contract/business-title`（工商抬头）、`order`（订单）。

---

## 0. 核心设计原则

### 0.1 高度抽象，统一流程

所有模块的写入操作遵循**完全相同的流程**，不按模块重复实现：

```
用户意图 → 识别模块/操作类型 → 获取表单定义 → 校验数据 → 构建请求体 → 执行写入 → 验证结果 → 输出
```

### 0.2 两阶段写入：先取表单，再写入

创建/更新前**必须先获取表单定义**，目的：
1. 了解有哪些字段、字段类型、必填项
2. 了解字段的合法值范围（如下拉选项）
3. 基于表单定义校验用户输入

### 0.3 抽象函数层

所有模块共享以下抽象操作，不按模块单独编写：

| 抽象函数 | 说明 |
|---------|------|
| `get_form(module)` | 获取模块表单定义 |
| `validate(form, data)` | 基于表单定义 + 自定义规则校验输入 |
| `build_save_body(form, data)` | 构建创建请求体 |
| `build_update_body(form, data, existing)` | 构建更新请求体（合并已有数据） |
| `save(module, data)` | 创建单条记录 |
| `update(module, id, data)` | 更新单条记录 |
| `batch_save(module, items)` | 批量创建 |
| `batch_update(module, items)` | 批量更新，仅 `lead`、`account`、`opportunity`、`account/contact`、`contract`、`order` |
| `transition_lead(lead_id, target, data)` | 线索转化 |

---

## 1. 表单获取

### 1.1 API 端点

```bash
# 获取模块表单定义（所有模块统一端点）
cordys.sh crm form <模块>

# 示例
cordys.sh crm form lead                  # 线索表单
cordys.sh crm form account               # 客户表单
cordys.sh crm form opportunity           # 商机表单
cordys.sh crm form account/contact       # 联系人表单
cordys.sh crm form follow/plan           # 跟进计划表单
cordys.sh crm form follow/record         # 跟进记录表单
cordys.sh crm form contract              # 合同表单
cordys.sh crm form contract/payment-plan # 回款计划表单
cordys.sh crm form contract/payment-record # 回款记录表单
cordys.sh crm form invoice               # 发票记录表单
cordys.sh crm form contract/business-title # 工商抬头表单
cordys.sh crm form opportunity/quotation # 报价单表单
cordys.sh crm form order                 # 订单表单
```

> 实际调用：`GET /{module}/module/form`

### 1.2 表单响应结构（ModuleFormConfigDTO）

```json
{
  "fields": [
    {
      "fieldId": "name",
      "fieldName": "名称",
      "fieldType": "INPUT",
      "required": true,
      ...
    },
    ...
  ],
  "formProp": {
    "layout": 1,
    "labelPos": "top",
    ...
  }
}
```

fields 数组中的每个元素是具体字段类型（InputField / SelectField / DateTimeField 等），均继承 BaseField，包含：
- `fieldId`：字段 API 标识
- `fieldName`：中文显示名
- `fieldType`：字段类型（INPUT / SELECT / DATE_TIME / INPUT_NUMBER / ...）
- `required`：是否必填
- `options[]`：下拉/单选的可选值（SELECT / RADIO 类型时）
- `defaultValue`：默认值（如有）

### 1.3 加载时机与缓存

| 场景 | 策略 |
|------|------|
| 对话内首次操作某模块 | 调用 `get_form(module)` 获取完整表单定义 |
| 同一对话再次操作同模块 | 复用已获取的表单定义（不重复请求） |
| 对话超过 30 分钟 | 重新获取（防止表单配置变更） |

---

## 2. 数据校验

### 2.1 内置校验规则

基于表单定义自动执行：

| 规则 | 来源 | 处理 |
|------|------|------|
| 必填字段为空 | `fields[].required = true` | 阻止提交，提示缺失字段 |
| 字段类型不匹配 | `fields[].type` | 阻止提交，提示类型错误 |
| 枚举值不合法 | `fields[].options`（SELECT/RADIO） | 阻止提交，列出合法选项 |
| 数字超出范围 | 业务规则 | 警告但允许提交（可覆盖） |

### 2.2 自定义校验规则

AI 在执行写入前，自动检查 `rules/form-rules/{module}.md` 是否存在：

```
├─ 存在 → 加载自定义校验规则，与内置规则合并
└─ 不存在 → 仅使用内置规则
```

自定义规则格式见 `rules/README.md`。

### 2.3 校验失败处理

```
校验失败：
  ├─ 列出所有不合规字段
  ├─ 给出修正建议
  └─ 询问用户是否修正后重试
```

---

## 3. 创建操作

### 3.1 创建流程

```
1. 用户说"创建一个客户" / "新建线索" / "添加联系人"
2. 识别模块 → 检查是否已加载表单 → 未加载则调用 get_form(module)
3. 分析用户输入 → 提取字段值映射到表单字段
4. 校验输入 → 通过则继续，失败则提示修正
5. 调用 save(module, data)
6. 验证结果（get 刚创建的记录）
7. 格式化输出
```

### 3.2 API 端点

```bash
# 创建记录（所有模块统一使用 POST /{module}/add）
cordys.sh crm add <模块> '<JSON>'

# 示例：创建客户
cordys.sh crm add account '{"name":"华星科技","owner":"user123"}'

# 示例：创建线索（name + products 必填）
cordys.sh crm add lead '{"name":"张三","phone":"13800138000","products":["p1"]}'

# 示例：创建商机（name + contactId + owner + products 必填）
cordys.sh crm add opportunity '{"name":"华星采购项目","customerId":"xxx","contactId":"yyy","amount":120000,"owner":"user123","products":["p1"]}'

# 示例：创建联系人（customerId + name 必填）
cordys.sh crm add account/contact '{"customerId":"xxx","name":"张三","phone":"13800138000"}'

# 示例：给线索新增跟进记录
cordys.sh crm add lead/follow/record '{"type":"CLUE","clueId":"xxx","content":"电话回访","followMethod":"方式ID","owner":"用户ID"}'
```

> **注意**：联系人不是独立模块，通过 `account/contact` 访问，调用 `POST /account/contact/add`。

### 3.3 各模块必填字段

| 模块 | 必填字段 |
|------|---------|
| 线索 | `name`, `products` |
| 客户 | `name` |
| 商机 | `name`, `contactId`, `owner`, `products` |
| 联系人 | `customerId`, `name` |
| 跟进计划 | 对应父资源 ID + `type`, `content`, `method`, `owner` |
| 跟进记录 | 对应父资源 ID + `type`, `content`, `followMethod`, `owner` |
| 合同 | 以 `crm form contract` 返回的 `required=true` 为准 |
| 回款计划 | 以 `crm form contract/payment-plan` 返回的 `required=true` 为准 |
| 回款记录 | 以 `crm form contract/payment-record` 返回的 `required=true` 为准 |
| 发票记录 | 以 `crm form invoice` 返回的 `required=true` 为准 |
| 工商抬头 | 以 `crm form contract/business-title` 返回的 `required=true` 为准 |
| 报价单 | `name`, `opportunityId`, `untilTime`, `products`, `moduleFields`, `moduleFormConfigDTO` |
| 订单 | 以 `crm form order` 返回的 `required=true` 为准 |

> 除必填字段外，`moduleFields` 数组可以传入任意自定义字段值（`[{fieldId, fieldValue}, ...]`）。
> 报价单更新为完整对象更新：先执行 `crm get opportunity/quotation <id>`，保留创建必填字段，并额外提交 `id`、`approvalStatus`；不得按 PATCH 只传修改字段。

### 3.4 字段智能推断

用户通常不会提供完整字段，AI 需要：

| 用户输入 | 推断策略 |
|---------|---------|
| 仅给名称 | 使用最小必填字段，其余留空 |
| 自然语言描述 | 提取实体名、数字、日期，映射到对应字段 |
| 部分字段 | 补全默认值（如有），必填缺失的主动询问 |
| 批量数据 | 逐条校验，统一提交 |

### 3.5 批量操作

> ⚠️ Cordys CRM **不提供批量创建（batch-add）端点**，批量编辑只对 `lead`、`account`、`opportunity`、`account/contact`、`contract`、`order` 开放。
> 如需批量创建，AI 需在用户确认后逐条调用 `crm add`。
> 其它模块需要多条变更时，不得通过循环调用 `crm update` 绕过限制。

创建前 AI 应：
- 展示全部待创建记录的预览表格
- 标注可能的问题字段
- 要求用户确认后逐条执行

---

## 4. 更新操作

### 4.1 更新流程

```
1. 用户说"修改XX公司的行业为金融" / "更新商机金额"
2. 识别模块 + 目标记录（通过名称 → 搜索 → 获取 ID）
3. 获取目标记录当前值（cordys.sh crm get {module} {id}）
4. 检查是否已加载表单 → 未加载则调用 get_form(module)
5. 合并更新字段到现有数据
6. 校验合并后的数据
7. 调用 update(module, id, merged_data)
8. 验证结果
9. 输出变更对比（旧值 → 新值）
```

### 4.2 API 端点

```bash
# 更新记录（JSON body 须包含 id 字段）
cordys.sh crm update <模块> '<JSON>'

# 示例：更新客户名称
cordys.sh crm update account '{"id":"123456","name":"华星科技（新）"}'

# 示例：更新商机金额（id + 全部必填字段都要传）
cordys.sh crm update opportunity '{"id":"xxx","name":"华星采购","contactId":"yyy","owner":"user123","products":["p1"],"amount":200000}'
```

> ⚠️ **update 使用 POST**（不是 PUT），且更新后的请求体必须满足目标表单的全部必填字段。商机更新需要传全部必填字段（name, contactId, owner, products），二级表单同样以 `crm form <模块>` 的实时定义为准。

### 4.3 批量更新

```bash
# 按字段批量更新（仅线索、客户、商机、联系人、合同和订单）
cordys.sh crm batch-update <模块> '{"ids":["id1","id2"],"fieldId":"owner","fieldValue":"user456"}'
```

> `fieldId` 必须使用表单定义中的实际字段 ID（如 `"635449004900372"`）、系统字段的内部 key（如 `"owner"`），或自定义字段 ID。
> ⚠️ **注意：** `fieldId` 不支持系统字段的 `businessKey`（如 `name`、`phone`）。必须使用系统字段的内部 key（如 `owner`）或字段的实际 `id`。如果 API 返回 "Field does not exist"，请从表单定义中找到正确的字段 ID。

| 场景 | 策略 |
|------|------|
| 用户明确指定字段+值 | 直接更新该字段 |
| 用户说"把XX改成YY" | 先搜索确认目标，再更新 |
| 批量修改线索/客户/商机/联系人/合同/订单 | 先搜索筛选 → 确认范围 → 使用 `batch-update` |
| 批量修改跟进、回款、发票、工商抬头等其它模块 | 明确告知不支持批量编辑，不自动拆成多次单条更新 |
| 字段值清空 | 传空字符串 `""` 或 `null` |
| 商机更新 | 必须传全部必填字段（name/contactId/owner/products），非仅修改字段 |
| 跟进计划/记录更新 | 模块路径带父模块，JSON 包含 `id`、对应父资源 ID及完整必填字段 |
| 合同及二级表单更新 | 必须包含 `id`，合并后重新按目标表单的必填项校验 |

### 4.4 变更展示

每次更新成功后，输出变更对比：

```
✅ 已更新 客户「华星科技」

| 字段 | 旧值 | 新值 |
|------|------|------|
| 行业 | 科技 | 金融 |
```

---

## 5. 线索转化

### 5.1 转化流程

```
1. 用户说"把XX线索转为客户" / "这条线索转商机"
2. 获取线索详情（cordys.sh crm get lead {id}）
3. 根据目标类型加载目标模块的表单定义
4. 将线索字段映射到目标模块字段
5. 检查自定义映射规则（rules/field-mapping/lead-to-{target}.md）
6. 展示转化预览（线索字段 → 目标字段）
7. 用户确认后执行转化 API
8. 验证结果
9. 输出转化结果
```

### 5.2 API 端点

```bash
# 线索转客户（只要有个客户名称即可）
cordys.sh crm transition '{"clueId":"xxx","name":"华星科技"}'

# 带模块字段的转化
cordys.sh crm transition '{"clueId":"xxx","name":"华星科技","owner":"user123","moduleFields":[{"fieldId":"industry","fieldValue":"科技"}]}'
```

> 实际调用：`POST /lead/transition/account`，必填字段：`clueId` + `name`。

```bash
# 快速转换（线索 → 客户 + 可选商机）
cordys.sh crm transform '{"clueId":"xxx","oppCreated":true,"oppName":"华星采购项目"}'

# 只转客户不创建商机
cordys.sh crm transform '{"clueId":"xxx","oppCreated":false}'
```

> 实际调用：`POST /lead/transform`，必填字段：`clueId`。

### 5.3 默认字段映射

| 线索字段 | 客户字段 | 说明 |
|---------|---------|------|
| `company` / `name` | `name` | 公司名称 |
| `phone` | `phone` | 联系电话 |
| `industry` | `industry` | 行业 |
| `province` / `city` | `province` / `city` | 地区 |
| `website` | `website` | 网站 |
| `address` | `address` | 地址 |
| `remark` / `description` | `remark` | 备注 |

> 可通过 `rules/field-mapping/lead-to-account.md` 自定义映射规则。

---

## 6. 写入操作的安全约束

### 6.1 必须做的事

| 约束 | 说明 |
|------|------|
| **先取表单** | 创建/更新前必须获取表单定义，不得盲写 |
| **校验输入** | 所有写入前必须执行数据校验 |
| **展示预览** | 批量操作必须展示预览表格，确认后执行 |
| **变更对比** | 更新后必须展示变更前后的差异 |
| **验证结果** | 写入后必须查询确认数据已正确落库 |

### 6.2 绝对不能做的事

| 禁止 | 说明 |
|------|------|
| ❌ **删除操作** | 不提供、不执行任何删除 API |
| ❌ **跳过校验** | 不得绕过表单定义校验 |
| ❌ **批量操作不预览** | 批量操作必须预览确认 |
| ❌ **修改系统字段** | 不修改 `id`、`createTime`、`createUser` 等系统字段 |
| ❌ **覆盖式全量更新** | 不执行"先删后建"等同删除的操作 |

---

## 7. 写入确认流程

### 7.1 单条操作确认

```
AI: 即将创建客户「华星科技」
    | 字段 | 值 |
    |------|-----|
    | 名称 | 华星科技 |
    | 行业 | 科技 |
    | 省份 | 广东 |

    确认创建？（是/修改/取消）

用户确认 → 执行
```

### 7.2 批量操作确认

```
AI: 即将批量创建 5 条线索，预览如下：

    | # | 名称 | 公司 | 电话 |
    |---|------|------|------|
    | 1 | 张三 | A公司 | 138xxx |
    | 2 | 李四 | B公司 | 139xxx |
    | ... | ... | ... | ... |

    ⚠️ 第 3 条缺少「电话」字段
    确认创建全部？（是/跳过第3条/取消）
```

---

## 8. 错误处理

| 响应 | 处理 |
|------|------|
| `code ≠ 100200` | 读取 message，格式化后展示给用户 |
| 必填字段缺失 | 列出缺失字段，引导用户补充 |
| 字段值不合法 | 说明原因 + 列出合法选项 |
| 权限不足 | 提示用户联系管理员 |
| 重复数据 | 提示可能重复，询问是否仍要创建 |
| 网络超时 | 提示稍后重试 |

---

## 9. CLI 命令速查

```bash
# 获取表单定义
cordys.sh crm form lead
cordys.sh crm form account
cordys.sh crm form opportunity
cordys.sh crm form account/contact
cordys.sh crm form follow/plan
cordys.sh crm form follow/record
cordys.sh crm form contract
cordys.sh crm form contract/payment-plan
cordys.sh crm form contract/payment-record
cordys.sh crm form invoice
cordys.sh crm form contract/business-title
cordys.sh crm form opportunity/quotation
cordys.sh crm form order

# 创建
cordys.sh crm add lead '{"name":"张三","products":["p1"]}'
cordys.sh crm add account '{"name":"华星科技"}'
cordys.sh crm add opportunity '{"name":"项目","contactId":"yyy","owner":"u1","products":["p1"]}'
cordys.sh crm add account/contact '{"customerId":"xxx","name":"张三"}'
cordys.sh crm add lead/follow/record '{"type":"CLUE","clueId":"xxx","content":"电话回访","followMethod":"方式ID","owner":"u1"}'
# 报价单先取表单，再按表单结果提交全部必填字段
cordys.sh crm add opportunity/quotation '<完整 JSON>'

# 更新（JSON 须含 id）
cordys.sh crm update lead '{"id":"xxx","name":"新名称"}'
cordys.sh crm update account '{"id":"xxx","owner":"newUser"}'
cordys.sh crm update opportunity/quotation '<详情合并后的完整 JSON>'

# 批量更新（按字段批量修改）
cordys.sh crm batch-update lead '{"ids":["id1","id2"],"fieldId":"635449004900383","fieldValue":"admin"}'

# 线索转化
cordys.sh crm transition '{"clueId":"xxx","name":"客户名"}'
cordys.sh crm transform '{"clueId":"xxx","oppCreated":true,"oppName":"商机名"}'
```
