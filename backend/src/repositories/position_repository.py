from __future__ import annotations

import hashlib
import json
from datetime import UTC, datetime

from core.db import get_connection
from schemas.position import RecruitmentPositionCreate, RecruitmentPositionDetail, RecruitmentPositionListItem


class PositionRepository:
    def __init__(self, database_url: str) -> None:
        self.database_url = database_url

    def list_positions(self, resume_id: int | None = None, status: str | None = None, site_id: int | None = None) -> list[RecruitmentPositionListItem]:
        connection = get_connection(self.database_url)
        try:
            with connection, connection.cursor() as cursor:
                query = '''SELECT p.*, cs.company_name,
                                  pm.match_score, pm.match_reason
                           FROM recruitment_positions p
                           JOIN career_sites cs ON cs.id = p.site_id'''
                params: list = []
                conditions: list[str] = []

                if resume_id is not None:
                    query += ' LEFT JOIN position_matches pm ON pm.position_id = p.id AND pm.resume_id = %s'
                    params.append(resume_id)
                else:
                    query += ' LEFT JOIN position_matches pm ON pm.position_id = p.id AND 1=0'

                if status is not None:
                    conditions.append('p.status = %s')
                    params.append(status)
                if site_id is not None:
                    conditions.append('p.site_id = %s')
                    params.append(site_id)

                if conditions:
                    query += ' WHERE ' + ' AND '.join(conditions)

                query += ' ORDER BY p.extracted_at DESC, p.id DESC'
                cursor.execute(query, params)
                rows = cursor.fetchall()
        finally:
            connection.close()

        return [
            RecruitmentPositionListItem(
                id=r['id'],
                site_id=r['site_id'],
                company_name=r.get('company_name', ''),
                title=r['title'],
                location=r.get('location'),
                degree_requirement=r.get('degree_requirement'),
                position_type=r['position_type'],
                status=r['status'],
                match_score=r.get('match_score'),
                match_reason=r.get('match_reason'),
                extracted_at=r['extracted_at'],
                created_at=r['created_at'],
            )
            for r in rows
        ]

    def get_position(self, position_id: int, resume_id: int | None = None) -> RecruitmentPositionDetail | None:
        connection = get_connection(self.database_url)
        try:
            with connection, connection.cursor() as cursor:
                if resume_id is not None:
                    cursor.execute(
                        '''SELECT p.*, cs.company_name, pm.match_score, pm.match_reason
                           FROM recruitment_positions p
                           JOIN career_sites cs ON cs.id = p.site_id
                           LEFT JOIN position_matches pm ON pm.position_id = p.id AND pm.resume_id = %s
                           WHERE p.id = %s''',
                        (resume_id, position_id),
                    )
                else:
                    cursor.execute(
                        '''SELECT p.*, cs.company_name
                           FROM recruitment_positions p
                           JOIN career_sites cs ON cs.id = p.site_id
                           WHERE p.id = %s''',
                        (position_id,),
                    )
                row = cursor.fetchone()
                if row is None:
                    return None
        finally:
            connection.close()

        return RecruitmentPositionDetail(
            id=row['id'],
            site_id=row['site_id'],
            company_name=row.get('company_name', ''),
            title=row['title'],
            location=row.get('location'),
            degree_requirement=row.get('degree_requirement'),
            description=row.get('description'),
            apply_url=row.get('apply_url'),
            position_type=row['position_type'],
            status=row['status'],
            source_hash=row['source_hash'],
            match_score=row.get('match_score'),
            match_reason=row.get('match_reason'),
            extracted_at=row['extracted_at'],
            created_at=row['created_at'],
        )

    def create_from_scraped(self, site_id: int, positions: list[dict]) -> int:
        now = datetime.now(UTC).isoformat()
        count = 0
        connection = get_connection(self.database_url)
        try:
            with connection, connection.cursor() as cursor:
                for pos in positions:
                    title = pos.get('title', '')
                    company = pos.get('company', '')
                    location = pos.get('location', '')
                    source_hash = hashlib.md5(
                        (title + company + location).encode('utf-8')
                    ).hexdigest()

                    cursor.execute(
                        '''INSERT INTO recruitment_positions
                           (site_id, title, location, degree_requirement, description, apply_url,
                            position_type, status, source_hash, extracted_at, created_at)
                           VALUES (%s, %s, %s, %s, %s, %s, '未分类', 'pending', %s, %s, %s)
                           ON CONFLICT (source_hash) DO NOTHING''',
                        (
                            site_id, title, location,
                            pos.get('degree_requirement', ''),
                            pos.get('description', ''),
                            pos.get('apply_url', ''),
                            source_hash, now, now,
                        ),
                    )
                    if cursor.rowcount > 0:
                        count += 1
        finally:
            connection.close()
        return count

    def create_single(self, payload: RecruitmentPositionCreate) -> int:
        now = datetime.now(UTC).isoformat()
        source_hash = hashlib.md5(
            (payload.title + payload.location).encode('utf-8')
        ).hexdigest()

        connection = get_connection(self.database_url)
        with connection, connection.cursor() as cursor:
            cursor.execute(
                '''INSERT INTO recruitment_positions
                   (site_id, title, location, degree_requirement, description, apply_url,
                    position_type, status, source_hash, extracted_at, created_at)
                   VALUES (%s, %s, %s, %s, %s, %s, %s, 'pending', %s, %s, %s)
                   ON CONFLICT (source_hash) DO NOTHING
                   RETURNING id''',
                (
                    payload.site_id, payload.title, payload.location,
                    payload.degree_requirement, payload.description, payload.apply_url,
                    payload.position_type, source_hash, now, now,
                ),
            )
            row = cursor.fetchone()
            position_id = row['id'] if row else -1
        connection.close()
        return position_id

    def update_position_type(self, position_id: int, position_type: str) -> None:
        connection = get_connection(self.database_url)
        with connection, connection.cursor() as cursor:
            cursor.execute(
                'UPDATE recruitment_positions SET position_type = %s WHERE id = %s',
                (position_type, position_id),
            )
        connection.close()

    def confirm_position(self, position_id: int, resume_id: int, application_status: str = 'pending_apply') -> bool:
        now = datetime.now(UTC).isoformat()
        connection = get_connection(self.database_url)
        try:
            with connection, connection.cursor() as cursor:
                cursor.execute(
                    "UPDATE recruitment_positions SET status = 'confirmed' WHERE id = %s",
                    (position_id,),
                )

                cursor.execute(
                    '''INSERT INTO job_applications (position_id, resume_id, status, created_at, updated_at)
                       VALUES (%s, %s, %s, %s, %s)
                       ON CONFLICT DO NOTHING''',
                    (position_id, resume_id, application_status, now, now),
                )
                confirmed = cursor.rowcount > 0
        finally:
            connection.close()
        return confirmed

    def ignore_position(self, position_id: int) -> bool:
        connection = get_connection(self.database_url)
        with connection, connection.cursor() as cursor:
            cursor.execute(
                "UPDATE recruitment_positions SET status = 'ignored' WHERE id = %s",
                (position_id,),
            )
            updated = cursor.rowcount > 0
        connection.close()
        return updated

    def delete_position(self, position_id: int) -> bool:
        connection = get_connection(self.database_url)
        with connection, connection.cursor() as cursor:
            cursor.execute('DELETE FROM recruitment_positions WHERE id = %s', (position_id,))
            deleted = cursor.rowcount > 0
        connection.close()
        return deleted

    def upsert_match(self, position_id: int, resume_id: int, score: int, reason: str) -> None:
        now = datetime.now(UTC).isoformat()
        connection = get_connection(self.database_url)
        with connection, connection.cursor() as cursor:
            cursor.execute(
                '''INSERT INTO position_matches (position_id, resume_id, match_score, match_reason, created_at)
                   VALUES (%s, %s, %s, %s, %s)
                   ON CONFLICT (position_id, resume_id) DO UPDATE SET
                   match_score = EXCLUDED.match_score, match_reason = EXCLUDED.match_reason, created_at = EXCLUDED.created_at''',
                (position_id, resume_id, score, reason, now),
            )
        connection.close()

    def classify_uncategorized(self) -> list[dict]:
        connection = get_connection(self.database_url)
        try:
            with connection, connection.cursor() as cursor:
                cursor.execute(
                    "SELECT id, title, description FROM recruitment_positions WHERE position_type = '未分类'"
                )
                rows = cursor.fetchall()
        finally:
            connection.close()
        return [dict(r) for r in rows]

    def get_pending_for_matching(self, resume_id: int, limit: int = 50) -> list[dict]:
        connection = get_connection(self.database_url)
        try:
            with connection, connection.cursor() as cursor:
                cursor.execute(
                    '''SELECT p.*, cs.company_name
                       FROM recruitment_positions p
                       JOIN career_sites cs ON cs.id = p.site_id
                       WHERE p.status = 'pending'
                       AND p.position_type != '未分类'
                       AND NOT EXISTS (
                           SELECT 1 FROM position_matches pm
                           WHERE pm.position_id = p.id AND pm.resume_id = %s
                       )
                       ORDER BY p.extracted_at DESC
                       LIMIT %s''',
                     (resume_id, limit),
                )
                rows = cursor.fetchall()
        finally:
            connection.close()
        return [dict(r) for r in rows]

    def update_detail(self, position_id: int, detail: dict) -> None:
        connection = get_connection(self.database_url)
        with connection, connection.cursor() as cursor:
            cursor.execute(
                'UPDATE recruitment_positions SET detail = %s WHERE id = %s',
                (json.dumps(detail, ensure_ascii=False), position_id),
            )
        connection.close()

    def get_detail(self, position_id: int) -> dict | None:
        connection = get_connection(self.database_url)
        try:
            with connection, connection.cursor() as cursor:
                cursor.execute(
                    'SELECT detail FROM recruitment_positions WHERE id = %s',
                    (position_id,),
                )
                row = cursor.fetchone()
                return row['detail'] if row and row['detail'] else None
        finally:
            connection.close()
