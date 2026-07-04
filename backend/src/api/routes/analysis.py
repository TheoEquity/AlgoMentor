import json
from collections.abc import Iterator

from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.responses import StreamingResponse

from config import Settings
from repositories.llm_settings_repository import LLMSettingsRepository
from repositories.problem_repository import ProblemRepository
from repositories.submission_repository import SubmissionRepository
from schemas.agent_run import AgentRunRequest
from schemas.analysis import AnalysisResponse, AttributionAnalysisRequest, HintAnalysisRequest, ParsedProblemResult, ParseProblemRequest, ProblemAnalysisRequest, ProblemChatRequest, SolutionAnalysisRequest
from services.agent import AgentRunner
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


_runner: AgentRunner | None = None


def _get_runner() -> AgentRunner:
    global _runner
    if _runner is None:
        _runner = AgentRunner(Settings())
    return _runner


def _try_agent_delegate(agent_slug: str, context: dict) -> AnalysisResponse | None:
    try:
        app_settings = Settings()
        runner = _get_runner()

        # Enrich context: fetch problem/submission data if only IDs provided
        if 'problem_id' in context and 'problem' not in context:
            repo = ProblemRepository(app_settings.database_url)
            p = repo.get_problem(context['problem_id'])
            if p:
                context['problem'] = {
                    'title': p.title,
                    'tags': p.tags,
                    'statement_markdown': p.statement_markdown,
                    'constraints_text': p.constraints_text,
                }
        if 'submission_id' in context and 'submission' not in context:
            repo = SubmissionRepository(app_settings.database_url)
            s = repo.get_submission(context['submission_id'])
            if s:
                context['submission'] = {
                    'verdict': s.verdict,
                    'stderr_output': s.stderr_output or '',
                    'compiler_output': s.compiler_output or '',
                    'runtime_ms': s.runtime_ms,
                    'memory_kb': s.memory_kb,
                    'failed_input': s.failed_input or '',
                    'failed_expected_output': s.failed_expected_output or '',
                    'failed_actual_output': s.failed_actual_output or '',
                }

        request = AgentRunRequest(context=context)
        result = runner.run(agent_slug, request)
        if not result.content:
            return None

        # Try JSON first (for agents configured to return structured output)
        try:
            data = json.loads(result.content)
            return AnalysisResponse(**data)
        except (json.JSONDecodeError, TypeError):
            pass

        # Build AnalysisResponse from natural language output
        settings_repo = LLMSettingsRepository(app_settings.database_url)
        llm = settings_repo.get_settings()

        from repositories.agent_repository import AgentRepository
        agent_repo = AgentRepository(app_settings.database_url)
        agent = agent_repo.get_agent_by_slug(agent_slug)
        model = agent.model if agent else llm.solution_model

        content = result.content
        title = f'{agent.name if agent else agent_slug}'

        # Extract section headings as bullet points for the card list
        bullets: list[str] = []
        for line in content.split('\n'):
            stripped = line.strip()
            if stripped.startswith('## ') or stripped.startswith('### '):
                bullets.append(stripped.lstrip('#').strip())

        if not bullets:
            bullets = ['分析完成']

        # summary = full markdown content for MarkdownRenderer rendering
        summary = content

        return AnalysisResponse(
            analysis_type=context.get('analysis_type', 'problem_analysis'),
            provider=llm.provider,
            model=model,
            endpoint_url=llm.endpoint_url,
            execution_status='completed',
            title=title,
            summary=summary,
            bullets=bullets[:10],
            line_refs=[],
        )
    except Exception:
        return None


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

    ctx = {
        'analysis_type': 'solution',
        'problem_id': payload.problem_id,
        'language': payload.language,
        'code_text': payload.code_text,
    }
    agent_result = _try_agent_delegate('tutoring-agent', ctx)
    if agent_result:
        return agent_result
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

    ctx = {
        'analysis_type': 'hint',
        'problem_id': payload.problem_id,
        'language': payload.language,
        'code_text': payload.code_text,
        'hint_step': payload.hint_step,
        'hint_strength': payload.hint_strength,
    }
    agent_result = _try_agent_delegate('tutoring-agent', ctx)
    if agent_result:
        return agent_result

    return analysis_service.generate_hint(
        settings, api_key, problem,
        payload.language, payload.code_text,
        payload.hint_step, payload.hint_strength, submission,
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

    ctx = {'analysis_type': 'problem_analysis', 'problem_id': payload.problem_id}
    agent_result = _try_agent_delegate('solution-agent', ctx)
    if agent_result:
        return agent_result
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

    ctx = {
        'analysis_type': 'chat',
        'problem_id': payload.problem_id,
        'messages': [m.model_dump() for m in payload.messages],
        'question': payload.question,
    }
    agent_result = _try_agent_delegate('solution-agent', ctx)
    if agent_result:
        return agent_result
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

    ctx = {'analysis_type': 'attribution', 'submission_id': payload.submission_id}
    agent_result = _try_agent_delegate('tutoring-agent', ctx)
    if agent_result:
        submission_repository.save_submission_analysis(submission.id, agent_result)
        return agent_result

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

    ctx = {'analysis_type': 'review', 'submission_id': payload.submission_id}
    agent_result = _try_agent_delegate('tutoring-agent', ctx)
    if agent_result:
        submission_repository.save_submission_analysis(submission.id, agent_result)
        return agent_result

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


@router.post('/parse-problem', response_model=ParsedProblemResult)
async def parse_problem_text(
    payload: ParseProblemRequest,
    settings_repository: LLMSettingsRepository = Depends(get_settings_repository),
    analysis_service: AnalysisService = Depends(get_analysis_service),
) -> ParsedProblemResult:
    settings = settings_repository.get_settings()
    api_key = settings_repository.get_api_key()

    ctx = {
        'analysis_type': 'parse',
        'raw_text': payload.raw_text,
        'mode': payload.mode,
        'image_name': payload.image_name,
    }
    try:
        runner = _get_runner()
        agent_request = AgentRunRequest(context=ctx)
        agent_result = runner.run('parsing-agent', agent_request)
        if agent_result.content:
            data = json.loads(agent_result.content)
            return ParsedProblemResult(**data)
    except Exception:
        pass

    return analysis_service.parse_problem_text(
        settings, api_key, payload.raw_text,
        mode=payload.mode, image_data_url=payload.image_data_url,
        image_name=payload.image_name,
    )
