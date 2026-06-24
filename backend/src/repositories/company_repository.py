from __future__ import annotations

from core.db import get_connection
from schemas.companies import Company, CompanyCreate, CompanyUpdate


class CompanyRepository:
    def __init__(self, database_url: str) -> None:
        self._database_url = database_url

    def list_companies(self) -> list[Company]:
        connection = get_connection(self._database_url)
        with connection, connection.cursor() as cursor:
            cursor.execute('SELECT * FROM companies ORDER BY id')
            rows = cursor.fetchall()
            return [Company(**row) for row in rows]

    def create_company(self, payload: CompanyCreate) -> Company:
        connection = get_connection(self._database_url)
        now = self._now()
        with connection, connection.cursor() as cursor:
            cursor.execute(
                'INSERT INTO companies (name, name_en, abbreviation, created_at) VALUES (%s, %s, %s, %s) RETURNING id',
                (payload.name, payload.name_en, payload.abbreviation, now),
            )
            row = cursor.fetchone()
            return Company(
                id=row['id'],
                name=payload.name,
                name_en=payload.name_en,
                abbreviation=payload.abbreviation,
                created_at=now,
            )

    def update_company(self, company_id: int, payload: CompanyUpdate) -> Company | None:
        connection = get_connection(self._database_url)
        with connection, connection.cursor() as cursor:
            cursor.execute('SELECT * FROM companies WHERE id = %s', (company_id,))
            existing = cursor.fetchone()
            if not existing:
                return None

            name = payload.name if payload.name is not None else existing['name']
            name_en = payload.name_en if payload.name_en is not None else existing['name_en']
            abbreviation = payload.abbreviation if payload.abbreviation is not None else existing['abbreviation']

            cursor.execute(
                'UPDATE companies SET name = %s, name_en = %s, abbreviation = %s WHERE id = %s',
                (name, name_en, abbreviation, company_id),
            )
            cursor.execute('SELECT * FROM companies WHERE id = %s', (company_id,))
            return Company(**cursor.fetchone())

    def delete_company(self, company_id: int) -> bool:
        connection = get_connection(self._database_url)
        with connection, connection.cursor() as cursor:
            cursor.execute('DELETE FROM companies WHERE id = %s', (company_id,))
            return cursor.rowcount > 0

    @staticmethod
    def _now() -> str:
        from datetime import datetime, timezone
        return datetime.now(timezone.utc).strftime('%Y-%m-%dT%H:%M:%SZ')
