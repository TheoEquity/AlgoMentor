from __future__ import annotations

import json

from pydantic import BaseModel, ConfigDict, Field, field_validator


def _to_json_str(v: object) -> str | None:
    if v is None:
        return None
    if isinstance(v, str):
        return v
    return json.dumps(v, ensure_ascii=False)


class ChatSessionCreate(BaseModel):
    agent_id: int
    title: str = Field(default='New Chat', max_length=256)
    problem_id: int | None = None


class ChatSessionUpdate(BaseModel):
    title: str = Field(min_length=1, max_length=256)
    problem_id: int | None = None


class ChatSession(BaseModel):
    id: int
    agent_id: int
    title: str
    problem_id: int | None = None
    created_at: str
    updated_at: str


class CreateProblemSessionRequest(BaseModel):
    problem_id: int = Field(ge=1)
    agent_slug: str = Field(default='chat-agent')
    title: str | None = None


class ChatMessageCreate(BaseModel):
    role: str = Field(min_length=1, max_length=32)
    content: str
    tool_calls: str | None = None
    tool_results: str | None = None
    token_usage: str | None = None

    @field_validator('tool_calls', 'tool_results', 'token_usage', mode='before')
    @classmethod
    def coerce_jsonb_fields(cls, v: object) -> str | None:
        return _to_json_str(v)


class ChatMessage(BaseModel):
    id: int
    session_id: int
    role: str
    content: str
    tool_calls: str | None = None
    tool_results: str | None = None
    token_usage: str | None = None
    created_at: str

    @field_validator('tool_calls', 'tool_results', 'token_usage', mode='before')
    @classmethod
    def coerce_jsonb_fields(cls, v: object) -> str | None:
        return _to_json_str(v)


class ChatRequest(BaseModel):
    query: str = Field(min_length=1)
    context: dict | None = None
