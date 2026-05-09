#!/usr/bin/env bash
# CORDYS CRM CLI 工具
# 使用 X-Access-Key / X-Secret-Key 进行鉴权
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"
ENV_FILE="${SKILL_DIR}/.env"

# ── 加载环境变量 ──────────────────────────────────────────────────────
if [[ -f "$ENV_FILE" ]]; then
  set -a
  source "$ENV_FILE"
  set +a
fi

CORDYS_CRM_DOMAIN="${CORDYS_CRM_DOMAIN:-https://www.cordys.cn}"

# ── 辅助函数 ───────────────────────────────────────────────────────────
die()  { echo "错误: $*" >&2; exit 1; }
info() { echo ":: $*" >&2; }
warn() { echo "⚠️  警告: $*" >&2; }

check_keys() {
  [[ -n "${CORDYS_ACCESS_KEY:-}" ]] || die "未设置 CORDYS_ACCESS_KEY"
  [[ -n "${CORDYS_SECRET_KEY:-}" ]] || die "未设置 CORDYS_SECRET_KEY"
}

# 验证URL是否指向可信的Cordys CRM域名
validate_url() {
  local url="$1"
  
  # 提取域名部分
  local domain
  if [[ "$url" =~ ^https?://([^/]+) ]]; then
    domain="${BASH_REMATCH[1]}"
  else
    return 0  # 不是完整URL，可能是相对路径
  fi
  
  # 从配置的CORDYS_CRM_DOMAIN中提取可信域名
  local trusted_domain
  if [[ "$CORDYS_CRM_DOMAIN" =~ ^https?://([^/]+) ]]; then
    trusted_domain="${BASH_REMATCH[1]}"
  else
    trusted_domain="$CORDYS_CRM_DOMAIN"
  fi
  
  # 检查域名是否匹配（支持子域名）
  if [[ "$domain" != "$trusted_domain" ]] && [[ "$domain" != *".$trusted_domain" ]]; then
    warn "目标域名 '$domain' 与配置的Cordys CRM域名 '$trusted_domain' 不匹配"
    warn "这可能会泄露您的API凭证！"
    return 1
  fi
  
  return 0
}

page_payload() {
  local keyword="${1:-}"
  python3 - "$keyword" <<PY
import json, sys
keyword = sys.argv[1] if len(sys.argv) > 1 else ""
payload = {
  "current": 1,
  "pageSize": 30,
  "sort": {},
  "combineSearch": {"searchMode": "AND", "conditions": []},
  "keyword": keyword,
  "viewId": "ALL",
  "filters": []
}
print(json.dumps(payload, ensure_ascii=False))
PY
}

# ── API 封装（Header Key 鉴权）────────────────────────────────────────
api_request() {
  local method="$1" url="$2" content_type="$3"
  shift 3

  check_keys

  # 通过 `"$@"` 保证额外的参数能够传递给 curl
  curl -s -X "$method" "$url" \
    -H "X-Access-Key: ${CORDYS_ACCESS_KEY}" \
    -H "X-Secret-Key: ${CORDYS_SECRET_KEY}" \
    -H "Content-Type: $content_type" \
    "$@"  # 传递剩余的所有参数
}

api() {
  api_request "$1" "$2" "application/json" "${@:3}"  # 传递 method, url 和其余的参数
}

api_form() {
  api_request "$1" "$2" "application/x-www-form-urlencoded" "${@:3}"  # 同样地，传递其余的参数
}

# ── CRM 辅助函数 ──────────────────────────────────────────────────────
crm_base="${CORDYS_CRM_DOMAIN}"

crm_list() {
  local module="$1" opts="${2:-}"
  api GET "${crm_base}/${module}/view/list" $opts
}

crm_get() {
  local module="$1" id="$2"
  api GET "${crm_base}/${module}/${id}"
}

crm_contact() {
  local module="$1" id="$2"
  api GET "${crm_base}/${module}/contact/list/${id}"
}

crm_page() {
  local module="$1"
  shift
  local first="${1:-}"
  local body
  if [[ "$first" == \{* ]]; then
    body="$first"
  else
    body=$(page_payload "${first:-}")
  fi
  local path="${module}/page"
  api POST "${CORDYS_CRM_DOMAIN}/${path}" -d "$body"
}

crm_search() {
  local module="$1" json="${2:-}"
  local path="global/search/${module}"
  api POST "${CORDYS_CRM_DOMAIN}/${path}" -d "$json"
}

crm_follow_page() {
  local kind="$1" module="$2" payload="${3:-}"

  [[ "${kind}" == "plan" || "${kind}" == "record" ]] || die "follow 子命令只支持 plan/record"
  [[ -n "${module}" ]] || die "follow ${kind} 需要指定模块（lead/account 等）"

  local body
  if [[ "${payload}" == \{* ]]; then
    body="${payload}"
  else
    body=$(page_payload "${payload}")
  fi

  api POST "${crm_base}/${module}/follow/${kind}/page" -d "$body"
}

# 查询产品
crm_product() {
  local keyword="${1:-}"
  local body
  if [[ "$keyword" == \{* ]]; then
    body="$keyword"
  else
    body=$(page_payload "${keyword}")
  fi
  api POST "${CORDYS_CRM_DOMAIN}/field/source/product" -d "$body"
}

# 获取当前用户信息
crm_whoami() {
  api GET "${crm_base}/personal/center/info"
}

# 验证 API 密钥状态
crm_verify() {
  local result
  result=$(crm_whoami 2>&1) || {
    echo "{\"status\":\"error\",\"message\":\"API密钥验证失败\",\"detail\":\"$result\"}"
    return 1
  }
  echo "$result"
}

# 获取组织架构
crm_org() {
  api GET "${crm_base}/department/tree"
}

# 根据部门ID获取成员
crm_members() {
  api POST "${crm_base}/user/list" -d "$1"
}

# ── 原始 API 调用 ─────────────────────────────────────────────────────
raw_api() {
  local method="$1" path="$2"
  shift 2

  if [[ "$path" == http* ]]; then
    # 验证URL域名
    if ! validate_url "$path"; then
      echo "❌ 拒绝请求：目标域名与配置的Cordys CRM域名不匹配" >&2
      echo "   配置的域名: $CORDYS_CRM_DOMAIN" >&2
      echo "   如需强制发送，请设置环境变量 CORDYS_ALLOW_UNTRUSTED=1" >&2
      
      if [[ "${CORDYS_ALLOW_UNTRUSTED:-0}" != "1" ]]; then
        exit 1
      else
        warn "已启用不受信任域名模式，继续发送请求..."
      fi
    fi
    
    api "$method" "$path" "$@"
  else
    api "$method" "${CORDYS_CRM_DOMAIN}${path}" "$@"
  fi
}

# ── CLI 分发 ──────────────────────────────────────────────────────────
usage() {
  cat <<'EOF'
cordys — CORDYS CRM CLI 工具（X-Access-Key 模式）

使用方法:
  cordys <命令> [参数...]

CRM 操作:
  crm view <模块> [参数]             列出视图记录（例：account/lead/opportunity）
  crm get <模块> <ID>               获取单条记录详情
  crm search <模块> [关键词|JSON]    全局搜索记录
  crm page <模块> [关键词|JSON]      列表分页记录 /<module>/page （例：account/lead/opportunity）
  crm whoami                       获取当前登录用户信息
  crm verify                       验证 API 密钥是否有效
  crm org                          获取组织架构树
  crm members <部门IDs>             获取部门成员列表
  crm follow <plan|record> <模块> [关键词|JSON]  查询跟进计划或跟进记录
  crm product [关键词|JSON]          查询产品列表
  crm contact <模块> <ID>           获取联系人列表

支持的 CRM 一级模块:
 [lead（线索）, opportunity（商机）, account（客户）,contact（联系人）,contract（合同）]

列表查询示例:
  cordys crm view lead
  cordys crm page lead
  cordys crm page lead "测试"
  cordys crm page lead '{"current":1,"pageSize":30,"sort":{},"combineSearch":{"searchMode":"AND","conditions":[]},"keyword":"","viewId":"ALL","filters":[]}'
  cordys crm page contract/payment-plan '{"current":1,"pageSize":30,"sort":{},"combineSearch":{"searchMode":"AND","conditions":[]},"keyword":"","viewId":"ALL","filters":[]}'
  cordys crm search account '{"current":1,"pageSize":30,"combineSearch":{"searchMode":"AND","conditions":[]},"keyword":"xyz","viewId":"ALL","filters":[]}'
  cordys crm org
  cordys crm members '{"current":1,"pageSize":30,"combineSearch":{"searchMode":"AND","conditions":[]},"keyword":"","departmentIds":["deptId1","deptId2"],"filters":[]}'
  cordys crm follow plan lead '{"sourceId":"927627065163785","current":1,"pageSize":10,"keyword":"","status":"ALL","myPlan":false}'
  cordys crm follow record account '{"sourceId":"1751888184018919","current":1,"pageSize":10,"keyword":"","myPlan":false}'
  cordys crm product "测试"
  cordys crm contact account '927627065163785'

支持的 CRM 二级模块 :
  [contract/payment-plan(回款计划), invoice（发票）,contract/business-title(工商抬头）,contract/payment-record(回款记录), opportunity/quotation(报价单)]

列表查询示例：
  cordys crm page contract/payment-plan
  cordys crm page contract/business-title

原始 API:
  raw <方法> <路径> [curl参数...]
  cordys raw GET /settings/fields?module=account

环境变量要求:
  CORDYS_ACCESS_KEY
  CORDYS_SECRET_KEY
  CORDYS_CRM_DOMAIN

EOF
}

cmd="${1:-}"
shift || true

case "$cmd" in
  crm)
    sub="${1:-}"; shift || die "crm 需要子命令"
    case "$sub" in
      view)    crm_list "$@" ;;
      get)     crm_get "$@" ;;
      search)  crm_search "$@" ;;
      page)    crm_page "$@" ;;
      whoami)  crm_whoami ;;
      verify)  crm_verify ;;
      org)     crm_org ;;
      product)  crm_product "$@" ;;
      members) crm_members "$@" ;;
      contact) crm_contact "$@" ;;
      follow)
        kind="${1:-}"; shift || die "follow 需要 plan 或 record"
        case "${kind}" in
          plan|record) crm_follow_page "${kind}" "$@" ;;
          *) die "follow 只支持 plan 或 record" ;;
        esac
        ;;
      *)       die "未知的 crm 子命令: $sub" ;;
    esac
    ;;
  raw)
    method="${1:-}"; shift || die "raw 需要 HTTP 方法"
    path="${1:-}"; shift || die "raw 需要路径"
    raw_api "$method" "$path" "$@"
    ;;
  help|-h|--help)
    usage
    ;;
  *)
    die "未知命令: $cmd（尝试 cordys help）"
    ;;
esac