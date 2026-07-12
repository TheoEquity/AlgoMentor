from __future__ import annotations

from datetime import UTC, datetime

from core.db import get_connection
from schemas.application import (
    JobPositionCreate,
    JobPositionDetail,
    JobPositionListItem,
    JobPositionUpdate,
)


class ApplicationRepository:
    def __init__(self, database_url: str) -> None:
        self.database_url = database_url

    def list_positions(self, resume_id: int | None = None) -> list[JobPositionListItem]:
        connection = get_connection(self.database_url)
        try:
            with connection, connection.cursor() as cursor:
                query = 'SELECT id, resume_id, company_name, department, title, location, position_type, position_category, industry_category, deadline, status, status_date, notes, match_score, job_url, created_at, updated_at FROM job_positions'
                params: list = []
                if resume_id is not None:
                    query += ' WHERE resume_id = %s'
                    params.append(resume_id)
                query += ' ORDER BY updated_at DESC, id DESC'
                cursor.execute(query, params)
                rows = cursor.fetchall()
        finally:
            connection.close()

        return [
            JobPositionListItem(
                id=r['id'],
                resume_id=r['resume_id'],
                company_name=r['company_name'],
                department=r.get('department', ''),
                title=r['title'],
                location=r.get('location', ''),
                position_type=r.get('position_type', ''),
                position_category=r.get('position_category', ''),
                industry_category=r.get('industry_category', ''),
                deadline=r.get('deadline', ''),
                status=r['status'],
                status_date=r.get('status_date', ''),
                notes=r.get('notes', ''),
                match_score=r.get('match_score', 0),
                job_url=r.get('job_url', ''),
                created_at=r['created_at'],
                updated_at=r['updated_at'],
            )
            for r in rows
        ]

    def get_position(self, position_id: int) -> JobPositionDetail | None:
        connection = get_connection(self.database_url)
        try:
            with connection, connection.cursor() as cursor:
                cursor.execute('SELECT * FROM job_positions WHERE id = %s', (position_id,))
                row = cursor.fetchone()
                if row is None:
                    return None
        finally:
            connection.close()

        return JobPositionDetail(
            id=row['id'],
            resume_id=row['resume_id'],
            company_name=row['company_name'],
            department=row.get('department', ''),
            title=row['title'],
            location=row.get('location', ''),
            position_type=row.get('position_type', ''),
            position_category=row.get('position_category', ''),
            industry_category=row.get('industry_category', ''),
            job_url=row.get('job_url', ''),
            publish_date=row.get('publish_date', ''),
            deadline=row.get('deadline', ''),
            job_description=row.get('job_description', ''),
            job_requirements=row.get('job_requirements', ''),
            job_preferences=row.get('job_preferences', ''),
            status=row['status'],
            status_date=row.get('status_date', ''),
            notes=row.get('notes', ''),
            apply_channel=row.get('apply_channel', ''),
            match_score=row.get('match_score', 0),
            match_detail=row.get('match_detail', ''),
            match_advice=row.get('match_advice', ''),
            created_at=row['created_at'],
            updated_at=row['updated_at'],
        )

    def create_position(self, payload: JobPositionCreate) -> int:
        now = datetime.now(UTC).isoformat()
        connection = get_connection(self.database_url)
        with connection, connection.cursor() as cursor:
            cursor.execute(
                '''INSERT INTO job_positions (
                    resume_id, company_name, department, title, location, position_type, position_category,
                    industry_category, job_url, publish_date, deadline, job_description, job_requirements,
                    job_preferences, status, status_date, notes, apply_channel,
                    match_score, match_detail, match_advice, created_at, updated_at
                ) VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s) RETURNING id''',
                (
                    payload.resume_id or None, payload.company_name, payload.department, payload.title,
                    payload.location, payload.position_type, payload.position_category,
                    payload.industry_category, payload.job_url, payload.publish_date, payload.deadline,
                    payload.job_description, payload.job_requirements, payload.job_preferences,
                    payload.status, payload.status_date, payload.notes, payload.apply_channel,
                    payload.match_score, payload.match_detail, payload.match_advice,
                    now, now,
                ),
            )
            pos_id = cursor.fetchone()['id']
        connection.close()
        return pos_id

    def update_position(self, position_id: int, payload: JobPositionUpdate) -> bool:
        now = datetime.now(UTC).isoformat()
        connection = get_connection(self.database_url)
        with connection, connection.cursor() as cursor:
            field_map = {
                'company_name': 'company_name', 'department': 'department', 'title': 'title',
                'location': 'location', 'position_type': 'position_type', 'position_category': 'position_category',
                'industry_category': 'industry_category',
                'job_url': 'job_url', 'publish_date': 'publish_date', 'deadline': 'deadline',
                'job_description': 'job_description', 'job_requirements': 'job_requirements',
                'job_preferences': 'job_preferences', 'status': 'status', 'status_date': 'status_date',
                'notes': 'notes', 'apply_channel': 'apply_channel',
                'match_score': 'match_score', 'match_detail': 'match_detail',
                'match_advice': 'match_advice',
            }
            parts = []
            params: list = []
            for field, col in field_map.items():
                val = getattr(payload, field, None)
                if val is not None:
                    parts.append(f'{col} = %s')
                    params.append(val)
            if not parts:
                connection.close()
                return False
            parts.append('updated_at = %s')
            params.append(now)
            params.append(position_id)
            cursor.execute(
                f'UPDATE job_positions SET {", ".join(parts)} WHERE id = %s', params
            )
            updated = cursor.rowcount > 0
        connection.close()
        return updated

    def delete_position(self, position_id: int) -> bool:
        connection = get_connection(self.database_url)
        with connection, connection.cursor() as cursor:
            cursor.execute('DELETE FROM job_positions WHERE id = %s', (position_id,))
            deleted = cursor.rowcount > 0
        connection.close()
        return deleted
