from __future__ import annotations

from core.db import get_connection
from schemas.skill import SkillConfig, SkillCreate, SkillUpdate


class SkillRepository:
    def __init__(self, database_url: str) -> None:
        self._database_url = database_url

    def list_skills(self) -> list[SkillConfig]:
        connection = get_connection(self._database_url)
        with connection, connection.cursor() as cursor:
            cursor.execute('SELECT * FROM ai_skills ORDER BY id')
            rows = cursor.fetchall()
        connection.close()
        return [SkillConfig(**row) for row in rows]

    def get_skill(self, skill_id: int) -> SkillConfig | None:
        connection = get_connection(self._database_url)
        with connection, connection.cursor() as cursor:
            cursor.execute('SELECT * FROM ai_skills WHERE id = %s', (skill_id,))
            row = cursor.fetchone()
        connection.close()
        if row is None:
            return None
        return SkillConfig(**row)

    def create_skill(self, payload: SkillCreate) -> SkillConfig:
        now = self._now()
        connection = get_connection(self._database_url)
        with connection, connection.cursor() as cursor:
            cursor.execute(
                '''INSERT INTO ai_skills (
                    slug, name, description, prompt_text, created_at
                ) VALUES (%s, %s, %s, %s, %s) RETURNING id''',
                (payload.slug, payload.name, payload.description, payload.prompt_text, now),
            )
            row = cursor.fetchone()
        connection.close()
        return self.get_skill(row['id'])  # type: ignore[return-value]

    def update_skill(self, skill_id: int, payload: SkillUpdate) -> SkillConfig | None:
        connection = get_connection(self._database_url)
        with connection, connection.cursor() as cursor:
            cursor.execute('SELECT * FROM ai_skills WHERE id = %s', (skill_id,))
            existing = cursor.fetchone()
            if not existing:
                connection.close()
                return None

            updates = []
            params: list = []
            for field in ['slug', 'name', 'description', 'prompt_text', 'is_enabled']:
                val = getattr(payload, field, None)
                if val is not None:
                    updates.append(f'{field} = %s')
                    params.append(val)
            if updates:
                params.append(skill_id)
                cursor.execute(
                    f'UPDATE ai_skills SET {", ".join(updates)} WHERE id = %s',
                    params,
                )
        connection.close()
        return self.get_skill(skill_id)

    @staticmethod
    def _now() -> str:
        from datetime import datetime, timezone
        return datetime.now(timezone.utc).strftime('%Y-%m-%dT%H:%M:%SZ')
