from __future__ import annotations

from pydantic import BaseModel, Field

from schemas.submissions import Language, RunType, Verdict


class TrainingSummary(BaseModel):
    total_runs: int = Field(ge=0)
    ac_count: int = Field(ge=0)
    wrong_count: int = Field(ge=0)
    submit_count: int = Field(ge=0)
    strongest_tag: str | None = None
    main_error_type: Verdict | None = None


class TrainingRecentItem(BaseModel):
    submission_id: int = Field(ge=1)
    problem_id: int = Field(ge=1)
    title: str
    company: str
    language: Language
    run_type: RunType
    verdict: Verdict
    created_at: str


class TrainingErrorBucket(BaseModel):
    verdict: Verdict
    count: int = Field(ge=0)


class TrainingRecommendation(BaseModel):
    problem_id: int = Field(ge=1)
    title: str
    company: str
    tags: list[str]
    recommendation_reason: str


class TrainingOverviewResponse(BaseModel):
    summary: TrainingSummary
    recent_items: list[TrainingRecentItem]
    error_buckets: list[TrainingErrorBucket]
    recommendations: list[TrainingRecommendation]
