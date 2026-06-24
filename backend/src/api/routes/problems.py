from fastapi import APIRouter, Depends, HTTPException, Query, status

from config import Settings
from repositories.problem_repository import ProblemRepository
from schemas.problems import ProblemCreate, ProblemDetail, ProblemListItem


router = APIRouter(prefix='/problems', tags=['problems'])


def get_repository() -> ProblemRepository:
    settings = Settings()
    return ProblemRepository(settings.database_url)


@router.get('', response_model=list[ProblemListItem])
async def list_problems(
    company: str | None = Query(default=None),
    difficulty: str | None = Query(default=None),
    category_slug: str | None = Query(default=None),
    tag: str | None = Query(default=None),
    repository: ProblemRepository = Depends(get_repository),
) -> list[ProblemListItem]:
    return repository.list_problems(
        company=company,
        department=None,
        difficulty=difficulty,
        category_slug=category_slug,
        tag=tag,
    )


@router.get('/{problem_id}', response_model=ProblemDetail)
async def get_problem(
    problem_id: int,
    repository: ProblemRepository = Depends(get_repository),
) -> ProblemDetail:
    problem = repository.get_problem(problem_id)
    if problem is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail='Problem not found')

    return problem


@router.post('', response_model=ProblemDetail, status_code=status.HTTP_201_CREATED)
async def create_problem(
    payload: ProblemCreate,
    repository: ProblemRepository = Depends(get_repository),
) -> ProblemDetail:
    return repository.create_problem(payload)
