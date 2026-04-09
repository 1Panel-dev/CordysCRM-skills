#!/usr/bin/env python3
"""
CORDYS CRM CLI 工具
使用 X-Access-Key / X-Secret-Key 进行鉴权
"""

import os
import sys
import json
import argparse
from pathlib import Path
from typing import Optional, Dict, Any
from urllib import parse, request
from urllib.error import HTTPError, URLError

try:
    from dotenv import load_dotenv
except ImportError:
    # 如果没有 python-dotenv，提供简单的 .env 加载实现
    def load_dotenv(dotenv_path=None):
        if dotenv_path and os.path.exists(dotenv_path):
            with open(dotenv_path) as f:
                for line in f:
                    line = line.strip()
                    if line and not line.startswith('#') and '=' in line:
                        key, value = line.split('=', 1)
                        os.environ[key.strip()] = value.strip().strip(
                            '"').strip("'")


# ── 路径配置 ──────────────────────────────────────────────────────
SCRIPT_DIR = Path(__file__).resolve().parent
SKILL_DIR = SCRIPT_DIR.parent
ENV_FILE = SKILL_DIR / ".env"

# 加载环境变量
if ENV_FILE.exists():
    load_dotenv(ENV_FILE)

CORDYS_CRM_DOMAIN = os.environ.get(
    "CORDYS_CRM_DOMAIN", "https://www.cordys.cn")
CORDYS_ACCESS_KEY = os.environ.get("CORDYS_ACCESS_KEY", "")
CORDYS_SECRET_KEY = os.environ.get("CORDYS_SECRET_KEY", "")


# ── 辅助函数 ───────────────────────────────────────────────────────────
def die(message: str) -> None:
    """打印错误信息并退出"""
    print(f"错误: {message}", file=sys.stderr)
    sys.exit(1)


def info(message: str) -> None:
    """打印信息"""
    print(f":: {message}", file=sys.stderr)


def check_keys() -> None:
    """检查必需的 API 密钥"""
    if not CORDYS_ACCESS_KEY:
        die("未设置 CORDYS_ACCESS_KEY")
    if not CORDYS_SECRET_KEY:
        die("未设置 CORDYS_SECRET_KEY")


def page_payload(keyword: str = "") -> Dict[str, Any]:
    """生成分页请求的标准 payload"""
    return {
        "current": 1,
        "pageSize": 30,
        "sort": {},
        "combineSearch": {
            "searchMode": "AND",
            "conditions": []
        },
        "keyword": keyword,
        "viewId": "ALL",
        "filters": []
    }


# ── API 封装（Header Key 鉴权）────────────────────────────────────────
def api_request(method: str, url: str, content_type: str, **kwargs) -> str:
    """执行 API 请求"""
    check_keys()

    headers = {
        "X-Access-Key": CORDYS_ACCESS_KEY,
        "X-Secret-Key": CORDYS_SECRET_KEY,
        "Content-Type": content_type
    }

    # 合并用户提供的 headers（如果有）
    if 'headers' in kwargs:
        headers.update(kwargs.pop('headers'))

    params = kwargs.pop("params", None)
    data = kwargs.pop("data", None)

    if params:
        if isinstance(params, dict):
            query = parse.urlencode(params)
        else:
            query = str(params).lstrip("?")
        separator = "&" if "?" in url else "?"
        url = f"{url}{separator}{query}"

    data_bytes = None
    if data is not None:
        if isinstance(data, bytes):
            data_bytes = data
        elif isinstance(data, dict):
            data_bytes = parse.urlencode(data).encode("utf-8")
        else:
            data_bytes = str(data).encode("utf-8")

    try:
        req = request.Request(
            url=url,
            data=data_bytes,
            headers=headers,
            method=method.upper()
        )
        with request.urlopen(req) as response:
            charset = response.headers.get_content_charset() or "utf-8"
            return response.read().decode(charset, errors="replace")
    except HTTPError as e:
        try:
            detail = e.read().decode("utf-8", errors="replace")
        except Exception:
            detail = str(e)
        die(f"请求失败: HTTP {e.code} {detail}")
    except URLError as e:
        die(f"请求失败: {e}")


def api(method: str, url: str, **kwargs) -> str:
    """执行 JSON API 请求"""
    return api_request(method, url, "application/json", **kwargs)


def api_form(method: str, url: str, **kwargs) -> str:
    """执行表单 API 请求"""
    return api_request(
        method, url, "application/x-www-form-urlencoded", **kwargs)


# ── CRM 辅助函数 ──────────────────────────────────────────────────────
def crm_list(module: str, opts: str = "") -> str:
    """列出视图记录"""
    params = opts if opts else None
    return api("GET", f"{CORDYS_CRM_DOMAIN}/{module}/view/list", params=params)


def crm_get(module: str, id: str) -> str:
    """获取单条记录详情"""
    return api("GET", f"{CORDYS_CRM_DOMAIN}/{module}/{id}")


def crm_contact(module: str, id: str) -> str:
    """获取联系人列表"""
    return api("GET", f"{CORDYS_CRM_DOMAIN}/{module}/contact/list/{id}")


def crm_page(module: str, payload_or_keyword: str = "") -> str:
    """列表分页记录"""
    # 判断是否为 JSON
    if payload_or_keyword.startswith("{"):
        body = payload_or_keyword
    else:
        body = json.dumps(page_payload(payload_or_keyword), ensure_ascii=False)

    path = f"{module}/page"
    return api("POST", f"{CORDYS_CRM_DOMAIN}/{path}", data=body)


def crm_search(module: str, json_data: str = "") -> str:
    """全局搜索记录"""
    path = f"global/search/{module}"
    return api("POST", f"{CORDYS_CRM_DOMAIN}/{path}", data=json_data)


def crm_follow_page(kind: str, module: str, payload: str = "") -> str:
    """查询跟进计划或跟进记录"""
    if kind not in ["plan", "record"]:
        die("follow 子命令只支持 plan/record")
    if not module:
        die(f"follow {kind} 需要指定模块（lead/account 等）")

    # 判断是否为 JSON
    if payload.startswith("{"):
        body = payload
    else:
        body = json.dumps(page_payload(payload), ensure_ascii=False)

    return api("POST", f"{CORDYS_CRM_DOMAIN}/{module}/follow/{kind}/page", data=body)


def crm_product(keyword: str = "") -> str:
    """查询产品"""
    if keyword.startswith("{"):
        body = keyword
    else:
        body = json.dumps(page_payload(keyword), ensure_ascii=False)

    return api("POST", f"{CORDYS_CRM_DOMAIN}/field/source/product", data=body)


def crm_org() -> str:
    """获取组织架构"""
    return api("GET", f"{CORDYS_CRM_DOMAIN}/department/tree")


def crm_members(json_data: str) -> str:
    """根据部门ID获取成员"""
    return api("POST", f"{CORDYS_CRM_DOMAIN}/user/list", data=json_data)


# ── 原始 API 调用 ─────────────────────────────────────────────────────
def raw_api(method: str, path: str, *args) -> str:
    """执行原始 API 调用"""
    if path.startswith("http"):
        url = path
    else:
        url = f"{CORDYS_CRM_DOMAIN}{path}"

    # 这里简化处理，如果需要更多参数可以扩展
    return api(method, url)


# ── CLI 处理 ──────────────────────────────────────────────────────────
def print_usage():
    """打印使用帮助"""
    usage_text = """
cordys — CORDYS CRM CLI 工具（X-Access-Key 模式）

使用方法:
  cordys.py <命令> [参数...]

CRM 操作:
  crm view <模块> [参数]             列出视图记录（例：account/lead/opportunity）
  crm get <模块> <ID>               获取单条记录详情
  crm search <模块> [关键词|JSON]    全局搜索记录
  crm page <模块> [关键词|JSON]      列表分页记录 /<module>/page （例：account/lead/opportunity）
  crm org                          获取组织架构树
  crm members <部门IDs>             获取部门成员列表
  crm follow <plan|record> <模块> [关键词|JSON]  查询跟进计划或跟进记录
  crm product [关键词|JSON]      查询产品列表
  crm contact <模块> <ID>             获取联系人列表

示例:
  cordys.py crm view lead
  cordys.py crm page lead '{"current":1,"pageSize":30,"sort":{},"combineSearch":{"searchMode":"AND","conditions":[]},"keyword":"","viewId":"ALL","filters":[]}'
  cordys.py crm page lead "测试"
  cordys.py crm page contract/payment-plan '{"current":1,"pageSize":30,"sort":{},"combineSearch":{"searchMode":"AND","conditions":[]},"keyword":"","viewId":"ALL","filters":[]}'
  cordys.py crm search account '{"current":1,"pageSize":50,"combineSearch":{"searchMode":"AND","conditions":[]},"keyword":"xyz","viewId":"ALL","filters":[]}'
  cordys.py crm org
  cordys.py crm members '{"current":1,"pageSize":50,"combineSearch":{"searchMode":"AND","conditions":[]},"keyword":"","departmentIds":["deptId1","deptId2"],"filters":[]}'
  cordys.py crm follow plan lead '{"sourceId":"927627065163785","current":1,"pageSize":10,"keyword":"","status":"ALL","myPlan":false}'
  cordys.py crm follow record account '{"sourceId":"1751888184018919","current":1,"pageSize":10,"keyword":"","myPlan":false}'
  cordys.py crm product "测试"
  cordys.py crm contact account '927627065163785'

原始 API:
  raw <方法> <路径> [curl参数...]
  cordys.py raw GET /settings/fields?module=account

环境变量要求:
  CORDYS_ACCESS_KEY
  CORDYS_SECRET_KEY
  CORDYS_CRM_DOMAIN

支持的 CRM 一级模块列表查询 cordys.py crm page lead:
  lead（线索）, opportunity（商机）, account（客户）,contact（联系人）,contract（合同）

支持的 CRM 二级模块列表查询 cordys.py crm page contract/payment-plan:
  contract/payment-plan(回款计划), invoice（发票）,contract/business-title(工商抬头）,contract/payment-record(回款记录), opportunity/quotation(报价单)
"""
    print(usage_text)


def handle_crm_command(args: list) -> None:
    """处理 CRM 命令"""
    if not args:
        die("crm 需要子命令")

    sub_cmd = args[0]
    rest_args = args[1:]

    if sub_cmd == "view":
        if not rest_args:
            die("view 需要指定模块")
        module = rest_args[0]
        opts = rest_args[1] if len(rest_args) > 1 else ""
        print(crm_list(module, opts))

    elif sub_cmd == "get":
        if len(rest_args) < 2:
            die("get 需要 <模块> <ID>")
        print(crm_get(rest_args[0], rest_args[1]))

    elif sub_cmd == "search":
        if not rest_args:
            die("search 需要指定模块")
        module = rest_args[0]
        json_data = rest_args[1] if len(rest_args) > 1 else ""
        print(crm_search(module, json_data))

    elif sub_cmd == "page":
        if not rest_args:
            die("page 需要指定模块")
        module = rest_args[0]
        payload = rest_args[1] if len(rest_args) > 1 else ""
        print(crm_page(module, payload))

    elif sub_cmd == "org":
        print(crm_org())

    elif sub_cmd == "product":
        keyword = rest_args[0] if rest_args else ""
        print(crm_product(keyword))

    elif sub_cmd == "members":
        if not rest_args:
            die("members 需要部门ID JSON")
        print(crm_members(rest_args[0]))

    elif sub_cmd == "contact":
        if len(rest_args) < 2:
            die("contact 需要 <模块> <ID>")
        print(crm_contact(rest_args[0], rest_args[1]))

    elif sub_cmd == "follow":
        if not rest_args:
            die("follow 需要 plan 或 record")
        kind = rest_args[0]
        if kind not in ["plan", "record"]:
            die("follow 只支持 plan 或 record")
        if len(rest_args) < 2:
            die(f"follow {kind} 需要指定模块")
        module = rest_args[1]
        payload = rest_args[2] if len(rest_args) > 2 else ""
        print(crm_follow_page(kind, module, payload))

    else:
        die(f"未知的 crm 子命令: {sub_cmd}")


def handle_raw_command(args: list) -> None:
    """处理原始 API 命令"""
    if len(args) < 2:
        die("raw 需要 HTTP 方法和路径")

    method = args[0]
    path = args[1]
    print(raw_api(method, path))


def main():
    """主函数"""
    if len(sys.argv) < 2:
        print_usage()
        sys.exit(1)

    cmd = sys.argv[1]
    args = sys.argv[2:]

    if cmd == "crm":
        handle_crm_command(args)
    elif cmd == "raw":
        handle_raw_command(args)
    elif cmd in ["help", "-h", "--help"]:
        print_usage()
    else:
        die(f"未知命令: {cmd}（尝试 cordys.py help）")


if __name__ == "__main__":
    main()
