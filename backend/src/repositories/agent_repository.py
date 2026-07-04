from __future__ import annotations

from core.db import get_connection
from schemas.agent import AgentConfig, AgentCreate, AgentUpdate


class AgentRepository:
    def __init__(self, database_url: str) -> None:
        self._database_url = database_url

    def list_agents(self, enabled_only: bool = False) -> list[AgentConfig]:
        connection = get_connection(self._database_url)
        with connection, connection.cursor() as cursor:
            if enabled_only:
                cursor.execute('SELECT * FROM ai_agents WHERE is_enabled = TRUE ORDER BY sort_order')
            else:
                cursor.execute('SELECT * FROM ai_agents ORDER BY sort_order')
            rows = cursor.fetchall()
        connection.close()
        return [self._row_to_config(row) for row in rows]

    def get_agent(self, agent_id: int) -> AgentConfig | None:
        return self.get_agent_by_id(agent_id)

    def get_agent_by_slug(self, slug: str) -> AgentConfig | None:
        connection = get_connection(self._database_url)
        with connection, connection.cursor() as cursor:
            cursor.execute('SELECT * FROM ai_agents WHERE slug = %s', (slug,))
            row = cursor.fetchone()
        connection.close()
        if row is None:
            return None
        return self._row_to_config(row)

    def get_agent_by_id(self, agent_id: int) -> AgentConfig | None:
        connection = get_connection(self._database_url)
        with connection, connection.cursor() as cursor:
            cursor.execute('SELECT * FROM ai_agents WHERE id = %s', (agent_id,))
            row = cursor.fetchone()
        connection.close()
        if row is None:
            return None
        return self._row_to_config(row)

    def create_agent(self, payload: AgentCreate) -> AgentConfig:
        now = self._now()
        connection = get_connection(self._database_url)
        with connection, connection.cursor() as cursor:
            cursor.execute(
                '''INSERT INTO ai_agents (
                    slug, name, description, icon, system_prompt, user_prompt_template,
                    model, temperature, max_tokens, max_iterations, is_enabled, sort_order,
                    created_at, updated_at
                ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s) RETURNING id''',
                (
                    payload.slug, payload.name, payload.description, payload.icon,
                    payload.system_prompt, payload.user_prompt_template,
                    payload.model, payload.temperature, payload.max_tokens, payload.max_iterations,
                    payload.is_enabled, payload.sort_order, now, now,
                ),
            )
            agent_id = cursor.fetchone()['id']
            self._sync_tools(cursor, agent_id, payload.tool_ids)
            self._sync_skills(cursor, agent_id, payload.skill_ids)
        connection.close()
        return self.get_agent_by_id(agent_id)  # type: ignore[return-value]

    def update_agent(self, agent_id: int, payload: AgentUpdate) -> AgentConfig | None:
        connection = get_connection(self._database_url)
        with connection, connection.cursor() as cursor:
            cursor.execute('SELECT * FROM ai_agents WHERE id = %s', (agent_id,))
            existing = cursor.fetchone()
            if not existing:
                connection.close()
                return None

            now = self._now()
            updates = []
            params: list = []
            for field in ['slug', 'name', 'description', 'icon', 'system_prompt',
                          'user_prompt_template', 'model', 'temperature', 'max_tokens',
                          'max_iterations', 'is_enabled', 'sort_order']:
                val = getattr(payload, field, None)
                if val is not None:
                    updates.append(f'{field} = %s')
                    params.append(val)
            if updates:
                updates.append('updated_at = %s')
                params.append(now)
                params.append(agent_id)
                cursor.execute(
                    f'UPDATE ai_agents SET {", ".join(updates)} WHERE id = %s',
                    params,
                )

            if payload.tool_ids is not None:
                self._sync_tools(cursor, agent_id, payload.tool_ids)
            if payload.skill_ids is not None:
                self._sync_skills(cursor, agent_id, payload.skill_ids)

        connection.close()
        return self.get_agent_by_id(agent_id)

    def delete_agent(self, agent_id: int) -> bool:
        connection = get_connection(self._database_url)
        with connection, connection.cursor() as cursor:
            cursor.execute('DELETE FROM ai_agent_tools WHERE agent_id = %s', (agent_id,))
            cursor.execute('DELETE FROM ai_agent_skills WHERE agent_id = %s', (agent_id,))
            cursor.execute('DELETE FROM ai_agents WHERE id = %s', (agent_id,))
            deleted = cursor.rowcount > 0
        connection.close()
        return deleted

    def _row_to_config(self, row: dict) -> AgentConfig:
        return AgentConfig(
            id=row['id'],
            slug=row['slug'],
            name=row['name'],
            description=row['description'],
            icon=row['icon'],
            system_prompt=row['system_prompt'],
            user_prompt_template=row['user_prompt_template'],
            model=row['model'],
            temperature=row['temperature'],
            max_tokens=row['max_tokens'],
            max_iterations=row['max_iterations'],
            is_enabled=row['is_enabled'],
            sort_order=row['sort_order'],
            created_at=row['created_at'],
            updated_at=row['updated_at'],
            tools=self._load_tools(row['id']),
            skills=self._load_skills(row['id']),
        )

    def _load_tools(self, agent_id: int) -> list:
        from schemas.tool import ToolConfig
        connection = get_connection(self._database_url)
        with connection, connection.cursor() as cursor:
            cursor.execute(
                '''SELECT t.* FROM ai_tools t
                   JOIN ai_agent_tools at ON t.id = at.tool_id
                   WHERE at.agent_id = %s ORDER BY t.id''',
                (agent_id,),
            )
            rows = cursor.fetchall()
        connection.close()
        return [ToolConfig(**row) for row in rows]

    def _load_skills(self, agent_id: int) -> list:
        from schemas.skill import SkillConfig
        connection = get_connection(self._database_url)
        with connection, connection.cursor() as cursor:
            cursor.execute(
                '''SELECT s.* FROM ai_skills s
                   JOIN ai_agent_skills sa ON s.id = sa.skill_id
                   WHERE sa.agent_id = %s ORDER BY s.id''',
                (agent_id,),
            )
            rows = cursor.fetchall()
        connection.close()
        return [SkillConfig(**row) for row in rows]

    @staticmethod
    def _sync_tools(cursor, agent_id: int, tool_ids: list[int]) -> None:
        cursor.execute('DELETE FROM ai_agent_tools WHERE agent_id = %s', (agent_id,))
        for tid in tool_ids:
            cursor.execute(
                'INSERT INTO ai_agent_tools (agent_id, tool_id) VALUES (%s, %s) ON CONFLICT DO NOTHING',
                (agent_id, tid),
            )

    @staticmethod
    def _sync_skills(cursor, agent_id: int, skill_ids: list[int]) -> None:
        cursor.execute('DELETE FROM ai_agent_skills WHERE agent_id = %s', (agent_id,))
        for sid in skill_ids:
            cursor.execute(
                'INSERT INTO ai_agent_skills (agent_id, skill_id) VALUES (%s, %s) ON CONFLICT DO NOTHING',
                (agent_id, sid),
            )

    @staticmethod
    def _now() -> str:
        from datetime import datetime, timezone
        return datetime.now(timezone.utc).strftime('%Y-%m-%dT%H:%M:%SZ')
