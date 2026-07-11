from __future__ import annotations

import psycopg2
import psycopg2.extras
from psycopg2.extensions import connection as PgConnection

from data.seed_problems import SEED_PROBLEMS


def get_connection(database_url: str) -> PgConnection:
    connection = psycopg2.connect(database_url, cursor_factory=psycopg2.extras.RealDictCursor)
    connection.autocommit = False
    return connection


def initialize_database(database_url: str) -> None:
    connection = get_connection(database_url)

    with connection, connection.cursor() as cursor:
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS users (
                id SERIAL PRIMARY KEY,
                username TEXT NOT NULL UNIQUE,
                display_name TEXT NOT NULL DEFAULT '',
                created_at TEXT NOT NULL
            )
        ''')

        cursor.execute('''
            CREATE TABLE IF NOT EXISTS candidate_positions (
                id SERIAL PRIMARY KEY,
                resume_id INTEGER REFERENCES resumes(id) ON DELETE SET NULL,
                company_name TEXT NOT NULL,
                title TEXT NOT NULL,
                location TEXT DEFAULT '',
                description TEXT DEFAULT '',
                apply_url TEXT DEFAULT '',
                degree_requirement TEXT DEFAULT '',
                match_score INTEGER DEFAULT 0,
                match_reason TEXT DEFAULT '',
                source_type TEXT NOT NULL DEFAULT 'manual',
                site_id INTEGER REFERENCES career_sites(id) ON DELETE SET NULL,
                source_position_id INTEGER DEFAULT NULL,
                status TEXT NOT NULL DEFAULT 'candidate',
                created_at TEXT NOT NULL,
                updated_at TEXT NOT NULL
            )
        ''')

        cursor.execute(
                "INSERT INTO users (username, display_name, created_at) VALUES (%s, %s, %s) ON CONFLICT (username) DO NOTHING",
                ('default', '默认用户', '2026-06-23T17:20:00Z'),
            )

        cursor.execute(
            "ALTER TABLE problems ADD COLUMN IF NOT EXISTS category_slug TEXT NOT NULL DEFAULT ''"
        )
        cursor.execute(
            "ALTER TABLE problems ADD COLUMN IF NOT EXISTS source TEXT NOT NULL DEFAULT '手工'"
        )
        cursor.execute(
            "ALTER TABLE problems ADD COLUMN IF NOT EXISTS frequency TEXT NOT NULL DEFAULT '中'"
        )
        cursor.execute(
            "ALTER TABLE ai_chat_sessions ADD COLUMN IF NOT EXISTS problem_id INTEGER REFERENCES problems(id)"
        )
        cursor.execute(
            "ALTER TABLE problems ADD COLUMN IF NOT EXISTS analysis_json TEXT"
        )
        cursor.execute(
            "ALTER TABLE problems ADD COLUMN IF NOT EXISTS year INTEGER"
        )
        cursor.execute(
            "ALTER TABLE llm_settings ADD COLUMN IF NOT EXISTS vision_model TEXT NOT NULL DEFAULT 'gpt-4.1-mini'"
        )

        cursor.execute(
            "ALTER TABLE llm_settings ADD COLUMN IF NOT EXISTS resume_model TEXT NOT NULL DEFAULT 'gpt-4.1-mini'"
        )
        cursor.execute(
            "ALTER TABLE llm_settings ADD COLUMN IF NOT EXISTS scraping_model TEXT NOT NULL DEFAULT 'gpt-4.1-mini'"
        )

        cursor.execute('''
            CREATE TABLE IF NOT EXISTS browser_settings (
                id INTEGER PRIMARY KEY DEFAULT 1 CHECK (id = 1),
                headless INTEGER NOT NULL DEFAULT 1,
                executable_path TEXT NOT NULL DEFAULT '',
                viewport_width INTEGER NOT NULL DEFAULT 1280,
                viewport_height INTEGER NOT NULL DEFAULT 720,
                timeout_seconds INTEGER NOT NULL DEFAULT 30,
                user_data_dir TEXT NOT NULL DEFAULT '',
                proxy_url TEXT NOT NULL DEFAULT '',
                updated_at TEXT NOT NULL
            )
        ''')

        cursor.execute('''
            CREATE TABLE IF NOT EXISTS resumes (
                id SERIAL PRIMARY KEY,
                name TEXT NOT NULL,
                file_path TEXT NOT NULL,
                file_type TEXT NOT NULL,
                position_keywords TEXT NOT NULL DEFAULT '[]',
                position_type TEXT NOT NULL DEFAULT '日常实习',
                extracted_info TEXT,
                extract_status TEXT NOT NULL DEFAULT 'pending',
                extract_error TEXT,
                created_at TEXT NOT NULL,
                updated_at TEXT NOT NULL
            )
        ''')

        cursor.execute('''
            CREATE TABLE IF NOT EXISTS career_sites (
                id SERIAL PRIMARY KEY,
                company_name TEXT NOT NULL,
                url TEXT NOT NULL,
                notes TEXT,
                industry_category TEXT DEFAULT '',
                referral_code TEXT DEFAULT '',
                last_scraped_at TEXT,
                scrape_status TEXT NOT NULL DEFAULT 'idle',
                scrape_error TEXT,
                position_count INTEGER NOT NULL DEFAULT 0,
                created_at TEXT NOT NULL,
                updated_at TEXT NOT NULL
            )
        ''')

        cursor.execute('''
            CREATE TABLE IF NOT EXISTS recruitment_positions (
                id SERIAL PRIMARY KEY,
                site_id INTEGER NOT NULL REFERENCES career_sites(id) ON DELETE CASCADE,
                title TEXT NOT NULL,
                location TEXT,
                degree_requirement TEXT,
                description TEXT,
                apply_url TEXT,
                position_type TEXT NOT NULL DEFAULT '未分类',
                status TEXT NOT NULL DEFAULT 'pending',
                source_hash TEXT NOT NULL UNIQUE,
                extracted_at TEXT NOT NULL,
                created_at TEXT NOT NULL
            )
        ''')

        cursor.execute('''
            CREATE TABLE IF NOT EXISTS position_matches (
                id SERIAL PRIMARY KEY,
                position_id INTEGER NOT NULL REFERENCES recruitment_positions(id) ON DELETE CASCADE,
                resume_id INTEGER NOT NULL REFERENCES resumes(id) ON DELETE CASCADE,
                match_score INTEGER NOT NULL DEFAULT 0,
                match_reason TEXT,
                created_at TEXT NOT NULL,
                UNIQUE(position_id, resume_id)
            )
        ''')

        cursor.execute('''
            CREATE TABLE IF NOT EXISTS job_applications (
                id SERIAL PRIMARY KEY,
                position_id INTEGER NOT NULL REFERENCES recruitment_positions(id) ON DELETE CASCADE,
                resume_id INTEGER NOT NULL REFERENCES resumes(id) ON DELETE CASCADE,
                status TEXT NOT NULL DEFAULT 'pending_apply',
                applied_at TEXT,
                feedback_at TEXT,
                notes TEXT,
                created_at TEXT NOT NULL,
                updated_at TEXT NOT NULL
            )
        ''')

        cursor.execute(
            "UPDATE problems SET status = '未开始' WHERE status IN ('published', 'draft')"
        )
        cursor.execute(
            "ALTER TABLE problems ADD COLUMN IF NOT EXISTS time_limit_ms INTEGER NOT NULL DEFAULT 2000"
        )
        cursor.execute(
            "ALTER TABLE problems ADD COLUMN IF NOT EXISTS memory_limit_kb INTEGER NOT NULL DEFAULT 262144"
        )
        cursor.execute(
            "ALTER TABLE problems ADD COLUMN IF NOT EXISTS position VARCHAR(64) DEFAULT ''"
        )

        cursor.execute(
            "ALTER TABLE career_sites ADD COLUMN IF NOT EXISTS industry_category TEXT DEFAULT ''"
        )
        cursor.execute(
            "ALTER TABLE career_sites ADD COLUMN IF NOT EXISTS referral_code TEXT DEFAULT ''"
        )

        cursor.execute('''
            CREATE TABLE IF NOT EXISTS industry_categories (
                id SERIAL PRIMARY KEY,
                name TEXT NOT NULL UNIQUE,
                sort_order INTEGER NOT NULL DEFAULT 0,
                created_at TEXT NOT NULL
            )
        ''')

        cursor.execute('SELECT COUNT(*) AS count FROM industry_categories')
        if cursor.fetchone()['count'] == 0:
            from datetime import UTC, datetime
            now = datetime.now(UTC).isoformat()
            for item in ['互联网/科技', '金融', '游戏', '芯片/半导体', '人工智能', '新能源/汽车', '医疗/生物', '消费品', '咨询', '教育', '其他']:
                cursor.execute(
                    "INSERT INTO industry_categories (name, sort_order, created_at) VALUES (%s, %s, %s) ON CONFLICT (name) DO NOTHING",
                    (item, 0, now),
                )

        cursor.execute('SELECT COUNT(*) AS count FROM llm_settings')
        if cursor.fetchone()['count'] == 0:
            cursor.execute(
                '''
                INSERT INTO llm_settings (
                    id, provider, endpoint_url,
                    solution_model, vision_model, attribution_model, review_model,
                    resume_model, scraping_model,
                    solution_temperature, attribution_temperature, review_temperature,
                    api_key_secret, enabled, updated_at
                ) VALUES (1, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                ''',
                (
                    'OpenAI Compatible',
                    'https://api.openai.com/v1',
                    'gpt-4.1-mini',
                    'gpt-4.1-mini',
                    'gpt-4.1-mini',
                    'gpt-4.1-mini',
                    'gpt-4.1-mini',
                    'gpt-4.1-mini',
                    0.2,
                    0.1,
                    0.3,
                    '',
                    1,
                    '2026-06-23T17:20:00Z',
                ),
            )

        cursor.execute('SELECT COUNT(*) AS count FROM browser_settings')
        if cursor.fetchone()['count'] == 0:
            cursor.execute(
                '''INSERT INTO browser_settings (id, updated_at) VALUES (1, %s)''',
                ('2026-07-09T00:00:00Z',),
            )

        cursor.execute('SELECT COUNT(*) AS count FROM problem_categories')
        if cursor.fetchone()['count'] == 0:
            _seed_categories(cursor)

        cursor.execute('SELECT COUNT(*) AS count FROM ai_agents')
        if cursor.fetchone()['count'] == 0:
            _seed_agents(cursor)

        _migrate_new_agents(cursor)

        cursor.execute('SELECT COUNT(*) AS count FROM problems')
        if cursor.fetchone()['count'] == 0:
            _seed_database(cursor)

    connection.close()


def _seed_categories(cursor) -> None:
    _CATEGORIES = [
        (1, 'Two Pointers', 'two-pointers'),
        (2, 'Sliding Window', 'sliding-window'),
        (3, 'Hashing', 'hashing'),
        (4, 'Binary Search', 'binary-search'),
        (5, 'Prefix Sum', 'prefix-sum'),
        (6, 'Intervals', 'intervals'),
        (7, 'Matrix Grid', 'matrix-grid'),
        (8, 'Linked List', 'linked-list'),
        (9, 'Stack Queue', 'stack-queue'),
        (10, 'Monotonic Stack', 'monotonic-stack'),
        (11, 'Heap Priority Queue', 'heap-priority-queue'),
        (12, 'Tree', 'tree'),
        (13, 'Graphs', 'graphs'),
        (14, 'Backtracking', 'backtracking'),
        (15, 'DP', 'dynamic-programming'),
        (16, 'Greedy', 'greedy'),
        (17, 'Bit Manipulation', 'bit-manipulation'),
        (18, 'Simulation', 'simulation'),
        (19, '数学', 'math'),
        (20, 'String', 'string'),
    ]
    for cat_id, name, slug in _CATEGORIES:
        cursor.execute(
            "INSERT INTO problem_categories (id, name, slug, sort_order, created_at) VALUES (%s, %s, %s, %s, %s)",
            (cat_id, name, slug, cat_id, '2026-06-24T00:00:00Z'),
        )


def _seed_database(cursor) -> None:
    for problem in SEED_PROBLEMS:
        cursor.execute(
            '''
            INSERT INTO problems (
                slug, title, company, difficulty, category_slug,
                statement_markdown, constraints_text, tags_json,
                examples_json, supported_languages_json, starter_templates_json,
                source_type, source, frequency, year, source_ref, external_id,
                status, time_limit_ms, memory_limit_kb, created_at, updated_at
            ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
            RETURNING id
            ''',
            (
                problem['slug'],
                problem['title'],
                problem['company'],
                problem['difficulty'],
                problem['category_slug'],
                problem['statement_markdown'],
                problem['constraints_text'],
                problem['tags_json'],
                problem['examples_json'],
                problem['supported_languages_json'],
                problem['starter_templates_json'],
                problem['source_type'],
                problem['source'],
                problem['frequency'],
                problem['year'],
                problem['source_ref'],
                problem['external_id'],
                problem['status'],
                problem.get('time_limit_ms', 2000),
                problem.get('memory_limit_kb', 262144),
                problem['created_at'],
                problem['updated_at'],
            ),
        )
        problem_id = cursor.fetchone()['id']

        for test_case in problem['test_cases']:
            cursor.execute(
                '''
                INSERT INTO problem_test_cases (
                    problem_id, case_type, stdin_text, expected_output_text, sort_order
                ) VALUES (%s, %s, %s, %s, %s)
                ''',
                (
                    problem_id,
                    test_case['case_type'],
                    test_case['stdin_text'],
                    test_case['expected_output_text'],
                    test_case['sort_order'],
                ),
            )


def _seed_agents(cursor) -> None:
    now = '2026-07-04T00:00:00Z'

    _AGENTS = [
        (1, 'solution-agent', '解题 Agent', '分析题目解题思路并给出标准答案代码',
         '你是一位资深算法竞赛教练。分析题目时从题意拆解、关键观察、算法选择、复杂度、易错点五个维度展开。对于每道题务必给出标准答案参考代码（Python/C++/Java），代码不包含 main 入口和测试用例。',
         '请分析这道算法题的解题思路，并给出标准答案代码。\n\n## 题目标题\n{{ problem.title }}\n\n## 题目标签\n{{ ", ".join(problem.tags) if problem.tags else "无" }}\n\n## 题面\n{{ problem.statement_markdown }}\n\n## 约束\n{{ problem.constraints_text }}\n\n{% if code_text %}\n## 用户代码\n```{{ language }}\n{{ code_text }}\n```\n{% endif %}',
         'gpt-4.1-mini', 0.2, 2048, 10, 1),

        (2, 'tutoring-agent', '答题 Agent', '在编程做题过程中提供分步辅导',
         '你是一位耐心的编程导师。根据用户当前做题状态提供分步辅导：错误归因时准确定位代码行；复盘时总结薄弱点和改进方向；分步提示避免直接给完整答案；回答追问时聚焦题目思路和复杂度证明。',
         '{% if analysis_type == "attribution" %}\n请对下面的判题结果做错误归因。primary_category 是主要错误类型，secondary_category 是次级错误类型，title 是短标题，summary 是一段总结，bullets 是 3 到 5 条建议，line_refs 是可选的行号提示。\n\n## 判题信息\n- Verdict: {{ submission.verdict }}\n- 运行时错误: {{ submission.stderr_output }}\n- 编译输出: {{ submission.compiler_output }}\n- 失败输入: {{ submission.failed_input }}\n- 预期输出: {{ submission.failed_expected_output }}\n- 实际输出: {{ submission.failed_actual_output }}\n\n## 代码\n```{{ language }}\n{{ code_text }}\n```\n{% elif analysis_type == "review" %}\n请基于下面的做题记录生成复盘建议。重点输出下次训练建议、薄弱点和继续训练动作。\n\n## 题目: {{ problem.title }}\n## Verdict: {{ submission.verdict }}\n## 运行时间: {{ submission.runtime_ms }}ms\n## 内存: {{ submission.memory_kb }}KB\n\n## 代码\n```{{ language }}\n{{ code_text }}\n```\n{% elif analysis_type == "hint" %}\n请为 ACM 编程训练生成渐进式提示。title 是本步提示标题，summary 是克制提示，bullets 是 2 到 4 条可执行提示，line_refs 可指出当前代码风险。避免直接给完整代码。\n\n提示步骤：第 {{ hint_step }} 步\n提示强度：{{ hint_strength }}\n\n## 题目标题: {{ problem.title }}\n## 标签: {{ ", ".join(problem.tags) }}\n## 题面: {{ problem.statement_markdown }}\n## 约束: {{ problem.constraints_text }}\n\n## 代码\n```{{ language }}\n{{ code_text }}\n```\n{% elif analysis_type == "chat" %}\n请作为算法题解题助教回答用户追问。聚焦题目思路、复杂度证明、反例、边界条件和同类题迁移。\n\n## 题目标题: {{ problem.title }}\n## 标签: {{ ", ".join(problem.tags) }}\n## 题面: {{ problem.statement_markdown }}\n## 约束: {{ problem.constraints_text }}\n\n{% if messages %}\n## 对话历史\n{% for msg in messages %}\n{{ msg.role }}: {{ msg.content }}\n{% endfor %}\n{% endif %}\n\n## 用户问题\n{{ question }}\n{% else %}\n请分析下面的算法题代码并给出解题建议。\n\n## 题目标题: {{ problem.title }}\n## 标签: {{ ", ".join(problem.tags) }}\n## 约束: {{ problem.constraints_text }}\n## 语言: {{ language }}\n\n## 代码\n```{{ language }}\n{{ code_text }}\n```\n{% endif %}',
         'gpt-4.1-mini', 0.2, 2048, 10, 2),

        (3, 'chat-agent', '聊天 Agent', '独立 AI 聊天界面，自由对话和数据分析',
         '你是 AlgoMentor 平台的 AI 数据分析助手。支持自然语言查询题库统计、提交分析、公司趋势、个人进度等。用表格和图表描述数据，给出可操作的改进建议。回答时保持简洁专业，不超过 500 字。',
         '{{ query }}',
         'gpt-4.1-mini', 0.5, 2048, 10, 3),

        (4, 'parsing-agent', '解析 Agent', '将非结构化题目文本/图片解析为结构化数据',
         '你是算法题目结构化解析专家。将输入文本/图片解析为包含 slug/title/company/difficulty/category_slug/statement_markdown/tags/examples/time_limit_ms/memory_limit_kb/source/analysis 的完整 JSON 对象。数学公式统一用 $...$ 或 $$...$$ 包裹。无法识别的字段留空字符串。',
         '{% if mode == "image_only" %}\n请识别图片中的算法题目，解析为结构化 JSON。优先恢复题面正文、输入输出格式、样例和公式。\n{% elif mode == "text_plus_image" %}\n以下文本和图片是同一道算法题，请以文本为主线，用图片校正数学公式和复杂排版，解析为结构化 JSON。\n\n## 文本内容\n{{ raw_text }}\n\n## 图片说明\n{{ image_name }}\n{% else %}\n请将以下算法题目文本解析为结构化 JSON。\n\n{{ raw_text }}\n{% endif %}',
         'gpt-4.1-mini', 0.1, 4096, 5, 4),

        (5, 'coach-agent', '教练 Agent', '分析训练历史，生成个性化学习计划',
         '你是 AI 训练教练。分析用户提交历史识别薄弱题型和易错类别。生成 7 天训练计划，每天推荐 3-5 道针对弱项的题目。报告包含正确率趋势、耗时分布和知识点热力图描述。',
         '请分析我的训练数据并生成个性化学习计划。\n\n{% if submission_history %}\n## 提交历史\n{{ submission_history }}\n{% endif %}',
         'gpt-4.1-mini', 0.3, 2048, 10, 5),

        (6, 'problem-generator', 'AI 生题 Agent', '根据参考题目用 AI 生成一道同类型但场景不同的全新题目',
         '你是算法竞赛命题专家。根据参考题目生成一道**同类型但场景不同**的算法题。保持相同难度和题型分类，变换故事背景、数值和具体条件，但核心算法思想一致。\n\n严格按以下 JSON 格式输出，不要带 ```json 标记或其他额外内容：\n{"title":"...","statement_markdown":"...","examples":[{"input":"...","output":"...","explanation":"..."}],"tags":["..."]}',
         '## 参考题目\n- 标题：{{ problem.title }}\n- 题型：{{ problem.category_slug }}\n- 难度：{{ problem.difficulty }}\n- 公司：{{ problem.company }}\n- 岗位：{{ problem.position }}\n- 年度：{{ problem.year }}\n\n## 原题描述\n{{ problem.statement_markdown }}\n\n{% if original_examples %}\n## 原题样例\n{% for ex in original_examples %}\n- 输入：{{ ex.input }}\n- 输出：{{ ex.output }}\n{% if ex.explanation %}- 解释：{{ ex.explanation }}{% endif %}\n{% endfor %}\n{% endif %}',
         'qwen3.6-plus', 0.7, 4096, 1, 6),

        (7, 'resume-parsing-agent', '简历解析 Agent', '从简历文本中提取结构化信息（教育、技能、经历等）',
         '你是专业的简历信息提取引擎。忠实提取原文内容，不概括、不简化、不遗漏。技能/课程/荣誉/证书名称必须保持原文完整。经历和项目描述保留原文的量化数据和关键动词。日期格式统一为 "YYYY.MM" 或 "YYYY"。',
         '从以下简历文本中提取结构化 JSON：\n\n{{ resume_text }}',
         'gpt-4.1-mini', 0.1, 8192, 1, 7),

        (8, 'position-matching-agent', '岗位匹配 Agent', '评估简历与岗位的匹配度并给出建议',
         '你是校招岗位匹配专家。根据简历信息和岗位描述评估匹配度（0-100分）。评估维度包括学校层次匹配、专业相关度、技能匹配度、实习/项目经验相关性、地点偏好。',
         '评估以下简历与岗位的匹配度并返回 JSON（score 0-100, reason 50字内）：\n\n简历：\n{{ resume_summary }}\n\n岗位：\n{{ position_description }}',
         'gpt-4.1-mini', 0.1, 2048, 1, 8),
    ]
    for agent_id, slug, name, desc, system_prompt, user_template, model, temp, max_tok, max_iter, sort in _AGENTS:
        cursor.execute(
            '''INSERT INTO ai_agents (
                id, slug, name, description, system_prompt, user_prompt_template,
                model, temperature, max_tokens, max_iterations, sort_order, created_at, updated_at
            ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)''',
            (agent_id, slug, name, desc, system_prompt, user_template, model, temp, max_tok, max_iter, sort, now, now),
        )

    _TOOLS = [
        (1, 'query_problems', '搜索题库', '搜索题库，可按公司、题型、难度、关键词过滤',
         '{"type":"object","properties":{"company":{"type":"string","description":"公司名"},"category":{"type":"string","description":"题型slug"},"difficulty":{"type":"string","enum":["Easy","Medium","Hard"]},"keyword":{"type":"string","description":"关键词搜索标题"},"limit":{"type":"integer","default":10}},"required":[]}',
         'python_function', '{"module":"services.agent.builtin_tools","function":"query_problems"}'),
        (2, 'query_submissions', '查询提交记录', '查询用户的提交记录',
         '{"type":"object","properties":{"problem_id":{"type":"integer"},"verdict":{"type":"string"},"limit":{"type":"integer","default":20}},"required":[]}',
         'python_function', '{"module":"services.agent.builtin_tools","function":"query_submissions"}'),
        (3, 'read_user_code', '读取当前代码', '读取用户正在编辑的代码内容',
         '{"type":"object","properties":{},"required":[]}',
         'python_function', '{"module":"services.agent.builtin_tools","function":"read_user_code"}'),
        (4, 'run_test_case', '运行测试用例', '在判题系统中运行一个测试用例',
         '{"type":"object","properties":{"stdin":{"type":"string","description":"标准输入"}},"required":["stdin"]}',
         'python_function', '{"module":"services.agent.builtin_tools","function":"run_test_case"}'),
        (5, 'compare_output', '对比输出差异', '对比预期输出和实际输出的差异',
         '{"type":"object","properties":{"expected":{"type":"string"},"actual":{"type":"string"}},"required":["expected","actual"]}',
         'python_function', '{"module":"services.agent.builtin_tools","function":"compare_output"}'),
        (6, 'analyze_company_trends', '公司出题趋势', '分析指定公司的出题趋势',
         '{"type":"object","properties":{"company":{"type":"string"},"years":{"type":"integer","default":3}},"required":["company"]}',
         'python_function', '{"module":"services.agent.builtin_tools","function":"analyze_company_trends"}'),
        (7, 'analyze_category_distribution', '题型分布统计', '统计题型分布情况',
         '{"type":"object","properties":{"company":{"type":"string"},"difficulty":{"type":"string"}},"required":[]}',
         'python_function', '{"module":"services.agent.builtin_tools","function":"analyze_category_distribution"}'),
        (8, 'generate_training_report', '生成训练报告', '生成用户训练报告',
         '{"type":"object","properties":{"days":{"type":"integer","default":30}},"required":[]}',
         'python_function', '{"module":"services.agent.builtin_tools","function":"generate_training_report"}'),
        (9, 'query_similar_problems', '查找相似题', '根据题目 ID 查找相似题目',
         '{"type":"object","properties":{"problem_id":{"type":"integer"},"limit":{"type":"integer","default":5}},"required":["problem_id"]}',
         'python_function', '{"module":"services.agent.builtin_tools","function":"query_similar_problems"}'),
        (10, 'analyze_user_weaknesses', '弱项分析', '分析用户的薄弱题型和知识点',
         '{"type":"object","properties":{"days":{"type":"integer","default":30}},"required":[]}',
         'python_function', '{"module":"services.agent.builtin_tools","function":"analyze_user_weaknesses"}'),
        (11, 'generate_study_plan', '学习计划', '生成个性化学习计划',
         '{"type":"object","properties":{"target_areas":{"type":"string"},"days":{"type":"integer","default":7}},"required":[]}',
         'python_function', '{"module":"services.agent.builtin_tools","function":"generate_study_plan"}'),
        (12, 'recommend_daily_problems', '每日推荐', '推荐今日练习题',
         '{"type":"object","properties":{"count":{"type":"integer","default":5}},"required":[]}',
         'python_function', '{"module":"services.agent.builtin_tools","function":"recommend_daily_problems"}'),
        (13, 'generate_similar_problem', '生成相似题目', '根据题目 ID 用 AI 生成一道同类型的全新题目',
         '{"type":"object","properties":{"problem_id":{"type":"integer","description":"参照题目的 ID"}},"required":["problem_id"]}',
         'python_function', '{"module":"services.agent.builtin_tools","function":"generate_similar_problem"}'),
    ]
    for tool_id, slug, name, desc, schema, htype, hconfig in _TOOLS:
        cursor.execute(
            '''INSERT INTO ai_tools (
                id, slug, name, description, parameters_schema, handler_type, handler_config, created_at
            ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s)''',
            (tool_id, slug, name, desc, schema, htype, hconfig, now),
        )

    _SKILLS = [
        (1, 'hint-skill', '渐进提示', '控制提示的输出克制程度，按步骤推进。禁止直接给出完整答案。'),
        (2, 'attribution-skill', '错误归因', '根据判题结果定位错误类型和代码行。输出 primary_category 和 secondary_category。'),
        (3, 'review-skill', '训练复盘', '基于提交记录分析薄弱点，生成下一步训练方向和具体改进步骤。'),
    ]
    for skill_id, slug, name, prompt in _SKILLS:
        cursor.execute(
            '''INSERT INTO ai_skills (
                id, slug, name, description, prompt_text, created_at
            ) VALUES (%s, %s, %s, %s, %s, %s)''',
            (skill_id, slug, name, '', prompt, now),
        )

    _AGENT_TOOLS = [
        (1, 9),   # solution-agent -> query_similar_problems
        (2, 3), (2, 4), (2, 5), (2, 9),  # tutoring-agent -> read_user_code, run_test_case, compare_output, query_similar_problems
        (3, 1), (3, 2), (3, 6), (3, 7), (3, 8),  # chat-agent -> query_problems, query_submissions, analyze_company_trends, analyze_category_distribution, generate_training_report
        (5, 10), (5, 11), (5, 12), (5, 1),  # coach-agent -> analyze_user_weaknesses, generate_study_plan, recommend_daily_problems, query_problems
    ]
    for agent_id, tool_id in _AGENT_TOOLS:
        cursor.execute(
            'INSERT INTO ai_agent_tools (agent_id, tool_id) VALUES (%s, %s)',
            (agent_id, tool_id),
        )

    _AGENT_SKILLS = [
        (2, 1), (2, 2), (2, 3),  # tutoring-agent -> hint, attribution, review
    ]
    for agent_id, skill_id in _AGENT_SKILLS:
        cursor.execute(
            'INSERT INTO ai_agent_skills (agent_id, skill_id) VALUES (%s, %s)',
            (agent_id, skill_id),
        )


def _migrate_new_agents(cursor) -> None:
    now = '2026-07-09T00:00:00Z'
    _NEW_AGENTS = [
        (7, 'resume-parsing-agent', '简历解析 Agent', '从简历文本中提取结构化信息（教育、技能、经历等）',
         '你是专业的简历信息提取引擎。忠实提取原文内容，不概括、不简化、不遗漏。技能/课程/荣誉/证书名称必须保持原文完整。经历和项目描述保留原文的量化数据和关键动词。日期格式统一为 "YYYY.MM" 或 "YYYY"。',
         '从以下简历文本中提取结构化 JSON：\n\n{{ resume_text }}',
         'gpt-4.1-mini', 0.1, 8192, 1, 7),

        (8, 'position-matching-agent', '岗位匹配 Agent', '评估简历与岗位的匹配度并给出建议',
         '你是校招岗位匹配专家。根据简历信息和岗位描述评估匹配度（0-100分）。评估维度包括学校层次匹配、专业相关度、技能匹配度、实习/项目经验相关性、地点偏好。',
         '评估以下简历与岗位的匹配度并返回 JSON（score 0-100, reason 50字内）：\n\n简历：\n{{ resume_summary }}\n\n岗位：\n{{ position_description }}',
         'gpt-4.1-mini', 0.1, 2048, 1, 8),
    ]
    for agent_id, slug, name, desc, system_prompt, user_template, model, temp, max_tok, max_iter, sort in _NEW_AGENTS:
        cursor.execute(
            '''INSERT INTO ai_agents (
                id, slug, name, description, system_prompt, user_prompt_template,
                model, temperature, max_tokens, max_iterations, sort_order, created_at, updated_at
            ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
            ON CONFLICT (id) DO NOTHING''',
            (agent_id, slug, name, desc, system_prompt, user_template, model, temp, max_tok, max_iter, sort, now, now),
        )
