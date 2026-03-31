# Cordys CRM 字段映射表

> 最后更新：2026-03-27  
> 用途：将字段 ID 转换为可读的字段名和选项值

---

## 📌 线索 (Lead)

### 基础字段

| 字段 ID | 字段名 | 类型 | 说明 |
|--------|--------|------|------|
| `id` | ID | string | 线索唯一标识 |
| `name` | 名称 | string | 线索名称 |
| `owner` | 负责人 ID | string | 负责人用户 ID |
| `ownerName` | 负责人 | string | 负责人姓名 |
| `stage` | 阶段 | string | 线索阶段 (NEW/CONTACTED/QUALIFIED 等) |
| `contact` | 联系人 | string | 联系人姓名 |
| `phone` | 电话 | string | 联系电话 |
| `products` | 产品 | array | 感兴趣的产品 ID 列表 |
| `createTime` | 创建时间 | timestamp | 创建时间戳 (毫秒) |
| `updateTime` | 更新时间 | timestamp | 更新时间戳 (毫秒) |
| `departmentId` | 部门 ID | string | 所属部门 ID |
| `departmentName` | 部门 | string | 所属部门名称 |
| `reservedDays` | 保留天数 | number | 保护期天数 |
| `follower` | 跟进人 ID | string | 跟进人用户 ID |
| `followerName` | 跟进人 | string | 跟进人姓名 |
| `followTime` | 跟进时间 | timestamp | 最后跟进时间 |

### 自定义字段 (moduleFields)

| 字段 ID | 字段名 | 选项值映射 |
|--------|--------|-----------|
| `1751888184000015` | 区域 | `东区` `北区` `南区` `KA` `凌霞软件` `培训认证中心` |
| `1751888184000018` | 来源类型 | `Advertisement`=线上 `二期及续费`=多期续费/维保/扩容/增购 `增购和交叉销售`=交叉销售 `Employee Referral`=线下 - 员工发掘 `Partner`=线下 - 合作伙伴 `Customer Referral`=线下 - 客户推荐 `Sponsored Meeting`=线下 - 赞助会议 `Self-hosted Meeting`=线下 - 自办会议 |
| `1751888184000019` | 渠道类型 | `线下不涉及` `400 电话` `企业版试用` `技术咨询` `安装包下载` `网页购买咨询` `预约演示` `社区交流群` `解决方案咨询` `招标信息` `邮件` `培训` `网络空间测绘` `阿里云市场` `AWS 云市场` `凌霞开票用户` `Cloud 来源` |
| `1751888184000025` | 是否 | `1`=是 `0`=否 |
| `1751888184000027` | 区号 | 文本 (如 `3301-`) |
| `175188949491200000` | 行业 | `银行` `非银金融` `制造` `交通和物流` `零售和服务` `高科技和互联网` `媒体` `通信` `建筑和房地产` `能源和电力` `政府和军工` `教育` `医疗` `公共事业` |
| `175307914302000000` | 客户等级 | `175307914302000001`=战略客户 `175307914302000002`=重要客户 `175307914302000003`=一般客户 |
| `175576690158200000` | 跟进状态 | `175576690158200001`=尝试联系 `175576690158200002`=跟进中 `175576690158200003`=较感兴趣 `175576693719200000`=不感兴趣 |

---

## 💰 商机 (Opportunity)

### 基础字段

| 字段 ID | 字段名 | 类型 | 说明 |
|--------|--------|------|------|
| `id` | ID | string | 商机唯一标识 |
| `name` | 名称 | string | 商机名称 |
| `customerId` | 客户 ID | string | 关联客户 ID |
| `customerName` | 客户名称 | string | 关联客户名称 |
| `inCustomerPool` | 是否在客户池 | boolean | 是否在客户池中 |
| `poolId` | 池 ID | string | 客户池 ID |
| `owner` | 负责人 ID | string | 负责人用户 ID |
| `ownerName` | 负责人 | string | 负责人姓名 |
| `amount` | 金额 | number | 商机金额 (元) |
| `possible` | 赢单概率 | number | 赢单概率 (%) |
| `products` | 产品 | array | 涉及产品 ID 列表 |
| `contactId` | 联系人 ID | string | 联系人 ID |
| `contactName` | 联系人 | string | 联系人姓名 |
| `lastStage` | 上一阶段 | string | 上一阶段代码 |
| `stage` | 阶段 | string | 当前阶段代码 |
| `stageName` | 阶段名称 | string | 当前阶段名称 |
| `createTime` | 创建时间 | timestamp | 创建时间戳 |
| `updateTime` | 更新时间 | timestamp | 更新时间戳 |
| `createUser` | 创建人 ID | string | 创建人用户 ID |
| `updateUser` | 更新人 ID | string | 更新人用户 ID |
| `createUserName` | 创建人 | string | 创建人姓名 |
| `updateUserName` | 更新人 | string | 更新人姓名 |
| `reservedDays` | 保留天数 | number | 保护期天数 |
| `follower` | 跟进人 ID | string | 跟进人用户 ID |
| `followerName` | 跟进人 | string | 跟进人姓名 |
| `followTime` | 跟进时间 | timestamp | 最后跟进时间 |
| `departmentId` | 部门 ID | string | 所属部门 ID |
| `departmentName` | 部门 | string | 所属部门名称 |
| `expectedEndTime` | 预计结束时间 | timestamp | 预计成交时间 |
| `actualEndTime` | 实际结束时间 | timestamp | 实际成交时间 |
| `failureReason` | 失败原因 | string | 失败原因 |

### 自定义字段 (moduleFields)

| 字段 ID | 字段名 | 选项值映射 |
|--------|--------|-----------|
| `1751888184000030` | 区域 | `东区` `北区` `南区` `KA` `凌霞软件` `培训认证中心` |
| `1751888184000034` | 来源类型 | `Advertisement`=线上 `二期及续费`=多期续费/维保/扩容/增购 `增购和交叉销售`=交叉销售 `Employee Referral`=线下 - 员工发掘 `Partner`=线下 - 合作伙伴 `Customer Referral`=线下 - 客户推荐 `Sponsored Meeting`=线下 - 赞助会议 `Self-hosted Meeting`=线下 - 自办会议 |
| `1751888184000036` | 渠道类型 | `线下不涉及` `400 电话` `企业版试用` `技术咨询` `安装包下载` `网页购买咨询` `预约演示` `社区交流群` `解决方案咨询` `招标信息` `邮件` `培训` `网络空间测绘` `阿里云市场` `AWS 云市场` `凌霞开票用户` `Cloud 来源` |
| `1751888184000039` | 客户名称 | 文本 |
| `1751888184000041` | 金额 | 数字 (元) |
| `1751888184000042` | 商机简称 | 文本 |
| `1751888184000045` | 合同编号 | 文本 (如 `LX20251009X`) |
| `1751888184000046` | 商机编号 | 文本 (如 `Opp-202603-000316`) |
| `176490831663000000` | 合作伙伴 | `翰芃` `宇辰` `暂无--力航电子` 等 |
| `176847297349200000` | 合同类型 | `176847297349200001`=飞致云直签 `176847297349200002`=商务平台代签 `176975823877700000`=盟军代签 `176881828167100000`=联合培养销售签 `176847297349300000`=盟军报备签 `177010696382400000`=非盟军报备签 |

### 商机阶段

| 阶段代码 | 阶段名称 | 说明 |
|--------|--------|------|
| `CREATE` | 新建 | 刚创建的商机 |
| `CLEAR_REQUIREMENTS` | 需求明确 | 已明确客户需求 |
| `SCHEME_VALIDATION` | 方案验证 | 方案验证中 |
| `PROJECT_PROPOSAL_REPORT` | 立项汇报 | 等待立项汇报 |
| `SUCCESS` | 成功 | 已成交 |
| `FAILURE` | 失败 | 已失败 |

---

## 🏢 客户 (Account)

### 基础字段

| 字段 ID | 字段名 | 类型 | 说明 |
|--------|--------|------|------|
| `id` | ID | string | 客户唯一标识 |
| `name` | 名称 | string | 客户名称 |
| `owner` | 负责人 ID | string | 负责人用户 ID |
| `ownerName` | 负责人 | string | 负责人姓名 |
| `inSharedPool` | 是否在共享池 | boolean | 是否在共享池中 |
| `createTime` | 创建时间 | timestamp | 创建时间戳 |
| `updateTime` | 更新时间 | timestamp | 更新时间戳 |
| `createUser` | 创建人 ID | string | 创建人用户 ID |
| `updateUser` | 更新人 ID | string | 更新人用户 ID |
| `createUserName` | 创建人 | string | 创建人姓名 |
| `updateUserName` | 更新人 | string | 更新人姓名 |
| `departmentId` | 部门 ID | string | 所属部门 ID |
| `departmentName` | 部门 | string | 所属部门名称 |
| `latestFollowUpTime` | 最后跟进时间 | timestamp | 最后跟进时间 |
| `collectionTime` | 收集时间 | timestamp | 客户收集时间 |
| `reservedDays` | 保留天数 | number | 保护期天数 |
| `follower` | 跟进人 ID | string | 跟进人用户 ID |
| `followerName` | 跟进人 | string | 跟进人姓名 |
| `followTime` | 跟进时间 | timestamp | 最后跟进时间 |
| `poolId` | 池 ID | string | 客户池 ID |
| `recyclePoolName` | 公海池名称 | string | 所属公海池名称 |
| `reasonId` | 原因 ID | string | 转入公海原因 ID |
| `reasonName` | 原因名称 | string | 转入公海原因名称 |
| `collaborationType` | 协作类型 | string | 协作类型 |

### 自定义字段 (moduleFields)

| 字段 ID | 字段名 | 选项值映射 |
|--------|--------|-----------|
| `1751888184000004` | 客户等级 | `Hot`=战略客户 `Warm`=重要客户 `Cold`=一般客户 |
| `1751888184000005` | 行业 | `银行` `非银金融（证券、基金、保险等）` `制造` `交通和物流` `零售和服务（酒店、连锁、餐饮、快销等）` `高科技和互联网` `媒体（报业、广电等）` `通信（运营商）` `建筑和房地产` `能源和电力` `政府和军工` `教育` `医疗（医药、医院、医学检测等）` `公共事业（燃气、水务等）` |
| `1751888184000006` | 来源类型 | `Advertisement`=线上 `二期及续费`=多期续费/维保/扩容/增购 `增购和交叉销售`=交叉销售 `Employee Referral`=线下 - 员工发掘 `Partner`=线下 - 合作伙伴 `Customer Referral`=线下 - 客户推荐 `Sponsored Meeting`=线下 - 赞助会议 `Self-hosted Meeting`=线下 - 自办会议 |
| `1751888184000007` | 客户类型 | `Customer`=最终客户 `Partner`=代理商 |
| `1751888184000008` | 渠道类型 | `线下不涉及` `400 电话` `企业版试用` `技术咨询` `安装包下载` `网页购买咨询` `预约演示` `社区交流群` `解决方案咨询` `招标信息` `邮件` `培训` `网络空间测绘` `阿里云市场` `AWS 云市场` `凌霞开票用户` `Cloud 来源` |
| `1751888184000009` | 区域 | `东区` `北区` `南区` `KA` `凌霞软件` `培训认证中心` |
| `1751888184000011` | 区号 | 文本 (如 `310112-`) |

---

## 📦 产品列表 (Products)

| 产品 ID | 产品名称 |
|--------|---------|
| `1751888184000091` | JumpServer 企业版 |
| `1751888184000102` | MaxKB 专业版 |
| `8327632349528064` | MaxKB 企业版 |
| `1751888184000101` | DataEase 企业版 |
| `1751888184000092` | DataEase 专业版 |
| `1751888184000097` | DataEase 嵌入式版 |
| `10034933389336576` | Cordys CRM 企业版 |
| `8366853990875136` | SQLBot 专业版 |
| `1751888184000098` | MeterSphere 企业版 |
| `1751888184000093` | CloudExplorer 云管平台 |
| `1751888184000088` | 1Panel 专业版 |
| `312882406099316736` | Halo 企业版 |
| `312881942242848768` | Halo 专业版 |
| `1903666944581638` | 原厂专业服务（人天服务） |
| `321047594195578880` | OpenClaw 一体机 |
| `1751888184000087` | JumpServer 社区版 |
| `1901089964204038` | 标准维保服务 |
| `1952560852279302` | 授权版本升级 |
| `5139031449427968` | 培训服务 |

---

## 🔧 使用示例

### 1. 按时间范围筛选商机

```bash
# 查询今天创建的商机（需要计算今天的 timestamp）
cordys crm page opportunity '{
  "current": 1,
  "pageSize": 50,
  "filters": [
    {
      "field": "createTime",
      "operator": "greaterThan",
      "value": 1773100800000
    }
  ]
}'
```

### 2. 按金额筛选

```bash
# 查询金额大于 10 万的商机
cordys crm page opportunity '{
  "current": 1,
  "pageSize": 50,
  "filters": [
    {
      "field": "amount",
      "operator": "greaterThan",
      "value": 100000
    }
  ]
}'
```

### 3. 按阶段筛选

```bash
# 查询"需求明确"阶段的商机
cordys crm page opportunity '{
  "current": 1,
  "pageSize": 50,
  "filters": [
    {
      "field": "stage",
      "operator": "equals",
      "value": "CLEAR_REQUIREMENTS"
    }
  ]
}'
```

### 4. 按产品筛选

```bash
# 查询包含 MaxKB 专业版的商机
cordys crm page opportunity '{
  "current": 1,
  "pageSize": 50,
  "filters": [
    {
      "field": "products",
      "operator": "contains",
      "value": "1751888184000102"
    }
  ]
}'
```

---

## 📝 注意事项

1. **时间戳格式**：所有时间字段都是毫秒级时间戳 (JavaScript 格式)
2. **字段 ID**：自定义字段必须使用字段 ID，不能用字段名
3. **选项值**：下拉框字段存储的是选项 ID，不是显示名称
4. **金额单位**：所有金额字段单位是**元**（不是万元）
5. **分页参数**：`current` 从 1 开始，`pageSize` 最大 100

---

## 🔄 更新字段映射

当发现新字段或字段变更时，运行以下命令获取最新映射：

```bash
# 获取线索字段
cordys crm page lead '{"current":1,"pageSize":1}' | jq '.data.optionMap'

# 获取商机字段
cordys crm page opportunity '{"current":1,"pageSize":1}' | jq '.data.optionMap'

# 获取客户字段
cordys crm page account '{"current":1,"pageSize":1}' | jq '.data.optionMap'
```
