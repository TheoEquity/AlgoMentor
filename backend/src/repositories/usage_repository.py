from __future__ import annotations

from core.db import get_connection
from schemas.agent_run import UsageSummary


class UsageRepository:
    def __init__(self, database_url: str) -> None:
        self._database_url = database_url

    def log_usage(
        self,
        agent_slug: str,
        model: str,
        prompt_tokens: int,
        completion_tokens: int,
        total_tokens: int,
        tool_calls_count: int,
        duration_ms: int,
    ) -> None:
        now = self._now()
        connection = get_connection(self._database_url)
        with connection, connection.cursor() as cursor:
            cursor.execute(
                '''INSERT INTO ai_usage_logs (
                    agent_slug, model, prompt_tokens, completion_tokens, total_tokens,
                    tool_calls_count, duration_ms, created_at
                ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s)''',
                (agent_slug, model, prompt_tokens, completion_tokens, total_tokens,
                 tool_calls_count, duration_ms, now),
            )
        connection.close()

    def query_usage(
        self, agent_slug: str | None = None, from_date: str | None = None, to_date: str | None = None,
    ) -> list[UsageSummary]:
        connection = get_connection(self._database_url)
        conditions = ['1=1']
        params: list = []

        if agent_slug:
            conditions.append('agent_slug = %s')
            params.append(agent_slug)
        if from_date:
            conditions.append('created_at >= %s')
            params.append(from_date)
        if to_date:
            conditions.append('created_at <= %s')
            params.append(to_date)

        where = ' AND '.join(conditions)
        with connection, connection.cursor() as cursor:
            cursor.execute(
                f'''SELECT agent_slug, model,
                           COUNT(*) as total_requests,
                           SUM(prompt_tokens) as total_prompt_tokens,
                           SUM(completion_tokens) as total_completion_tokens,
                           SUM(total_tokens) as total_tokens,
                           SUM(tool_calls_count) as total_tool_calls,
                           AVG(duration_ms) as avg_duration_ms
                    FROM ai_usage_logs
                    WHERE {where}
                    GROUP BY agent_slug, model
                    ORDER BY agent_slug''',
                params,
            )
            rows = cursor.fetchall()
        connection.close()
        return [UsageSummary(
            agent_slug=row['agent_slug'],
            model=row['model'],
            total_requests=row['total_requests'],
            total_prompt_tokens=row['total_prompt_tokens'],
            total_completion_tokens=row['total_completion_tokens'],
            total_tokens=row['total_tokens'],
            total_tool_calls=row['total_tool_calls'],
            avg_duration_ms=round(row['avg_duration_ms'], 1),
        ) for row in rows]

    @staticmethod
    def _now() -> str:
        from datetime import datetime, timezone
        return datetime.now(timezone.utc).strftime('%Y-%m-%dT%H:%M:%SZ')
