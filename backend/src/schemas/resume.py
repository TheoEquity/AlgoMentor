from __future__ import annotations

from typing import Any

from pydantic import BaseModel, ConfigDict, Field


class EducationRecord(BaseModel):
    school: str = ''
    degree: str = ''
    major: str = ''
    start_date: str = ''
    end_date: str = ''
    gpa: str = ''
    courses: list[str] = Field(default_factory=list)
    honors: list[str] = Field(default_factory=list)


class ExperienceRecord(BaseModel):
    company: str = ''
    title: str = ''
    start_date: str = ''
    end_date: str = ''
    description: str = ''


class ProjectRecord(BaseModel):
    name: str = ''
    role: str = ''
    tech_stack: list[str] = Field(default_factory=list)
    start_date: str = ''
    end_date: str = ''
    description: str = ''


class LanguageRecord(BaseModel):
    name: str = ''
    level: str = ''


class ResumeExtractedInfo(BaseModel):
    name: str = ''
    email: str = ''
    phone: str = ''
    target_city: str = ''
    education: list[EducationRecord] = Field(default_factory=list)
    skills: list[str] = Field(default_factory=list)
    experiences: list[ExperienceRecord] = Field(default_factory=list)
    projects: list[ProjectRecord] = Field(default_factory=list)
    certifications: list[str] = Field(default_factory=list)
    languages: list[LanguageRecord] = Field(default_factory=list)
    self_evaluation: str = ''


class ResumeListItem(BaseModel):
    id: int
    name: str
    file_type: str
    position_keywords: list[str] = Field(default_factory=list)
    position_type: str
    extract_status: str
    created_at: str


class ResumeDetail(BaseModel):
    id: int
    name: str
    file_path: str
    file_type: str
    position_keywords: list[str] = Field(default_factory=list)
    position_type: str
    extracted_info: ResumeExtractedInfo | None = None
    extract_status: str
    extract_error: str | None = None
    created_at: str
    updated_at: str


class ResumeCreate(BaseModel):
    model_config = ConfigDict(str_strip_whitespace=True)

    name: str = Field(min_length=1)
    file_type: str = 'txt'
    position_keywords: list[str] = Field(default_factory=list, max_length=10)
    position_type: str = '日常实习'
