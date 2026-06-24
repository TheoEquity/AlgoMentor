from __future__ import annotations

from typing import Literal

from pydantic import BaseModel, Field

from schemas.submissions import Language, RunType, Verdict


ReviewErrorType = Literal['AC', 'WA', 'RE', 'CE', 'TLE']


class ReviewSummary(BaseModel):
    total_submissions: int = Field(ge=0)
    wrong_submissions: int = Field(ge=0)
    ac_submissions: int = Field(ge=0)
    top_error_type: ReviewErrorType | None = None


class ReviewListItem(BaseModel):
    submission_id: int = Field(ge=1)
    problem_id: int = Field(ge=1)
    title: str
    company: str
    difficulty: str
    category_slug: str
    tags: list[str]
    language: Language
    run_type: RunType
    verdict: Verdict
    error_type: ReviewErrorType
    runtime_ms: int = Field(ge=0)
    memory_kb: int = Field(ge=0)
    failed_case_summary: str
    created_at: str


class ReviewListResponse(BaseModel):
    summary: ReviewSummary
    items: list[ReviewListItem]
