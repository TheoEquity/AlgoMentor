from __future__ import annotations

import json
from datetime import UTC, datetime
from sqlite3 import Row
from typing import Any

from core.db import get_connection
from schemas.problems import ExampleItem, ProblemCreate, ProblemDetail, ProblemListItem, ProblemTestCase


class ProblemRepository:
    def __init__(self, database_url: str):
        self.database_url = database_url

    def list_problems(
        self,
        *,
        company: str | None,
        department: str | None,
        difficulty: str | None,
        tag: str | None,
    ) -> list[ProblemListItem]:
        query = '''
            SELECT * FROM problems
            WHERE (? IS NULL OR company = ?)
              AND (? IS NULL OR department = ?)
              AND (? IS NULL OR difficulty = ?)
              AND (? IS NULL OR tags_json LIKE ? OR tags_json LIKE ?)
            ORDER BY updated_at DESC, id DESC
        '''
        tag_like = f'%{tag}%' if tag else None
        tag_json_like = f'%{json.dumps(tag)}%' if tag else None

        connection = get_connection(self.database_url)
        rows = connection.execute(
            query,
            (company, company, department, department, difficulty, difficulty, tag, tag_like, tag_json_like),
        ).fetchall()
        connection.close()

        return [self._list_item_from_row(row) for row in rows]

    def get_problem(self, problem_id: int) -> ProblemDetail | None:
        connection = get_connection(self.database_url)
        row = connection.execute('SELECT * FROM problems WHERE id = ?', (problem_id,)).fetchone()
        if row is None:
            connection.close()
            return None

        test_case_rows = connection.execute(
            'SELECT * FROM problem_test_cases WHERE problem_id = ? ORDER BY sort_order ASC',
            (problem_id,),
        ).fetchall()
        connection.close()

        return self._detail_from_row(row, test_case_rows)

    def create_problem(self, payload: ProblemCreate) -> ProblemDetail:
        now = datetime.now(UTC).isoformat()
        connection = get_connection(self.database_url)

        with connection:
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
                    payload.slug,
                    payload.title,
                    payload.company,
                    payload.department,
                    payload.difficulty,
                    payload.statement_markdown,
                    payload.constraints_text,
                    json.dumps(payload.tags),
                    json.dumps([example.model_dump() for example in payload.examples]),
                    json.dumps(payload.supported_languages),
                    json.dumps(payload.starter_templates),
                    payload.source_type,
                    payload.source_ref,
                    payload.external_id,
                    payload.status,
                    now,
                    now,
                ),
            )
            problem_id = cursor.lastrowid

            for test_case in payload.test_cases:
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
                        test_case.case_type,
                        test_case.stdin_text,
                        test_case.expected_output_text,
                        test_case.sort_order,
                    ),
                )

        connection.close()

        created_problem = self.get_problem(problem_id)
        if created_problem is None:
            raise RuntimeError('Failed to create problem')

        return created_problem

    def _list_item_from_row(self, row: Row) -> ProblemListItem:
        return ProblemListItem(
            id=row['id'],
            slug=row['slug'],
            title=row['title'],
            company=row['company'],
            department=row['department'],
            difficulty=row['difficulty'],
            tags=json.loads(row['tags_json']),
            supported_languages=json.loads(row['supported_languages_json']),
            status=row['status'],
            updated_at=row['updated_at'],
        )

    def _detail_from_row(self, row: Row, test_case_rows: list[Row]) -> ProblemDetail:
        return ProblemDetail(
            id=row['id'],
            slug=row['slug'],
            title=row['title'],
            company=row['company'],
            department=row['department'],
            difficulty=row['difficulty'],
            statement_markdown=row['statement_markdown'],
            constraints_text=row['constraints_text'],
            tags=json.loads(row['tags_json']),
            examples=[ExampleItem(**item) for item in json.loads(row['examples_json'])],
            supported_languages=json.loads(row['supported_languages_json']),
            starter_templates=json.loads(row['starter_templates_json']),
            source_type=row['source_type'],
            source_ref=row['source_ref'],
            external_id=row['external_id'],
            status=row['status'],
            updated_at=row['updated_at'],
            test_cases=[self._test_case_from_row(test_case_row) for test_case_row in test_case_rows],
        )

    def _test_case_from_row(self, row: Row) -> ProblemTestCase:
        return ProblemTestCase(
            case_type=row['case_type'],
            stdin_text=row['stdin_text'],
            expected_output_text=row['expected_output_text'],
            sort_order=row['sort_order'],
        )
