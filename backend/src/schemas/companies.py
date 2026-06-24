from __future__ import annotations

from pydantic import BaseModel, ConfigDict, Field


class CompanyCreate(BaseModel):
    model_config = ConfigDict(str_strip_whitespace=True)

    name: str = Field(min_length=1, max_length=100)
    name_en: str = Field(default='', max_length=200)
    abbreviation: str = Field(default='', max_length=50)


class CompanyUpdate(BaseModel):
    model_config = ConfigDict(str_strip_whitespace=True)

    name: str | None = Field(default=None, min_length=1, max_length=100)
    name_en: str | None = Field(default=None, max_length=200)
    abbreviation: str | None = Field(default=None, max_length=50)


class Company(BaseModel):
    id: int
    name: str
    name_en: str
    abbreviation: str
    created_at: str
