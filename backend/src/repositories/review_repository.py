from __future__ import annotations

import json
from collections import Counter

from core.db import get_connection
from schemas.review import ReviewListItem, ReviewListResponse, ReviewSummary


class ReviewRepository:
    def __init__(self, database_url: str):
        self.database_url = database_url

    def list_reviews(
        self,
        *,
        wrong_only: bool,
        company: str | None,
        tag: str | None,
        error_type: str | None,
    ) -> ReviewListResponse:
        connection = get_connection(self.database_url)
        where_clauses: list[str] = []
        params: list[object] = []

        if wrong_only:
            where_clauses.append("s.verdict != 'AC'")
        if company:
            where_clauses.append('p.company = ?')
            params.append(company)
        if tag:
            where_clauses.append('(p.tags_json LIKE ? OR p.tags_json LIKE ?)')
            params.append(f'%"{tag}"%')
            params.append(f'%{json.dumps(tag)}%')
        if error_type:
            where_clauses.append('s.verdict = ?')
            params.append(error_type)

        where_sql = f"WHERE {' AND '.join(where_clauses)}" if where_clauses else ''
        rows = connection.execute(
            f'''
            SELECT
                s.id AS submission_id,
                s.problem_id,
                s.language,
                s.run_type,
                s.verdict,
                s.runtime_ms,
                s.memory_kb,
                s.failed_input,
                s.failed_expected_output,
                s.failed_actual_output,
                s.created_at,
                p.title,
                p.company,
                p.department,
                p.difficulty,
                p.tags_json
            FROM submissions s
            INNER JOIN problems p ON p.id = s.problem_id
            {where_sql}
            ORDER BY s.created_at DESC, s.id DESC
            LIMIT 100
            ''',
            tuple(params),
        ).fetchall()
        connection.close()

        items = [self._build_item(row) for row in rows]
        error_counter = Counter(item.error_type for item in items if item.error_type != 'AC')
        summary = ReviewSummary(
            total_submissions=len(items),
            wrong_submissions=sum(1 for item in items if item.verdict != 'AC'),
            ac_submissions=sum(1 for item in items if item.verdict == 'AC'),
            top_error_type=error_counter.most_common(1)[0][0] if error_counter else None,
        )
        return ReviewListResponse(summary=summary, items=items)

    def _build_item(self, row) -> ReviewListItem:
        tags = json.loads(row['tags_json'])
        return ReviewListItem(
            submission_id=row['submission_id'],
            problem_id=row['problem_id'],
            title=row['title'],
            company=row['company'],
            department=row['department'],
            difficulty=row['difficulty'],
            tags=tags,
            language=row['language'],
            run_type=row['run_type'],
            verdict=row['verdict'],
            error_type=row['verdict'],
            runtime_ms=row['runtime_ms'],
            memory_kb=row['memory_kb'],
            failed_case_summary=self._build_failed_case_summary(row),
            created_at=row['created_at'],
        )

    def _build_failed_case_summary(self, row) -> str:
        if row['verdict'] == 'AC':
            return '本次提交通过，可直接进入复盘提炼思路。'

        expected = (row['failed_expected_output'] or '').strip()
        actual = (row['failed_actual_output'] or '').strip()
        if expected or actual:
            return f'Expected: {expected or "<empty>"} | Actual: {actual or "<empty>"}'

        failed_input = (row['failed_input'] or '').strip()
        if failed_input:
            compact_input = failed_input.replace('\n', ' | ')
            return f'失败输入: {compact_input}'

        return '当前提交失败，适合打开详情继续定位。'
