from __future__ import annotations

from datetime import UTC, datetime

from core.db import get_connection
from schemas.website import CareerSiteCreate, CareerSiteUpdate, CareerSiteListItem


class WebsiteRepository:
    def __init__(self, database_url: str) -> None:
        self.database_url = database_url

    def list_sites(self) -> list[CareerSiteListItem]:
        connection = get_connection(self.database_url)
        with connection, connection.cursor() as cursor:
            cursor.execute('SELECT * FROM career_sites ORDER BY updated_at DESC, id DESC')
            rows = cursor.fetchall()
        connection.close()
        return [CareerSiteListItem(**r) for r in rows]

    def get_site(self, site_id: int) -> CareerSiteListItem | None:
        connection = get_connection(self.database_url)
        try:
            with connection, connection.cursor() as cursor:
                cursor.execute('SELECT * FROM career_sites WHERE id = %s', (site_id,))
                row = cursor.fetchone()
                if row is None:
                    return None
                return CareerSiteListItem(**row)
        finally:
            connection.close()

    def create_site(self, payload: CareerSiteCreate) -> int:
        now = datetime.now(UTC).isoformat()
        connection = get_connection(self.database_url)
        with connection, connection.cursor() as cursor:
            cursor.execute(
                '''INSERT INTO career_sites (company_name, url, notes, industry_category, referral_code, account, password, created_at, updated_at)
                   VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s) RETURNING id''',
                (payload.company_name, payload.url, payload.notes or '',
                 payload.industry_category, payload.referral_code,
                 payload.account, payload.password, now, now),
            )
            site_id = cursor.fetchone()['id']
        connection.close()
        return site_id

    def update_site(self, site_id: int, payload: CareerSiteUpdate) -> bool:
        now = datetime.now(UTC).isoformat()
        connection = get_connection(self.database_url)
        with connection, connection.cursor() as cursor:
            parts = []
            params: list = []
            if payload.company_name is not None:
                parts.append('company_name = %s')
                params.append(payload.company_name)
            if payload.url is not None:
                parts.append('url = %s')
                params.append(payload.url)
            if payload.notes is not None:
                parts.append('notes = %s')
                params.append(payload.notes)
            if payload.industry_category is not None:
                parts.append('industry_category = %s')
                params.append(payload.industry_category)
            if payload.referral_code is not None:
                parts.append('referral_code = %s')
                params.append(payload.referral_code)
            if payload.account is not None:
                parts.append('account = %s')
                params.append(payload.account)
            if payload.password is not None:
                parts.append('password = %s')
                params.append(payload.password)
            if not parts:
                connection.close()
                return False
            parts.append('updated_at = %s')
            params.append(now)
            params.append(site_id)
            cursor.execute(f'UPDATE career_sites SET {", ".join(parts)} WHERE id = %s', params)
            updated = cursor.rowcount > 0
        connection.close()
        return updated

    def update_scrape_status(self, site_id: int, status: str, error: str | None = None, position_count: int | None = None) -> None:
        now = datetime.now(UTC).isoformat()
        connection = get_connection(self.database_url)
        with connection, connection.cursor() as cursor:
            parts = ['scrape_status = %s', 'updated_at = %s']
            params: list = [status, now]
            if status in ('success', 'failed'):
                parts.append('last_scraped_at = %s')
                params.append(now)
            if error is not None:
                parts.append('scrape_error = %s')
                params.append(error)
            if position_count is not None:
                parts.append('position_count = %s')
                params.append(position_count)
            params.append(site_id)
            cursor.execute(f'UPDATE career_sites SET {", ".join(parts)} WHERE id = %s', params)
        connection.close()

    def delete_site(self, site_id: int) -> bool:
        connection = get_connection(self.database_url)
        with connection, connection.cursor() as cursor:
            cursor.execute('DELETE FROM career_sites WHERE id = %s', (site_id,))
            deleted = cursor.rowcount > 0
        connection.close()
        return deleted
