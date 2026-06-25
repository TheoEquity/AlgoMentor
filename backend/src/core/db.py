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
            CREATE TABLE IF NOT EXISTS problems (
                id SERIAL PRIMARY KEY,
                slug TEXT NOT NULL UNIQUE,
                title TEXT NOT NULL,
                company TEXT NOT NULL,
                difficulty TEXT NOT NULL,
                category_slug TEXT NOT NULL DEFAULT '',
                statement_markdown TEXT NOT NULL,
                constraints_text TEXT NOT NULL,
                tags_json TEXT NOT NULL,
                examples_json TEXT NOT NULL,
                supported_languages_json TEXT NOT NULL,
                starter_templates_json TEXT NOT NULL,
                source_type TEXT,
                source TEXT NOT NULL DEFAULT '手工',
                frequency TEXT NOT NULL DEFAULT '中',
                year INTEGER,
                source_ref TEXT,
                external_id TEXT,
                status TEXT NOT NULL DEFAULT '未开始',
                created_at TEXT NOT NULL,
                updated_at TEXT NOT NULL
            )
        ''')

        cursor.execute('''
            CREATE TABLE IF NOT EXISTS problem_test_cases (
                id SERIAL PRIMARY KEY,
                problem_id INTEGER NOT NULL REFERENCES problems(id),
                case_type TEXT NOT NULL,
                stdin_text TEXT NOT NULL,
                expected_output_text TEXT NOT NULL,
                sort_order INTEGER NOT NULL
            )
        ''')

        cursor.execute('''
            CREATE TABLE IF NOT EXISTS submissions (
                id SERIAL PRIMARY KEY,
                user_id INTEGER NOT NULL REFERENCES users(id),
                problem_id INTEGER NOT NULL REFERENCES problems(id),
                language TEXT NOT NULL,
                run_type TEXT NOT NULL,
                code_text TEXT NOT NULL,
                custom_input TEXT NOT NULL DEFAULT '',
                verdict TEXT NOT NULL,
                runtime_ms INTEGER NOT NULL DEFAULT 0,
                memory_kb INTEGER NOT NULL DEFAULT 0,
                compiler_output TEXT NOT NULL DEFAULT '',
                stderr_output TEXT NOT NULL DEFAULT '',
                failed_case_index INTEGER,
                failed_input TEXT,
                failed_expected_output TEXT,
                failed_actual_output TEXT,
                case_results_json TEXT NOT NULL DEFAULT '[]',
                judge_token TEXT,
                created_at TEXT NOT NULL
            )
        ''')

        cursor.execute('''
            CREATE TABLE IF NOT EXISTS error_attributions (
                id SERIAL PRIMARY KEY,
                submission_id INTEGER NOT NULL REFERENCES submissions(id),
                analysis_type TEXT NOT NULL,
                primary_category TEXT NOT NULL DEFAULT '',
                secondary_category TEXT NOT NULL DEFAULT '',
                summary TEXT NOT NULL DEFAULT '',
                suggestion TEXT NOT NULL DEFAULT '',
                bullets_json TEXT NOT NULL DEFAULT '[]',
                line_refs_json TEXT NOT NULL DEFAULT '[]',
                execution_status TEXT NOT NULL DEFAULT 'completed',
                status_reason TEXT NOT NULL DEFAULT '',
                provider TEXT NOT NULL DEFAULT '',
                model TEXT NOT NULL DEFAULT '',
                endpoint_url TEXT NOT NULL DEFAULT '',
                raw_response_json TEXT NOT NULL DEFAULT '',
                created_at TEXT NOT NULL
            )
        ''')

        cursor.execute('''
            CREATE TABLE IF NOT EXISTS llm_settings (
                id INTEGER PRIMARY KEY DEFAULT 1 CHECK (id = 1),
                provider TEXT NOT NULL,
                endpoint_url TEXT NOT NULL,
                solution_model TEXT NOT NULL,
                attribution_model TEXT NOT NULL,
                review_model TEXT NOT NULL,
                solution_temperature REAL NOT NULL,
                attribution_temperature REAL NOT NULL,
                review_temperature REAL NOT NULL,
                api_key_secret TEXT NOT NULL DEFAULT '',
                enabled INTEGER NOT NULL DEFAULT 1,
                updated_at TEXT NOT NULL
            )
        ''')

        cursor.execute('''
            CREATE TABLE IF NOT EXISTS companies (
                id SERIAL PRIMARY KEY,
                name TEXT NOT NULL,
                name_en TEXT NOT NULL DEFAULT '',
                abbreviation TEXT NOT NULL DEFAULT '',
                created_at TEXT NOT NULL
            )
        ''')

        cursor.execute('''
            CREATE TABLE IF NOT EXISTS problem_categories (
                id SERIAL PRIMARY KEY,
                name TEXT NOT NULL UNIQUE,
                slug TEXT NOT NULL UNIQUE,
                sort_order INTEGER NOT NULL DEFAULT 0,
                created_at TEXT NOT NULL
            )
        ''')

        cursor.execute('SELECT COUNT(*) AS count FROM users')
        if cursor.fetchone()['count'] == 0:
            cursor.execute(
                "INSERT INTO users (username, display_name, created_at) VALUES (%s, %s, %s)",
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
            "ALTER TABLE problems ADD COLUMN IF NOT EXISTS year INTEGER"
        )
        cursor.execute(
            "UPDATE problems SET status = '未开始' WHERE status IN ('published', 'draft')"
        )
        cursor.execute(
            "ALTER TABLE problems DROP COLUMN IF EXISTS department"
        )

        cursor.execute('SELECT COUNT(*) AS count FROM llm_settings')
        if cursor.fetchone()['count'] == 0:
            cursor.execute(
                '''
                INSERT INTO llm_settings (
                    id, provider, endpoint_url,
                    solution_model, attribution_model, review_model,
                    solution_temperature, attribution_temperature, review_temperature,
                    api_key_secret, enabled, updated_at
                ) VALUES (1, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                ''',
                (
                    'OpenAI Compatible',
                    'https://api.openai.com/v1',
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

        cursor.execute('SELECT COUNT(*) AS count FROM problem_categories')
        if cursor.fetchone()['count'] == 0:
            _seed_categories(cursor)

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
                status, created_at, updated_at
            ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
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
