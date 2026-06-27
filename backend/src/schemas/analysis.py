from __future__ import annotations

from typing import Literal

from pydantic import BaseModel, ConfigDict, Field

from schemas.submissions import Verdict


class AnalysisLineRef(BaseModel):
    line: int = Field(ge=1)
    message: str
    severity: Literal['warning', 'error']


class SolutionAnalysisRequest(BaseModel):
    model_config = ConfigDict(str_strip_whitespace=True)

    problem_id: int = Field(ge=1)
    language: Literal['Python', 'C++', 'Java']
    code_text: str = Field(min_length=1)


class AttributionAnalysisRequest(BaseModel):
    submission_id: int = Field(ge=1)


class HintAnalysisRequest(BaseModel):
    model_config = ConfigDict(str_strip_whitespace=True)

    problem_id: int = Field(ge=1)
    language: Literal['Python', 'C++', 'Java']
    code_text: str = ''
    hint_step: int = Field(ge=1, le=6)
    hint_strength: Literal['light', 'medium', 'strong'] = 'light'
    submission_id: int | None = Field(default=None, ge=1)


class ProblemAnalysisRequest(BaseModel):
    problem_id: int = Field(ge=1)


class ProblemChatMessage(BaseModel):
    role: Literal['user', 'assistant']
    content: str = Field(min_length=1)


class ProblemChatRequest(BaseModel):
    model_config = ConfigDict(str_strip_whitespace=True)

    problem_id: int = Field(ge=1)
    messages: list[ProblemChatMessage] = Field(default_factory=list)
    question: str = Field(min_length=1)


class AnalysisResponse(BaseModel):
    analysis_type: Literal['solution', 'attribution', 'review', 'hint', 'problem_analysis', 'problem_qa']
    provider: str
    model: str
    endpoint_url: str
    execution_status: Literal['completed', 'degraded'] = 'completed'
    status_reason: str = ''
    primary_category: str = ''
    secondary_category: str = ''
    title: str
    summary: str
    bullets: list[str]
    line_refs: list[AnalysisLineRef]
    verdict: Verdict | None = None


class ErrorAttributionRecord(BaseModel):
    id: int
    submission_id: int
    analysis_type: Literal['solution', 'attribution', 'review']
    primary_category: str = ''
    secondary_category: str = ''
    summary: str = ''
    suggestion: str = ''
    bullets_json: str = '[]'
    line_refs_json: str = '[]'
    execution_status: Literal['completed', 'degraded'] = 'completed'
    status_reason: str = ''
    provider: str = ''
    model: str = ''
    endpoint_url: str = ''
    raw_response_json: str = ''
    created_at: str = ''


class ParseProblemRequest(BaseModel):
    model_config = ConfigDict(str_strip_whitespace=True)

    mode: Literal['text_only', 'image_only', 'text_plus_image'] = 'text_only'
    raw_text: str = ''
    image_data_url: str = ''
    image_name: str = ''


class ParsedExample(BaseModel):
    input: str
    output: str
    explanation: str = ''


class ParsedProblemResult(BaseModel):
    slug: str = ''
    title: str = ''
    company: str = ''
    difficulty: str = 'Medium'
    category_slug: str = ''
    statement_markdown: str = ''
    tags: list[str] = []
    time_limit_ms: int = 2000
    memory_limit_kb: int = 262144
    source: str = '手工'
    source_type: str = 'manual'
    frequency: str = '中'
    year: int | None = None
    source_ref: str = ''
    external_id: str = ''
    examples: list[ParsedExample] = []
    analysis: str = ''
