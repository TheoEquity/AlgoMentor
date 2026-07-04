from __future__ import annotations

import json
from collections.abc import Iterator

from fastapi import APIRouter, Depends, HTTPException, Query, Request, status
from fastapi.responses import StreamingResponse
from pydantic import ValidationError

from config import Settings
from repositories.agent_repository import AgentRepository
from repositories.tool_repository import ToolRepository
from repositories.skill_repository import SkillRepository
from schemas.agent import AgentConfig, AgentCreate, AgentUpdate
from schemas.agent_run import AgentRunRequest, AgentRunResult
from schemas.tool import ToolConfig
from schemas.skill import SkillConfig
from services.agent import AgentRunner

router = APIRouter(prefix='/agents', tags=['agents'])


def _settings() -> Settings:
    return Settings()


def _agent_repo() -> AgentRepository:
    s = Settings()
    return AgentRepository(s.database_url)


def _tool_repo() -> ToolRepository:
    s = Settings()
    return ToolRepository(s.database_url)


def _skill_repo() -> SkillRepository:
    s = Settings()
    return SkillRepository(s.database_url)


_runner: AgentRunner | None = None


def _get_runner(settings: Settings = Depends(_settings)) -> AgentRunner:
    global _runner
    if _runner is None:
        _runner = AgentRunner(settings)
    return _runner


# ── Agent CRUD ──────────────────────────────────────────────

@router.get('', response_model=list[AgentConfig])
async def list_agents(
    enabled_only: bool = Query(default=False),
    repo: AgentRepository = Depends(_agent_repo),
) -> list[AgentConfig]:
    return repo.list_agents(enabled_only=enabled_only)


@router.get('/{agent_id}', response_model=AgentConfig)
async def get_agent(
    agent_id: int,
    repo: AgentRepository = Depends(_agent_repo),
) -> AgentConfig:
    agent = repo.get_agent_by_id(agent_id)
    if not agent:
        raise HTTPException(status_code=404, detail=f'Agent {agent_id} 不存在')
    return agent


@router.post('', response_model=AgentConfig, status_code=201)
async def create_agent(
    payload: AgentCreate,
    repo: AgentRepository = Depends(_agent_repo),
    runner: AgentRunner = Depends(_get_runner),
) -> AgentConfig:
    agent = repo.create_agent(payload)
    runner.reload_agents()
    return agent


@router.put('/{agent_id}', response_model=AgentConfig)
async def update_agent(
    agent_id: int,
    payload: AgentUpdate,
    repo: AgentRepository = Depends(_agent_repo),
    runner: AgentRunner = Depends(_get_runner),
) -> AgentConfig:
    agent = repo.update_agent(agent_id, payload)
    if not agent:
        raise HTTPException(status_code=404, detail=f'Agent {agent_id} 不存在')
    runner.reload_agents()
    return agent


@router.delete('/{agent_id}')
async def delete_agent(
    agent_id: int,
    repo: AgentRepository = Depends(_agent_repo),
    runner: AgentRunner = Depends(_get_runner),
) -> dict[str, str]:
    ok = repo.delete_agent(agent_id)
    if not ok:
        raise HTTPException(status_code=404, detail=f'Agent {agent_id} 不存在')
    runner.reload_agents()
    return {'message': f'Agent {agent_id} 已删除'}


# ── Tools & Skills ──────────────────────────────────────────

@router.get('/tools/list', response_model=list[ToolConfig])
async def list_tools(repo: ToolRepository = Depends(_tool_repo)) -> list[ToolConfig]:
    return repo.list_tools()


@router.get('/skills/list', response_model=list[SkillConfig])
async def list_skills(repo: SkillRepository = Depends(_skill_repo)) -> list[SkillConfig]:
    return repo.list_skills()


# ── Agent 执行 ──────────────────────────────────────────────

@router.post('/{agent_slug}/run', response_model=AgentRunResult)
async def run_agent(
    agent_slug: str,
    payload: AgentRunRequest,
    runner: AgentRunner = Depends(_get_runner),
) -> AgentRunResult:
    return runner.run(agent_slug, payload)


@router.get('/{agent_slug}/stream')
async def run_agent_stream(
    agent_slug: str,
    request: Request,
    context_json: str = Query(default='{}'),
    runner: AgentRunner = Depends(_get_runner),
) -> StreamingResponse:
    try:
        context = json.loads(context_json)
    except json.JSONDecodeError:
        raise HTTPException(status_code=422, detail='context_json 不是合法的 JSON')

    sse_request = AgentRunRequest(context=context)

    async def event_stream() -> Iterator[str]:
        for event in runner.run_stream(agent_slug, sse_request):
            if await request.is_disconnected():
                break
            yield f"event: {event['type']}\ndata: {json.dumps(event['data'], ensure_ascii=False)}\n\n"

    return StreamingResponse(
        event_stream(),
        media_type='text/event-stream',
        headers={
            'Cache-Control': 'no-cache',
            'Connection': 'keep-alive',
            'X-Accel-Buffering': 'no',
        },
    )


# ── 热刷新 ──────────────────────────────────────────────────

@router.post('/reload')
async def reload_agents(runner: AgentRunner = Depends(_get_runner)) -> dict[str, str]:
    runner.reload_agents()
    return {'message': 'Agents 已刷新'}
