from fastapi import APIRouter, Depends

from config import Settings
from repositories.llm_settings_repository import LLMSettingsRepository
from schemas.llm_settings import LLMSettings, LLMSettingsUpdate


router = APIRouter(prefix='/system', tags=['system'])


def get_repository() -> LLMSettingsRepository:
    settings = Settings()
    return LLMSettingsRepository(settings.database_url)


@router.get('/ping')
async def ping() -> dict[str, str]:
    return {'message': 'pong'}


@router.get('/llm-settings', response_model=LLMSettings)
async def get_llm_settings(repository: LLMSettingsRepository = Depends(get_repository)) -> LLMSettings:
    return repository.get_settings()


@router.put('/llm-settings', response_model=LLMSettings)
async def update_llm_settings(
    payload: LLMSettingsUpdate,
    repository: LLMSettingsRepository = Depends(get_repository),
) -> LLMSettings:
    return repository.update_settings(payload)
