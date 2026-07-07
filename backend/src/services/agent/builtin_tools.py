from __future__ import annotations

"""Built-in tool implementations for agents.

Each function is called by ToolRegistry via handler_config:
  {"module": "services.agent.builtin_tools", "function": "query_problems"}

All functions receive (arguments: dict, context: dict) and return str.
The `context` dict carries runtime state (database_url, problem, etc.) from AgentRunner.
"""

import json


def query_problems(args: dict, context: dict) -> str:
    from core.db import get_connection

    db_url = context.get('database_url', '')
    company = args.get('company')
    category = args.get('category')
    difficulty = args.get('difficulty')
    keyword = args.get('keyword')
    limit = args.get('limit', 10)

    conditions = ['1=1']
    params: list = []
    if company:
        conditions.append('company = %s')
        params.append(company)
    if category:
        conditions.append('category_slug = %s')
        params.append(category)
    if difficulty:
        conditions.append('difficulty = %s')
        params.append(difficulty)
    if keyword:
        conditions.append('title ILIKE %s')
        params.append(f'%{keyword}%')

    where = ' AND '.join(conditions)
    connection = get_connection(db_url)
    with connection, connection.cursor() as cursor:
        cursor.execute(
            f'SELECT id, title, company, difficulty, category_slug, frequency, year FROM problems WHERE {where} ORDER BY frequency DESC LIMIT %s',
            params + [limit],
        )
        rows = cursor.fetchall()
    connection.close()

    if not rows:
        return '未找到符合条件的题目。'
    return json.dumps(rows, ensure_ascii=False)


def query_submissions(args: dict, context: dict) -> str:
    from core.db import get_connection

    db_url = context.get('database_url', '')
    problem_id = args.get('problem_id')
    verdict = args.get('verdict')
    limit = args.get('limit', 20)

    conditions = ['1=1']
    params: list = []
    if problem_id:
        conditions.append('problem_id = %s')
        params.append(problem_id)
    if verdict:
        conditions.append('verdict = %s')
        params.append(verdict)

    where = ' AND '.join(conditions)
    connection = get_connection(db_url)
    with connection, connection.cursor() as cursor:
        cursor.execute(
            f'SELECT id, problem_id, language, verdict, runtime_ms, memory_kb, created_at FROM submissions WHERE {where} ORDER BY created_at DESC LIMIT %s',
            params + [limit],
        )
        rows = cursor.fetchall()
    connection.close()

    if not rows:
        return '未找到提交记录。'
    return json.dumps(rows, ensure_ascii=False)


def read_user_code(args: dict, context: dict) -> str:
    code_text = context.get('code_text', '')
    if not code_text:
        return '当前编辑器中没有代码。'
    return code_text


def run_test_case(args: dict, context: dict) -> str:
    return f'[模拟] 测试用例 stdin={args.get("stdin", "")[:100]} 运行完成。注：当前为内置工具，未对接 Judge0 判题系统。'


def compare_output(args: dict, context: dict) -> str:
    expected = args.get('expected', '')
    actual = args.get('actual', '')
    if expected == actual:
        return '输出完全匹配。'
    return f'输出不匹配。\n预期: {expected[:200]}\n实际: {actual[:200]}'


def analyze_company_trends(args: dict, context: dict) -> str:
    from core.db import get_connection

    db_url = context.get('database_url', '')
    company = args.get('company', '')
    years = args.get('years', 3)

    connection = get_connection(db_url)
    with connection, connection.cursor() as cursor:
        cursor.execute(
            '''SELECT year, COUNT(*) as cnt, 
                      COUNT(CASE WHEN difficulty='Easy' THEN 1 END) as easy_cnt,
                      COUNT(CASE WHEN difficulty='Medium' THEN 1 END) as medium_cnt,
                      COUNT(CASE WHEN difficulty='Hard' THEN 1 END) as hard_cnt
               FROM problems WHERE company = %s AND year IS NOT NULL
               GROUP BY year ORDER BY year DESC LIMIT %s''',
            (company, years),
        )
        rows = cursor.fetchall()
    connection.close()

    if not rows:
        return f'未找到公司 "{company}" 的题目数据。'
    return json.dumps(rows, ensure_ascii=False)


def analyze_category_distribution(args: dict, context: dict) -> str:
    from core.db import get_connection

    db_url = context.get('database_url', '')
    company = args.get('company')
    difficulty = args.get('difficulty')

    conditions = ['1=1']
    params: list = []
    if company:
        conditions.append('company = %s')
        params.append(company)
    if difficulty:
        conditions.append('difficulty = %s')
        params.append(difficulty)

    where = ' AND '.join(conditions)
    connection = get_connection(db_url)
    with connection, connection.cursor() as cursor:
        cursor.execute(
            f'''SELECT category_slug, COUNT(*) as cnt 
                FROM problems WHERE {where} 
                GROUP BY category_slug ORDER BY cnt DESC''',
            params,
        )
        rows = cursor.fetchall()
    connection.close()
    return json.dumps(rows, ensure_ascii=False)


def generate_training_report(args: dict, context: dict) -> str:
    days = args.get('days', 30)
    return f'[模拟] 已生成最近 {days} 天的训练报告。注：完整实现依赖提交历史和复盘数据的详细分析。'


def query_similar_problems(args: dict, context: dict) -> str:
    from core.db import get_connection

    db_url = context.get('database_url', '')
    problem_id = args.get('problem_id')
    limit = args.get('limit', 5)

    connection = get_connection(db_url)
    with connection, connection.cursor() as cursor:
        cursor.execute(
            'SELECT category_slug, difficulty FROM problems WHERE id = %s',
            (problem_id,),
        )
        row = cursor.fetchone()
    if not row:
        connection.close()
        return '未找到该题目。'

    category = row['category_slug']
    cursor2 = connection.cursor()
    with connection, cursor2:
        cursor2.execute(
            'SELECT id, title, difficulty, company FROM problems WHERE category_slug = %s AND id != %s ORDER BY id DESC LIMIT %s',
            (category, problem_id, limit),
        )
        rows = cursor2.fetchall()
    connection.close()

    if not rows:
        return '未找到相似题目。'
    return json.dumps(rows, ensure_ascii=False)


def analyze_user_weaknesses(args: dict, context: dict) -> str:
    days = args.get('days', 30)
    return f'[模拟] 已分析最近 {days} 天的弱项。注：完整实现依赖提交历史和判题数据。'


def generate_study_plan(args: dict, context: dict) -> str:
    target = args.get('target_areas', '')
    days = args.get('days', 7)
    return f'[模拟] 已生成针对 "{target}" 的 {days} 天学习计划。注：完整实现依赖题库和弱项分析数据。'


def recommend_daily_problems(args: dict, context: dict) -> str:
    count = args.get('count', 5)
    return f'[模拟] 已推荐 {count} 道今日练习题。注：完整实现依赖用户训练历史和未做题目列表。'


def generate_similar_problem(args: dict, context: dict) -> str:
    from core.db import get_connection

    problem_id = args.get('problem_id')
    if not problem_id:
        return '错误：请提供 problem_id 参数。'

    db_url = context.get('database_url', '')
    connection = get_connection(db_url)
    with connection, connection.cursor() as cursor:
        cursor.execute(
            '''SELECT id, title, company, difficulty, category_slug, position, year,
                      statement_markdown, source_type
               FROM problems WHERE id = %s''',
            (problem_id,),
        )
        row = cursor.fetchone()
    connection.close()

    if not row:
        return f'未找到题目 #{problem_id}。'

    original = {
        'id': row['id'],
        'title': row['title'],
        'company': row['company'],
        'difficulty': row['difficulty'],
        'category_slug': row['category_slug'],
        'position': row['position'],
        'year': row['year'],
        'statement_markdown': row['statement_markdown'],
        'source_type': row['source_type'],
    }

    from services.llm_client import LLMClient
    from repositories.llm_settings_repository import LLMSettingsRepository

    settings_repo = LLMSettingsRepository(db_url)
    settings = settings_repo.get_settings()
    if not settings:
        return '错误：未配置 LLM 设置，请先在系统设置中配置。'

    api_key = settings_repo.get_api_key()
    model_name = settings.review_model or settings.solution_model or 'gpt-4.1-mini'
    temperature = settings.review_temperature or 0.5

    prompt = f"""你是一位算法竞赛命题专家。请参考以下题目，生成一道**同类型但内容不同**的算法题。

## 原题信息
- 标题：{original['title']}
- 公司：{original['company']}
- 岗位：{original['position'] or '未知'}
- 难度：{original['difficulty']}
- 题型分类：{original['category_slug']}
- 年度：{original['year'] or '未知'}

## 原题描述
{original['statement_markdown']}

## 要求
1. 保持相同题型和难度级别
2. 变换题目场景和具体数值，但算法核心思想一致
3. 生成完整的题目描述（含输入输出格式说明）
4. 提供 1-2 个样例（输入/输出/解释）
5. 新题目标题要有区分度，不要和原题重复

请按以下 JSON 格式输出：
```json
{{
  "title": "新题目标题",
  "difficulty": "{original['difficulty']}",
  "category_slug": "{original['category_slug']}",
  "statement_markdown": "完整的题目描述（Markdown格式，含输入描述、输出描述、样例）",
  "examples": [
    {{"input": "样例输入", "output": "样例输出", "explanation": "样例解释"}}
  ],
  "company": "{original['company']}",
  "position": "{original['position'] or '研发'}"
}}
```
只输出 JSON，不要其他内容。"""

    client = LLMClient()
    try:
        result = client.generate_json(settings, api_key, model_name, prompt, temperature)
        return json.dumps(result, ensure_ascii=False, indent=2)
    except Exception as exc:
        return f'生成失败：{exc}'
