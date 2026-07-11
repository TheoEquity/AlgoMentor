from __future__ import annotations

from datetime import UTC, datetime

from fastapi import APIRouter, Depends, HTTPException
from fastapi import status as http_status

from config import Settings
from core.db import get_connection
from repositories.position_repository import PositionRepository
from repositories.website_repository import WebsiteRepository
from schemas.website import CareerSiteCreate, CareerSiteListItem, CareerSiteUpdate
from schemas.position import PositionDetailRequest, PositionDetailResponse
from services.scraping_service import scrape_site, fetch_position_detail

router = APIRouter(prefix='/career-sites', tags=['Career Sites'])


def _get_repo() -> WebsiteRepository:
    return WebsiteRepository(Settings().database_url)


@router.get('', response_model=list[CareerSiteListItem])
def list_sites(repo: WebsiteRepository = Depends(_get_repo)):
    return repo.list_sites()


@router.post('', response_model=CareerSiteListItem, status_code=http_status.HTTP_201_CREATED)
def create_site(payload: CareerSiteCreate, repo: WebsiteRepository = Depends(_get_repo)):
    site_id = repo.create_site(payload)
    result = repo.get_site(site_id)
    if result is None:
        raise HTTPException(status_code=500, detail='创建后获取官网失败')
    return result


@router.put('/{site_id}', response_model=CareerSiteListItem)
def update_site(site_id: int, payload: CareerSiteUpdate, repo: WebsiteRepository = Depends(_get_repo)):
    updated = repo.update_site(site_id, payload)
    if not updated:
        raise HTTPException(status_code=404, detail='官网不存在')
    result = repo.get_site(site_id)
    if result is None:
        raise HTTPException(status_code=500, detail='更新后获取官网失败')
    return result


@router.delete('/{site_id}', status_code=http_status.HTTP_204_NO_CONTENT)
def delete_site(site_id: int, repo: WebsiteRepository = Depends(_get_repo)):
    deleted = repo.delete_site(site_id)
    if not deleted:
        raise HTTPException(status_code=404, detail='官网不存在')


def _get_browser_settings() -> dict:
    connection = get_connection(Settings().database_url)
    try:
        with connection, connection.cursor() as cursor:
            cursor.execute('SELECT * FROM browser_settings WHERE id = 1')
            row = cursor.fetchone()
            if row is None:
                return {'headless': True, 'timeout_seconds': 30, 'viewport_width': 1280, 'viewport_height': 720}
            return {
                'headless': bool(row['headless']),
                'timeout_seconds': row.get('timeout_seconds', 30),
                'viewport_width': row.get('viewport_width', 1280),
                'viewport_height': row.get('viewport_height', 720),
                'executable_path': row.get('executable_path', ''),
                'user_data_dir': row.get('user_data_dir', ''),
                'proxy_url': row.get('proxy_url', ''),
            }
    finally:
        connection.close()


@router.post('/{site_id}/scrape')
async def scrape_career_site(
    site_id: int,
    repo: WebsiteRepository = Depends(_get_repo),
):
    site = repo.get_site(site_id)
    if site is None:
        raise HTTPException(status_code=404, detail='官网不存在')

    repo.update_scrape_status(site_id, 'running')
    try:
        browser_settings = _get_browser_settings()
        positions = await scrape_site(site.company_name, site.url, browser_settings)
        pos_repo = PositionRepository(Settings().database_url)
        count = pos_repo.create_from_scraped(site_id, positions)
        repo.update_scrape_status(site_id, 'success', position_count=count)
        return {'ok': True, 'positions_found': len(positions), 'positions_added': count}
    except Exception as e:
        err_msg = str(e) or type(e).__name__
        repo.update_scrape_status(site_id, 'failed', error=err_msg)
        raise HTTPException(status_code=500, detail=f'抓取失败: {err_msg}')


@router.post('/{site_id}/fetch-detail', response_model=PositionDetailResponse)
async def fetch_detail(
    site_id: int,
    payload: PositionDetailRequest,
    repo: WebsiteRepository = Depends(_get_repo),
):
    site = repo.get_site(site_id)
    if site is None:
        raise HTTPException(status_code=404, detail='官网不存在')

    if payload.source_position_id:
        pos_repo = PositionRepository(Settings().database_url)
        cached = pos_repo.get_detail(payload.source_position_id)
        if cached:
            return cached

    browser_settings = _get_browser_settings()
    detail = await fetch_position_detail(site.company_name, site.url, payload.title, payload.company, browser_settings)
    return detail
