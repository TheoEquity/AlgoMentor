# AlgoMentor

AlgoMentor 是一个面向算法刷题、笔试训练和错误复盘的全栈练习平台。项目提供题库管理、在线做题、提交记录、失败归因、训练中心、复盘中心、系统配置以及题目解析导入能力，适合用于沉淀公司笔试题、维护结构化题库并辅助训练。

## 功能概览

- 题库管理：按公司、题型、难度维护题目，支持题目详情、测试用例和语言模板。
- 新增题目：支持粘贴原题文本并规则解析为结构化题目 Markdown。
- 在线做题：前端集成 Monaco Editor，支持 Python、C++、Java 模板。
- 提交与判题：对接 Judge0，保存运行结果、错误输出和失败用例。
- AI 辅助：支持失败归因、题目解析、分步提示、代码评审等能力。
- 训练复盘：按错误类型、题目、公司等维度整理训练数据。
- 数学公式渲染：题目 Markdown 支持 KaTeX 公式显示。
- 数据种子：仓库包含非 LLM 配置的数据库种子数据。

## 技术架构

```text
AlgoMentor
├── frontend/                 # React + TypeScript + Vite 前端
│   ├── src/pages/            # 题库、做题、训练、复盘、系统设置页面
│   ├── src/components/       # Markdown/KaTeX、布局、编辑器等组件
│   ├── src/lib/              # API 客户端
│   └── package.json          # 前端依赖和脚本
├── backend/                  # FastAPI 后端
│   ├── src/api/routes/       # problems/submissions/analysis/review/training/system 路由
│   ├── src/repositories/     # PostgreSQL 数据访问层
│   ├── src/services/         # 判题、LLM、题目解析等业务服务
│   ├── src/schemas/          # Pydantic 请求/响应模型
│   ├── src/core/db.py        # 数据库初始化与种子数据
│   ├── src/data/             # 题目与数据库种子数据
│   └── requirements.txt      # 后端依赖
└── README.md
```

### 前端

- React 19 + TypeScript
- Vite 开发与构建
- Monaco Editor 代码编辑器
- marked + KaTeX 渲染题面 Markdown 和数学公式
- Oxlint 代码检查

### 后端

- FastAPI 提供 REST API
- Pydantic / pydantic-settings 管理模型和配置
- PostgreSQL 存储题目、测试用例、提交记录、归因结果、公司和题型配置
- psycopg2 访问数据库
- Judge0 用于代码运行与判题
- LLM 配置通过系统设置维护，数据库种子文件不包含 LLM 配置和密钥

### 数据库表

主要表包括：

- `users`
- `companies`
- `problem_categories`
- `problems`
- `problem_test_cases`
- `submissions`
- `error_attributions`
- `llm_settings`

`backend/src/data/database_seed.sql` 导出了除 `llm_settings` 外的本地数据，可用于初始化题库、提交记录和复盘数据。

## 安装说明

### 1. 克隆仓库

```bash
git clone https://github.com/TheoEquity/AlgoMentor.git
cd AlgoMentor
```

### 2. 准备 PostgreSQL

项目默认数据库连接为：

```text
postgresql://bytehunter:bytehunter123@localhost:5432/bytehunter
```

可以通过环境变量覆盖：

```bash
export BYTEHUNTER_DATABASE_URL="postgresql://<USER>:<PASSWORD>@<HOST>:<PORT>/<DATABASE>"
```

后端启动时会自动创建基础表结构。

### 3. 导入非 LLM 种子数据

```bash
psql "$BYTEHUNTER_DATABASE_URL" -f backend/src/data/database_seed.sql
```

如果使用默认连接，也可以执行：

```bash
psql "postgresql://bytehunter:bytehunter123@localhost:5432/bytehunter" -f backend/src/data/database_seed.sql
```

### 4. 启动后端

```bash
cd backend
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
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

### 5. 启动前端

```bash
cd frontend
npm install
npm run dev -- --host 0.0.0.0 --port 5173
```

访问：

```text
http://localhost:5173
```

### 6. 配置 AI 能力

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
