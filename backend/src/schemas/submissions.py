from __future__ import annotations

from typing import Literal

from pydantic import BaseModel, ConfigDict, Field


Language = Literal['Python', 'C++', 'Java']
RunType = Literal['run', 'submit']
Verdict = Literal['AC', 'WA', 'RE', 'CE', 'TLE', 'PENDING']


class SubmissionCaseResult(BaseModel):
    case_index: int = Field(ge=1)
    case_type: Literal['sample', 'hidden']
    stdin_text: str
    expected_output_text: str
    actual_output_text: str
    verdict: Verdict
    runtime_ms: int = Field(ge=0)
    memory_kb: int = Field(ge=0)
    stderr_output: str = ''


class SubmissionCreate(BaseModel):
    model_config = ConfigDict(str_strip_whitespace=True)

    problem_id: int = Field(ge=1)
    language: Language
    run_type: RunType = 'submit'
    code_text: str = Field(min_length=1)
    custom_input: str = ''


class SubmissionAnalysisLineRef(BaseModel):
    line: int = Field(ge=1)
    message: str
    severity: Literal['warning', 'error']


class SubmissionAnalysisSnapshot(BaseModel):
    analysis_type: Literal['solution', 'attribution', 'review']
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
    line_refs: list[SubmissionAnalysisLineRef]
    verdict: Verdict | None = None


class SubmissionResult(BaseModel):
    id: int
    user_id: int
    problem_id: int
    language: Language
    run_type: RunType
    code_text: str
    verdict: Verdict
    runtime_ms: int = Field(ge=0)
    memory_kb: int = Field(ge=0)
    compiler_output: str = ''
    stderr_output: str = ''
    failed_case_index: int | None = None
    failed_input: str | None = None
    failed_expected_output: str | None = None
    failed_actual_output: str | None = None
    case_results: list[SubmissionCaseResult]
    judge_token: str | None = None
    attribution_analysis: SubmissionAnalysisSnapshot | None = None
    review_analysis: SubmissionAnalysisSnapshot | None = None
    created_at: str
