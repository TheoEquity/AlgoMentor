from __future__ import annotations

from datetime import UTC, datetime

from core.db import get_connection
from schemas.application import JobApplicationListItem, JobApplicationUpdate, JobApplicationStats


class ApplicationRepository:
    def __init__(self, database_url: str) -> None:
        self.database_url = database_url

    def list_applications(self, status: str | None = None, company: str | None = None, start_date: str | None = None, end_date: str | None = None) -> list[JobApplicationListItem]:
        connection = get_connection(self.database_url)
        try:
            with connection, connection.cursor() as cursor:
                query = '''SELECT a.*, cs.company_name, p.title AS position_title, r.name AS resume_name
                           FROM job_applications a
                           JOIN recruitment_positions p ON p.id = a.position_id
                           JOIN career_sites cs ON cs.id = p.site_id
                           JOIN resumes r ON r.id = a.resume_id'''
                conditions: list[str] = []
                params: list = []

                if status:
                    conditions.append('a.status = %s')
                    params.append(status)
                if company:
                    conditions.append('cs.company_name ILIKE %s')
                    params.append(f'%{company}%')
                if start_date:
                    conditions.append('a.created_at >= %s')
                    params.append(start_date)
                if end_date:
                    conditions.append('a.created_at <= %s')
                    params.append(end_date)

                if conditions:
                    query += ' WHERE ' + ' AND '.join(conditions)

                query += ' ORDER BY a.updated_at DESC, a.id DESC'
                cursor.execute(query, params)
                rows = cursor.fetchall()
        finally:
            connection.close()

        return [
            JobApplicationListItem(
                id=r['id'],
                position_id=r['position_id'],
                resume_id=r['resume_id'],
                company_name=r.get('company_name', ''),
                position_title=r.get('position_title', ''),
                resume_name=r.get('resume_name', ''),
                status=r['status'],
                applied_at=r.get('applied_at'),
                feedback_at=r.get('feedback_at'),
                notes=r.get('notes'),
                created_at=r['created_at'],
                updated_at=r['updated_at'],
            )
            for r in rows
        ]

    def get_application(self, application_id: int) -> JobApplicationListItem | None:
        connection = get_connection(self.database_url)
        try:
            with connection, connection.cursor() as cursor:
                cursor.execute(
                    '''SELECT a.*, cs.company_name, p.title AS position_title, r.name AS resume_name
                       FROM job_applications a
                       JOIN recruitment_positions p ON p.id = a.position_id
                       JOIN career_sites cs ON cs.id = p.site_id
                       JOIN resumes r ON r.id = a.resume_id
                       WHERE a.id = %s''',
                    (application_id,),
                )
                row = cursor.fetchone()
                if row is None:
                    return None
        finally:
            connection.close()

        return JobApplicationListItem(
            id=row['id'],
            position_id=row['position_id'],
            resume_id=row['resume_id'],
            company_name=row.get('company_name', ''),
            position_title=row.get('position_title', ''),
            resume_name=row.get('resume_name', ''),
            status=row['status'],
            applied_at=row.get('applied_at'),
            feedback_at=row.get('feedback_at'),
            notes=row.get('notes'),
            created_at=row['created_at'],
            updated_at=row['updated_at'],
        )

    def update_application(self, application_id: int, payload: JobApplicationUpdate) -> bool:
        now = datetime.now(UTC).isoformat()
        connection = get_connection(self.database_url)
        with connection, connection.cursor() as cursor:
            parts = []
            params: list = []

            if payload.status is not None:
                parts.append('status = %s')
                params.append(payload.status)

                status_map = {
                    'applied': 'applied_at',
                    'screening_pass': 'feedback_at',
                    'rejected': 'feedback_at',
                }
                for trigger, column in status_map.items():
                    if payload.status == trigger:
                        parts.append(f'{column} = %s')
                        params.append(now)

            if payload.notes is not None:
                parts.append('notes = %s')
                params.append(payload.notes)

            if not parts:
                connection.close()
                return False

            parts.append('updated_at = %s')
            params.append(now)
            params.append(application_id)
            cursor.execute(
                f'UPDATE job_applications SET {", ".join(parts)} WHERE id = %s', params
            )
            updated = cursor.rowcount > 0
        connection.close()
        return updated

    def delete_application(self, application_id: int) -> bool:
        connection = get_connection(self.database_url)
        with connection, connection.cursor() as cursor:
            cursor.execute('DELETE FROM job_applications WHERE id = %s', (application_id,))
            deleted = cursor.rowcount > 0
        connection.close()
        return deleted

    def get_stats(self) -> JobApplicationStats:
        connection = get_connection(self.database_url)
        try:
            with connection, connection.cursor() as cursor:
                cursor.execute(
                    '''SELECT status, COUNT(*) AS count
                       FROM job_applications
                       GROUP BY status'''
                )
                rows = cursor.fetchall()
        finally:
            connection.close()

        stats = {
            'total': 0,
            'pending_apply': 0,
            'applied': 0,
            'screening_pass': 0,
            'written_test': 0,
            'interviewing': 0,
            'offered': 0,
            'rejected': 0,
        }
        for row in rows:
            key = row['status']
            if key in stats:
                stats[key] = row['count']
        stats['total'] = sum(row['count'] for row in rows)
        return JobApplicationStats(**stats)
