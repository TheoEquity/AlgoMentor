from __future__ import annotations

import json
from datetime import UTC, datetime

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
        category_slug: str | None,
        tag: str | None,
    ) -> list[ProblemListItem]:
        query = '''
            SELECT * FROM problems
            WHERE (%s IS NULL OR company = %s)
              AND (%s IS NULL OR difficulty = %s)
              AND (%s IS NULL OR category_slug = %s)
              AND (%s IS NULL OR tags_json LIKE %s OR tags_json LIKE %s)
            ORDER BY updated_at DESC, id DESC
        '''
        tag_like = f'%{tag}%' if tag else None
        escaped_tag = json.dumps(tag).replace('\\', '\\\\') if tag else None
        tag_json_like = f'%{escaped_tag}%' if escaped_tag else None

        connection = get_connection(self.database_url)
        with connection, connection.cursor() as cursor:
            cursor.execute(
                query,
                (
                    company, company,
                    difficulty, difficulty,
                    category_slug, category_slug,
                    tag, tag_like, tag_json_like,
                ),
            )
            rows = cursor.fetchall()
        connection.close()

        return [self._list_item_from_row(row) for row in rows]

    def get_problem(self, problem_id: int) -> ProblemDetail | None:
        connection = get_connection(self.database_url)
        try:
            with connection, connection.cursor() as cursor:
                cursor.execute('SELECT * FROM problems WHERE id = %s', (problem_id,))
                row = cursor.fetchone()
                if row is None:
                    return None

                cursor.execute(
                    'SELECT * FROM problem_test_cases WHERE problem_id = %s ORDER BY sort_order ASC',
                    (problem_id,),
                )
                test_case_rows = cursor.fetchall()

            return self._detail_from_row(row, test_case_rows)
        finally:
            connection.close()

    def create_problem(self, payload: ProblemCreate) -> ProblemDetail:
        now = datetime.now(UTC).isoformat()
        connection = get_connection(self.database_url)

        with connection, connection.cursor() as cursor:
            cursor.execute(
                '''
                INSERT INTO problems (
                    slug, title, company, difficulty, category_slug,
                    statement_markdown, constraints_text, tags_json,
                    examples_json, supported_languages_json, starter_templates_json,
                    source_type, source_ref, external_id,
                    status, created_at, updated_at
                ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                RETURNING id
                ''',
                (
                    payload.slug,
                    payload.title,
                    payload.company,
                    payload.difficulty,
                    payload.category_slug,
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
            problem_id = cursor.fetchone()['id']

            for test_case in payload.test_cases:
                cursor.execute(
                    '''
                    INSERT INTO problem_test_cases (
                        problem_id, case_type, stdin_text, expected_output_text, sort_order
                    ) VALUES (%s, %s, %s, %s, %s)
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

    @staticmethod
    def _list_item_from_row(row: dict) -> ProblemListItem:
        return ProblemListItem(
            id=row['id'],
            slug=row['slug'],
            title=row['title'],
            company=row['company'],
            difficulty=row['difficulty'],
            category_slug=row['category_slug'],
            tags=json.loads(row['tags_json']),
            supported_languages=json.loads(row['supported_languages_json']),
            status=row['status'],
            updated_at=row['updated_at'],
        )

    @staticmethod
    def _detail_from_row(row: dict, test_case_rows: list[dict]) -> ProblemDetail:
        return ProblemDetail(
            id=row['id'],
            slug=row['slug'],
            title=row['title'],
            company=row['company'],
            difficulty=row['difficulty'],
            category_slug=row['category_slug'],
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
            test_cases=[ProblemRepository._test_case_from_row(tcr) for tcr in test_case_rows],
        )

    @staticmethod
    def _test_case_from_row(row: dict) -> ProblemTestCase:
        return ProblemTestCase(
            case_type=row['case_type'],
            stdin_text=row['stdin_text'],
            expected_output_text=row['expected_output_text'],
            sort_order=row['sort_order'],
        )
