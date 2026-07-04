from __future__ import annotations

from pydantic import BaseModel, ConfigDict, Field


class SkillCreate(BaseModel):
    model_config = ConfigDict(str_strip_whitespace=True)

    slug: str = Field(min_length=1, max_length=64)
    name: str = Field(min_length=1, max_length=128)
    description: str = Field(default='')
    prompt_text: str = Field(min_length=1)
    is_enabled: bool = Field(default=True)


class SkillUpdate(BaseModel):
    model_config = ConfigDict(str_strip_whitespace=True)

    slug: str | None = Field(default=None, min_length=1, max_length=64)
    name: str | None = Field(default=None, min_length=1, max_length=128)
    description: str | None = None
    prompt_text: str | None = Field(default=None, min_length=1)
    is_enabled: bool | None = None


class SkillConfig(BaseModel):
    id: int
    slug: str
    name: str
    description: str
    prompt_text: str
    is_enabled: bool
    created_at: str
