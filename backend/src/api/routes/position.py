from __future__ import annotations

import json

from fastapi import APIRouter, Depends, HTTPException, Query
from fastapi import status as http_status

from config import Settings
from repositories.position_repository import PositionRepository
from repositories.resume_repository import ResumeRepository
from schemas.position import RecruitmentPositionCreate, RecruitmentPositionDetail, RecruitmentPositionListItem
from services.recruitment_llm import RecruitmentLLMService

router = APIRouter(prefix='/recruitment-positions', tags=['Recruitment Positions'])


def _get_repo() -> PositionRepository:
    return PositionRepository(Settings().database_url)


def _get_resume_repo() -> ResumeRepository:
    return ResumeRepository(Settings().database_url)


def _get_llm() -> RecruitmentLLMService:
    return RecruitmentLLMService(Settings().database_url)


@router.get('', response_model=list[RecruitmentPositionListItem])
def list_positions(
    resume_id: int | None = Query(None),
    status: str | None = Query(None),
    site_id: int | None = Query(None),
    repo: PositionRepository = Depends(_get_repo),
):
    return repo.list_positions(resume_id=resume_id, status=status, site_id=site_id)


@router.get('/{position_id}', response_model=RecruitmentPositionDetail)
def get_position(
    position_id: int,
    resume_id: int | None = Query(None),
    repo: PositionRepository = Depends(_get_repo),
):
    result = repo.get_position(position_id, resume_id=resume_id)
    if result is None:
        raise HTTPException(status_code=404, detail='岗位不存在')
    return result


@router.get('/{position_id}/detail')
def get_position_detail(
    position_id: int,
    repo: PositionRepository = Depends(_get_repo),
):
    detail = repo.get_detail(position_id)
    if detail is None:
        raise HTTPException(status_code=404, detail='岗位详情未缓存')
    return detail


@router.post('', response_model=RecruitmentPositionDetail, status_code=http_status.HTTP_201_CREATED)
def create_position(
    payload: RecruitmentPositionCreate,
    repo: PositionRepository = Depends(_get_repo),
):
    position_id = repo.create_single(payload)
    if position_id < 0:
        raise HTTPException(status_code=409, detail='岗位已存在')
    result = repo.get_position(position_id)
    if result is None:
        raise HTTPException(status_code=500, detail='创建后获取岗位失败')
    return result


@router.put('/{position_id}/confirm')
def confirm_position(
    position_id: int,
    resume_id: int = Query(...),
    repo: PositionRepository = Depends(_get_repo),
    resume_repo: ResumeRepository = Depends(_get_resume_repo),
):
    resume = resume_repo.get_resume(resume_id)
    if resume is None:
        raise HTTPException(status_code=404, detail='简历不存在')

    confirmed = repo.confirm_position(position_id, resume_id)
    if not confirmed:
        raise HTTPException(status_code=404, detail='岗位不存在')
    return {'ok': True}


@router.put('/{position_id}/ignore')
def ignore_position(position_id: int, repo: PositionRepository = Depends(_get_repo)):
    updated = repo.ignore_position(position_id)
    if not updated:
        raise HTTPException(status_code=404, detail='岗位不存在')
    return {'ok': True}


@router.delete('/{position_id}', status_code=http_status.HTTP_204_NO_CONTENT)
def delete_position(position_id: int, repo: PositionRepository = Depends(_get_repo)):
    deleted = repo.delete_position(position_id)
    if not deleted:
        raise HTTPException(status_code=404, detail='岗位不存在')


@router.post('/classify-all')
async def classify_all(repo: PositionRepository = Depends(_get_repo)):
    llm = _get_llm()
    uncategorized = repo.classify_uncategorized()
    count = 0
    for pos in uncategorized:
        try:
            pos_type = await llm.classify_position_type(pos['title'], pos.get('description') or '')
            repo.update_position_type(pos['id'], pos_type)
            count += 1
        except Exception:
            pass
    return {'ok': True, 'classified': count, 'total': len(uncategorized)}


@router.post('/match/{resume_id}')
async def match_positions(
    resume_id: int,
    limit: int = Query(50, ge=1, le=200),
    repo: PositionRepository = Depends(_get_repo),
    resume_repo: ResumeRepository = Depends(_get_resume_repo),
):
    resume = resume_repo.get_resume(resume_id)
    if resume is None:
        raise HTTPException(status_code=404, detail='简历不存在')
    if resume.extracted_info is None:
        raise HTTPException(status_code=400, detail='简历尚未解析，无法匹配')

    llm = _get_llm()
    positions = repo.get_pending_for_matching(resume_id, limit=limit)
    matched = 0
    for pos in positions:
        try:
            result = await llm.match_position(
                resume.extracted_info,
                pos['title'],
                pos.get('description') or '',
                pos.get('location'),
                pos.get('degree_requirement'),
            )
            repo.upsert_match(
                pos['id'], resume_id,
                int(result.get('score', 0)),
                str(result.get('reason', '')),
            )
            matched += 1
        except Exception:
            pass

    return {'ok': True, 'matched': matched, 'total': len(positions)}


@router.post('/match-single/{position_id}/{resume_id}')
async def match_single_position(
    position_id: int,
    resume_id: int,
    repo: PositionRepository = Depends(_get_repo),
    resume_repo: ResumeRepository = Depends(_get_resume_repo),
):
    position = repo.get_position(position_id)
    if position is None:
        raise HTTPException(status_code=404, detail='岗位不存在')

    resume = resume_repo.get_resume(resume_id)
    if resume is None:
        raise HTTPException(status_code=404, detail='简历不存在')
    if resume.extracted_info is None:
        raise HTTPException(status_code=400, detail='简历尚未解析，无法匹配')

    llm = _get_llm()
    result = await llm.match_position(
        resume.extracted_info,
        position.title,
        position.description or '',
        position.location,
        position.degree_requirement,
    )
    repo.upsert_match(
        position_id, resume_id,
        int(result.get('score', 0)),
        str(result.get('reason', '')),
    )
    return result
