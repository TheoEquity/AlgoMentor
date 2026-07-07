# AlgoMentor

AlgoMentor 是一个面向算法刷题、笔试训练和错误复盘的全栈练习平台。项目提供题库管理、在线做题、提交记录、失败归因、训练中心、复盘中心、系统配置以及题目解析导入能力，适合用于沉淀公司笔试题、维护结构化题库并辅助训练。

## 功能概览

- 题库管理：按公司、题型、难度、来源维护题目，支持题目详情、测试用例和语言模板。
- 新增题目：支持粘贴原题文本并规则解析为结构化题目 Markdown，支持 SSPoffer 离线文件批量导入。
- 在线做题：前端集成 Monaco Editor，支持 Python、C++、Java 模板。
- 提交与判题：对接 Judge0，保存运行结果、错误输出和失败用例。
- AI 辅助：失败归因、题目解析、分步提示、代码评审、AI 生题等 Agent 体系。
- AI 生题：基于已有题目自动生成同类型派生题，追踪派生关系，一键入库。
- 训练复盘：按错误类型、题目、公司等维度整理训练数据。
- 总览 Dashboard：题库全局分布（来源/难度/年度/题型/公司），图表可视化。
- 数学公式渲染：题目 Markdown 支持 KaTeX 公式显示。
- 数据种子：仓库包含 1121 道题目的完整种子数据。

| `problems_export.sql` | 全部 1121 道题目及测试用例 | 核心题库资产，可独立导入 |

# 导出全部 1121 道题目及测试用例
PGPASSWORD=bytehunter123 psql -h localhost -U bytehunter -d bytehunter -f backend/src/data/problems_export.sql
```

如果已通过环境变量配置了数据库连接，可直接使用：

```bash
psql "$BYTEHUNTER_DATABASE_URL" -f backend/src/data/database_seed.sql
psql "$BYTEHUNTER_DATABASE_URL" -f backend/src/data/problems_export.sql
```

### 5. 重新启动后端

```bash
cd backend
source .venv/bin/activate
cd src
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

健康检查：

```bash
curl http://localhost:8000/healthz
```

API 前缀为：

```text
/api/v1
```

### 6. 启动前端

```bash
cd frontend
npm install
npm run dev -- --host 0.0.0.0 --port 5173
```

访问：

```text
http://localhost:5173
```

### 7. 配置 AI 能力

进入前端系统设置页面，填写 LLM Provider、Endpoint、模型名和 API Key。仓库中的种子数据不包含 LLM 配置和密钥。

## 常用开发命令

### 后端测试

```bash
cd backend
python3 -m unittest discover -s tests -v
```

### 前端构建

```bash
cd frontend
npm run build
```

### 前端 lint

```bash
cd frontend
npm run lint
```

## 数据与安全说明

- `.env`、本地密钥和私钥文件已通过 `.gitignore` 排除。
- `database_seed.sql` 不包含 `llm_settings` 表数据。
- LLM API Key 应只通过运行环境或系统设置页面配置。
- 对外发布前建议检查数据库种子中是否包含个人提交代码、判题 token 或业务敏感样例。
