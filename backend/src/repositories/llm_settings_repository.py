from __future__ import annotations

from datetime import UTC, datetime

from core.db import get_connection
from schemas.llm_settings import LLMSettings, LLMSettingsUpdate


class LLMSettingsRepository:
    def __init__(self, database_url: str):
        self.database_url = database_url

    def get_settings(self) -> LLMSettings:
        connection = get_connection(self.database_url)
        with connection, connection.cursor() as cursor:
            cursor.execute('SELECT * FROM llm_settings WHERE id = 1')
            row = cursor.fetchone()
        connection.close()
        if row is None:
            raise RuntimeError('LLM settings row not initialized')

        return self._from_row(row)

    def update_settings(self, payload: LLMSettingsUpdate) -> LLMSettings:
        updated_at = datetime.now(UTC).isoformat()
        connection = get_connection(self.database_url)

        with connection, connection.cursor() as cursor:
            cursor.execute('SELECT api_key_secret FROM llm_settings WHERE id = 1')
            current_row = cursor.fetchone()
        current_api_key = current_row['api_key_secret'] if current_row is not None else ''
        next_api_key = current_api_key
        if payload.clear_api_key:
            next_api_key = ''
        elif payload.api_key is not None and payload.api_key != '':
            next_api_key = payload.api_key

        with connection, connection.cursor() as cursor:
            cursor.execute(
                '''
                UPDATE llm_settings
                SET provider = %s, endpoint_url = %s,
                    solution_model = %s, attribution_model = %s, review_model = %s,
                    solution_temperature = %s, attribution_temperature = %s,
                    review_temperature = %s, api_key_secret = %s,
                    enabled = %s, updated_at = %s
                WHERE id = 1
                ''',
                (
                    payload.provider,
                    payload.endpoint_url,
                    payload.solution_model,
                    payload.attribution_model,
                    payload.review_model,
                    payload.solution_temperature,
                    payload.attribution_temperature,
                    payload.review_temperature,
                    next_api_key,
                    1 if payload.enabled else 0,
                    updated_at,
                ),
            )

        connection.close()
        return self.get_settings()

    def _from_row(self, row: dict) -> LLMSettings:
        return LLMSettings(
            id=row['id'],
            provider=row['provider'],
            endpoint_url=row['endpoint_url'],
            solution_model=row['solution_model'],
            attribution_model=row['attribution_model'],
            review_model=row['review_model'],
            solution_temperature=row['solution_temperature'],
            attribution_temperature=row['attribution_temperature'],
            review_temperature=row['review_temperature'],
            api_key_configured=bool(row['api_key_secret']),
            api_key_masked=self._mask_api_key(row['api_key_secret'] or ''),
            enabled=bool(row['enabled']),
            updated_at=row['updated_at'],
        )

    def get_api_key(self) -> str:
        connection = get_connection(self.database_url)
        with connection, connection.cursor() as cursor:
            cursor.execute('SELECT api_key_secret FROM llm_settings WHERE id = 1')
            row = cursor.fetchone()
        connection.close()
        return '' if row is None else row['api_key_secret'] or ''

    @staticmethod
    def _mask_api_key(api_key: str) -> str:
        if not api_key:
            return ''
        if len(api_key) <= 8:
            return '*' * len(api_key)
        return f'{api_key[:4]}...{api_key[-4:]}'
