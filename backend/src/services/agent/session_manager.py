from __future__ import annotations

from schemas.chat import ChatMessage
from repositories.chat_repository import ChatRepository


class SessionManager:
    def __init__(self, chat_repo: ChatRepository, llm_client) -> None:
        self._repo = chat_repo
        self._llm = llm_client
        self._max_window = 20

    def load_history(self, session_id: int) -> list[ChatMessage]:
        return self._repo.list_messages(session_id)

    def save_message(self, session_id: int, role: str, content: str,
                     tool_calls: str | None = None,
                     tool_results: str | None = None,
                     token_usage: str | None = None) -> ChatMessage:
        from schemas.chat import ChatMessageCreate
        payload = ChatMessageCreate(
            role=role,
            content=content,
            tool_calls=tool_calls,
            tool_results=tool_results,
            token_usage=token_usage,
        )
        return self._repo.create_message(session_id, payload)

    def build_context(self, messages: list[ChatMessage]) -> tuple[list[dict], str | None]:
        """Build message array with sliding window and optional summary compression."""
        if len(messages) <= self._max_window:
            history = []
            for msg in messages:
                entry = {'role': msg.role, 'content': msg.content}
                if msg.tool_calls:
                    entry['tool_calls'] = msg.tool_calls
                history.append(entry)
            return history, None

        recent = messages[-self._max_window:]
        older = messages[:-self._max_window]
        if not older:
            history = []
            for msg in recent:
                entry = {'role': msg.role, 'content': msg.content}
                history.append(entry)
            return history, None

        summary = self._summarize(older)
        history = []
        for msg in recent:
            entry = {'role': msg.role, 'content': msg.content}
            history.append(entry)
        return history, summary

    def _summarize(self, messages: list[ChatMessage]) -> str:
        texts = []
        for msg in messages:
            texts.append(f'{msg.role}: {msg.content[:300]}')
        combined = '\n'.join(texts[-50:])
        if not combined:
            return ''
        if len(combined) < 500:
            return combined
        return combined[:500] + '...'
