from fastapi import APIRouter, Depends, HTTPException, Query, status

from config import Settings
from repositories.llm_settings_repository import LLMSettingsRepository
from repositories.problem_repository import ProblemRepository
from repositories.submission_repository import SubmissionRepository
from schemas.submissions import SubmissionCreate, SubmissionResult
from services.analysis_service import AnalysisService


router = APIRouter(prefix='/submissions', tags=['submissions'])


def get_repository() -> SubmissionRepository:
    settings = Settings()
    return SubmissionRepository(settings.database_url, settings.judge0_url)


def get_settings_repository() -> LLMSettingsRepository:
    settings = Settings()
    return LLMSettingsRepository(settings.database_url)


def get_problem_repository() -> ProblemRepository:
    settings = Settings()
    return ProblemRepository(settings.database_url)


def get_analysis_service() -> AnalysisService:
    return AnalysisService()


@router.post('', response_model=SubmissionResult, status_code=status.HTTP_201_CREATED)
async def create_submission(
    payload: SubmissionCreate,
    repository: SubmissionRepository = Depends(get_repository),
    settings_repository: LLMSettingsRepository = Depends(get_settings_repository),
    problem_repository: ProblemRepository = Depends(get_problem_repository),
    analysis_service: AnalysisService = Depends(get_analysis_service),
) -> SubmissionResult:
    try:
        result = repository.create_submission(payload)
    except ValueError as exc:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(exc)) from exc

    if result.verdict != 'AC':
        try:
            settings = settings_repository.get_settings()
            api_key = settings_repository.get_api_key()
            problem = problem_repository.get_problem(result.problem_id)
            if problem is not None:
                analysis = analysis_service.attribute_error(settings, api_key, problem, result)
                repository.save_submission_analysis(result.id, analysis)
        except Exception:
            pass

    return result


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
