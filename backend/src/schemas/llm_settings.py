from __future__ import annotations

from typing import Literal

from pydantic import BaseModel, ConfigDict, Field


LLMProvider = Literal['OpenAI Compatible', 'Anthropic Compatible', 'Custom']


class LLMSettingsBase(BaseModel):
    model_config = ConfigDict(str_strip_whitespace=True)

    provider: LLMProvider = 'OpenAI Compatible'
    endpoint_url: str = Field(default='https://api.openai.com/v1')
    solution_model: str = Field(min_length=1, default='gpt-4.1-mini')
    vision_model: str = Field(min_length=1, default='gpt-4.1-mini')
    attribution_model: str = Field(min_length=1, default='gpt-4.1-mini')
    review_model: str = Field(min_length=1, default='gpt-4.1-mini')
    solution_temperature: float = Field(default=0.2, ge=0.0, le=2.0)
    attribution_temperature: float = Field(default=0.1, ge=0.0, le=2.0)
    review_temperature: float = Field(default=0.3, ge=0.0, le=2.0)
    enabled: bool = True


class LLMSettingsUpdate(LLMSettingsBase):
    api_key: str | None = None
    clear_api_key: bool = False


class LLMSettings(LLMSettingsBase):
    id: int
    api_key_configured: bool = False
    api_key_masked: str = ''
    updated_at: str
