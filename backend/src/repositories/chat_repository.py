from __future__ import annotations

from core.db import get_connection
from schemas.chat import ChatSession, ChatSessionCreate, ChatSessionUpdate, ChatMessage, ChatMessageCreate


class ChatRepository:
    def __init__(self, database_url: str) -> None:
        self._database_url = database_url

    def list_sessions(self, agent_id: int | None = None) -> list[ChatSession]:
        connection = get_connection(self._database_url)
        with connection, connection.cursor() as cursor:
            if agent_id is not None:
                cursor.execute(
                    'SELECT * FROM ai_chat_sessions WHERE agent_id = %s ORDER BY updated_at DESC',
                    (agent_id,),
                )
            else:
                cursor.execute('SELECT * FROM ai_chat_sessions ORDER BY updated_at DESC')
            rows = cursor.fetchall()
        connection.close()
        return [ChatSession(**row) for row in rows]

    def get_session(self, session_id: int) -> ChatSession | None:
        connection = get_connection(self._database_url)
        with connection, connection.cursor() as cursor:
            cursor.execute('SELECT * FROM ai_chat_sessions WHERE id = %s', (session_id,))
            row = cursor.fetchone()
        connection.close()
        if row is None:
            return None
        return ChatSession(**row)

    def create_session(self, payload: ChatSessionCreate) -> ChatSession:
        now = self._now()
        connection = get_connection(self._database_url)
        with connection, connection.cursor() as cursor:
            cursor.execute(
                '''INSERT INTO ai_chat_sessions (agent_id, title, problem_id, created_at, updated_at)
                   VALUES (%s, %s, %s, %s, %s) RETURNING id''',
                (payload.agent_id, payload.title, payload.problem_id, now, now),
            )
            row = cursor.fetchone()
        connection.close()
        return ChatSession(id=row['id'], agent_id=payload.agent_id, title=payload.title,
                           problem_id=payload.problem_id, created_at=now, updated_at=now)

    def find_by_problem(self, problem_id: int, agent_id: int) -> ChatSession | None:
        connection = get_connection(self._database_url)
        with connection, connection.cursor() as cursor:
            cursor.execute(
                'SELECT * FROM ai_chat_sessions WHERE problem_id = %s AND agent_id = %s ORDER BY updated_at DESC LIMIT 1',
                (problem_id, agent_id),
            )
            row = cursor.fetchone()
        connection.close()
        if row is None:
            return None
        return ChatSession(**row)

    def update_session(self, session_id: int, payload: ChatSessionUpdate) -> ChatSession | None:
        now = self._now()
        connection = get_connection(self._database_url)
        with connection, connection.cursor() as cursor:
            cursor.execute(
                'UPDATE ai_chat_sessions SET title = %s, updated_at = %s WHERE id = %s',
                (payload.title, now, session_id),
            )
        connection.close()
        return self.get_session(session_id)

    def delete_session(self, session_id: int) -> bool:
        connection = get_connection(self._database_url)
        with connection, connection.cursor() as cursor:
            cursor.execute('DELETE FROM ai_chat_sessions WHERE id = %s', (session_id,))
            deleted = cursor.rowcount > 0
        connection.close()
        return deleted

    def list_messages(self, session_id: int) -> list[ChatMessage]:
        connection = get_connection(self._database_url)
        with connection, connection.cursor() as cursor:
            cursor.execute(
                'SELECT * FROM ai_chat_messages WHERE session_id = %s ORDER BY id ASC',
                (session_id,),
            )
            rows = cursor.fetchall()
        connection.close()
        return [ChatMessage(**row) for row in rows]

    def create_message(self, session_id: int, payload: ChatMessageCreate) -> ChatMessage:
        now = self._now()
        connection = get_connection(self._database_url)
        with connection, connection.cursor() as cursor:
            cursor.execute(
                '''INSERT INTO ai_chat_messages (
                    session_id, role, content, tool_calls, tool_results, token_usage, created_at
                ) VALUES (%s, %s, %s, %s, %s, %s, %s) RETURNING id''',
                (session_id, payload.role, payload.content,
                 payload.tool_calls, payload.tool_results, payload.token_usage, now),
            )
            row = cursor.fetchone()
        connection.close()
        return ChatMessage(
            id=row['id'], session_id=session_id,
            role=payload.role, content=payload.content,
            tool_calls=payload.tool_calls, tool_results=payload.tool_results,
            token_usage=payload.token_usage, created_at=now,
        )

    @staticmethod
    def _now() -> str:
        from datetime import datetime, timezone
        return datetime.now(timezone.utc).strftime('%Y-%m-%dT%H:%M:%SZ')
