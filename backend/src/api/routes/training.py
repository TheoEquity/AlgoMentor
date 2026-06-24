from __future__ import annotations

from fastapi import APIRouter, Depends

from config import Settings
from repositories.training_repository import TrainingRepository
from schemas.training import TrainingOverviewResponse


router = APIRouter(prefix='/training', tags=['training'])


def get_repository() -> TrainingRepository:
    settings = Settings()
    return TrainingRepository(settings.database_url)


@router.get('/overview', response_model=TrainingOverviewResponse)
async def get_training_overview(
    repository: TrainingRepository = Depends(get_repository),
) -> TrainingOverviewResponse:
    return repository.get_overview()
