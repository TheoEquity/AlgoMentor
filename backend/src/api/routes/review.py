from __future__ import annotations

from typing import Literal

from fastapi import APIRouter, Depends, Query

from config import Settings
from repositories.review_repository import ReviewRepository
from schemas.review import ReviewListResponse


router = APIRouter(prefix='/review', tags=['review'])


def get_repository() -> ReviewRepository:
    settings = Settings()
    return ReviewRepository(settings.database_url)


@router.get('', response_model=ReviewListResponse)
async def list_reviews(
    wrong_only: bool = Query(default=False),
    company: str | None = Query(default=None),
    tag: str | None = Query(default=None),
    error_type: Literal['AC', 'WA', 'RE', 'CE', 'TLE'] | None = Query(default=None),
    repository: ReviewRepository = Depends(get_repository),
) -> ReviewListResponse:
    return repository.list_reviews(
        wrong_only=wrong_only,
        company=company,
        tag=tag,
        error_type=error_type,
    )
