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
    department: str = Field(min_length=2)
    difficulty: Literal['Easy', 'Medium', 'Hard']
    statement_markdown: str = Field(min_length=10)
    constraints_text: str = Field(min_length=5)
    tags: list[str] = Field(min_length=1)
    examples: list[ExampleItem] = Field(min_length=1)
    supported_languages: list[Literal['Python', 'C++', 'Java']] = Field(min_length=1)
    starter_templates: dict[str, str]
    source_type: str = 'manual'
    source_ref: str = ''
    external_id: str = ''
    status: Literal['draft', 'published'] = 'published'


class ProblemCreate(ProblemBase):
    test_cases: list[ProblemTestCase] = Field(min_length=1)


class ProblemListItem(BaseModel):
    id: int
    slug: str
    title: str
    company: str
    department: str
    difficulty: str
    tags: list[str]
    supported_languages: list[str]
    status: str
    updated_at: str


class ProblemDetail(ProblemListItem):
    statement_markdown: str
    constraints_text: str
    starter_templates: dict[str, str]
    source_type: str | None = None
    source_ref: str | None = None
    external_id: str | None = None
    examples: list[ExampleItem]
    test_cases: list[ProblemTestCase]
