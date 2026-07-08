from __future__ import annotations

from pydantic import BaseModel, ConfigDict, Field


class TrainingPlanItemDetail(BaseModel):
    id: int
    problem_id: int
    title: str = ''
    company: str = ''
    difficulty: str = ''
    category_slug: str = ''
    tags: list[str] = Field(default_factory=list)
    sort_order: int = 1
    status: str = '未开始'


class TrainingPlanDetail(BaseModel):
    id: int
    name: str
    plan_type: str
    duration_days: int = 7
    total_problems: int = 0
    completed_count: int = 0
    correct_count: int = 0
    created_at: str
    updated_at: str
    items: list[TrainingPlanItemDetail] = Field(default_factory=list)


class TrainingPlanListItem(BaseModel):
    id: int
    name: str
    plan_type: str
    duration_days: int = 7
    total_problems: int = 0
    completed_count: int = 0
    correct_count: int = 0
    created_at: str
    updated_at: str


class TrainingPlanCreate(BaseModel):
    model_config = ConfigDict(str_strip_whitespace=True)

    name: str = Field(min_length=1)
    plan_type: str = 'comprehensive'
    duration_days: int = Field(default=7, ge=1, le=90)
    problem_ids: list[int] = Field(min_length=1)


class PlanPreviewProblem(BaseModel):
    problem_id: int
    title: str = ''
    company: str = ''
    difficulty: str = ''
    category_slug: str = ''
    tags: list[str] = Field(default_factory=list)


class PlanPreview(BaseModel):
    name: str
    plan_type: str
    duration_days: int = 7
    problems: list[PlanPreviewProblem] = Field(default_factory=list)
