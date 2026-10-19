# Cordys CRM API 完整目录

> ⚠️ **安全红线**：批量删除 API（标记 🚫）绝对禁止调用。单个删除 API（标记 ⚠️）需要用户二次确认后执行。

---

## URL 模式速查（构造规则）


所有 API 遵循一致的 URL 模式。掌握以下模式即可构造任意 API 路径：

| 操作 | URL 模式 | 方法 | 示例 |
|------|---------|------|------|
| 分页查询 | `/{module}/page` | POST | `/account/page` |
| 获取详情 | `/{module}/get/{id}` | GET | `/account/get/123` |
| 创建 | `/{module}/add` | POST | `/account/add` |
| 更新 | `/{module}/update` | POST | `/account/update` |
| 删除（单个）⚠️ | `/{module}/delete/{id}` | GET | `/account/delete/123` |
| 批量删除 🚫 | `/{module}/batch/delete` | POST | **禁止调用** |
| 批量更新 | `/{module}/batch/update` | POST | `/account/batch/update` |
| 批量转移 | `/{module}/batch/transfer` | POST | `/account/batch/transfer` |
| 导出全部 | `/{module}/export-all` | POST | `/account/export-all` |
| 导出选中 | `/{module}/export-select` | POST | `/account/export-select` |
| 导入 | `/{module}/import` | POST | `/account/import` |
| 导入预检 | `/{module}/import/pre-check` | POST | `/account/import/pre-check` |
| 图表 | `/{module}/chart` | POST | `/account/chart` |
| 统计 | `/{module}/statistic` | POST | `/contract/statistic` |
| 合并 | `/{module}/merge` | POST | `/account/merge` |
| 表单定义 | `/{module}/module/form` | GET | `/account/module/form` |
| Tab 配置 | `/{module}/tab` | GET | `/account/tab` |
| 导入模板 | `/{module}/template/download` | GET | `/account/template/download` |
| 选项列表 | `/{module}/option` | GET/POST | `/account/option` |
| 视图列表 | `/{module}/view/list` | GET | `/account/view/list` |
| 视图操作 | `/{module}/view/{action}` | GET/POST | `/account/view/add` |
| 阶段管理 | `/{module}/stage/{action}` | POST/GET | `/contract/stage/add` |
| 跟进计划 | `/{module}/follow/plan/{action}` | POST/GET | `/account/follow/plan/page` |
| 跟进记录 | `/{module}/follow/record/{action}` | POST/GET | `/account/follow/record/page` |
| 排序 | `/{module}/sort` | POST | `/contract/sort` |

### 使用方式

```bash
# 方式一：使用 cordys raw（任意 API）
cordys raw POST /account/add '{"name":"test"}'
cordys raw GET /account/get/123
cordys raw POST /account/page '{"keyword":"test"}'

# 方式二：使用 cordys crm api（自动拼接域名 + 安全检查）
cordys.sh crm api POST /account/add '{"name":"test"}'
cordys.sh crm api GET /department/tree
```

### 子资源模块

某些模块包含子资源，URL 为 `/{parent}/{child}/{operation}`：

| 父模块 | 子资源 | 完整前缀 |
|--------|--------|---------|
| account | contact | `/account/contact/` |
| account | follow/plan | `/account/follow/plan/` |
| account | follow/record | `/account/follow/record/` |
| account | view | `/account/view/` |
| account | relation | `/account/relation/` |
| account | collaboration | `/account/collaboration/` |
| contract | payment-plan | `/contract/payment-plan/` |
| contract | payment-record | `/contract/payment-record/` |
| contract | business-title | `/contract/business-title/` |
| contract | stage | `/contract/stage/` |
| contract | view | `/contract/view/` |
| opportunity | quotation | `/opportunity/quotation/` |
| opportunity | follow | `/opportunity/follow/` |
| opportunity | stage | `/opportunity/stage/` |
| opportunity | view | `/opportunity/view/` |
| custom-form | data | `/custom-form/data/` |
| pool | account | `/pool/account/` |
| pool | lead | `/pool/lead/` |


## 产品与价格 (Product & Price)（27 APIs）

| 方法 | 路径 | 说明 | 安全 |
|------|------|------|------|
| POST | `/price/add` | 添加价格表 |  |
| POST | `/price/batch/update` | 批量更新价格表 |  |
| GET | `/price/copy/{id}` | 复制价格表 |  |
| GET | `/price/delete/{id}` | 删除价格表 | ⚠️ 需确认 |
| POST | `/price/edit/pos` | 拖拽排序 |  |
| POST | `/price/export` | 导出全部 |  |
| POST | `/price/export-select` | 导出选中 |  |
| GET | `/price/get/{id}` | 价格表详情 |  |
| POST | `/price/import` | 导入 |  |
| POST | `/price/import/pre-check` | 导入检查 |  |
| GET | `/price/module/form` | 获取表单配置 |  |
| POST | `/price/page` | 价格列表 |  |
| GET | `/price/template/download` | 下载导入模板 |  |
| POST | `/price/update` | 修改价格表 |  |
| POST | `/product/add` | 添加产品 |  |
| POST | `/product/batch/delete` | 批量删除产品 | 🚫 禁止 |
| POST | `/product/batch/update` | 批量更新产品 |  |
| GET | `/product/delete/{id}` | 删除产品 | ⚠️ 需确认 |
| POST | `/product/edit/pos` | 拖拽排序 |  |
| GET | `/product/get/{id}` | 产品详情 |  |
| POST | `/product/import` | 导入产品 |  |
| POST | `/product/import/pre-check` | 导入检查 |  |
| GET | `/product/list/option` | 获取当前组织下全部产品的id,和name集合 |  |
| GET | `/product/module/form` | 获取产品表单配置 |  |
| POST | `/product/page` | 产品列表 |  |
| GET | `/product/template/download` | 下载导入模板 |  |
| POST | `/product/update` | 更新产品 |  |

## 仪表盘 (Dashboard)（16 APIs）

| 方法 | 路径 | 说明 | 安全 |
|------|------|------|------|
| POST | `/dashboard/add` | 仪表板-添加 |  |
| POST | `/dashboard/collect/page` | 仪表板收藏列表 |  |
| GET | `/dashboard/collect/{id}` | 仪表板收藏 |  |
| GET | `/dashboard/delete/{id}` | 仪表板-删除 | ⚠️ 需确认 |
| GET | `/dashboard/detail/{id}` | 仪表板-详情 |  |
| POST | `/dashboard/edit/pos` | 仪表板-拖拽排序 |  |
| POST | `/dashboard/module/add` | 仪表板-添加文件夹 |  |
| GET | `/dashboard/module/count` | 仪表板-文件树数量 |  |
| POST | `/dashboard/module/delete` | 仪表板-刪除文件夹 | ⚠️ 需确认 |
| POST | `/dashboard/module/move` | 仪表板-文件夹移动 |  |
| POST | `/dashboard/module/rename` | 仪表板-重命名文件夹 |  |
| GET | `/dashboard/module/tree` | 仪表板-文件树查询 |  |
| POST | `/dashboard/page` | 仪表板列表 |  |
| POST | `/dashboard/rename` | 仪表板-重命名 |  |
| GET | `/dashboard/un-collect/{id}` | 仪表板取消收藏 |  |
| POST | `/dashboard/update` | 仪表板-更新 |  |

## 发票 (Invoice)（23 APIs）

| 方法 | 路径 | 说明 | 安全 |
|------|------|------|------|
| POST | `/invoice/add` | 创建 |  |
| POST | `/invoice/batch/delete` | 批量删除客户 | 🚫 禁止 |
| GET | `/invoice/delete/{id}` | 删除 | ⚠️ 需确认 |
| POST | `/invoice/export-all` | 导出全部合同 |  |
| POST | `/invoice/export-select` | 导出选中发票 |  |
| GET | `/invoice/get/snapshot/{id}` | 获取详情快照 |  |
| GET | `/invoice/get/{id}` | 详情 |  |
| POST | `/invoice/import` | 导入 |  |
| POST | `/invoice/import/pre-check` | 导入检查 |  |
| GET | `/invoice/module/form` | 获取表单配置 |  |
| GET | `/invoice/module/form/snapshot/{id}` | 获取表单快照配置 |  |
| POST | `/invoice/page` | 列表 |  |
| GET | `/invoice/tab` | tab是否显示 |  |
| GET | `/invoice/template/download` | 下载导入模板 |  |
| POST | `/invoice/update` | 更新 |  |
| POST | `/invoice/view/add` | 添加发票视图 |  |
| GET | `/invoice/view/delete/{id}` | 删除发票视图 | ⚠️ 需确认 |
| GET | `/invoice/view/detail/{id}` | 发票视图详情 |  |
| POST | `/invoice/view/edit/pos` | 视图-拖拽排序 |  |
| GET | `/invoice/view/enable/{id}` | 视图-启用/禁用 |  |
| GET | `/invoice/view/fixed/{id}` | 发票固定/取消固定 |  |
| GET | `/invoice/view/list` | 发票视图列表 |  |
| POST | `/invoice/view/update` | 编辑发票视图 |  |

## 合同 (Contract)（93 APIs）

| 方法 | 路径 | 说明 | 安全 |
|------|------|------|------|
| POST | `/contract/add` | 创建 |  |
| POST | `/contract/batch/update` | 批量更新合同 |  |
| POST | `/contract/business-title/add` | 创建 |  |
| POST | `/contract/business-title/approval` | 审核通过/不通过 |  |
| GET | `/contract/business-title/delete/{id}` | 删除 | ⚠️ 需确认 |
| POST | `/contract/business-title/export-all` | 导出全部 |  |
| POST | `/contract/business-title/export-select` | 导出选中工商抬头 |  |
| GET | `/contract/business-title/get/{id}` | 详情 |  |
| POST | `/contract/business-title/import` | 导入 |  |
| POST | `/contract/business-title/import/pre-check` | excel导入检查 |  |
| GET | `/contract/business-title/invoice/check/{id}` | 检查工商抬头是否开过票 |  |
| GET | `/contract/business-title/module/form` | 获取表单配置 |  |
| POST | `/contract/business-title/page` | 列表 |  |
| GET | `/contract/business-title/revoke/{id}` | 撤销审批 |  |
| GET | `/contract/business-title/template/download` | 下载导入模板 |  |
| GET | `/contract/business-title/third-query` | 第三方接口查询工商抬头信息 |  |
| POST | `/contract/business-title/third-query/option` | 第三方接口分页模糊查询工商名称 |  |
| POST | `/contract/business-title/update` | 更新 |  |
| POST | `/contract/contract-payment-plan/page` | 合同详情-回款列表 |  |
| POST | `/contract/contract-payment-record/page` | 合同详情-回款记录 |  |
| GET | `/contract/delete/{id}` | 删除 | ⚠️ 需确认 |
| POST | `/contract/export-all` | 导出全部合同 |  |
| POST | `/contract/export-select` | 导出选中合同 |  |
| GET | `/contract/get/snapshot/{id}` | 获取详情快照 |  |
| GET | `/contract/get/{id}` | 详情 |  |
| POST | `/contract/invoice/page` | 合同详情-发票列表 |  |
| GET | `/contract/invoice/statistic/{contractId}` | 合同详情-发票列表统计 |  |
| GET | `/contract/module/form` | 获取表单配置 |  |
| GET | `/contract/module/form/snapshot/{id}` | 获取表单快照配置 |  |
| POST | `/contract/order/page` | 合同详情-订单列表 |  |
| POST | `/contract/page` | 列表 |  |
| POST | `/contract/payment-plan/add` | 添加合同回款计划 |  |
| GET | `/contract/payment-plan/delete/{id}` | 删除合同回款计划 | ⚠️ 需确认 |
| POST | `/contract/payment-plan/export-all` | 导出全部回款计划 |  |
| POST | `/contract/payment-plan/export-select` | 导出选中回款计划 |  |
| GET | `/contract/payment-plan/get/{id}` | 合同回款计划详情 |  |
| POST | `/contract/payment-plan/import` | 导入 |  |
| POST | `/contract/payment-plan/import/pre-check` | 导入检查 |  |
| GET | `/contract/payment-plan/module/form` | 获取表单配置 |  |
| POST | `/contract/payment-plan/page` | 合同回款计划列表 |  |
| GET | `/contract/payment-plan/tab` | tab是否显示 |  |
| GET | `/contract/payment-plan/template/download` | 下载导入模板 |  |
| POST | `/contract/payment-plan/update` | 更新合同回款计划 |  |
| POST | `/contract/payment-plan/view/add` | 添加回款计划视图 |  |
| GET | `/contract/payment-plan/view/delete/{id}` | 删除回款计划视图 | ⚠️ 需确认 |
| GET | `/contract/payment-plan/view/detail/{id}` | 回款计划视图详情 |  |
| POST | `/contract/payment-plan/view/edit/pos` | 回款计划视图-拖拽排序 |  |
| GET | `/contract/payment-plan/view/enable/{id}` | 回款计划视图-启用/禁用 |  |
| GET | `/contract/payment-plan/view/fixed/{id}` | 回款计划视图固定/取消固定 |  |
| GET | `/contract/payment-plan/view/list` | 回款计划视图列表 |  |
| POST | `/contract/payment-plan/view/update` | 编辑回款计划视图 |  |
| POST | `/contract/payment-record/add` | 添加回款记录 |  |
| GET | `/contract/payment-record/delete/{id}` | 删除回款记录 | ⚠️ 需确认 |
| POST | `/contract/payment-record/export-all` | 导出全部回款记录 |  |
| POST | `/contract/payment-record/export-select` | 导出选中回款记录 |  |
| GET | `/contract/payment-record/get/{id}` | 回款记录详情 |  |
| POST | `/contract/payment-record/import` | 导入 |  |
| POST | `/contract/payment-record/import/pre-check` | 导入检查 |  |
| GET | `/contract/payment-record/module/form` | 获取表单配置 |  |
| POST | `/contract/payment-record/page` | 回款记录列表 |  |
| POST | `/contract/payment-record/statistic` | 回款统计 |  |
| GET | `/contract/payment-record/tab` | 视图TAB显示配置 |  |
| GET | `/contract/payment-record/template/download` | 下载导入模板 |  |
| POST | `/contract/payment-record/update` | 修改回款记录 |  |
| POST | `/contract/payment-record/view/add` | 添加回款记录视图 |  |
| GET | `/contract/payment-record/view/delete/{id}` | 删除回款记录视图 | ⚠️ 需确认 |
| GET | `/contract/payment-record/view/detail/{id}` | 回款记录视图详情 |  |
| POST | `/contract/payment-record/view/edit/pos` | 回款记录视图-拖拽排序 |  |
| GET | `/contract/payment-record/view/enable/{id}` | 回款记录视图-启用/禁用 |  |
| GET | `/contract/payment-record/view/fixed/{id}` | 回款记录视图固定/取消固定 |  |
| GET | `/contract/payment-record/view/list` | 回款记录视图列表 |  |
| POST | `/contract/payment-record/view/update` | 编辑回款记录视图 |  |
| POST | `/contract/sort` | 合同阶段看板拖拽排序 |  |
| POST | `/contract/stage/add` | 添加合同状态流 |  |
| POST | `/contract/stage/advanced/config` | 合同流转配置保存 |  |
| GET | `/contract/stage/circulation-type/{type}` | 基础/高级流转切换 |  |
| GET | `/contract/stage/delete/{id}` | 删除合同状态流 | ⚠️ 需确认 |
| GET | `/contract/stage/get` | 合同状态配置列表 |  |
| POST | `/contract/stage/sort` | 合同阶段排序 |  |
| POST | `/contract/stage/update` | 更新合同阶段配置 |  |
| POST | `/contract/stage/update-rollback` | 合同状态流回退设置 |  |
| POST | `/contract/statistic` | 合同统计 |  |
| GET | `/contract/tab` | tab是否显示 |  |
| POST | `/contract/update` | 更新 |  |
| POST | `/contract/update/stage` | 更新合同阶段 |  |
| POST | `/contract/view/add` | 添加合同视图 |  |
| GET | `/contract/view/delete/{id}` | 删除合同视图 | ⚠️ 需确认 |
| GET | `/contract/view/detail/{id}` | 合同视图详情 |  |
| POST | `/contract/view/edit/pos` | 视图-拖拽排序 |  |
| GET | `/contract/view/enable/{id}` | 视图-启用/禁用 |  |
| GET | `/contract/view/fixed/{id}` | 视图固定/取消固定 |  |
| GET | `/contract/view/list` | 合同视图列表 |  |
| POST | `/contract/view/update` | 编辑合同视图 |  |

## 商机 (Opportunity)（75 APIs）

| 方法 | 路径 | 说明 | 安全 |
|------|------|------|------|
| POST | `/opportunity-rule/add` | 添加商机规则 |  |
| GET | `/opportunity-rule/delete/{id}` | 删除商机规则 | ⚠️ 需确认 |
| POST | `/opportunity-rule/page` | 分页获取商机规则 |  |
| GET | `/opportunity-rule/switch/{id}` | 启用/禁用商机规则 |  |
| POST | `/opportunity-rule/update` | 修改商机规则 |  |
| POST | `/opportunity/add` | 添加商机 |  |
| POST | `/opportunity/batch/delete` | 批量删除商机 | 🚫 禁止 |
| POST | `/opportunity/batch/transfer` | 批量转移商机 |  |
| POST | `/opportunity/batch/update` | 批量更新商机 |  |
| POST | `/opportunity/chart` | 客户图表生成 |  |
| GET | `/opportunity/contact/list/{opportunityId}` | 商机下的联系人列表 |  |
| GET | `/opportunity/delete/{id}` | 删除商机 | ⚠️ 需确认 |
| POST | `/opportunity/export-all` | 商机导出全部 |  |
| POST | `/opportunity/export-select` | 导出选中商机 |  |
| POST | `/opportunity/follow/plan/add` | 添加商机跟进计划 |  |
| GET | `/opportunity/follow/plan/cancel/{id}` | 取消商机跟进计划 |  |
| GET | `/opportunity/follow/plan/delete/{id}` | 商机删除跟进计划 | ⚠️ 需确认 |
| GET | `/opportunity/follow/plan/get/{id}` | 商机跟进计划详情 |  |
| POST | `/opportunity/follow/plan/page` | 商机跟进计划列表 |  |
| POST | `/opportunity/follow/plan/status/update` | 商机更新跟进计划状态 |  |
| POST | `/opportunity/follow/plan/update` | 更新商机跟进计划 |  |
| POST | `/opportunity/follow/record/add` | 添加商机跟进记录 |  |
| GET | `/opportunity/follow/record/delete/{id}` | 客户删除跟进记录 | ⚠️ 需确认 |
| GET | `/opportunity/follow/record/get/{id}` | 商机跟进记录详情 |  |
| POST | `/opportunity/follow/record/page` | 商机跟进记录列表 |  |
| POST | `/opportunity/follow/record/update` | 更新商机跟进记录 |  |
| GET | `/opportunity/get/{id}` | 商机详情 |  |
| POST | `/opportunity/import` | 导入 |  |
| POST | `/opportunity/import/pre-check` | 导入检查 |  |
| GET | `/opportunity/module/form` | 获取表单配置 |  |
| POST | `/opportunity/page` | 商机列表 |  |
| POST | `/opportunity/quotation/add` | 新增报价单 |  |
| POST | `/opportunity/quotation/approve` | 审批报价单 |  |
| POST | `/opportunity/quotation/batch/approve` | 批量审批报价单 |  |
| POST | `/opportunity/quotation/batch/update` | 批量更新报价单 |  |
| POST | `/opportunity/quotation/batch/voided` | 批量作废报价单 |  |
| GET | `/opportunity/quotation/delete/{id}` | 删除报价单 | ⚠️ 需确认 |
| GET | `/opportunity/quotation/download/{id}` | 下载报价单日志记录 |  |
| GET | `/opportunity/quotation/get/snapshot/{id}` | 获取报价单快照详情 |  |
| GET | `/opportunity/quotation/get/{id}` | 获取报价单详情 |  |
| GET | `/opportunity/quotation/module/form` | 获取表单配置 |  |
| GET | `/opportunity/quotation/module/form/snapshot/{id}` | 获取表单快照配置 |  |
| POST | `/opportunity/quotation/page` | 报价单列表 |  |
| GET | `/opportunity/quotation/revoke/{id}` | 撤销报价单审批 |  |
| GET | `/opportunity/quotation/tab` | 所有商机报价单和部门商机报价单tab是否显示 |  |
| POST | `/opportunity/quotation/update` | 更新报价单 |  |
| POST | `/opportunity/quotation/view/add` | 添加报价单视图 |  |
| GET | `/opportunity/quotation/view/delete/{id}` | 删除报价单视图 | ⚠️ 需确认 |
| GET | `/opportunity/quotation/view/detail/{id}` | 报价单视图详情 |  |
| POST | `/opportunity/quotation/view/edit/pos` | 报价单视图-拖拽排序 |  |
| GET | `/opportunity/quotation/view/enable/{id}` | 报价单视图-启用/禁用 |  |
| GET | `/opportunity/quotation/view/fixed/{id}` | 报价单视图固定/取消固定 |  |
| GET | `/opportunity/quotation/view/list` | 报价单视图列表 |  |
| POST | `/opportunity/quotation/view/update` | 编辑报价单视图 |  |
| GET | `/opportunity/quotation/voided/{id}` | 作废报价单 |  |
| POST | `/opportunity/sort` | 商机阶段看板拖拽排序 |  |
| POST | `/opportunity/stage/add` | 添加商机阶段 |  |
| GET | `/opportunity/stage/delete/{id}` | 删除商机阶段 | ⚠️ 需确认 |
| GET | `/opportunity/stage/get` | 商机阶段配置列表 |  |
| POST | `/opportunity/stage/sort` | 商机阶段排序 |  |
| POST | `/opportunity/stage/update` | 更新商机阶段配置 |  |
| POST | `/opportunity/stage/update-rollback` | 商机阶段回退设置 |  |
| POST | `/opportunity/statistic` | 商机统计 |  |
| GET | `/opportunity/tab` | 所有商机和部门商机tab是否显示 |  |
| GET | `/opportunity/template/download` | 下载导入模板 |  |
| POST | `/opportunity/update` | 更新商机 |  |
| POST | `/opportunity/update/stage` | 更新商机阶段 |  |
| POST | `/opportunity/view/add` | 添加商机视图 |  |
| GET | `/opportunity/view/delete/{id}` | 删除商机视图 | ⚠️ 需确认 |
| GET | `/opportunity/view/detail/{id}` | 商机视图详情 |  |
| POST | `/opportunity/view/edit/pos` | 商机视图-拖拽排序 |  |
| GET | `/opportunity/view/enable/{id}` | 商机视图-启用/禁用 |  |
| GET | `/opportunity/view/fixed/{id}` | 商机视图固定/取消固定 |  |
| GET | `/opportunity/view/list` | 商机视图列表 |  |
| POST | `/opportunity/view/update` | 编辑商机视图 |  |

## 审批 (Approval)（25 APIs）

| 方法 | 路径 | 说明 | 安全 |
|------|------|------|------|
| POST | `/approval-action/approve` | 同意 |  |
| POST | `/approval-action/back` | 退回 |  |
| POST | `/approval-action/batch-approve` | 批量同意 |  |
| POST | `/approval-action/batch-reject` | 批量驳回 |  |
| POST | `/approval-action/reject` | 驳回 |  |
| POST | `/approval-action/revoke` | 撤回 |  |
| POST | `/approval-action/sign` | 加签 |  |
| POST | `/approval-flow/add` | 新建审批流 |  |
| GET | `/approval-flow/delete/{id}` | 删除审批流 | ⚠️ 需确认 |
| GET | `/approval-flow/enable/{id}` | 启用/禁用审批流 |  |
| GET | `/approval-flow/get-by-form-type/{formType}` | 根据表单类型获取审批流信息 |  |
| GET | `/approval-flow/get/{id}` | 获取审批流详情 |  |
| POST | `/approval-flow/page` | 审批流列表 |  |
| GET | `/approval-flow/status-permission/setting/{formType}` | 根据表单类型获取审批流状态权限配置 |  |
| POST | `/approval-flow/update` | 更新审批流 |  |
| POST | `/approval-flow/webhook/test` | webhook-测试连接 |  |
| GET | `/approval-resource/detail/{resourceId}` | 记录详情 |  |
| POST | `/approval-resource/push` | 提审 |  |
| POST | `/approval-resource/revoke` | 撤销 |  |
| GET | `/approval-resource/simple-detail/{resourceId}` | 列表详情 |  |
| POST | `/approval-todo/cc/page` | 审核代办-抄送我的审批分页 |  |
| POST | `/approval-todo/initiated/page` | 审核代办-我发起的审批分页 |  |
| GET | `/approval-todo/pending/count` | 审核代办-待我审批统计 |  |
| POST | `/approval-todo/pending/page` | 审核代办-当前用户待审核资源分页 |  |
| POST | `/approval-todo/processed/page` | 审核代办-当前用户已处理审批分页 |  |

## 客户 (Account)（124 APIs）

| 方法 | 路径 | 说明 | 安全 |
|------|------|------|------|
| POST | `/account-capacity/add` | 添加客户库容设置 |  |
| GET | `/account-capacity/delete/{id}` | 删除客户库容设置 | ⚠️ 需确认 |
| GET | `/account-capacity/get` | 获取客户库容设置 |  |
| POST | `/account-capacity/update` | 修改客户库容设置 |  |
| POST | `/account-pool/add` | 保存公海池 |  |
| GET | `/account-pool/delete/{id}` | 删除公海池 | ⚠️ 需确认 |
| GET | `/account-pool/no-pick/{id}` | 公海池是否存在未领取线索 |  |
| POST | `/account-pool/page` | 分页获取公海池 |  |
| POST | `/account-pool/quick-update` | 快捷保存公海池 |  |
| GET | `/account-pool/switch/{id}` | 启用/禁用公海池 |  |
| POST | `/account-pool/update` | 编辑公海池 |  |
| POST | `/account/add` | 添加客户 |  |
| POST | `/account/batch/delete` | 批量删除客户 | 🚫 禁止 |
| POST | `/account/batch/to-pool` | 批量移入公海 |  |
| POST | `/account/batch/transfer` | 批量转移客户 |  |
| POST | `/account/batch/update` | 批量更新客户 |  |
| POST | `/account/chart` | 客户图表生成 |  |
| POST | `/account/collaboration/add` | 添加客户协作人 |  |
| POST | `/account/collaboration/batch/delete` | 批量删除客户协作人 | 🚫 禁止 |
| GET | `/account/collaboration/delete/{id}` | 删除客户协作人 | ⚠️ 需确认 |
| GET | `/account/collaboration/list/{customerId}` | 客户协作人列表 |  |
| POST | `/account/collaboration/update` | 更新客户协作人 |  |
| POST | `/account/contact/add` | 添加客户联系人 |  |
| POST | `/account/contact/batch/update` | 批量更新客户联系人 |  |
| POST | `/account/contact/chart` | 联系人图表生成 |  |
| GET | `/account/contact/delete/{id}` | 删除客户联系人 | ⚠️ 需确认 |
| POST | `/account/contact/disable/{id}` | 禁用联系人 |  |
| GET | `/account/contact/enable/{id}` | 启用联系人 |  |
| POST | `/account/contact/export-all` | 联系人导出全部 |  |
| POST | `/account/contact/export-select` | 导出选中联系人 |  |
| GET | `/account/contact/get/{id}` | 客户联系人详情 |  |
| POST | `/account/contact/import` | 导入 |  |
| POST | `/account/contact/import/pre-check` | 导入检查 |  |
| GET | `/account/contact/list/{customerId}` | 客户下的联系人列表 |  |
| GET | `/account/contact/module/form` | 获取表单配置 |  |
| GET | `/account/contact/opportunity/check/{id}` | 检查客户联系人是否有关联商机 |  |
| POST | `/account/contact/page` | 联系人列表 |  |
| GET | `/account/contact/tab` | 所有所有和部门联系人tab是否显示 |  |
| GET | `/account/contact/template/download` | 下载导入模板 |  |
| POST | `/account/contact/update` | 更新客户联系人 |  |
| POST | `/account/contact/view/add` | 添加联系人视图 |  |
| GET | `/account/contact/view/delete/{id}` | 删除联系人视图 | ⚠️ 需确认 |
| GET | `/account/contact/view/detail/{id}` | 联系人视图详情 |  |
| POST | `/account/contact/view/edit/pos` | 联系人视图-拖拽排序 |  |
| GET | `/account/contact/view/enable/{id}` | 联系人视图-启用/禁用 |  |
| GET | `/account/contact/view/fixed/{id}` | 联系人视图固定/取消固定 |  |
| GET | `/account/contact/view/list` | 联系人视图列表 |  |
| POST | `/account/contact/view/update` | 编辑联系人视图 |  |
| POST | `/account/contract/page` | 客户详情-合同列表 |  |
| POST | `/account/contract/payment-plan/page` | 客户详情-合同回款计划列表 |  |
| GET | `/account/contract/payment-plan/statistic/{accountId}` | 客户详情-合同回款计划列表统计 |  |
| POST | `/account/contract/payment-record/page` | 客户详情-合同回款记录列表 |  |
| GET | `/account/contract/payment-record/statistic/{accountId}` | 客户详情-合同回款记录列表统计 |  |
| GET | `/account/contract/statistic/{accountId}` | 客户详情-合同列表统计 |  |
| GET | `/account/delete/{id}` | 删除客户 | ⚠️ 需确认 |
| POST | `/account/export-all` | 客户导出全部 |  |
| POST | `/account/export-select` | 导出选中客户 |  |
| POST | `/account/follow/plan/add` | 添加客户跟进计划 |  |
| GET | `/account/follow/plan/cancel/{id}` | 取消客户跟进计划 |  |
| GET | `/account/follow/plan/delete/{id}` | 客户删除跟进计划 | ⚠️ 需确认 |
| GET | `/account/follow/plan/get/{id}` | 客户跟进计划详情 |  |
| POST | `/account/follow/plan/page` | 客户跟进计划列表 |  |
| POST | `/account/follow/plan/status/update` | 客户更新跟进计划状态 |  |
| POST | `/account/follow/plan/update` | 更新客户跟进计划 |  |
| POST | `/account/follow/record/add` | 添加客户跟进记录 |  |
| GET | `/account/follow/record/delete/{id}` | 客户删除跟进记录 | ⚠️ 需确认 |
| GET | `/account/follow/record/get/{id}` | 客户跟进记录详情 |  |
| POST | `/account/follow/record/page` | 客户跟进记录列表 |  |
| POST | `/account/follow/record/pool/page` | 客户公海池跟进记录列表 |  |
| POST | `/account/follow/record/update` | 更新客户跟进记录 |  |
| GET | `/account/get/{id}` | 客户详情 |  |
| POST | `/account/import` | 导入 |  |
| POST | `/account/import/pre-check` | 导入检查 |  |
| POST | `/account/invoice/page` | 客户详情-发票列表 |  |
| GET | `/account/invoice/statistic/{accountId}` | 客户详情-发票列表统计 |  |
| POST | `/account/merge` | 合并客户 |  |
| POST | `/account/merge/page` | 分页获取合并客户列表 |  |
| GET | `/account/module/form` | 获取表单配置 |  |
| POST | `/account/opportunity/page` | 客户详情-商机列表 |  |
| POST | `/account/option` | 客户选项 |  |
| POST | `/account/order/page` | 客户详情-订单列表 |  |
| GET | `/account/owner/history/list/{customerId}` | 客户责任人历史列表 |  |
| POST | `/account/page` | 客户列表 |  |
| POST | `/account/relation/add/{customerId}` | 添加客户关系 |  |
| GET | `/account/relation/delete/{id}` | 删除客户关系 | ⚠️ 需确认 |
| GET | `/account/relation/list/{customerId}` | 客户关系列表 |  |
| POST | `/account/relation/save/{customerId}` | 整体客户关系 |  |
| POST | `/account/relation/update/{customerId}` | 更新客户关系 |  |
| GET | `/account/tab` | 所有客户和部门客户tab是否显示 |  |
| GET | `/account/template/download` | 下载导入模板 |  |
| POST | `/account/to-pool` | 移入公海 |  |
| POST | `/account/update` | 更新客户 |  |
| POST | `/account/view/add` | 添加客户视图 |  |
| GET | `/account/view/delete/{id}` | 删除客户视图 | ⚠️ 需确认 |
| GET | `/account/view/detail/{id}` | 客户视图详情 |  |
| POST | `/account/view/edit/pos` | 客户视图-拖拽排序 |  |
| GET | `/account/view/enable/{id}` | 客户视图-启用/禁用 |  |
| GET | `/account/view/fixed/{id}` | 客户视图固定/取消固定 |  |
| GET | `/account/view/list` | 客户视图列表 |  |
| POST | `/account/view/update` | 编辑客户视图 |  |
| POST | `/pool/account/assign` | 分配客户 |  |
| POST | `/pool/account/batch-assign` | 批量分配客户 |  |
| POST | `/pool/account/batch-delete` | 批量删除客户 | 🚫 禁止 |
| POST | `/pool/account/batch-pick` | 批量领取客户 |  |
| POST | `/pool/account/batch-update` | 批量更新客户 |  |
| POST | `/pool/account/chart` | 客户图表生成 |  |
| GET | `/pool/account/delete/{id}` | 删除客户 | ⚠️ 需确认 |
| POST | `/pool/account/export-all` | 客户导出全部 |  |
| POST | `/pool/account/export-select` | 导出选中客户 |  |
| GET | `/pool/account/get/{id}` | 客户详情 |  |
| POST | `/pool/account/import` | 导入 |  |
| POST | `/pool/account/import/pre-check` | 导入检查 |  |
| GET | `/pool/account/options` | 获取当前用户公海选项 |  |
| POST | `/pool/account/page` | 客户列表 |  |
| POST | `/pool/account/pick` | 领取客户 |  |
| GET | `/pool/account/template/download` | 下载导入模板 |  |
| POST | `/pool/account/view/add` | 添加公海视图 |  |
| GET | `/pool/account/view/delete/{id}` | 删除公海视图 | ⚠️ 需确认 |
| GET | `/pool/account/view/detail/{id}` | 公海视图详情 |  |
| POST | `/pool/account/view/edit/pos` | 公海视图-拖拽排序 |  |
| GET | `/pool/account/view/enable/{id}` | 公海视图-启用/禁用 |  |
| GET | `/pool/account/view/fixed/{id}` | 公海视图固定/取消固定 |  |
| GET | `/pool/account/view/list` | 公海视图列表 |  |
| POST | `/pool/account/view/update` | 编辑公海视图 |  |

## 智能体 (Agent)（23 APIs）

| 方法 | 路径 | 说明 | 安全 |
|------|------|------|------|
| POST | `/agent/add` | 智能体-添加 |  |
| GET | `/agent/application/config` | 获取智能体设置 |  |
| GET | `/agent/application/{workspaceId}` | 获取智能体应用 |  |
| GET | `/agent/check` | 配置连接检测 |  |
| POST | `/agent/collect/page` | 智能体收藏列表 |  |
| GET | `/agent/collect/{id}` | 智能体收藏 |  |
| GET | `/agent/delete/{id}` | 智能体-删除 | ⚠️ 需确认 |
| GET | `/agent/detail/{id}` | 智能体-详情 |  |
| POST | `/agent/edit/pos` | 智能体-拖拽排序 |  |
| GET | `/agent/edition` | 获取版本 |  |
| POST | `/agent/module/add` | 智能体-添加文件夹 |  |
| GET | `/agent/module/count` | 智能体-文件树数量 |  |
| POST | `/agent/module/delete` | 智能体-刪除文件夹 | ⚠️ 需确认 |
| POST | `/agent/module/move` | 智能体-文件夹移动 |  |
| POST | `/agent/module/rename` | 智能体-重命名文件夹 |  |
| GET | `/agent/module/tree` | 智能体-文件树查询 |  |
| GET | `/agent/option` | 用户可选智能体下拉option |  |
| POST | `/agent/page` | 智能体列表 |  |
| POST | `/agent/rename` | 智能体-重命名 |  |
| POST | `/agent/script` | 获取脚本信息 |  |
| GET | `/agent/un-collect/{id}` | 智能体取消收藏 |  |
| POST | `/agent/update` | 智能体-更新 |  |
| GET | `/agent/workspace` | 获取用户工作空间 |  |

## 系统管理 (System)（113 APIs）

| 方法 | 路径 | 说明 | 安全 |
|------|------|------|------|
| POST | `/announcement/add` | 新增公告 |  |
| GET | `/announcement/delete/{announcementId}` | 删除公告 | ⚠️ 需确认 |
| POST | `/announcement/edit` | 编辑公告 |  |
| GET | `/announcement/get/{announcementId}` | 获取公告 |  |
| POST | `/announcement/page` | 公告列表分页查询 |  |
| GET | `/attachment/download/{id}` | 下载附件 |  |
| GET | `/attachment/preview/{id}` | 预览附件 |  |
| POST | `/attachment/upload/temp` | 上传临时附件 |  |
| GET | `/business-title/config/get` | 获取工商抬头配置 |  |
| GET | `/business-title/config/switch/{id}` | 必填/非必填设置 |  |
| POST | `/dict/add` | 添加字典值 |  |
| GET | `/dict/config/{module}` | 获取字典配置 |  |
| GET | `/dict/delete/{id}` | 删除字典值 | ⚠️ 需确认 |
| GET | `/dict/get/{module}` | 获取字典列表 |  |
| POST | `/dict/sort` | 字典排序 |  |
| POST | `/dict/switch` | 字典开启关闭 |  |
| POST | `/dict/update` | 修改字典值 |  |
| GET | `/export/center/cancel/{taskId}` | 取消导出 |  |
| GET | `/export/center/download/{taskId}` | 下载 |  |
| POST | `/export/center/list` | 查询导出任务列表 |  |
| POST | `/field/check/repeat` | 校验重复值 |  |
| GET | `/field/dept/tree` | 获取部门树 |  |
| GET | `/field/display/{formKey}` | 获取表单配置 |  |
| POST | `/field/resolve/business` | 解析业务ID |  |
| POST | `/field/source/account` | 分页获取客户 |  |
| POST | `/field/source/business-title` | 分页获取工商抬头信息 |  |
| GET | `/field/source/config/{formKey}` | 获取数据源表单配置 |  |
| POST | `/field/source/contact` | 分页获取联系人 |  |
| POST | `/field/source/contract` | 分页获取合同 |  |
| POST | `/field/source/contract/payment-plan` | 分页获取合同回款计划 |  |
| POST | `/field/source/contract/payment-record` | 分页获取合同回款记录 |  |
| POST | `/field/source/custom-form-data` | 分页获取自定义表单数据 |  |
| POST | `/field/source/invoice` | 分页获取发票信息 |  |
| POST | `/field/source/lead` | 分页获取线索 |  |
| POST | `/field/source/opportunity` | 分页获取商机 |  |
| POST | `/field/source/order` | 分页获取订单列表 |  |
| POST | `/field/source/price` | 分页获取产品价格表 |  |
| POST | `/field/source/product` | 分页获取产品 |  |
| POST | `/field/source/quotation` | 分页获取报价单 |  |
| POST | `/field/source/ref-detail` | 批量获取数据源引用详情 |  |
| GET | `/field/user/dept/tree` | 获取部门用户树 |  |
| GET | `/get-key` | 获取公钥 |  |
| GET | `/is-login` | 是否登录 |  |
| POST | `/license/add` | 添加License |  |
| GET | `/license/validate` | License 校验 |  |
| POST | `/locale-language/change` | 修改本地语言 |  |
| POST | `/login` | 登录 |  |
| POST | `/login/log/list` | 系统管理-登录日志-列表查询 |  |
| GET | `/logout` | 退出登录 |  |
| GET | `/mask/config/get` | 获取脱敏字段配置 |  |
| POST | `/mask/config/save` | 保存配置 |  |
| GET | `/mcp/form/config/{formKey}` | 获取表单配置 |  |
| POST | `/message/task/batch/save` | 项目管理-消息管理-消息设置-批量编辑 |  |
| POST | `/message/task/config/query` | 项目管理-消息管理-消息设置-获取消息配置 |  |
| GET | `/message/task/get` | 项目管理-消息管理-消息设置-获取消息设置 |  |
| POST | `/message/task/save` | 项目管理-消息管理-消息设置-保存消息设置 |  |
| GET | `/module/advanced-search/settings` | 高级搜索开关设置 |  |
| GET | `/module/advanced-search/switch` | 高级搜索开关设置 |  |
| GET | `/module/form/config/{formKey}` | 获取表单配置 |  |
| GET | `/module/form/list` | 获取表单列表 |  |
| POST | `/module/form/save` | 保存 |  |
| POST | `/module/list` | 获取模块设置列表 |  |
| GET | `/module/role/tree` | 获取角色树 |  |
| POST | `/module/sort` | 模块排序 |  |
| GET | `/module/switch/{id}` | 单个模块开启或关闭 |  |
| GET | `/module/user/dept/tree` | 获取部门用户树 |  |
| GET | `/navigation/list` | 获取导航栏列表 |  |
| POST | `/navigation/sort` | 导航栏排序 |  |
| POST | `/notification/count` | 消息中心-获取消息中心消息具体类型具体状态的数量 |  |
| GET | `/notification/last/announcement/list` | 消息中心-获取用户未读的公告列表 |  |
| GET | `/notification/last/list` | 消息中心-获取消息中未读的最新部分消息 |  |
| POST | `/notification/list/all/page` | 消息中心-获取消息中心所有消息列表 |  |
| GET | `/notification/read/all` | 消息中心-将消息中心所有信息设置为已读消息 |  |
| GET | `/notification/read/{id}` | 消息中心-将消息设置为已读 |  |
| GET | `/operation/log/detail/{id}` | 系统管理-操作日志-详情 |  |
| POST | `/operation/log/list` | 系统管理-操作日志-列表查询 |  |
| GET | `/organization/settings/de-token` | 生成DE-Token |  |
| POST | `/organization/settings/de/org/list` | 获取de组织列表 |  |
| GET | `/organization/settings/de/sync` | 同步DE数据 |  |
| GET | `/organization/settings/email` | 获取邮件设置 |  |
| POST | `/organization/settings/email/edit` | 编辑邮件设置 |  |
| POST | `/organization/settings/email/test` | 系统设置-系统-系统参数-基本设置-邮件设置-测试连接 |  |
| GET | `/organization/settings/switch-third-party` | 切换三方设置 |  |
| GET | `/organization/settings/third-party` | 获取三方设置 |  |
| POST | `/organization/settings/third-party/edit` | 编辑三方设置 |  |
| GET | `/organization/settings/third-party/get/{type}` | 根据类型获取开启的三方扫码设置 |  |
| GET | `/organization/settings/third-party/sync/resource` | 获取最新的三方同步来源 |  |
| POST | `/organization/settings/third-party/test` | 校验配置是否链接成功 |  |
| GET | `/organization/settings/third-party/types` | 获取三方应用扫码类型集合 |  |
| POST | `/personal/center/follow/plan/list` | 用户跟进计划列表 |  |
| GET | `/personal/center/info` | 当前用户详情 |  |
| POST | `/personal/center/info/reset` | 用户密码重置 |  |
| POST | `/personal/center/mail/code/send` |  |  |
| POST | `/personal/center/update` | 更新户详情 |  |
| GET | `/pic/preview/{id}` | 预览图片 |  |
| POST | `/pic/upload/temp` | 上传临时图片 |  |
| GET | `/search/config/get` | 获取搜索字段配置 |  |
| GET | `/search/config/reset` | 重置 |  |
| POST | `/search/config/save` | 保存配置 |  |
| GET | `/sse/close` | 主动断开客户端连接 |  |
| GET | `/sse/subscribe` | 客户端订阅 SSE 事件流 |  |
| GET | `/sso/callback/ding-talk` | 获取钉钉扫码登陆验证 |  |
| GET | `/sso/callback/lark` | 获取飞书扫码登陆验证 |  |
| GET | `/sso/callback/oauth/ding-talk` |  |  |
| GET | `/sso/callback/oauth/lark` |  |  |
| GET | `/sso/callback/oauth/lark-mobile` |  |  |
| GET | `/sso/callback/oauth/wecom` |  |  |
| GET | `/sso/callback/wecom` | 获取企业微信登陆验证 |  |
| GET | `/system/version` | 获取当前系统版本 |  |
| GET | `/tender/application/config` | 获取标讯设置 |  |
| GET | `/ui/display/info` | 系统设置-界面设置-保获取界面设置信息 |  |
| GET | `/ui/display/preview` | 预览图片 |  |
| POST | `/ui/display/save` | 系统设置-界面设置-保存界面设置信息 |  |

## 线索 (Lead)（80 APIs）

| 方法 | 路径 | 说明 | 安全 |
|------|------|------|------|
| POST | `/lead-capacity/add` | 添加线索库容设置 |  |
| GET | `/lead-capacity/delete/{id}` | 删除线索库容设置 | ⚠️ 需确认 |
| GET | `/lead-capacity/get` | 获取线索库容设置 |  |
| POST | `/lead-capacity/update` | 修改线索库容设置 |  |
| POST | `/lead-pool/add` | 新增线索池 |  |
| GET | `/lead-pool/delete/{id}` | 删除线索池 | ⚠️ 需确认 |
| GET | `/lead-pool/no-pick/{id}` | 线索池是否存在未领取线索 |  |
| POST | `/lead-pool/page` | 分页获取线索池 |  |
| POST | `/lead-pool/quick-update` | 快捷保存线索池 |  |
| GET | `/lead-pool/switch/{id}` | 启用/禁用线索池 |  |
| POST | `/lead-pool/update` | 编辑线索池 |  |
| POST | `/lead/add` | 添加线索 |  |
| POST | `/lead/batch/delete` | 批量删除线索 | 🚫 禁止 |
| POST | `/lead/batch/to-pool` | 批量移入线索池 |  |
| POST | `/lead/batch/transfer` | 批量转移线索 |  |
| POST | `/lead/batch/update` | 批量更新线索 |  |
| POST | `/lead/chart` | 客户图表生成 |  |
| GET | `/lead/delete/{id}` | 删除线索 | ⚠️ 需确认 |
| POST | `/lead/export` | 导出全部 |  |
| POST | `/lead/export-select` | 导出选中 |  |
| POST | `/lead/follow/plan/add` | 添加线索跟进计划 |  |
| GET | `/lead/follow/plan/cancel/{id}` | 取消线索跟进计划 |  |
| GET | `/lead/follow/plan/delete/{id}` | 线索删除跟进计划 | ⚠️ 需确认 |
| GET | `/lead/follow/plan/get/{id}` | 线索跟进计划详情 |  |
| POST | `/lead/follow/plan/page` | 线索跟进计划列表 |  |
| POST | `/lead/follow/plan/status/update` | 线索更新跟进计划状态 |  |
| POST | `/lead/follow/plan/update` | 更新线索跟进计划 |  |
| POST | `/lead/follow/record/add` | 添加线索跟进记录 |  |
| GET | `/lead/follow/record/delete/{id}` | 线索删除跟进记录 | ⚠️ 需确认 |
| GET | `/lead/follow/record/get/{id}` | 线索跟进记录详情 |  |
| POST | `/lead/follow/record/page` | 线索跟进记录列表 |  |
| POST | `/lead/follow/record/pool/page` | 线索池跟进记录列表 |  |
| POST | `/lead/follow/record/update` | 更新线索跟进记录 |  |
| GET | `/lead/get/{id}` | 线索详情 |  |
| POST | `/lead/import` | 导入 |  |
| POST | `/lead/import/pre-check` | 导入检查 |  |
| GET | `/lead/module/form` | 获取表单配置 |  |
| GET | `/lead/owner/history/list/{clueId}` | 线索责任人历史列表 |  |
| POST | `/lead/page` | 线索列表 |  |
| POST | `/lead/re-transition/account` | 批量关联已有客户 |  |
| POST | `/lead/status/update` | 更新线索状态 |  |
| GET | `/lead/tab` | 所有线索和部门线索tab是否显示 |  |
| GET | `/lead/template/download` | 下载导入模板 |  |
| POST | `/lead/to-pool` | 移入线索池 |  |
| POST | `/lead/transform` | 转换 |  |
| POST | `/lead/transition/account` | 转为客户 |  |
| POST | `/lead/transition/account/page` | 客户转移分页查询 |  |
| POST | `/lead/update` | 更新线索 |  |
| POST | `/lead/view/add` | 添加线索视图 |  |
| GET | `/lead/view/delete/{id}` | 删除线索视图 | ⚠️ 需确认 |
| GET | `/lead/view/detail/{id}` | 线索视图详情 |  |
| POST | `/lead/view/edit/pos` | 线索视图-拖拽排序 |  |
| GET | `/lead/view/enable/{id}` | 线索视图-启用/禁用 |  |
| GET | `/lead/view/fixed/{id}` | 线索视图固定/取消固定 |  |
| GET | `/lead/view/list` | 线索视图列表 |  |
| POST | `/lead/view/update` | 编辑线索视图 |  |
| POST | `/pool/lead/assign` | 分配线索 |  |
| POST | `/pool/lead/batch-assign` | 批量分配线索 |  |
| POST | `/pool/lead/batch-delete` | 批量删除线索 | 🚫 禁止 |
| POST | `/pool/lead/batch-pick` | 批量领取线索 |  |
| POST | `/pool/lead/batch-update` | 批量更新线索 |  |
| POST | `/pool/lead/chart` | 客户图表生成 |  |
| GET | `/pool/lead/delete/{id}` | 删除线索 | ⚠️ 需确认 |
| POST | `/pool/lead/export-all` | 导出全部 |  |
| POST | `/pool/lead/export-select` | 导出选中 |  |
| GET | `/pool/lead/get/{id}` | 线索详情 |  |
| POST | `/pool/lead/import` | 导入 |  |
| POST | `/pool/lead/import/pre-check` | 导入检查 |  |
| GET | `/pool/lead/options` | 获取当前用户线索池选项 |  |
| POST | `/pool/lead/page` | 线索列表 |  |
| POST | `/pool/lead/pick` | 领取线索 |  |
| GET | `/pool/lead/template/download` | 下载导入模板 |  |
| POST | `/pool/lead/view/add` | 添加线索池视图 |  |
| GET | `/pool/lead/view/delete/{id}` | 删除线索池视图 | ⚠️ 需确认 |
| GET | `/pool/lead/view/detail/{id}` | 线索池视图详情 |  |
| POST | `/pool/lead/view/edit/pos` | 线索池视图-拖拽排序 |  |
| GET | `/pool/lead/view/enable/{id}` | 线索池视图-启用/禁用 |  |
| GET | `/pool/lead/view/fixed/{id}` | 线索池视图固定/取消固定 |  |
| GET | `/pool/lead/view/list` | 线索池视图列表 |  |
| POST | `/pool/lead/view/update` | 编辑线索池视图 |  |

## 组织架构 (Organization)（34 APIs）

| 方法 | 路径 | 说明 | 安全 |
|------|------|------|------|
| POST | `/department/add` | 组织架构-添加子部门 |  |
| POST | `/department/delete` | 组织架构-删除部门 | ⚠️ 需确认 |
| POST | `/department/delete/check` | 组织架构-删除部门校验 | ⚠️ 需确认 |
| POST | `/department/rename` | 组织架构-重命名子部门 |  |
| POST | `/department/set-commander` | 组织架构-设置部门负责人 |  |
| POST | `/department/sort` | 组织架构-部门排序 |  |
| GET | `/department/tree` | 组织架构-部门树查询 |  |
| POST | `/user/add` | 用户(员工)-添加员工 |  |
| GET | `/user/admin/option` | 获取管理员用户下拉option |  |
| GET | `/user/api/key/add` | 个人中心-APIKEY-新增 |  |
| GET | `/user/api/key/delete/{id}` | 个人中心-APIKEY-删除 | ⚠️ 需确认 |
| GET | `/user/api/key/disable/{id}` | 个人中心-APIKEY-启用 |  |
| GET | `/user/api/key/enable/{id}` | 个人中心-APIKEY-启用 |  |
| GET | `/user/api/key/list` | 个人中心-APIKEY-列表 |  |
| POST | `/user/api/key/update` | 个人中心-APIKEY-更新 |  |
| POST | `/user/batch-enable` | 用户(员工)-批量启用/禁用 |  |
| POST | `/user/batch/edit` | 用户(员工)-批量编辑 |  |
| POST | `/user/batch/reset-password` | 用户(员工)-批量重置密码 |  |
| GET | `/user/delete/check/{id}` | 用户(员工)-删除校验 | ⚠️ 需确认 |
| GET | `/user/delete/{id}` | 用户(员工)-删除 | ⚠️ 需确认 |
| GET | `/user/detail/{id}` | 用户(员工)-员工详情 |  |
| GET | `/user/download/template` | 用户(员工)-excel导入-下载模板 |  |
| GET | `/user/get/{departmentId}` | 获取指定部门下用户 |  |
| POST | `/user/import` | 用户(员工)-excel导入 |  |
| POST | `/user/import/pre-check` | 用户(员工)-excel导入检查 |  |
| POST | `/user/list` | 用户(员工)-列表查询 |  |
| GET | `/user/option` | 获取用户下拉option |  |
| GET | `/user/reset-password/{userId}` | 用户(员工)-重置密码 |  |
| GET | `/user/role/option` | 获取用户角色下拉option |  |
| GET | `/user/sync-check` | 用户(员工)-是否为第三方同步数据 |  |
| GET | `/user/sync/check` | 用户(员工)-检查是否还在同步组织架构 |  |
| GET | `/user/sync/{type}` | 用户(员工)-同步组织架构 |  |
| POST | `/user/update` | 用户(员工)-更新 |  |
| POST | `/user/update/name` | 用户(员工)-更新名称 |  |

## 统计分析 (Statistics)（20 APIs）

| 方法 | 路径 | 说明 | 安全 |
|------|------|------|------|
| POST | `/advanced/search/account` | 全局搜索客户相关数据 |  |
| POST | `/advanced/search/account-pool` | 全局搜索-公海 |  |
| POST | `/advanced/search/contact` | 全局搜索联系人相关数据 |  |
| POST | `/advanced/search/lead` | 全局搜索线索相关数据 |  |
| POST | `/advanced/search/lead-pool` | 全局搜索-线索池 |  |
| POST | `/advanced/search/lead/detail` | 全局搜索线索详情 |  |
| POST | `/advanced/search/opportunity` | 全局搜索-商机 |  |
| POST | `/advanced/search/opportunity/detail` | 全局搜索商机详情 |  |
| POST | `/global/search/account` | 全局搜索-客户 |  |
| POST | `/global/search/clue_pool` | 全局搜索-线索池 |  |
| POST | `/global/search/contact` | 全局搜索-联系人 |  |
| POST | `/global/search/customer_pool` | 全局搜索-公海 |  |
| POST | `/global/search/lead` | 全局搜索-线索 |  |
| POST | `/global/search/module/count` | 全局搜索-模块数量统计 |  |
| POST | `/global/search/opportunity` | 全局搜索-商机 |  |
| GET | `/home/statistic/department/tree` | 用户部门权限树 |  |
| POST | `/home/statistic/lead` | 线索统计 |  |
| POST | `/home/statistic/opportunity` | 商机统计 |  |
| POST | `/home/statistic/opportunity/success` | 赢单统计 |  |
| POST | `/home/statistic/opportunity/underway` | 进行中商机统计 |  |

## 自定义表单 (Custom Form)（28 APIs）

| 方法 | 路径 | 说明 | 安全 |
|------|------|------|------|
| POST | `/custom-form/add` | 创建自定义表单 |  |
| GET | `/custom-form/admin/get/{customFormId}` | 查询表单管理员 |  |
| POST | `/custom-form/admin/set` | 设置表单管理员 |  |
| POST | `/custom-form/data/add` | 创建表单数据 |  |
| POST | `/custom-form/data/batch/delete` | 批量删除表单数据 | 🚫 禁止 |
| POST | `/custom-form/data/batch/update` | 批量更新表单数据 |  |
| GET | `/custom-form/data/delete/{id}` | 删除表单数据 | ⚠️ 需确认 |
| POST | `/custom-form/data/export-all` | 导出全部表单数据 |  |
| POST | `/custom-form/data/export-select` | 导出选中表单数据 |  |
| GET | `/custom-form/data/get/{id}` | 表单数据详情 |  |
| POST | `/custom-form/data/import` | 导入表单数据 |  |
| POST | `/custom-form/data/import/pre-check` | 导入预检查 |  |
| POST | `/custom-form/data/page` | 表单数据列表 |  |
| GET | `/custom-form/data/template/download` | 下载导入模板 |  |
| POST | `/custom-form/data/update` | 更新表单数据 |  |
| GET | `/custom-form/delete/{id}` | 删除自定义表单 | ⚠️ 需确认 |
| GET | `/custom-form/disable/{id}` | 禁用自定义表单 |  |
| GET | `/custom-form/enable/{id}` | 启用自定义表单 |  |
| GET | `/custom-form/get/{id}` | 自定义表单详情 |  |
| GET | `/custom-form/list` | 自定义表单列表 |  |
| GET | `/custom-form/option` | 自定义表单选项(开启的) |  |
| GET | `/custom-form/role/list/{customFormId}` | 获取表单角色列表 |  |
| POST | `/custom-form/role/user/add` | 角色添加用户 |  |
| GET | `/custom-form/role/user/dept/tree` | 获取部门用户树 |  |
| POST | `/custom-form/role/user/remove` | 角色移除用户 |  |
| GET | `/custom-form/role/user/role/tree` | 获取角色用户树 |  |
| POST | `/custom-form/role/users` | 获取角色用户列表 |  |
| POST | `/custom-form/update` | 更新自定义表单 |  |

## 角色权限 (Role)（14 APIs）

| 方法 | 路径 | 说明 | 安全 |
|------|------|------|------|
| POST | `/role/add` | 添加角色 |  |
| GET | `/role/delete/{id}` | 删除角色 | ⚠️ 需确认 |
| GET | `/role/dept/tree` | 获取部门树 |  |
| GET | `/role/get/{id}` | 角色详情 |  |
| GET | `/role/list` | 角色列表 |  |
| GET | `/role/permission/setting` | 获取权限配置 |  |
| POST | `/role/update` | 更新角色 |  |
| POST | `/role/user/batch/delete` | 角色批量移除用户 | 🚫 禁止 |
| GET | `/role/user/delete/{id}` | 角色移除用户 | ⚠️ 需确认 |
| GET | `/role/user/dept/tree/{roleId}` | 获取部门用户树 |  |
| GET | `/role/user/option/{roleId}` | 获取所有用户选项 |  |
| POST | `/role/user/page` | 查看拥有该权限的用户 |  |
| POST | `/role/user/relate` | 角色关联添加用户 |  |
| GET | `/role/user/role/tree/{roleId}` | 获取角色用户树 |  |

## 订单 (Order)（30 APIs）

| 方法 | 路径 | 说明 | 安全 |
|------|------|------|------|
| POST | `/order/add` | 创建 |  |
| POST | `/order/batch/update` | 批量更新订单 |  |
| GET | `/order/delete/{id}` | 删除 | ⚠️ 需确认 |
| GET | `/order/download/{id}` | 下载订单日志记录 |  |
| GET | `/order/get/snapshot/{id}` | 获取详情快照 |  |
| GET | `/order/get/{id}` | 详情 |  |
| GET | `/order/module/form` | 获取表单配置 |  |
| GET | `/order/module/form/snapshot/{id}` | 获取表单快照配置 |  |
| POST | `/order/page` | 列表 |  |
| POST | `/order/sort` | 订单看板拖拽排序 |  |
| POST | `/order/stage/add` | 添加订单状态流 |  |
| POST | `/order/stage/advanced/config` | 订单流转配置保存 |  |
| GET | `/order/stage/circulation-type/{type}` | 基础/高级流转切换 |  |
| GET | `/order/stage/delete/{id}` | 删除订单状态流 | ⚠️ 需确认 |
| GET | `/order/stage/get` | 订单状态配置列表 |  |
| POST | `/order/stage/sort` | 订单阶段排序 |  |
| POST | `/order/stage/update` | 更新订单阶段配置 |  |
| POST | `/order/stage/update-rollback` | 订单状态流回退设置 |  |
| POST | `/order/statistic` | 订单统计 |  |
| GET | `/order/tab` | tab是否显示 |  |
| POST | `/order/update` | 更新 |  |
| POST | `/order/update/stage` | 更新订单阶段 |  |
| POST | `/order/view/add` | 添加订单视图 |  |
| GET | `/order/view/delete/{id}` | 删除订单视图 | ⚠️ 需确认 |
| GET | `/order/view/detail/{id}` | 订单视图详情 |  |
| POST | `/order/view/edit/pos` | 视图-拖拽排序 |  |
| GET | `/order/view/enable/{id}` | 视图-启用/禁用 |  |
| GET | `/order/view/fixed/{id}` | 视图固定/取消固定 |  |
| GET | `/order/view/list` | 订单视图列表 |  |
| POST | `/order/view/update` | 编辑订单视图 |  |

## 跟进 (Follow)（31 APIs）

| 方法 | 路径 | 说明 | 安全 |
|------|------|------|------|
| POST | `/follow/plan/add` | 添加跟进计划 |  |
| GET | `/follow/plan/delete/{id}` | 删除跟进计划 | ⚠️ 需确认 |
| GET | `/follow/plan/get/{id}` | 跟进计划详情 |  |
| GET | `/follow/plan/module/form` | 获取表单配置 |  |
| POST | `/follow/plan/page` | 跟进记录列表 |  |
| POST | `/follow/plan/status/update` | 更新跟进计划状态 |  |
| GET | `/follow/plan/tab` | 数据权限TAB |  |
| POST | `/follow/plan/update` | 更新跟进计划 |  |
| POST | `/follow/plan/view/add` | 添加计划视图 |  |
| GET | `/follow/plan/view/delete/{id}` | 删除计划视图 | ⚠️ 需确认 |
| GET | `/follow/plan/view/detail/{id}` | 计划视图详情 |  |
| POST | `/follow/plan/view/edit/pos` | 计划视图-拖拽排序 |  |
| GET | `/follow/plan/view/enable/{id}` | 计划视图-启用/禁用 |  |
| GET | `/follow/plan/view/fixed/{id}` | 计划视图固定/取消固定 |  |
| GET | `/follow/plan/view/list` | 计划视图列表 |  |
| POST | `/follow/plan/view/update` | 编辑计划视图 |  |
| POST | `/follow/record/add` | 添加跟进记录 |  |
| GET | `/follow/record/delete/{id}` | 删除跟进记录 | ⚠️ 需确认 |
| GET | `/follow/record/get/{id}` | 跟进记录详情 |  |
| GET | `/follow/record/module/form` | 获取表单配置 |  |
| POST | `/follow/record/page` | 跟进记录列表 |  |
| GET | `/follow/record/tab` | 数据权限TAB |  |
| POST | `/follow/record/update` | 更新跟进记录 |  |
| POST | `/follow/record/view/add` | 添加记录视图 |  |
| GET | `/follow/record/view/delete/{id}` | 删除记录视图 | ⚠️ 需确认 |
| GET | `/follow/record/view/detail/{id}` | 记录视图详情 |  |
| POST | `/follow/record/view/edit/pos` | 记录视图-拖拽排序 |  |
| GET | `/follow/record/view/enable/{id}` | 记录视图-启用/禁用 |  |
| GET | `/follow/record/view/fixed/{id}` | 记录视图固定/取消固定 |  |
| GET | `/follow/record/view/list` | 记录视图列表 |  |
| POST | `/follow/record/view/update` | 编辑记录视图 |  |
