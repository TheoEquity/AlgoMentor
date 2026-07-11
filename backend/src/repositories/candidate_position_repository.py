from __future__ import annotations

from datetime import UTC, datetime

from core.db import get_connection
from schemas.candidate_position import CandidatePositionCreate, CandidatePositionItem, CandidatePositionUpdate


class CandidatePositionRepository:
    def __init__(self, database_url: str) -> None:
        self.database_url = database_url

    def list(self, resume_id: int | None = None) -> list[CandidatePositionItem]:
        connection = get_connection(self.database_url)
        try:
            with connection, connection.cursor() as cursor:
                if resume_id is not None:
                    cursor.execute(
                        'SELECT * FROM candidate_positions WHERE resume_id = %s ORDER BY match_score DESC, id DESC',
                        (resume_id,),
                    )
                else:
                    cursor.execute('SELECT * FROM candidate_positions ORDER BY match_score DESC, id DESC')
                rows = cursor.fetchall()
        finally:
            connection.close()
        return [CandidatePositionItem(**r) for r in rows]

    def get(self, position_id: int) -> CandidatePositionItem | None:
        connection = get_connection(self.database_url)
        try:
            with connection, connection.cursor() as cursor:
                cursor.execute('SELECT * FROM candidate_positions WHERE id = %s', (position_id,))
                row = cursor.fetchone()
        finally:
            connection.close()
        return CandidatePositionItem(**row) if row else None

    def create(self, payload: CandidatePositionCreate, source_type: str = 'manual', site_id: int | None = None, source_position_id: int | None = None) -> int:
        now = datetime.now(UTC).isoformat()
        connection = get_connection(self.database_url)
        try:
            with connection, connection.cursor() as cursor:
                cursor.execute(
                    '''INSERT INTO candidate_positions
                       (resume_id, company_name, title, location, description, apply_url, degree_requirement,
                        match_score, match_reason, source_type, site_id, source_position_id, created_at, updated_at)
                       VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s) RETURNING id''',
                    (
                        payload.resume_id, payload.company_name, payload.title,
                        payload.location, payload.description, payload.apply_url,
                        payload.degree_requirement, payload.match_score, payload.match_reason,
                        source_type, site_id, source_position_id, now, now,
                    ),
                )
                pos_id = cursor.fetchone()['id']
        finally:
            connection.close()
        return pos_id

    def update(self, position_id: int, payload: CandidatePositionUpdate) -> bool:
        now = datetime.now(UTC).isoformat()
        connection = get_connection(self.database_url)
        try:
            with connection, connection.cursor() as cursor:
                parts = []
                params: list = []
                for field in ('company_name', 'title', 'location', 'description', 'apply_url',
                              'degree_requirement', 'match_score', 'match_reason', 'status'):
                    val = getattr(payload, field, None)
                    if val is not None:
                        parts.append(f'{field} = %s')
                        params.append(val)
                if not parts:
                    return False
                parts.append('updated_at = %s')
                params.append(now)
                params.append(position_id)
                cursor.execute(f'UPDATE candidate_positions SET {", ".join(parts)} WHERE id = %s', params)
                updated = cursor.rowcount > 0
        finally:
            connection.close()
        return updated

    def delete(self, position_id: int) -> bool:
        connection = get_connection(self.database_url)
        try:
            with connection, connection.cursor() as cursor:
                cursor.execute('DELETE FROM candidate_positions WHERE id = %s', (position_id,))
                deleted = cursor.rowcount > 0
        finally:
            connection.close()
        return deleted

    def get_pending_for_matching(self, resume_id: int, site_id: int | None = None, keywords: list[str] | None = None, limit: int = 50) -> list[dict]:
        connection = get_connection(self.database_url)
        try:
            with connection, connection.cursor() as cursor:
                like_clauses: list[str] = []
                like_params: list = []
                if keywords:
                    for kw in keywords:
                        like_clauses.append('p.title ILIKE %s')
                        like_params.append(f'%{kw}%')
                keyword_filter = f' AND ({" OR ".join(like_clauses)})' if like_clauses else ''

                if site_id:
                    params = [site_id] + like_params + [limit]
                    cursor.execute(
                        f'''SELECT p.*, cs.company_name
                           FROM recruitment_positions p
                           JOIN career_sites cs ON cs.id = p.site_id
                           WHERE p.site_id = %s AND p.status != 'ignored'{keyword_filter}
                           ORDER BY p.extracted_at DESC
                           LIMIT %s''',
                        params,
                    )
                else:
                    params = like_params + [limit]
                    cursor.execute(
                        f'''SELECT p.*, cs.company_name
                           FROM recruitment_positions p
                           JOIN career_sites cs ON cs.id = p.site_id
                           WHERE p.status != 'ignored'{keyword_filter}
                           ORDER BY p.extracted_at DESC
                           LIMIT %s''',
                        params,
                    )
                rows = cursor.fetchall()
        finally:
            connection.close()
        return [dict(r) for r in rows]

    def calc_and_save_match(self, position_id: int, resume_id: int, score: int, reason: str) -> None:
        connection = get_connection(self.database_url)
        try:
            with connection, connection.cursor() as cursor:
                cursor.execute(
                    'UPDATE candidate_positions SET match_score = %s, match_reason = %s, updated_at = %s WHERE id = %s',
                    (score, reason, datetime.now(UTC).isoformat(), position_id),
                )
        finally:
            connection.close()
