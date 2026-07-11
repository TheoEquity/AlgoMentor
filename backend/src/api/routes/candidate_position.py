from __future__ import annotations

import asyncio

from fastapi import APIRouter, BackgroundTasks, Depends, HTTPException, Query
from fastapi import status as http_status

from config import Settings
from repositories.candidate_position_repository import CandidatePositionRepository
from repositories.position_repository import PositionRepository
from repositories.resume_repository import ResumeRepository
from repositories.website_repository import WebsiteRepository
from schemas.candidate_position import (
    CandidatePositionCreate,
    CandidatePositionItem,
    CandidatePositionUpdate,
    ExtractFromSiteRequest,
    ExtractFromSiteResponse,
    ExtractedPositionResult,
)
from services.recruitment_llm import RecruitmentLLMService
from services.scraping_service import fetch_position_detail

router = APIRouter(prefix='/candidate-positions', tags=['Candidate Positions'])


def _repo() -> CandidatePositionRepository:
    return CandidatePositionRepository(Settings().database_url)


def _resume_repo() -> ResumeRepository:
    return ResumeRepository(Settings().database_url)


def _llm() -> RecruitmentLLMService:
    return RecruitmentLLMService(Settings().database_url)


@router.get('', response_model=list[CandidatePositionItem])
def list_positions(
    resume_id: int | None = Query(None),
    repo: CandidatePositionRepository = Depends(_repo),
):
    return repo.list(resume_id=resume_id)


@router.get('/{position_id}', response_model=CandidatePositionItem)
def get_position(position_id: int, repo: CandidatePositionRepository = Depends(_repo)):
    result = repo.get(position_id)
    if result is None:
        raise HTTPException(status_code=404, detail='候选岗位不存在')
    return result


@router.post('', response_model=CandidatePositionItem, status_code=http_status.HTTP_201_CREATED)
def create_position(
    payload: CandidatePositionCreate,
    repo: CandidatePositionRepository = Depends(_repo),
):
    source_type = 'site' if payload.site_id else 'manual'
    pos_id = repo.create(payload, source_type=source_type, site_id=payload.site_id, source_position_id=payload.source_position_id)
    result = repo.get(pos_id)
    if result is None:
        raise HTTPException(status_code=500, detail='创建失败')
    return result


@router.put('/{position_id}', response_model=CandidatePositionItem)
def update_position(
    position_id: int,
    payload: CandidatePositionUpdate,
    repo: CandidatePositionRepository = Depends(_repo),
):
    updated = repo.update(position_id, payload)
    if not updated:
        raise HTTPException(status_code=404, detail='候选岗位不存在')
    result = repo.get(position_id)
    if result is None:
        raise HTTPException(status_code=500, detail='更新后获取失败')
    return result


@router.delete('/{position_id}', status_code=http_status.HTTP_204_NO_CONTENT)
def delete_position(position_id: int, repo: CandidatePositionRepository = Depends(_repo)):
    deleted = repo.delete(position_id)
    if not deleted:
        raise HTTPException(status_code=404, detail='候选岗位不存在')


@router.post('/extract-from-site', response_model=ExtractFromSiteResponse)
async def extract_from_site(
    payload: ExtractFromSiteRequest,
    background_tasks: BackgroundTasks,
    repo: CandidatePositionRepository = Depends(_repo),
    resume_repo: ResumeRepository = Depends(_resume_repo),
    llm: RecruitmentLLMService = Depends(_llm),
):
    resume = resume_repo.get_resume(payload.resume_id)
    if resume is None:
        raise HTTPException(status_code=404, detail='简历不存在')
    if resume.extracted_info is None:
        raise HTTPException(status_code=400, detail='简历尚未解析，无法匹配')

    pos_repo = PositionRepository(Settings().database_url)
    keywords = resume.position_keywords if resume.position_keywords else None
    positions = repo.get_pending_for_matching(payload.resume_id, site_id=payload.site_id, keywords=keywords, limit=100)

    if keywords and len(positions) > 15:
        def keyword_score(pos: dict) -> int:
            title = pos.get('title', '').lower()
            return sum(1 for kw in keywords if kw.lower() in title)
        positions.sort(key=keyword_score, reverse=True)
        positions = positions[:15]

    results: list[dict] = []
    for pos in positions:
        try:
            result = await llm.match_position(
                resume.extracted_info,
                pos['title'],
                pos.get('description') or '',
                pos.get('location'),
                pos.get('degree_requirement'),
            )
            score = int(result.get('score', 0))
            reason = str(result.get('reason', ''))
            pos_repo.upsert_match(pos['id'], payload.resume_id, score, reason)
            results.append({
                'position': pos,
                'score': score,
                'reason': reason,
            })
        except Exception:
            pass

    results.sort(key=lambda x: x['score'], reverse=True)
    top5 = results[:5]

    extracted = [
        ExtractedPositionResult(
            source_position_id=r['position']['id'],
            company_name=r['position'].get('company_name', ''),
            title=r['position']['title'],
            location=r['position'].get('location') or '',
            description=r['position'].get('description') or '',
            apply_url=r['position'].get('apply_url') or '',
            degree_requirement=r['position'].get('degree_requirement') or '',
            score=r['score'],
            reason=r['reason'],
        )
        for r in top5
    ]

    site_repo = WebsiteRepository(Settings().database_url)
    site = site_repo.get_site(payload.site_id)
    if site and top5:
        background_tasks.add_task(
            _fetch_details_background,
            [{'source_position_id': r['position']['id'], 'title': r['position']['title'],
              'company_name': r['position'].get('company_name', '')} for r in top5],
            site.url,
            site.company_name,
            Settings().database_url,
        )

    return ExtractFromSiteResponse(ok=True, results=extracted)


async def _fetch_details_background(
    positions: list[dict],
    site_url: str,
    site_company: str,
    database_url: str,
) -> None:
    """Background task: fetch detail for each matched position and cache it."""
    pos_repo = PositionRepository(database_url)
    browser_settings = {'headless': True, 'timeout_seconds': 30, 'viewport_width': 1280, 'viewport_height': 720}
    for p in positions:
        pid = p['source_position_id']
        if pos_repo.get_detail(pid):
            continue
        try:
            detail = await fetch_position_detail(
                site_company, site_url, p['title'], p['company_name'], browser_settings,
            )
            detail.pop('apply_url', None)
            pos_repo.update_detail(pid, detail)
        except Exception:
            pass


@router.post('/{position_id}/recalc-match')
async def recalc_match(
    position_id: int,
    resume_id: int = Query(...),
    repo: CandidatePositionRepository = Depends(_repo),
    resume_repo: ResumeRepository = Depends(_resume_repo),
    llm: RecruitmentLLMService = Depends(_llm),
):
    pos = repo.get(position_id)
    if pos is None:
        raise HTTPException(status_code=404, detail='候选岗位不存在')

    resume = resume_repo.get_resume(resume_id)
    if resume is None:
        raise HTTPException(status_code=404, detail='简历不存在')
    if resume.extracted_info is None:
        raise HTTPException(status_code=400, detail='简历尚未解析，无法匹配')

    result = await llm.match_position(
        resume.extracted_info,
        pos.title,
        pos.description or '',
        pos.location,
        pos.degree_requirement,
    )
    score = int(result.get('score', 0))
    reason = str(result.get('reason', ''))
    repo.calc_and_save_match(position_id, resume_id, score, reason)

    return {'score': score, 'reason': reason}
