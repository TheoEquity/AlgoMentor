from fastapi import APIRouter, Depends, HTTPException

from config import Settings
from repositories.company_repository import CompanyRepository
from repositories.llm_settings_repository import LLMSettingsRepository
from repositories.problem_category_repository import ProblemCategoryRepository
from schemas.companies import Company, CompanyCreate, CompanyUpdate
from schemas.llm_settings import LLMSettings, LLMSettingsUpdate
from schemas.problem_categories import CategoryCreate, CategoryUpdate, ProblemCategory


router = APIRouter(prefix='/system', tags=['system'])


def _llm_repo() -> LLMSettingsRepository:
    settings = Settings()
    return LLMSettingsRepository(settings.database_url)


def _company_repo() -> CompanyRepository:
    settings = Settings()
    return CompanyRepository(settings.database_url)


def _category_repo() -> ProblemCategoryRepository:
    settings = Settings()
    return ProblemCategoryRepository(settings.database_url)


@router.get('/ping')
async def ping() -> dict[str, str]:
    return {'message': 'pong'}


@router.get('/llm-settings', response_model=LLMSettings)
async def get_llm_settings(repository: LLMSettingsRepository = Depends(_llm_repo)) -> LLMSettings:
    return repository.get_settings()


@router.put('/llm-settings', response_model=LLMSettings)
async def update_llm_settings(
    payload: LLMSettingsUpdate,
    repository: LLMSettingsRepository = Depends(_llm_repo),
) -> LLMSettings:
    return repository.update_settings(payload)


@router.get('/companies', response_model=list[Company])
async def list_companies(repo: CompanyRepository = Depends(_company_repo)) -> list[Company]:
    return repo.list_companies()


@router.post('/companies', response_model=Company, status_code=201)
async def create_company(
    payload: CompanyCreate,
    repo: CompanyRepository = Depends(_company_repo),
) -> Company:
    return repo.create_company(payload)


@router.put('/companies/{company_id}', response_model=Company)
async def update_company(
    company_id: int,
    payload: CompanyUpdate,
    repo: CompanyRepository = Depends(_company_repo),
) -> Company:
    result = repo.update_company(company_id, payload)
    if not result:
        raise HTTPException(status_code=404, detail='Company not found')
    return result


@router.delete('/companies/{company_id}')
async def delete_company(
    company_id: int,
    repo: CompanyRepository = Depends(_company_repo),
) -> dict[str, str]:
    if not repo.delete_company(company_id):
        raise HTTPException(status_code=404, detail='Company not found')
    return {'message': 'deleted'}


@router.get('/problem-categories', response_model=list[ProblemCategory])
async def list_categories(repo: ProblemCategoryRepository = Depends(_category_repo)) -> list[ProblemCategory]:
    return repo.list_categories()


@router.post('/problem-categories', response_model=ProblemCategory, status_code=201)
async def create_category(
    payload: CategoryCreate,
    repo: ProblemCategoryRepository = Depends(_category_repo),
) -> ProblemCategory:
    return repo.create_category(payload)


@router.put('/problem-categories/{category_id}', response_model=ProblemCategory)
async def update_category(
    category_id: int,
    payload: CategoryUpdate,
    repo: ProblemCategoryRepository = Depends(_category_repo),
) -> ProblemCategory:
    result = repo.update_category(category_id, payload)
    if not result:
        raise HTTPException(status_code=404, detail='Category not found')
    return result


@router.delete('/problem-categories/{category_id}')
async def delete_category(
    category_id: int,
    repo: ProblemCategoryRepository = Depends(_category_repo),
) -> dict[str, str]:
    if not repo.delete_category(category_id):
        raise HTTPException(status_code=404, detail='Category not found')
    return {'message': 'deleted'}
