from __future__ import annotations

from enum import StrEnum

from pydantic import BaseModel, Field


class SSEEventType(StrEnum):
    META = 'meta'
    THINKING = 'thinking'
    TOOL_CALL = 'tool_call'
    TOOL_RESULT = 'tool_result'
    CONTENT = 'content'
    STATUS = 'status'
    DONE = 'done'
    ERROR = 'error'


class AgentRunRequest(BaseModel):
    context: dict = Field(default_factory=dict)
    history: list[dict] | None = None


class ToolCallTrace(BaseModel):
    name: str
    arguments: dict
    result: str
    duration_ms: int


class TokenUsage(BaseModel):
    prompt_tokens: int = 0
    completion_tokens: int = 0
    total_tokens: int = 0


class AgentRunResult(BaseModel):
    content: str
    tool_calls_trace: list[ToolCallTrace] = Field(default_factory=list)
    token_usage: TokenUsage = Field(default_factory=TokenUsage)
    iterations: int = 0
    duration_ms: int = 0


class UsageQuery(BaseModel):
    agent: str | None = None
    from_date: str | None = None
    to_date: str | None = None


class UsageSummary(BaseModel):
    agent_slug: str
    model: str
    total_requests: int
    total_prompt_tokens: int
    total_completion_tokens: int
    total_tokens: int
    total_tool_calls: int
    avg_duration_ms: float
