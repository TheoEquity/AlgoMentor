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
        search: str | None = None,
        position: str | None = None,
        page: int = 1,
        page_size: int = 50,
    ) -> tuple[list[ProblemListItem], int]:
        conditions = [
            '(%s IS NULL OR company = %s)',
            '(%s IS NULL OR difficulty = %s)',
            '(%s IS NULL OR category_slug = %s)',
            '(%s IS NULL OR tags_json LIKE %s OR tags_json LIKE %s)',
            '(%s IS NULL OR position = %s)',
            '(%s IS NULL OR title ILIKE %s OR company ILIKE %s)',
        ]
        base_conditions = 'WHERE ' + ' AND '.join(conditions)
        tag_like = f'%{tag}%' if tag else None
        escaped_tag = json.dumps(tag).replace('\\', '\\\\') if tag else None
        tag_json_like = f'%{escaped_tag}%' if escaped_tag else None
        search_like = f'%{search}%' if search else None
        params = (
            company, company,
            difficulty, difficulty,
            category_slug, category_slug,
            tag, tag_like, tag_json_like,
            position, position,
            search, search_like, search_like,
        )

        connection = get_connection(self.database_url)
        with connection, connection.cursor() as cursor:
            cursor.execute(
                'SELECT COUNT(*) FROM problems ' + base_conditions,
                params,
            )
            total = cursor.fetchone()['count']

            offset = (page - 1) * page_size
            cursor.execute(
                'SELECT * FROM problems ' + base_conditions + ' ORDER BY updated_at DESC, id DESC LIMIT %s OFFSET %s',
                params + (page_size, offset),
            )
            rows = cursor.fetchall()
        connection.close()

        return [self._list_item_from_row(row) for row in rows], total

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

    def save_analysis(self, problem_id: int, analysis_json: str) -> None:
        connection = get_connection(self.database_url)
        with connection, connection.cursor() as cursor:
            cursor.execute(
                'UPDATE problems SET analysis_json = %s WHERE id = %s',
                (analysis_json, problem_id),
            )
        connection.close()

    def create_problem(self, payload: ProblemCreate) -> ProblemDetail:
        now = datetime.now(UTC).isoformat()
        slug = self._make_unique_slug(payload.slug)
        connection = get_connection(self.database_url)

        with connection, connection.cursor() as cursor:
            cursor.execute(
                '''
                INSERT INTO problems (
                    slug, title, company, position, difficulty, category_slug,
                    statement_markdown, constraints_text, tags_json,
                    examples_json, supported_languages_json, starter_templates_json,
                    source_type, source, frequency, year, source_ref, external_id,
                    status, time_limit_ms, memory_limit_kb, created_at, updated_at
                ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                RETURNING id
                ''',
                (
                    slug,
                    payload.title,
                    payload.company,
                    payload.position,
                    payload.difficulty,
                    payload.category_slug,
                    payload.statement_markdown,
                    payload.constraints_text,
                    json.dumps(payload.tags),
                    json.dumps([example.model_dump() for example in payload.examples]),
                    json.dumps(payload.supported_languages),
                    json.dumps(payload.starter_templates),
                    payload.source_type,
                    payload.source,
                    payload.frequency,
                    payload.year,
                    payload.source_ref,
                    payload.external_id,
                    payload.status,
                    payload.time_limit_ms,
                    payload.memory_limit_kb,
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

    def update_problem(self, problem_id: int, payload: ProblemCreate) -> ProblemDetail | None:
        now = datetime.now(UTC).isoformat()
        connection = get_connection(self.database_url)

        try:
            with connection, connection.cursor() as cursor:
                cursor.execute('SELECT id FROM problems WHERE id = %s', (problem_id,))
                if cursor.fetchone() is None:
                    return None

                cursor.execute(
                    '''
                    UPDATE problems
                    SET slug = %s,
                        title = %s,
                        company = %s,
                        position = %s,
                        difficulty = %s,
                        category_slug = %s,
                        statement_markdown = %s,
                        constraints_text = %s,
                        tags_json = %s,
                        examples_json = %s,
                        supported_languages_json = %s,
                        starter_templates_json = %s,
                        source_type = %s,
                        source = %s,
                        frequency = %s,
                        year = %s,
                        source_ref = %s,
                        external_id = %s,
                        status = %s,
                        time_limit_ms = %s,
                        memory_limit_kb = %s,
                        analysis_json = %s,
                        updated_at = %s
                    WHERE id = %s
                    ''',
                    (
                        payload.slug,
                        payload.title,
                        payload.company,
                        payload.position,
                        payload.difficulty,
                        payload.category_slug,
                        payload.statement_markdown,
                        payload.constraints_text,
                        json.dumps(payload.tags),
                        json.dumps([example.model_dump() for example in payload.examples]),
                        json.dumps(payload.supported_languages),
                        json.dumps(payload.starter_templates),
                        payload.source_type,
                        payload.source,
                        payload.frequency,
                        payload.year,
                        payload.source_ref,
                        payload.external_id,
                        payload.status,
                        payload.time_limit_ms,
                        payload.memory_limit_kb,
                        payload.analysis_json,
                        now,
                        problem_id,
                    ),
                )

                cursor.execute('DELETE FROM problem_test_cases WHERE problem_id = %s', (problem_id,))
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
        finally:
            connection.close()

        return self.get_problem(problem_id)

    def delete_problem(self, problem_id: int) -> bool:
        connection = get_connection(self.database_url)
        try:
            with connection, connection.cursor() as cursor:
                cursor.execute('SELECT id FROM problems WHERE id = %s', (problem_id,))
                if cursor.fetchone() is None:
                    return False

                cursor.execute('DELETE FROM error_attributions WHERE submission_id IN (SELECT id FROM submissions WHERE problem_id = %s)', (problem_id,))
                cursor.execute('DELETE FROM submissions WHERE problem_id = %s', (problem_id,))
                cursor.execute('DELETE FROM problem_test_cases WHERE problem_id = %s', (problem_id,))
                cursor.execute('DELETE FROM problems WHERE id = %s', (problem_id,))
            return True
        finally:
            connection.close()

    @staticmethod
    def _list_item_from_row(row: dict) -> ProblemListItem:
        return ProblemListItem(
            id=row['id'],
            slug=row['slug'],
            title=row['title'],
            company=row['company'] or '',
            position=row.get('position', ''),
            difficulty=row['difficulty'],
            category_slug=row['category_slug'],
            tags=json.loads(row['tags_json']),
            frequency=row['frequency'],
            year=row['year'],
            source=row['source'],
            supported_languages=json.loads(row['supported_languages_json']),
            status=row['status'],
            time_limit_ms=row.get('time_limit_ms', 2000),
            memory_limit_kb=row.get('memory_limit_kb', 262144),
            updated_at=row['updated_at'],
        )

    def _make_unique_slug(self, slug: str) -> str:
        import time
        connection = get_connection(self.database_url)
        base = slug or 'untitled-problem'
        candidate = base
        attempt = 1
        with connection, connection.cursor() as cursor:
            while True:
                cursor.execute('SELECT id FROM problems WHERE slug = %s', (candidate,))
                if cursor.fetchone() is None:
                    return candidate
                attempt += 1
                candidate = f'{base}-{attempt}'
        connection.close()

    @staticmethod
    def _detail_from_row(row: dict, test_case_rows: list[dict]) -> ProblemDetail:
        return ProblemDetail(
            id=row['id'],
            slug=row['slug'],
            title=row['title'],
            company=row['company'] or '',
            position=row.get('position', ''),
            difficulty=row['difficulty'],
            category_slug=row['category_slug'],
            statement_markdown=row['statement_markdown'],
            constraints_text=row['constraints_text'] or '',
            tags=json.loads(row['tags_json']),
            examples=[ExampleItem(**item) for item in json.loads(row['examples_json'])],
            supported_languages=json.loads(row['supported_languages_json']),
            starter_templates=json.loads(row['starter_templates_json']),
            source_type=row['source_type'],
            source=row['source'],
            frequency=row['frequency'],
            year=row['year'],
            source_ref=row['source_ref'],
            external_id=row['external_id'],
            status=row['status'],
            time_limit_ms=row.get('time_limit_ms', 2000),
            memory_limit_kb=row.get('memory_limit_kb', 262144),
            updated_at=row['updated_at'],
            analysis_json=row.get('analysis_json'),
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

    def distinct_companies(self) -> list[str]:
        connection = get_connection(self.database_url)
        with connection, connection.cursor() as cursor:
            cursor.execute("SELECT DISTINCT company FROM problems WHERE company IS NOT NULL AND company != '' ORDER BY company")
            rows = cursor.fetchall()
        connection.close()
        return [row['company'] for row in rows]

    def distinct_positions(self) -> list[str]:
        connection = get_connection(self.database_url)
        with connection, connection.cursor() as cursor:
            cursor.execute("SELECT DISTINCT position FROM problems WHERE position IS NOT NULL AND position != '' ORDER BY position")
            rows = cursor.fetchall()
        connection.close()
        return [row['position'] for row in rows]
