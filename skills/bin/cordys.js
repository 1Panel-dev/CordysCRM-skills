#!/usr/bin/env node

# CORDYS CRM CLI 工具
# 使用 X-Access-Key / X-Secret-Key 进行鉴权

const http = require('http');
const https = require('https');
const fs = require('fs');
const path = require('path');
const url = require('url');
const { promisify } = require('util');

// ── 常量定义 ───────────────────────────────────────────────────────

const ENV_FILE = '.env';
const DEFAULT_DOMAIN = 'https://www.cordys.cn';

// ── 全局变量 ───────────────────────────────────────────────────────

let config = {
  domain: DEFAULT_DOMAIN,
  accessKey: '',
  secretKey: ''
};

// ── 辅助函数 ───────────────────────────────────────────────────────────

function die(message) {
  console.error(`错误: ${message}`);
  process.exit(1);
}

function info(message) {
  console.error(`:: ${message}`);
}

// 简单的 .env 文件加载
function loadEnvFile(envPath) {
  if (!fs.existsSync(envPath)) return;

  const content = fs.readFileSync(envPath, 'utf-8');
  const lines = content.split('\n');

  for (const line of lines) {
    const trimmed = line.trim();
    if (!trimmed || trimmed.startsWith('#')) continue;

    const idx = trimmed.indexOf('=');
    if (idx === -1) continue;

    const key = trimmed.substring(0, idx).trim();
    let value = trimmed.substring(idx + 1).trim();
    // 去除引号
    if ((value.startsWith('"') && value.endsWith('"')) ||
        (value.startsWith("'") && value.endsWith("'"))) {
      value = value.slice(1, -1);
    }
    process.env[key] = value;
  }
}

function loadEnv() {
  // 尝试当前目录
  if (fs.existsSync(ENV_FILE)) {
    loadEnvFile(ENV_FILE);
  }
  // 尝试脚本所在目录
  const scriptDir = path.dirname(process.execPath);
  if (fs.existsSync(path.join(scriptDir, ENV_FILE))) {
    loadEnvFile(path.join(scriptDir, ENV_FILE));
  }
}

function initEnv() {
  loadEnv();

  config.domain = process.env.CORDYS_CRM_DOMAIN || DEFAULT_DOMAIN;
  config.accessKey = process.env.CORDYS_ACCESS_KEY || '';
  config.secretKey = process.env.CORDYS_SECRET_KEY || '';

  if (!config.accessKey) die('未设置 CORDYS_ACCESS_KEY');
  if (!config.secretKey) die('未设置 CORDYS_SECRET_KEY');
}

function pagePayload(keyword = '') {
  return {
    current: 1,
    pageSize: 30,
    sort: {},
    combineSearch: { searchMode: 'AND', conditions: [] },
    keyword: keyword,
    viewId: 'ALL',
    filters: []
  };
}

// ── API 请求 ─────────────────────────────────────────────────────────

class APIError extends Error {
  constructor(statusCode, message) {
    super(message);
    this.statusCode = statusCode;
    this.name = 'APIError';
  }
}

function apiRequest(method, rawUrl, contentType, params, body) {
  return new Promise((resolve, reject) => {
    if (!config.accessKey || !config.secretKey) {
      die('未设置 CORDYS_ACCESS_KEY 或 CORDYS_SECRET_KEY');
    }

    // 构建完整 URL
    let fullUrl = rawUrl;
    if (!rawUrl.startsWith('http://') && !rawUrl.startsWith('https://')) {
      fullUrl = config.domain + rawUrl;
    }

    const parsedUrl = new URL(fullUrl);
    if (params) {
      Object.keys(params).forEach(key => parsedUrl.searchParams.set(key, params[key]));
    }

    const options = {
      hostname: parsedUrl.hostname,
      port: parsedUrl.port || (parsedUrl.protocol === 'https:' ? 443 : 80),
      path: parsedUrl.pathname + parsedUrl.search,
      method: method.toUpperCase(),
      headers: {
        'X-Access-Key': config.accessKey,
        'X-Secret-Key': config.secretKey,
        'Content-Type': contentType
      }
    };

    const client = parsedUrl.protocol === 'https:' ? https : http;

    const req = client.request(options, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        if (res.statusCode >= 400) {
          reject(new APIError(res.statusCode, data));
        } else {
          resolve(data);
        }
      });
    });

    req.on('error', reject);

    if (body) {
      const bodyStr = typeof body === 'string' ? body : JSON.stringify(body);
      req.write(bodyStr);
    }

    req.end();
  });
}

function api(method, rawUrl, params, body) {
  let bodyData = body;
  if (body && typeof body === 'object') {
    bodyData = JSON.stringify(body);
  }
  return apiRequest(method, rawUrl, 'application/json', params, bodyData);
}

// ── CRM 功能函数 ─────────────────────────────────────────────────────

async function crmList(module, opts = '') {
  const params = opts ? { opts } : {};
  return api('GET', `/${module}/view/list`, params, null);
}

async function crmGet(module, id) {
  return api('GET', `/${module}/${id}`, null, null);
}

async function crmContact(module, id) {
  return api('GET', `/${module}/contact/list/${id}`, null, null);
}

async function crmPage(module, payloadOrKeyword) {
  let body;
  if (payloadOrKeyword && payloadOrKeyword.startsWith('{')) {
    body = payloadOrKeyword;
  } else {
    body = pagePayload(payloadOrKeyword);
  }
  return api('POST', `/${module}/page`, null, body);
}

async function crmSearch(module, jsonData) {
  const body = (jsonData && jsonData.startsWith('{')) ? jsonData : pagePayload('');
  return api('POST', `/global/search/${module}`, null, body);
}

async function crmFollowPage(kind, module, payload) {
  if (kind !== 'plan' && kind !== 'record') {
    die('follow 只支持 plan/record');
  }
  const body = (payload && payload.startsWith('{')) ? payload : pagePayload('');
  return api('POST', `/${module}/follow/${kind}/page`, null, body);
}

async function crmProduct(keyword) {
  let body;
  if (keyword && keyword.startsWith('{')) {
    body = keyword;
  } else if (keyword) {
    body = pagePayload(keyword);
  } else {
    body = pagePayload('');
  }
  return api('POST', '/field/source/product', null, body);
}

async function crmOrg() {
  return api('GET', '/department/tree', null, null);
}

async function crmMembers(jsonData) {
  const body = (jsonData && jsonData.startsWith('{'))
    ? JSON.parse(jsonData)
    : {
        current: 1,
        pageSize: 30,
        combineSearch: { searchMode: 'AND', conditions: [] },
        keyword: '',
        departmentIds: [],
        filters: []
      };
  return api('POST', '/user/list', null, body);
}

async function rawAPI(method, path, extraArgs = []) {
  const params = {};
  for (let i = 0; i < extraArgs.length; i++) {
    const arg = extraArgs[i];
    if (arg.startsWith('-')) {
      if (i + 1 < extraArgs.length && !extraArgs[i + 1].startsWith('-')) {
        const key = arg.replace(/^-+/, '');
        params[key === 'X' ? 'X-Custom' : key] = extraArgs[i + 1];
        i++;
      }
    } else if (arg.includes('=')) {
      const [key, value] = arg.split('=');
      params[key] = value;
    }
  }
  return api(method.toUpperCase(), path, params, null);
}

// ── 命令处理 ─────────────────────────────────────────────────────────

async function handleCrmCommand(args) {
  if (args.length < 1) die('crm 需要子命令');

  const subCmd = args[0];
  const restArgs = args.slice(1);

  let result;
  let err;

  switch (subCmd) {
    case 'view':
      if (restArgs.length < 1) die('view 需要指定模块');
      const opts = restArgs[1] || '';
      result = await crmList(restArgs[0], opts);
      break;

    case 'get':
      if (restArgs.length < 2) die('get 需要 <模块> <ID>');
      result = await crmGet(restArgs[0], restArgs[1]);
      break;

    case 'search':
      if (restArgs.length < 1) die('search 需要指定模块');
      const searchJson = restArgs[1] || '';
      result = await crmSearch(restArgs[0], searchJson);
      break;

    case 'page':
      if (restArgs.length < 1) die('page 需要指定模块');
      const payload = restArgs[1] || '';
      result = await crmPage(restArgs[0], payload);
      break;

    case 'org':
      result = await crmOrg();
      break;

    case 'product':
      const keyword = restArgs[0] || '';
      result = await crmProduct(keyword);
      break;

    case 'members':
      if (restArgs.length < 1) die('members 需要部门ID JSON');
      result = await crmMembers(restArgs[0]);
      break;

    case 'contact':
      if (restArgs.length < 2) die('contact 需要 <模块> <ID>');
      result = await crmContact(restArgs[0], restArgs[1]);
      break;

    case 'follow':
      if (restArgs.length < 2) die('follow 需要 <plan|record> <模块>');
      const kind = restArgs[0];
      const mod = restArgs[1];
      const followPayload = restArgs[2] || '';
      result = await crmFollowPage(kind, mod, followPayload);
      break;

    default:
      die(`未知的 crm 子命令: ${subCmd}`);
  }

  console.log(result);
}

async function handleRawCommand(args) {
  if (args.length < 2) die('raw 需要 <方法> <路径>');
  const result = await rawAPI(args[0], args[1], args.slice(2));
  console.log(result);
}

function printUsage() {
  const usage = `CORDYS CRM CLI 工具
使用 X-Access-Key / X-Secret-Key 进行鉴权

用法:
  cordys crm <子命令> [参数...]
  cordys raw <方法> <路径> [curl参数...]

子命令:
  crm view <模块> [opts]         列出视图记录
  crm get <模块> <ID>            获取单条记录详情
  crm page <模块> [关键词|JSON]   列表分页记录
  crm search <模块> [JSON]        全局搜索记录
  crm org                        获取组织架构
  crm members <部门JSON>         获取部门成员列表
  crm follow <plan|record> <模块> [关键词|JSON]  查询跟进计划或记录
  crm product [关键词|JSON]       查询产品列表
  crm contact <模块> <ID>        获取联系人列表

支持的 CRM 一级模块:
  lead（线索）, opportunity（商机）, account（客户）, contact（联系人）, contract（合同）

示例:
  cordys crm view lead
  cordys crm page lead "测试"
  cordys crm page lead '{"current":1,"pageSize":30,"keyword":"","viewId":"ALL","filters":[]}'
  cordys crm search account '{"keyword":"测试"}'
  cordys crm org
  cordys crm members '{"departmentIds":["xxx"]}'
  cordys crm follow plan lead '{"sourceId":"xxx"}'
  cordys crm product "测试"
  cordys crm contact account 'xxx'

支持的 CRM 二级模块:
  contract/payment-plan, invoice, contract/business-title, contract/payment-record, opportunity/quotation

原始 API:
  cordys raw GET /settings/fields?module=account

环境变量要求:
  CORDYS_ACCESS_KEY
  CORDYS_SECRET_KEY
  CORDYS_CRM_DOMAIN
`;
  console.log(usage);
}

// ── 主函数 ─────────────────────────────────────────────────────────

async function main() {
  const args = process.argv.slice(2);

  if (args.length === 0) {
    printUsage();
    process.exit(0);
  }

  initEnv();

  const command = args[0];
  const commandArgs = args.slice(1);

  try {
    switch (command) {
      case 'crm':
        await handleCrmCommand(commandArgs);
        break;
      case 'raw':
        await handleRawCommand(commandArgs);
        break;
      default:
        die(`未知的命令: ${command}`);
    }
  } catch (e) {
    if (e instanceof APIError) {
      die(`请求失败: HTTP ${e.statusCode} ${e.message}`);
    } else {
      die(e.message);
    }
  }
}

main();
