from __future__ import annotations

from core.db import get_connection
from schemas.tool import ToolConfig, ToolCreate, ToolUpdate


class ToolRepository:
    def __init__(self, database_url: str) -> None:
        self._database_url = database_url

    def list_tools(self) -> list[ToolConfig]:
        connection = get_connection(self._database_url)
        with connection, connection.cursor() as cursor:
            cursor.execute('SELECT * FROM ai_tools ORDER BY id')
            rows = cursor.fetchall()
        connection.close()
        return [ToolConfig(**row) for row in rows]

    def get_tool(self, tool_id: int) -> ToolConfig | None:
        connection = get_connection(self._database_url)
        with connection, connection.cursor() as cursor:
            cursor.execute('SELECT * FROM ai_tools WHERE id = %s', (tool_id,))
            row = cursor.fetchone()
        connection.close()
        if row is None:
            return None
        return ToolConfig(**row)

    def create_tool(self, payload: ToolCreate) -> ToolConfig:
        now = self._now()
        connection = get_connection(self._database_url)
        with connection, connection.cursor() as cursor:
            cursor.execute(
                '''INSERT INTO ai_tools (
                    slug, name, description, parameters_schema, handler_type, handler_config, created_at
                ) VALUES (%s, %s, %s, %s, %s, %s, %s) RETURNING id''',
                (payload.slug, payload.name, payload.description,
                 payload.parameters_schema, payload.handler_type, payload.handler_config, now),
            )
            row = cursor.fetchone()
        connection.close()
        return self.get_tool(row['id'])  # type: ignore[return-value]

    def update_tool(self, tool_id: int, payload: ToolUpdate) -> ToolConfig | None:
        connection = get_connection(self._database_url)
        with connection, connection.cursor() as cursor:
            cursor.execute('SELECT * FROM ai_tools WHERE id = %s', (tool_id,))
            existing = cursor.fetchone()
            if not existing:
                connection.close()
                return None

            updates = []
            params: list = []
            for field in ['slug', 'name', 'description', 'parameters_schema',
                          'handler_type', 'handler_config', 'is_enabled']:
                val = getattr(payload, field, None)
                if val is not None:
                    updates.append(f'{field} = %s')
                    params.append(val)
            if updates:
                params.append(tool_id)
                cursor.execute(
                    f'UPDATE ai_tools SET {", ".join(updates)} WHERE id = %s',
                    params,
                )
        connection.close()
        return self.get_tool(tool_id)

    @staticmethod
    def _now() -> str:
        from datetime import datetime, timezone
        return datetime.now(timezone.utc).strftime('%Y-%m-%dT%H:%M:%SZ')
