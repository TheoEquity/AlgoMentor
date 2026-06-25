import json
from collections.abc import Iterator

from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.responses import StreamingResponse

from config import Settings
from repositories.llm_settings_repository import LLMSettingsRepository
from repositories.problem_repository import ProblemRepository
from repositories.submission_repository import SubmissionRepository
from schemas.analysis import AnalysisResponse, AttributionAnalysisRequest, HintAnalysisRequest, ProblemAnalysisRequest, ProblemChatRequest, SolutionAnalysisRequest
from services.analysis_service import AnalysisService


router = APIRouter(prefix='/analysis', tags=['analysis'])


def get_settings_repository() -> LLMSettingsRepository:
    settings = Settings()
    return LLMSettingsRepository(settings.database_url)


def get_problem_repository() -> ProblemRepository:
    settings = Settings()
    return ProblemRepository(settings.database_url)


def get_submission_repository() -> SubmissionRepository:
    settings = Settings()
    return SubmissionRepository(settings.database_url)


def get_analysis_service() -> AnalysisService:
    return AnalysisService()


def _encode_sse(event: str, payload: dict) -> str:
    return f'event: {event}\ndata: {json.dumps(payload, ensure_ascii=False)}\n\n'


def _stream_analysis_response(events: Iterator[tuple[str, dict | AnalysisResponse]], submission_repository: SubmissionRepository | None = None, submission_id: int | None = None) -> StreamingResponse:
    def iterator() -> Iterator[str]:
        for event_name, payload in events:
            if isinstance(payload, AnalysisResponse):
                if submission_repository is not None and submission_id is not None:
                    submission_repository.save_submission_analysis(submission_id, payload)
                yield _encode_sse(event_name, payload.model_dump())
                continue

            yield _encode_sse(event_name, payload)

    return StreamingResponse(
        iterator(),
        media_type='text/event-stream',
        headers={
            'Cache-Control': 'no-cache',
            'Connection': 'keep-alive',
            'X-Accel-Buffering': 'no',
        },
    )


@router.post('/solution', response_model=AnalysisResponse)
async def analyze_solution(
    payload: SolutionAnalysisRequest,
    settings_repository: LLMSettingsRepository = Depends(get_settings_repository),
    problem_repository: ProblemRepository = Depends(get_problem_repository),
    analysis_service: AnalysisService = Depends(get_analysis_service),
) -> AnalysisResponse:
    settings = settings_repository.get_settings()
    api_key = settings_repository.get_api_key()
    problem = problem_repository.get_problem(payload.problem_id)
    if problem is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail='Problem not found')

    return analysis_service.analyze_solution(settings, api_key, problem, payload.language, payload.code_text)


@router.post('/solution/stream')
async def analyze_solution_stream(
    payload: SolutionAnalysisRequest,
    settings_repository: LLMSettingsRepository = Depends(get_settings_repository),
    problem_repository: ProblemRepository = Depends(get_problem_repository),
    analysis_service: AnalysisService = Depends(get_analysis_service),
) -> StreamingResponse:
    settings = settings_repository.get_settings()
    api_key = settings_repository.get_api_key()
    problem = problem_repository.get_problem(payload.problem_id)
    if problem is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail='Problem not found')

    return _stream_analysis_response(
        analysis_service.stream_solution_analysis(settings, api_key, problem, payload.language, payload.code_text),
    )


@router.post('/hint', response_model=AnalysisResponse)
async def analyze_hint(
    payload: HintAnalysisRequest,
    settings_repository: LLMSettingsRepository = Depends(get_settings_repository),
    problem_repository: ProblemRepository = Depends(get_problem_repository),
    submission_repository: SubmissionRepository = Depends(get_submission_repository),
    analysis_service: AnalysisService = Depends(get_analysis_service),
) -> AnalysisResponse:
    settings = settings_repository.get_settings()
    api_key = settings_repository.get_api_key()
    problem = problem_repository.get_problem(payload.problem_id)
    if problem is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail='Problem not found')

    submission = None
    if payload.submission_id is not None:
        submission = submission_repository.get_submission(payload.submission_id)

    return analysis_service.generate_hint(
        settings,
        api_key,
        problem,
        payload.language,
        payload.code_text,
        payload.hint_step,
        payload.hint_strength,
        submission,
    )


@router.post('/problem', response_model=AnalysisResponse)
async def analyze_problem(
    payload: ProblemAnalysisRequest,
    settings_repository: LLMSettingsRepository = Depends(get_settings_repository),
    problem_repository: ProblemRepository = Depends(get_problem_repository),
    analysis_service: AnalysisService = Depends(get_analysis_service),
) -> AnalysisResponse:
    settings = settings_repository.get_settings()
    api_key = settings_repository.get_api_key()
    problem = problem_repository.get_problem(payload.problem_id)
    if problem is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail='Problem not found')

    return analysis_service.analyze_problem_thinking(settings, api_key, problem)


@router.post('/problem/chat', response_model=AnalysisResponse)
async def chat_problem(
    payload: ProblemChatRequest,
    settings_repository: LLMSettingsRepository = Depends(get_settings_repository),
    problem_repository: ProblemRepository = Depends(get_problem_repository),
    analysis_service: AnalysisService = Depends(get_analysis_service),
) -> AnalysisResponse:
    settings = settings_repository.get_settings()
    api_key = settings_repository.get_api_key()
    problem = problem_repository.get_problem(payload.problem_id)
    if problem is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail='Problem not found')

    return analysis_service.chat_problem_thinking(settings, api_key, problem, payload.messages, payload.question)


@router.post('/attribution', response_model=AnalysisResponse)
async def analyze_attribution(
    payload: AttributionAnalysisRequest,
    settings_repository: LLMSettingsRepository = Depends(get_settings_repository),
    problem_repository: ProblemRepository = Depends(get_problem_repository),
    submission_repository: SubmissionRepository = Depends(get_submission_repository),
    analysis_service: AnalysisService = Depends(get_analysis_service),
) -> AnalysisResponse:
    settings = settings_repository.get_settings()
    api_key = settings_repository.get_api_key()
    submission = submission_repository.get_submission(payload.submission_id)
    if submission is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail='Submission not found')

    problem = problem_repository.get_problem(submission.problem_id)
    if problem is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail='Problem not found')

    result = analysis_service.attribute_error(settings, api_key, problem, submission)
    submission_repository.save_submission_analysis(submission.id, result)
    return result


@router.post('/attribution/stream')
async def analyze_attribution_stream(
    payload: AttributionAnalysisRequest,
    settings_repository: LLMSettingsRepository = Depends(get_settings_repository),
    problem_repository: ProblemRepository = Depends(get_problem_repository),
    submission_repository: SubmissionRepository = Depends(get_submission_repository),
    analysis_service: AnalysisService = Depends(get_analysis_service),
) -> StreamingResponse:
    settings = settings_repository.get_settings()
    api_key = settings_repository.get_api_key()
    submission = submission_repository.get_submission(payload.submission_id)
    if submission is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail='Submission not found')

    problem = problem_repository.get_problem(submission.problem_id)
    if problem is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail='Problem not found')

    return _stream_analysis_response(
        analysis_service.stream_error_attribution(settings, api_key, problem, submission),
        submission_repository=submission_repository,
        submission_id=submission.id,
    )


@router.post('/review', response_model=AnalysisResponse)
async def analyze_review(
    payload: AttributionAnalysisRequest,
    settings_repository: LLMSettingsRepository = Depends(get_settings_repository),
    problem_repository: ProblemRepository = Depends(get_problem_repository),
    submission_repository: SubmissionRepository = Depends(get_submission_repository),
    analysis_service: AnalysisService = Depends(get_analysis_service),
) -> AnalysisResponse:
    settings = settings_repository.get_settings()
    api_key = settings_repository.get_api_key()
    submission = submission_repository.get_submission(payload.submission_id)
    if submission is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail='Submission not found')

    problem = problem_repository.get_problem(submission.problem_id)
    if problem is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail='Problem not found')

    result = analysis_service.review_submission(settings, api_key, problem, submission)
    submission_repository.save_submission_analysis(submission.id, result)
    return result


@router.post('/review/stream')
async def analyze_review_stream(
    payload: AttributionAnalysisRequest,
    settings_repository: LLMSettingsRepository = Depends(get_settings_repository),
    problem_repository: ProblemRepository = Depends(get_problem_repository),
    submission_repository: SubmissionRepository = Depends(get_submission_repository),
    analysis_service: AnalysisService = Depends(get_analysis_service),
) -> StreamingResponse:
    settings = settings_repository.get_settings()
    api_key = settings_repository.get_api_key()
    submission = submission_repository.get_submission(payload.submission_id)
    if submission is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail='Submission not found')

    problem = problem_repository.get_problem(submission.problem_id)
    if problem is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail='Problem not found')

    return _stream_analysis_response(
        analysis_service.stream_review_submission(settings, api_key, problem, submission),
        submission_repository=submission_repository,
        submission_id=submission.id,
    )
