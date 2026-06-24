from fastapi import APIRouter, Depends, HTTPException, Query, status

from config import Settings
from repositories.submission_repository import SubmissionRepository
from schemas.submissions import SubmissionCreate, SubmissionResult


router = APIRouter(prefix='/submissions', tags=['submissions'])


def get_repository() -> SubmissionRepository:
    settings = Settings()
    return SubmissionRepository(settings.database_url, settings.judge0_url)


@router.post('', response_model=SubmissionResult, status_code=status.HTTP_201_CREATED)
async def create_submission(
    payload: SubmissionCreate,
    repository: SubmissionRepository = Depends(get_repository),
) -> SubmissionResult:
    try:
        return repository.create_submission(payload)
    except ValueError as exc:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(exc)) from exc


@router.get('', response_model=list[SubmissionResult])
async def list_submissions(
    problem_id: int = Query(ge=1),
    limit: int = Query(default=20, ge=1, le=50),
    repository: SubmissionRepository = Depends(get_repository),
) -> list[SubmissionResult]:
    return repository.list_submissions(problem_id=problem_id, limit=limit)


@router.get('/{submission_id}', response_model=SubmissionResult)
async def get_submission(
    submission_id: int,
    repository: SubmissionRepository = Depends(get_repository),
) -> SubmissionResult:
    submission = repository.get_submission(submission_id)
    if submission is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail='Submission not found')

    return submission
