from __future__ import annotations

import json
from datetime import UTC, datetime

from core.db import get_connection
from schemas.resume import ResumeCreate, ResumeDetail, ResumeExtractedInfo, ResumeListItem


class ResumeRepository:
    def __init__(self, database_url: str) -> None:
        self.database_url = database_url

    def list_resumes(self) -> list[ResumeListItem]:
        connection = get_connection(self.database_url)
        with connection, connection.cursor() as cursor:
            cursor.execute('SELECT * FROM resumes ORDER BY created_at DESC, id DESC')
            rows = cursor.fetchall()
        connection.close()

        return [
            ResumeListItem(
                id=r['id'],
                name=r['name'],
                file_type=r['file_type'],
                position_keywords=json.loads(r['position_keywords']),
                position_type=r['position_type'],
                position_category=r.get('position_category', ''),
                extract_status=r['extract_status'],
                created_at=r['created_at'],
            )
            for r in rows
        ]

    def get_resume(self, resume_id: int) -> ResumeDetail | None:
        connection = get_connection(self.database_url)
        try:
            with connection, connection.cursor() as cursor:
                cursor.execute('SELECT * FROM resumes WHERE id = %s', (resume_id,))
                row = cursor.fetchone()
                if row is None:
                    return None
        finally:
            connection.close()

        extracted_info = None
        if row['extracted_info']:
            try:
                extracted_info = json.loads(row['extracted_info'])
            except (json.JSONDecodeError, TypeError):
                pass

        return ResumeDetail(
            id=row['id'],
            name=row['name'],
            file_path=row['file_path'],
            file_type=row['file_type'],
            position_keywords=json.loads(row['position_keywords']),
            position_type=row['position_type'],
            position_category=row.get('position_category', ''),
            extracted_info=extracted_info,
            extract_status=row['extract_status'],
            extract_error=row['extract_error'],
            created_at=row['created_at'],
            updated_at=row['updated_at'],
        )

    def create_resume(self, payload: ResumeCreate, file_path: str) -> int:
        now = datetime.now(UTC).isoformat()
        connection = get_connection(self.database_url)
        with connection, connection.cursor() as cursor:
            cursor.execute(
                '''INSERT INTO resumes (name, file_path, file_type, position_keywords, position_type, position_category, extract_status, created_at, updated_at)
                   VALUES (%s, %s, %s, %s, %s, %s, 'pending', %s, %s) RETURNING id''',
                (payload.name, file_path, payload.file_type, json.dumps(payload.position_keywords, ensure_ascii=False),
                 payload.position_type, payload.position_category, now, now),
            )
            resume_id = cursor.fetchone()['id']
        connection.close()
        return resume_id

    def update_extracted_info(self, resume_id: int, info: dict) -> None:
        now = datetime.now(UTC).isoformat()
        connection = get_connection(self.database_url)
        with connection, connection.cursor() as cursor:
            cursor.execute(
                '''UPDATE resumes SET extracted_info = %s, extract_status = 'success', extract_error = NULL, updated_at = %s
                   WHERE id = %s''',
                (json.dumps(info, ensure_ascii=False), now, resume_id),
            )
        connection.close()

    def update_extract_status(self, resume_id: int, status: str, error: str | None = None) -> None:
        now = datetime.now(UTC).isoformat()
        connection = get_connection(self.database_url)
        with connection, connection.cursor() as cursor:
            cursor.execute(
                '''UPDATE resumes SET extract_status = %s, extract_error = %s, updated_at = %s WHERE id = %s''',
                (status, error, now, resume_id),
            )
        connection.close()

    def update_resume(self, resume_id: int, name: str | None = None, keywords: list[str] | None = None, position_type: str | None = None, position_category: str | None = None) -> bool:
        now = datetime.now(UTC).isoformat()
        connection = get_connection(self.database_url)
        with connection, connection.cursor() as cursor:
            parts = []
            params: list = []
            if name is not None:
                parts.append('name = %s')
                params.append(name)
            if keywords is not None:
                parts.append('position_keywords = %s')
                params.append(json.dumps(keywords, ensure_ascii=False))
            if position_type is not None:
                parts.append('position_type = %s')
                params.append(position_type)
            if position_category is not None:
                parts.append('position_category = %s')
                params.append(position_category)
            if not parts:
                connection.close()
                return False
            parts.append('updated_at = %s')
            params.append(now)
            params.append(resume_id)
            cursor.execute(f'UPDATE resumes SET {", ".join(parts)} WHERE id = %s', params)
            updated = cursor.rowcount > 0
        connection.close()
        return updated

    def update_resume_info(self, resume_id: int, info: ResumeExtractedInfo) -> bool:
        now = datetime.now(UTC).isoformat()
        connection = get_connection(self.database_url)
        with connection, connection.cursor() as cursor:
            cursor.execute(
                '''UPDATE resumes SET extracted_info = %s, updated_at = %s WHERE id = %s''',
                (json.dumps(info.model_dump(), ensure_ascii=False), now, resume_id),
            )
            updated = cursor.rowcount > 0
        connection.close()
        return updated

    def delete_resume(self, resume_id: int) -> bool:
        connection = get_connection(self.database_url)
        with connection, connection.cursor() as cursor:
            cursor.execute('DELETE FROM resumes WHERE id = %s', (resume_id,))
            deleted = cursor.rowcount > 0
        connection.close()
        return deleted
