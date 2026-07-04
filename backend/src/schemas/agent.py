from __future__ import annotations

from pydantic import BaseModel, ConfigDict, Field


class AgentCreate(BaseModel):
    model_config = ConfigDict(str_strip_whitespace=True)

    slug: str = Field(min_length=1, max_length=64)
    name: str = Field(min_length=1, max_length=128)
    description: str = Field(default='')
    icon: str = Field(default='bot', max_length=32)
    system_prompt: str = Field(default='')
    user_prompt_template: str = Field(default='')
    model: str = Field(default='gpt-4.1-mini', max_length=128)
    temperature: float = Field(default=0.2, ge=0.0, le=2.0)
    max_tokens: int = Field(default=2048, ge=1, le=32768)
    max_iterations: int = Field(default=10, ge=1, le=50)
    is_enabled: bool = Field(default=True)
    sort_order: int = Field(default=0, ge=0)
    tool_ids: list[int] = Field(default_factory=list)
    skill_ids: list[int] = Field(default_factory=list)


class AgentUpdate(BaseModel):
    model_config = ConfigDict(str_strip_whitespace=True)

    slug: str | None = Field(default=None, min_length=1, max_length=64)
    name: str | None = Field(default=None, min_length=1, max_length=128)
    description: str | None = None
    icon: str | None = Field(default=None, max_length=32)
    system_prompt: str | None = None
    user_prompt_template: str | None = None
    model: str | None = Field(default=None, max_length=128)
    temperature: float | None = Field(default=None, ge=0.0, le=2.0)
    max_tokens: int | None = Field(default=None, ge=1, le=32768)
    max_iterations: int | None = Field(default=None, ge=1, le=50)
    is_enabled: bool | None = None
    sort_order: int | None = Field(default=None, ge=0)
    tool_ids: list[int] | None = None
    skill_ids: list[int] | None = None


class AgentConfig(BaseModel):
    id: int
    slug: str
    name: str
    description: str
    icon: str
    system_prompt: str
    user_prompt_template: str
    model: str
    temperature: float
    max_tokens: int
    max_iterations: int
    is_enabled: bool
    sort_order: int
    created_at: str
    updated_at: str
    tools: list = Field(default_factory=list)
    skills: list = Field(default_factory=list)
