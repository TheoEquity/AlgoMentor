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


class AnalysisResponse(BaseModel):
    analysis_type: Literal['solution', 'attribution', 'review']
    provider: str
    model: str
    endpoint_url: str
    execution_status: Literal['completed', 'degraded'] = 'completed'
    status_reason: str = ''
    title: str
    summary: str
    bullets: list[str]
    line_refs: list[AnalysisLineRef]
    verdict: Verdict | None = None
