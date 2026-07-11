from __future__ import annotations

from fastapi import APIRouter, Depends, HTTPException, Query
from fastapi import status as http_status

from config import Settings
from repositories.application_repository import ApplicationRepository
from schemas.application import JobApplicationListItem, JobApplicationUpdate, JobApplicationStats

router = APIRouter(prefix='/applications', tags=['Applications'])


def _get_repo() -> ApplicationRepository:
    return ApplicationRepository(Settings().database_url)


@router.get('', response_model=list[JobApplicationListItem])
def list_applications(
    status: str | None = Query(None),
    company: str | None = Query(None),
    start_date: str | None = Query(None),
    end_date: str | None = Query(None),
    repo: ApplicationRepository = Depends(_get_repo),
):
    return repo.list_applications(status=status, company=company, start_date=start_date, end_date=end_date)


@router.get('/stats', response_model=JobApplicationStats)
def get_stats(repo: ApplicationRepository = Depends(_get_repo)):
    return repo.get_stats()


@router.get('/{application_id}', response_model=JobApplicationListItem)
def get_application(application_id: int, repo: ApplicationRepository = Depends(_get_repo)):
    app = repo.get_application(application_id)
    if app is None:
        raise HTTPException(status_code=404, detail='投递记录不存在')
    return app


@router.put('/{application_id}', response_model=JobApplicationListItem)
def update_application(
    application_id: int,
    payload: JobApplicationUpdate,
    repo: ApplicationRepository = Depends(_get_repo),
):
    updated = repo.update_application(application_id, payload)
    if not updated:
        raise HTTPException(status_code=404, detail='投递记录不存在')
    result = repo.get_application(application_id)
    if result is None:
        raise HTTPException(status_code=500, detail='更新后获取投递记录失败')
    return result


@router.delete('/{application_id}', status_code=http_status.HTTP_204_NO_CONTENT)
def delete_application(application_id: int, repo: ApplicationRepository = Depends(_get_repo)):
    deleted = repo.delete_application(application_id)
    if not deleted:
        raise HTTPException(status_code=404, detail='投递记录不存在')
