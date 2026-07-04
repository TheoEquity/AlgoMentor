from __future__ import annotations

import json
from collections.abc import Iterator

from fastapi import APIRouter, Depends, HTTPException, Query, Request, status
from fastapi.responses import StreamingResponse

from config import Settings
from repositories.agent_repository import AgentRepository
from repositories.chat_repository import ChatRepository
from repositories.problem_repository import ProblemRepository
from schemas.chat import ChatMessage, ChatRequest, ChatSession, ChatSessionCreate, ChatSessionUpdate, CreateProblemSessionRequest
from services.agent import AgentRunner

router = APIRouter(prefix='/chat', tags=['chat'])


def _chat_repo() -> ChatRepository:
    s = Settings()
    return ChatRepository(s.database_url)


_runner: AgentRunner | None = None


def _get_runner() -> AgentRunner:
    global _runner
    if _runner is None:
        _runner = AgentRunner(Settings())
    return _runner


# ── 会话 CRUD ───────────────────────────────────────────────

@router.get('/sessions', response_model=list[ChatSession])
async def list_sessions(
    agent_id: int | None = Query(default=None),
    repo: ChatRepository = Depends(_chat_repo),
) -> list[ChatSession]:
    return repo.list_sessions(agent_id=agent_id)


@router.post('/sessions', response_model=ChatSession, status_code=201)
async def create_session(
    payload: ChatSessionCreate,
    repo: ChatRepository = Depends(_chat_repo),
) -> ChatSession:
    return repo.create_session(payload)


@router.get('/sessions/{session_id}', response_model=ChatSession)
async def get_session(
    session_id: int,
    repo: ChatRepository = Depends(_chat_repo),
) -> ChatSession:
    session = repo.get_session(session_id)
    if not session:
        raise HTTPException(status_code=404, detail='会话不存在')
    return session


@router.put('/sessions/{session_id}', response_model=ChatSession)
async def update_session(
    session_id: int,
    payload: ChatSessionUpdate,
    repo: ChatRepository = Depends(_chat_repo),
) -> ChatSession:
    session = repo.update_session(session_id, payload)
    if not session:
        raise HTTPException(status_code=404, detail='会话不存在')
    return session


@router.delete('/sessions/{session_id}')
async def delete_session(
    session_id: int,
    repo: ChatRepository = Depends(_chat_repo),
) -> dict[str, str]:
    ok = repo.delete_session(session_id)
    if not ok:
        raise HTTPException(status_code=404, detail='会话不存在')
    return {'message': '已删除'}


# ── 按题目创建/查找会话 ─────────────────────────────────────

@router.post('/sessions/by-problem', response_model=ChatSession)
async def find_or_create_problem_session(
    payload: CreateProblemSessionRequest,
    repo: ChatRepository = Depends(_chat_repo),
) -> ChatSession:
    s = Settings()
    agent_repo = AgentRepository(s.database_url)
    agent = agent_repo.get_agent_by_slug(payload.agent_slug)
    if agent is None:
        raise HTTPException(status_code=404, detail=f'Agent {payload.agent_slug} 不存在')

    existing = repo.find_by_problem(payload.problem_id, agent.id)
    if existing:
        return existing

    title = payload.title
    if not title:
        problem_repo = ProblemRepository(s.database_url)
        problem = problem_repo.get_problem(payload.problem_id)
        title = problem.title if problem else f'题目 {payload.problem_id}'

    return repo.create_session(ChatSessionCreate(
        agent_id=agent.id,
        title=title,
        problem_id=payload.problem_id,
    ))


# ── 消息 ────────────────────────────────────────────────────

@router.get('/sessions/{session_id}/messages', response_model=list[ChatMessage])
async def list_messages(
    session_id: int,
    repo: ChatRepository = Depends(_chat_repo),
) -> list[ChatMessage]:
    return repo.list_messages(session_id)


@router.post('/sessions/{session_id}/messages')
async def send_message(
    session_id: int,
    payload: ChatRequest,
    repo: ChatRepository = Depends(_chat_repo),
    runner: AgentRunner = Depends(_get_runner),
) -> dict:
    session = repo.get_session(session_id)
    if not session:
        raise HTTPException(status_code=404, detail='会话不存在')

    result = runner.run_chat(session_id, payload.query)
    return {
        'content': result.content,
        'tool_calls_trace': [tc.model_dump() for tc in result.tool_calls_trace],
        'token_usage': result.token_usage.model_dump(),
        'iterations': result.iterations,
        'duration_ms': result.duration_ms,
    }


@router.post('/sessions/{session_id}/stream')
async def send_message_stream(
    session_id: int,
    payload: ChatRequest,
    request: Request,
    repo: ChatRepository = Depends(_chat_repo),
    runner: AgentRunner = Depends(_get_runner),
) -> StreamingResponse:
    session = repo.get_session(session_id)
    if not session:
        raise HTTPException(status_code=404, detail='会话不存在')

    async def event_stream() -> Iterator[str]:
        for event in runner.run_chat_stream(session_id, payload.query):
            if await request.is_disconnected():
                break
            if event['type'] == 'chunk':
                yield f"event: chunk\ndata: {json.dumps(event['data'], ensure_ascii=False)}\n\n"
            elif event['type'] == 'content':
                yield f"event: content\ndata: {json.dumps(event['data'], ensure_ascii=False)}\n\n"
            elif event['type'] == 'done':
                yield f"event: done\ndata: {json.dumps(event['data'], ensure_ascii=False)}\n\n"
            elif event['type'] == 'error':
                yield f"event: error\ndata: {json.dumps(event['data'], ensure_ascii=False)}\n\n"

    return StreamingResponse(
        event_stream(),
        media_type='text/event-stream',
        headers={
            'Cache-Control': 'no-cache',
            'Connection': 'keep-alive',
            'X-Accel-Buffering': 'no',
        },
    )
