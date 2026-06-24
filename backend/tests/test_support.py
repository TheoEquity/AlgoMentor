from __future__ import annotations

import json
import sys
from pathlib import Path


SRC_DIR = Path(__file__).resolve().parents[1] / 'src'
if str(SRC_DIR) not in sys.path:
    sys.path.insert(0, str(SRC_DIR))

from core.db import get_connection, initialize_database

TEST_DATABASE_URL = 'postgresql://bytehunter:bytehunter123@localhost:5432/bytehunter_test'


def reset_test_database() -> None:
    connection = get_connection(TEST_DATABASE_URL)
    with connection, connection.cursor() as cursor:
        cursor.execute('DROP TABLE IF EXISTS error_attributions CASCADE')
        cursor.execute('DROP TABLE IF EXISTS submissions CASCADE')
        cursor.execute('DROP TABLE IF EXISTS problem_test_cases CASCADE')
        cursor.execute('DROP TABLE IF EXISTS problems CASCADE')
        cursor.execute('DROP TABLE IF EXISTS companies CASCADE')
        cursor.execute('DROP TABLE IF EXISTS problem_categories CASCADE')
        cursor.execute('DROP TABLE IF EXISTS llm_settings CASCADE')
        cursor.execute('DROP TABLE IF EXISTS users CASCADE')
    connection.close()
    initialize_database(TEST_DATABASE_URL)


def insert_submission(
    *,
    problem_id: int,
    language: str,
    run_type: str,
    verdict: str,
    created_at: str,
    user_id: int = 1,
    runtime_ms: int = 10,
    memory_kb: int = 1024,
    failed_input: str = '',
    failed_expected_output: str = '',
    failed_actual_output: str = '',
    judge_token: str | None = None,
) -> int:
    connection = get_connection(TEST_DATABASE_URL)
    with connection, connection.cursor() as cursor:
        cursor.execute(
            '''
            INSERT INTO submissions (
                user_id, problem_id, language, run_type, code_text, custom_input,
                verdict, runtime_ms, memory_kb, compiler_output, stderr_output,
                failed_case_index, failed_input, failed_expected_output, failed_actual_output,
                case_results_json, judge_token, created_at
            ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
            RETURNING id
            ''',
            (
                user_id,
                problem_id,
                language,
                run_type,
                '// test code',
                '',
                verdict,
                runtime_ms,
                memory_kb,
                '',
                '',
                1 if verdict != 'AC' else None,
                failed_input,
                failed_expected_output,
                failed_actual_output,
                json.dumps([]),
                judge_token,
                created_at,
            ),
        )
        submission_id = cursor.fetchone()['id']
    connection.close()
    return submission_id
