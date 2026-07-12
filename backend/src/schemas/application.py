from __future__ import annotations

from pydantic import BaseModel, ConfigDict, Field


class JobPositionListItem(BaseModel):
    id: int
    resume_id: int | None = None
    company_name: str
    department: str = ''
    title: str
    location: str = ''
    position_type: str = ''
    position_category: str = ''
    industry_category: str = ''
    deadline: str = ''
    status: str
    status_date: str = ''
    notes: str = ''
    match_score: int = 0
    job_url: str = ''
    created_at: str
    updated_at: str


class JobPositionDetail(BaseModel):
    id: int
    resume_id: int | None = None
    company_name: str
    department: str = ''
    title: str
    location: str = ''
    position_type: str = ''
    position_category: str = ''
    industry_category: str = ''
    job_url: str = ''
    publish_date: str = ''
    deadline: str = ''
    job_description: str = ''
    job_requirements: str = ''
    job_preferences: str = ''
    status: str
    status_date: str = ''
    notes: str = ''
    apply_channel: str = ''
    match_score: int = 0
    match_detail: str = ''
    match_advice: str = ''
    created_at: str
    updated_at: str


class JobPositionCreate(BaseModel):
    model_config = ConfigDict(str_strip_whitespace=True)

    resume_id: int | None = None
    company_name: str = Field(min_length=1)
    department: str = ''
    title: str = Field(min_length=1)
    location: str = ''
    position_type: str = ''
    position_category: str = ''
    industry_category: str = ''
    job_url: str = ''
    publish_date: str = ''
    deadline: str = ''
    job_description: str = ''
    job_requirements: str = ''
    job_preferences: str = ''
    status: str = '待投递'
    status_date: str = ''
    notes: str = ''
    apply_channel: str = ''
    match_score: int = 0
    match_detail: str = ''
    match_advice: str = ''


class JobPositionUpdate(BaseModel):
    model_config = ConfigDict(str_strip_whitespace=True)

    company_name: str | None = None
    department: str | None = None
    title: str | None = None
    location: str | None = None
    position_type: str | None = None
    position_category: str | None = None
    industry_category: str | None = None
    job_url: str | None = None
    publish_date: str | None = None
    deadline: str | None = None
    job_description: str | None = None
    job_requirements: str | None = None
    job_preferences: str | None = None
    status: str | None = None
    status_date: str | None = None
    notes: str | None = None
    apply_channel: str | None = None
    match_score: int | None = None
    match_detail: str | None = None
    match_advice: str | None = None


class ExtractFromUrlRequest(BaseModel):
    url: str


class MatchAnalysisRequest(BaseModel):
    resume_id: int


class MatchAnalysisResponse(BaseModel):
    match_score: int = 0
    match_detail: str = ''
    match_advice: str = ''
