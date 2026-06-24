from __future__ import annotations

from core.db import get_connection
from schemas.problem_categories import CategoryCreate, CategoryUpdate, ProblemCategory


class ProblemCategoryRepository:
    def __init__(self, database_url: str) -> None:
        self._database_url = database_url

    def list_categories(self) -> list[ProblemCategory]:
        connection = get_connection(self._database_url)
        with connection, connection.cursor() as cursor:
            cursor.execute('SELECT * FROM problem_categories ORDER BY sort_order')
            rows = cursor.fetchall()
            return [ProblemCategory(**row) for row in rows]

    def create_category(self, payload: CategoryCreate) -> ProblemCategory:
        connection = get_connection(self._database_url)
        now = self._now()
        with connection, connection.cursor() as cursor:
            cursor.execute(
                'INSERT INTO problem_categories (name, slug, sort_order, created_at) VALUES (%s, %s, %s, %s) RETURNING id',
                (payload.name, payload.slug, payload.sort_order, now),
            )
            row = cursor.fetchone()
            return ProblemCategory(
                id=row['id'],
                name=payload.name,
                slug=payload.slug,
                sort_order=payload.sort_order,
                created_at=now,
            )

    def update_category(self, category_id: int, payload: CategoryUpdate) -> ProblemCategory | None:
        connection = get_connection(self._database_url)
        with connection, connection.cursor() as cursor:
            cursor.execute('SELECT * FROM problem_categories WHERE id = %s', (category_id,))
            existing = cursor.fetchone()
            if not existing:
                return None

            name = payload.name if payload.name is not None else existing['name']
            slug = payload.slug if payload.slug is not None else existing['slug']
            sort_order = payload.sort_order if payload.sort_order is not None else existing['sort_order']

            cursor.execute(
                'UPDATE problem_categories SET name = %s, slug = %s, sort_order = %s WHERE id = %s',
                (name, slug, sort_order, category_id),
            )
            cursor.execute('SELECT * FROM problem_categories WHERE id = %s', (category_id,))
            return ProblemCategory(**cursor.fetchone())

    def delete_category(self, category_id: int) -> bool:
        connection = get_connection(self._database_url)
        with connection, connection.cursor() as cursor:
            cursor.execute('DELETE FROM problem_categories WHERE id = %s', (category_id,))
            return cursor.rowcount > 0

    @staticmethod
    def _now() -> str:
        from datetime import datetime, timezone
        return datetime.now(timezone.utc).strftime('%Y-%m-%dT%H:%M:%SZ')
