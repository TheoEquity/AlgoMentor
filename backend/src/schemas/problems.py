from __future__ import annotations

from typing import Literal

from pydantic import BaseModel, ConfigDict, Field


class ExampleItem(BaseModel):
    input: str
    output: str
    explanation: str = ''


class ProblemTestCase(BaseModel):
    case_type: Literal['sample', 'hidden']
    stdin_text: str
    expected_output_text: str
    sort_order: int = Field(ge=1)


class ProblemBase(BaseModel):
    model_config = ConfigDict(str_strip_whitespace=True)

    slug: str = Field(min_length=3)
    title: str = Field(min_length=2)
    company: str = Field(min_length=2)
    difficulty: Literal['Easy', 'Medium', 'Hard']
    category_slug: str = Field(default='')
    statement_markdown: str = Field(min_length=10)
    constraints_text: str = Field(default='')
    time_limit_ms: int = Field(default=2000, ge=200)
    memory_limit_kb: int = Field(default=262144, ge=16384)
    tags: list[str] = Field(min_length=1)
    examples: list[ExampleItem] = Field(default_factory=list)
    supported_languages: list[Literal['Python', 'C++', 'Java']] = Field(min_length=1)
    starter_templates: dict[str, str]
    source_type: str = 'manual'
    source: str = '手工'
    frequency: str = '中'
    year: int | None = None
    source_ref: str = ''
    external_id: str = ''
    status: Literal['未开始', '已通过', '待复盘', '待修正'] = '未开始'


class ProblemCreate(ProblemBase):
    test_cases: list[ProblemTestCase] = Field(min_length=1)


class ProblemListItem(BaseModel):
    id: int
    slug: str
    title: str
    company: str
    difficulty: str
    category_slug: str
    tags: list[str]
    frequency: str
    year: int | None = None
    source: str
    supported_languages: list[str]
    status: str
    time_limit_ms: int = 2000
    memory_limit_kb: int = 262144
    updated_at: str


class ProblemDetail(ProblemListItem):
    statement_markdown: str
    constraints_text: str = ''
    time_limit_ms: int = 2000
    memory_limit_kb: int = 262144
    starter_templates: dict[str, str]
    source_type: str | None = None
    source: str | None = None
    frequency: str | None = None
    year: int | None = None
    source_ref: str | None = None
    external_id: str | None = None
    examples: list[ExampleItem]
    test_cases: list[ProblemTestCase]
