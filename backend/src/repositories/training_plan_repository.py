from __future__ import annotations

import json
from datetime import UTC, datetime

from core.db import get_connection
from schemas.training_plan import TrainingPlanCreate, TrainingPlanDetail, TrainingPlanItemDetail, TrainingPlanListItem


class TrainingPlanRepository:
    def __init__(self, database_url: str) -> None:
        self.database_url = database_url

    def list_plans(self) -> list[TrainingPlanListItem]:
        connection = get_connection(self.database_url)
        with connection, connection.cursor() as cursor:
            cursor.execute(
                'SELECT * FROM training_plans ORDER BY created_at DESC, id DESC',
            )
            rows = cursor.fetchall()
        connection.close()
        return [self._list_item_from_row(row) for row in rows]

    def get_plan(self, plan_id: int) -> TrainingPlanDetail | None:
        connection = get_connection(self.database_url)
        try:
            with connection, connection.cursor() as cursor:
                cursor.execute('SELECT * FROM training_plans WHERE id = %s', (plan_id,))
                row = cursor.fetchone()
                if row is None:
                    return None
                plan = self._list_item_from_row(row)

                cursor.execute(
                    '''SELECT pi.id, pi.problem_id, pi.sort_order, pi.status,
                              p.title, p.company, p.difficulty, p.category_slug, p.tags_json
                       FROM training_plan_items pi
                       JOIN problems p ON p.id = pi.problem_id
                       WHERE pi.plan_id = %s
                       ORDER BY pi.sort_order''',
                    (plan_id,),
                )
                item_rows = cursor.fetchall()
        finally:
            connection.close()

        return TrainingPlanDetail(
            **plan.model_dump(),
            items=[
                TrainingPlanItemDetail(
                    id=ir['id'],
                    problem_id=ir['problem_id'],
                    title=ir['title'],
                    company=ir['company'] or '',
                    difficulty=ir['difficulty'],
                    category_slug=ir['category_slug'],
                    tags=json.loads(ir['tags_json']),
                    sort_order=ir['sort_order'],
                    status=ir['status'],
                )
                for ir in item_rows
            ],
        )

    def create_plan(self, payload: TrainingPlanCreate) -> TrainingPlanDetail:
        now = datetime.now(UTC).isoformat()
        connection = get_connection(self.database_url)
        with connection, connection.cursor() as cursor:
            cursor.execute(
                '''INSERT INTO training_plans (
                    name, plan_type, duration_days, total_problems, created_at, updated_at
                ) VALUES (%s, %s, %s, %s, %s, %s) RETURNING id''',
                (payload.name, payload.plan_type, payload.duration_days, len(payload.problem_ids), now, now),
            )
            plan_id = cursor.fetchone()['id']

            for i, pid in enumerate(payload.problem_ids):
                cursor.execute(
                    '''INSERT INTO training_plan_items (plan_id, problem_id, sort_order)
                       VALUES (%s, %s, %s)
                       ON CONFLICT (plan_id, problem_id) DO NOTHING''',
                    (plan_id, pid, i + 1),
                )

        connection.close()
        return self.get_plan(plan_id)  # type: ignore[return-value]

    def delete_plan(self, plan_id: int) -> bool:
        connection = get_connection(self.database_url)
        with connection, connection.cursor() as cursor:
            cursor.execute('DELETE FROM training_plans WHERE id = %s', (plan_id,))
            deleted = cursor.rowcount > 0
        connection.close()
        return deleted

    def update_item_status(self, item_id: int, status: str) -> bool:
        connection = get_connection(self.database_url)
        with connection, connection.cursor() as cursor:
            cursor.execute(
                'UPDATE training_plan_items SET status = %s WHERE id = %s',
                (status, item_id),
            )
            updated = cursor.rowcount > 0

            if updated:
                cursor.execute(
                    '''SELECT plan_id FROM training_plan_items WHERE id = %s''',
                    (item_id,),
                )
                plan_id = cursor.fetchone()['plan_id']
                cursor.execute(
                    '''UPDATE training_plans SET
                        completed_count = (SELECT COUNT(*) FROM training_plan_items WHERE plan_id = %s AND status != '未开始'),
                        correct_count = (SELECT COUNT(*) FROM training_plan_items WHERE plan_id = %s AND status = '已通过'),
                        updated_at = %s
                       WHERE id = %s''',
                    (plan_id, plan_id, datetime.now(UTC).isoformat(), plan_id),
                )
        connection.close()
        return updated

    @staticmethod
    def _list_item_from_row(row: dict) -> TrainingPlanListItem:
        return TrainingPlanListItem(
            id=row['id'],
            name=row['name'],
            plan_type=row['plan_type'],
            duration_days=row['duration_days'],
            total_problems=row['total_problems'],
            completed_count=row['completed_count'],
            correct_count=row['correct_count'],
            created_at=row['created_at'],
            updated_at=row['updated_at'],
        )
