from __future__ import annotations

from pydantic import BaseModel, ConfigDict, Field


class JobApplicationListItem(BaseModel):
    id: int
    position_id: int
    resume_id: int
    company_name: str = ''
    position_title: str = ''
    resume_name: str = ''
    status: str
    applied_at: str | None = None
    feedback_at: str | None = None
    notes: str | None = None
    created_at: str
    updated_at: str


class JobApplicationUpdate(BaseModel):
    model_config = ConfigDict(str_strip_whitespace=True)

    status: str | None = None
    notes: str | None = None


class JobApplicationStats(BaseModel):
    total: int = 0
    pending_apply: int = 0
    applied: int = 0
    screening_pass: int = 0
    written_test: int = 0
    interviewing: int = 0
    offered: int = 0
    rejected: int = 0
