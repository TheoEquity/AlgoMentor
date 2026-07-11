from __future__ import annotations

from pydantic import BaseModel, ConfigDict, Field


class CandidatePositionItem(BaseModel):
    id: int
    resume_id: int | None = None
    company_name: str
    title: str
    location: str = ''
    description: str = ''
    apply_url: str = ''
    degree_requirement: str = ''
    match_score: int = 0
    match_reason: str = ''
    source_type: str
    site_id: int | None = None
    source_position_id: int | None = None
    status: str
    created_at: str
    updated_at: str


class CandidatePositionCreate(BaseModel):
    model_config = ConfigDict(str_strip_whitespace=True)

    resume_id: int | None = None
    company_name: str = Field(min_length=1)
    title: str = Field(min_length=1)
    location: str = ''
    description: str = ''
    apply_url: str = ''
    degree_requirement: str = ''
    match_score: int = 0
    match_reason: str = ''
    site_id: int | None = None
    source_position_id: int | None = None


class CandidatePositionUpdate(BaseModel):
    model_config = ConfigDict(str_strip_whitespace=True)

    company_name: str | None = None
    title: str | None = None
    location: str | None = None
    description: str | None = None
    apply_url: str | None = None
    degree_requirement: str | None = None
    match_score: int | None = None
    match_reason: str | None = None
    status: str | None = None


class ExtractFromSiteRequest(BaseModel):
    site_id: int
    resume_id: int


class ExtractedPositionResult(BaseModel):
    source_position_id: int
    company_name: str
    title: str
    department: str = ''
    location: str
    description: str
    apply_url: str
    degree_requirement: str
    deadline: str = ''
    score: int
    reason: str


class ExtractFromSiteResponse(BaseModel):
    ok: bool
    results: list[ExtractedPositionResult]
