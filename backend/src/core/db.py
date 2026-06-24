from __future__ import annotations

import sqlite3
from pathlib import Path

from data.seed_problems import SEED_PROBLEMS


def _database_path(database_url: str) -> Path:
    if not database_url.startswith('sqlite:///'):
        raise ValueError('Current MVP database layer supports sqlite URLs only.')

    raw_path = database_url.removeprefix('sqlite:///')
    return Path(raw_path).resolve()


def get_connection(database_url: str) -> sqlite3.Connection:
    connection = sqlite3.connect(_database_path(database_url))
    connection.row_factory = sqlite3.Row
    return connection


def _ensure_column(connection: sqlite3.Connection, table_name: str, column_name: str, definition: str) -> None:
    existing_columns = {
        row['name']
        for row in connection.execute(f'PRAGMA table_info({table_name})').fetchall()
    }
    if column_name not in existing_columns:
        connection.execute(f'ALTER TABLE {table_name} ADD COLUMN {column_name} {definition}')


def initialize_database(database_url: str) -> None:
    connection = get_connection(database_url)

    with connection:
        connection.executescript(
            '''
            CREATE TABLE IF NOT EXISTS problems (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                slug TEXT NOT NULL UNIQUE,
                title TEXT NOT NULL,
                company TEXT NOT NULL,
                department TEXT NOT NULL,
                difficulty TEXT NOT NULL,
                statement_markdown TEXT NOT NULL,
                constraints_text TEXT NOT NULL,
                tags_json TEXT NOT NULL,
                examples_json TEXT NOT NULL,
                supported_languages_json TEXT NOT NULL,
                starter_templates_json TEXT NOT NULL,
                source_type TEXT,
                source_ref TEXT,
                external_id TEXT,
                status TEXT NOT NULL DEFAULT 'draft',
                created_at TEXT NOT NULL,
                updated_at TEXT NOT NULL
            );

            CREATE TABLE IF NOT EXISTS problem_test_cases (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                problem_id INTEGER NOT NULL,
                case_type TEXT NOT NULL,
                stdin_text TEXT NOT NULL,
                expected_output_text TEXT NOT NULL,
                sort_order INTEGER NOT NULL,
                FOREIGN KEY(problem_id) REFERENCES problems(id)
            );

            CREATE TABLE IF NOT EXISTS submissions (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                problem_id INTEGER NOT NULL,
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
                attribution_analysis_json TEXT NOT NULL DEFAULT '',
                review_analysis_json TEXT NOT NULL DEFAULT '',
                created_at TEXT NOT NULL,
                FOREIGN KEY(problem_id) REFERENCES problems(id)
            );

            CREATE TABLE IF NOT EXISTS llm_settings (
                id INTEGER PRIMARY KEY CHECK (id = 1),
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
            );
            '''
        )

        _ensure_column(connection, 'llm_settings', 'api_key_secret', "TEXT NOT NULL DEFAULT ''")
        _ensure_column(connection, 'submissions', 'attribution_analysis_json', "TEXT NOT NULL DEFAULT ''")
        _ensure_column(connection, 'submissions', 'review_analysis_json', "TEXT NOT NULL DEFAULT ''")

        settings_count = connection.execute('SELECT COUNT(*) AS count FROM llm_settings').fetchone()['count']
        if settings_count == 0:
            connection.execute(
                '''
                INSERT INTO llm_settings (
                    id,
                    provider,
                    endpoint_url,
                    solution_model,
                    attribution_model,
                    review_model,
                    solution_temperature,
                    attribution_temperature,
                    review_temperature,
                    api_key_secret,
                    enabled,
                    updated_at
                ) VALUES (1, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
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

        problem_count = connection.execute('SELECT COUNT(*) AS count FROM problems').fetchone()['count']
        if problem_count == 0:
            _seed_database(connection)

    connection.close()


def _seed_database(connection: sqlite3.Connection) -> None:
    for problem in SEED_PROBLEMS:
        cursor = connection.execute(
            '''
            INSERT INTO problems (
                slug,
                title,
                company,
                department,
                difficulty,
                statement_markdown,
                constraints_text,
                tags_json,
                examples_json,
                supported_languages_json,
                starter_templates_json,
                source_type,
                source_ref,
                external_id,
                status,
                created_at,
                updated_at
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            ''',
            (
                problem['slug'],
                problem['title'],
                problem['company'],
                problem['department'],
                problem['difficulty'],
                problem['statement_markdown'],
                problem['constraints_text'],
                problem['tags_json'],
                problem['examples_json'],
                problem['supported_languages_json'],
                problem['starter_templates_json'],
                problem['source_type'],
                problem['source_ref'],
                problem['external_id'],
                problem['status'],
                problem['created_at'],
                problem['updated_at'],
            ),
        )

        problem_id = cursor.lastrowid
        for test_case in problem['test_cases']:
            connection.execute(
                '''
                INSERT INTO problem_test_cases (
                    problem_id,
                    case_type,
                    stdin_text,
                    expected_output_text,
                    sort_order
                ) VALUES (?, ?, ?, ?, ?)
                ''',
                (
                    problem_id,
                    test_case['case_type'],
                    test_case['stdin_text'],
                    test_case['expected_output_text'],
                    test_case['sort_order'],
                ),
            )
