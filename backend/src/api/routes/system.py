from fastapi import APIRouter, Depends, HTTPException, Query
from datetime import UTC, datetime

from config import Settings
from core.db import get_connection
from repositories.company_repository import CompanyRepository
from repositories.llm_settings_repository import LLMSettingsRepository
from repositories.problem_category_repository import ProblemCategoryRepository
from repositories.usage_repository import UsageRepository
from schemas.agent_run import UsageSummary
from schemas.browser_setting import BrowserSettings, BrowserSettingsUpdate
from schemas.companies import Company, CompanyCreate, CompanyUpdate
from schemas.llm_settings import LLMSettings, LLMSettingsUpdate
from schemas.problem_categories import CategoryCreate, CategoryUpdate, ProblemCategory
from schemas.website import IndustryCategoryCreate, IndustryCategoryItem, IndustryCategoryUpdate


router = APIRouter(prefix='/system', tags=['system'])


def _now_iso() -> str:
    return datetime.now(UTC).isoformat()


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


def _usage_repo() -> UsageRepository:
    settings = Settings()
    return UsageRepository(settings.database_url)


@router.get('/dashboard')
async def get_dashboard() -> dict:
    settings = Settings()
    connection = get_connection(settings.database_url)
    try:
        with connection.cursor() as cur:
            cur.execute("""SELECT company, COUNT(*) AS cnt FROM problems
                           WHERE company IS NOT NULL AND company != ''
                           GROUP BY company ORDER BY cnt DESC""")
            company_distribution = [{'name': r['company'], 'count': r['cnt']} for r in cur.fetchall()]

            cur.execute("""SELECT difficulty, COUNT(*) AS cnt FROM problems
                           GROUP BY difficulty ORDER BY difficulty""")
            difficulty_distribution = [{'name': r['difficulty'], 'count': r['cnt']} for r in cur.fetchall()]

            cur.execute("""SELECT c.slug, c.name, c.sort_order, COUNT(p.id) AS cnt
                           FROM problem_categories c
                           LEFT JOIN problems p ON p.category_slug = c.slug
                           GROUP BY c.slug, c.name, c.sort_order
                           ORDER BY c.sort_order""")
            category_distribution = [
                {'slug': r['slug'], 'name': r['name'], 'count': r['cnt']}
                for r in cur.fetchall()
            ]

            cur.execute("""SELECT p.difficulty, COUNT(*) AS cnt
                           FROM submissions s
                           JOIN problems p ON p.id = s.problem_id
                           WHERE s.verdict != 'AC'
                           GROUP BY p.difficulty
                           ORDER BY p.difficulty""")
            wrong_distribution = [{'name': r['difficulty'], 'count': r['cnt']} for r in cur.fetchall()]

            cur.execute("""SELECT source_type, COUNT(*) AS cnt
                           FROM problems
                           WHERE source_type IS NOT NULL AND source_type != ''
                           GROUP BY source_type
                           ORDER BY cnt DESC""")
            source_distribution = [{'name': r['source_type'], 'count': r['cnt']} for r in cur.fetchall()]

            cur.execute("""SELECT year, COUNT(*) AS cnt
                           FROM problems
                           WHERE year IS NOT NULL
                           GROUP BY year
                           ORDER BY year""")
            year_distribution = [{'name': str(r['year']), 'count': r['cnt']} for r in cur.fetchall()]

            return {
                'company_distribution': company_distribution,
                'difficulty_distribution': difficulty_distribution,
                'category_distribution': category_distribution,
                'wrong_distribution': wrong_distribution,
                'source_distribution': source_distribution,
                'year_distribution': year_distribution,
            }
    finally:
        connection.close()


@router.get('/ai-usage', response_model=list[UsageSummary])
async def get_ai_usage(
    agent: str | None = Query(default=None),
    from_date: str | None = Query(default=None),
    to_date: str | None = Query(default=None),
    repo: UsageRepository = Depends(_usage_repo),
) -> list[UsageSummary]:
    return repo.query_usage(agent_slug=agent, from_date=from_date, to_date=to_date)


@router.get('/browser-settings', response_model=BrowserSettings)
def get_browser_settings() -> BrowserSettings:
    settings = Settings()
    connection = get_connection(settings.database_url)
    try:
        with connection, connection.cursor() as cursor:
            cursor.execute('SELECT * FROM browser_settings WHERE id = 1')
            row = cursor.fetchone()
            if row is None:
                return BrowserSettings(id=1, updated_at='')
            return BrowserSettings(
                id=row['id'],
                headless=bool(row['headless']),
                executable_path=row.get('executable_path', ''),
                viewport_width=row.get('viewport_width', 1280),
                viewport_height=row.get('viewport_height', 720),
                timeout_seconds=row.get('timeout_seconds', 30),
                user_data_dir=row.get('user_data_dir', ''),
                proxy_url=row.get('proxy_url', ''),
                updated_at=row['updated_at'],
            )
    finally:
        connection.close()


@router.put('/browser-settings', response_model=BrowserSettings)
def update_browser_settings(payload: BrowserSettingsUpdate) -> BrowserSettings:
    from datetime import UTC, datetime

    settings = Settings()
    connection = get_connection(settings.database_url)
    now = datetime.now(UTC).isoformat()
    try:
        with connection, connection.cursor() as cursor:
            cursor.execute(
                '''UPDATE browser_settings SET
                   headless = %s, executable_path = %s,
                   viewport_width = %s, viewport_height = %s,
                   timeout_seconds = %s, user_data_dir = %s, proxy_url = %s,
                   updated_at = %s
                   WHERE id = 1''',
                (
                    1 if payload.headless else 0,
                    payload.executable_path,
                    payload.viewport_width,
                    payload.viewport_height,
                    payload.timeout_seconds,
                    payload.user_data_dir,
                    payload.proxy_url,
                    now,
                ),
            )

            cursor.execute('SELECT * FROM browser_settings WHERE id = 1')
            row = cursor.fetchone()
    finally:
        connection.close()

    return BrowserSettings(
        id=row['id'],
        headless=bool(row['headless']),
        executable_path=row.get('executable_path', ''),
        viewport_width=row.get('viewport_width', 1280),
        viewport_height=row.get('viewport_height', 720),
        timeout_seconds=row.get('timeout_seconds', 30),
        user_data_dir=row.get('user_data_dir', ''),
        proxy_url=row.get('proxy_url', ''),
        updated_at=row['updated_at'],
    )


@router.get('/industry-categories', response_model=list[IndustryCategoryItem])
async def list_industry_categories() -> list[IndustryCategoryItem]:
    connection = get_connection(Settings().database_url)
    try:
        with connection, connection.cursor() as cursor:
            cursor.execute('SELECT id, name, sort_order, created_at FROM industry_categories ORDER BY sort_order, id')
            rows = cursor.fetchall()
    finally:
        connection.close()
    return [IndustryCategoryItem(**r) for r in rows]


@router.post('/industry-categories', response_model=IndustryCategoryItem)
async def create_industry_category(payload: IndustryCategoryCreate) -> IndustryCategoryItem:
    now = _now_iso()
    connection = get_connection(Settings().database_url)
    try:
        with connection, connection.cursor() as cursor:
            cursor.execute(
                'INSERT INTO industry_categories (name, sort_order, created_at) VALUES (%s, %s, %s) RETURNING id, sort_order',
                (payload.name, 0, now),
            )
            row = cursor.fetchone()
            return IndustryCategoryItem(id=row['id'], name=payload.name, sort_order=row['sort_order'], created_at=now)
    finally:
        connection.close()


@router.put('/industry-categories/{category_id}', response_model=IndustryCategoryItem)
async def update_industry_category(category_id: int, payload: IndustryCategoryUpdate) -> IndustryCategoryItem:
    connection = get_connection(Settings().database_url)
    try:
        with connection, connection.cursor() as cursor:
            parts = []
            params: list = []
            if payload.name is not None:
                parts.append('name = %s')
                params.append(payload.name)
            if payload.sort_order is not None:
                parts.append('sort_order = %s')
                params.append(payload.sort_order)
            if parts:
                params.append(category_id)
                cursor.execute(f'UPDATE industry_categories SET {", ".join(parts)} WHERE id = %s', params)
            cursor.execute('SELECT id, name, sort_order, created_at FROM industry_categories WHERE id = %s', (category_id,))
            row = cursor.fetchone()
            if not row:
                raise HTTPException(status_code=404, detail='行业类别不存在')
            return IndustryCategoryItem(**row)
    finally:
        connection.close()


@router.delete('/industry-categories/{category_id}')
async def delete_industry_category(category_id: int) -> dict:
    connection = get_connection(Settings().database_url)
    try:
        with connection, connection.cursor() as cursor:
            cursor.execute('DELETE FROM industry_categories WHERE id = %s', (category_id,))
            if cursor.rowcount == 0:
                raise HTTPException(status_code=404, detail='行业类别不存在')
    finally:
        connection.close()
    return {}
