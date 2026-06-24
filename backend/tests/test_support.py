from __future__ import annotations

import json
import sqlite3
import sys
import tempfile
from pathlib import Path


SRC_DIR = Path(__file__).resolve().parents[1] / 'src'
if str(SRC_DIR) not in sys.path:
    sys.path.insert(0, str(SRC_DIR))

from core.db import get_connection, initialize_database


class TemporaryDatabase:
    def __init__(self):
        self._tmpdir = tempfile.TemporaryDirectory()
        self.database_path = Path(self._tmpdir.name) / 'bytehunter-test.db'
        self.database_url = f'sqlite:///{self.database_path}'
        initialize_database(self.database_url)

    def close(self) -> None:
        self._tmpdir.cleanup()

    def connection(self) -> sqlite3.Connection:
        return get_connection(self.database_url)


def insert_submission(
    database_url: str,
    *,
    problem_id: int,
    language: str,
    run_type: str,
    verdict: str,
    created_at: str,
    runtime_ms: int = 10,
    memory_kb: int = 1024,
    failed_input: str = '',
    failed_expected_output: str = '',
    failed_actual_output: str = '',
) -> int:
    connection = get_connection(database_url)
    with connection:
        cursor = connection.execute(
            '''
            INSERT INTO submissions (
                problem_id,
                language,
                run_type,
                code_text,
                custom_input,
                verdict,
                runtime_ms,
                memory_kb,
                compiler_output,
                stderr_output,
                failed_case_index,
                failed_input,
                failed_expected_output,
                failed_actual_output,
                case_results_json,
                created_at
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            ''',
            (
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
                created_at,
            ),
        )
        submission_id = int(cursor.lastrowid)
    connection.close()
    return submission_id
