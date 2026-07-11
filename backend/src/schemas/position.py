from __future__ import annotations

from pydantic import BaseModel, ConfigDict


class RecruitmentPositionListItem(BaseModel):
    id: int
    site_id: int
    company_name: str = ''
    title: str
    location: str | None = None
    department: str = ''
    deadline: str = ''
    degree_requirement: str | None = None
    position_type: str
    status: str
    match_score: int | None = None
    match_reason: str | None = None
    extracted_at: str
    created_at: str


class RecruitmentPositionDetail(BaseModel):
    id: int
    site_id: int
    company_name: str = ''
    title: str
    location: str | None = None
    department: str = ''
    deadline: str = ''
    degree_requirement: str | None = None
    description: str | None = None
    apply_url: str | None = None
    position_type: str
    status: str
    source_hash: str
    match_score: int | None = None
    match_reason: str | None = None
    extracted_at: str
    created_at: str


class RecruitmentPositionCreate(BaseModel):
    model_config = ConfigDict(str_strip_whitespace=True)

    site_id: int
    title: str
    location: str = ''
    department: str = ''
    deadline: str = ''
    degree_requirement: str = ''
    description: str = ''
    apply_url: str = ''
    position_type: str = '未分类'


class PositionDetailRequest(BaseModel):
    title: str
    company: str = ''
    source_position_id: int | None = None


class PositionDetailResponse(BaseModel):
    title: str = ''
    company: str = ''
    location: str = ''
    description: str = ''
    requirements: str = ''
    priority: str = ''
    other: str = ''
    deadline: str = ''
    degree_requirement: str = ''
    apply_url: str = ''
