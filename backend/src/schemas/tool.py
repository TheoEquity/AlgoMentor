from __future__ import annotations

import json

from pydantic import BaseModel, ConfigDict, Field, field_validator


def _ensure_json_str(v: object) -> str:
    if isinstance(v, str):
        return v
    return json.dumps(v, ensure_ascii=False)


class ToolCreate(BaseModel):
    model_config = ConfigDict(str_strip_whitespace=True)

    slug: str = Field(min_length=1, max_length=64)
    name: str = Field(min_length=1, max_length=128)
    description: str = Field(default='')
    parameters_schema: str = Field(default='{}')
    handler_type: str = Field(default='python_function', max_length=32)
    handler_config: str = Field(default='{}')
    is_enabled: bool = Field(default=True)

    @field_validator('parameters_schema')
    @classmethod
    def validate_schema_json(cls, v: str) -> str:
        json.loads(v)
        return v

    @field_validator('handler_config')
    @classmethod
    def validate_config_json(cls, v: str) -> str:
        json.loads(v)
        return v


class ToolUpdate(BaseModel):
    model_config = ConfigDict(str_strip_whitespace=True)

    slug: str | None = Field(default=None, min_length=1, max_length=64)
    name: str | None = Field(default=None, min_length=1, max_length=128)
    description: str | None = None
    parameters_schema: str | None = None
    handler_type: str | None = Field(default=None, max_length=32)
    handler_config: str | None = None
    is_enabled: bool | None = None


class ToolConfig(BaseModel):
    id: int
    slug: str
    name: str
    description: str
    parameters_schema: str
    handler_type: str
    handler_config: str
    is_enabled: bool
    created_at: str

    @field_validator('parameters_schema', 'handler_config', mode='before')
    @classmethod
    def coerce_jsonb_fields(cls, v: object) -> str:
        return _ensure_json_str(v)
