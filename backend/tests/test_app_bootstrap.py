from __future__ import annotations

import asyncio
import os
import sys
import unittest
from pathlib import Path
from unittest.mock import patch


SRC_DIR = Path(__file__).resolve().parents[1] / 'src'
if str(SRC_DIR) not in sys.path:
    sys.path.insert(0, str(SRC_DIR))

from config import Settings
from main import app, healthz, lifespan, settings


class AppBootstrapTests(unittest.TestCase):
    def test_settings_defaults_are_loaded(self) -> None:
        current = Settings()

        self.assertEqual(current.app_name, 'ByteHunter Backend')
        self.assertEqual(current.api_prefix, '/api/v1')
        self.assertEqual(current.database_url, 'postgresql://bytehunter:bytehunter123@localhost:5432/bytehunter')
        self.assertEqual(current.judge0_url, 'https://ce.judge0.com')

    def test_settings_can_be_overridden_by_environment(self) -> None:
        with patch.dict(
            os.environ,
            {
                'BYTEHUNTER_APP_NAME': 'Test Backend',
                'BYTEHUNTER_API_PREFIX': '/test-api',
                'BYTEHUNTER_DATABASE_URL': 'postgresql://bytehunter:bytehunter123@localhost:5432/bytehunter_env_test',
                'BYTEHUNTER_JUDGE0_URL': 'https://judge0.example.com',
            },
            clear=False,
        ):
            overridden = Settings()

        self.assertEqual(overridden.app_name, 'Test Backend')
        self.assertEqual(overridden.api_prefix, '/test-api')
        self.assertEqual(overridden.database_url, 'postgresql://bytehunter:bytehunter123@localhost:5432/bytehunter_env_test')
        self.assertEqual(overridden.judge0_url, 'https://judge0.example.com')

    def test_lifespan_initializes_database_with_current_settings(self) -> None:
        async def run_lifespan() -> None:
            async with lifespan(app):
                return None

        with patch('main.initialize_database') as mocked_initialize:
            original_database_url = settings.database_url
            settings.database_url = 'postgresql://bytehunter:bytehunter123@localhost:5432/bytehunter_lifespan_test'
            try:
                asyncio.run(run_lifespan())
            finally:
                settings.database_url = original_database_url

        mocked_initialize.assert_called_once_with('postgresql://bytehunter:bytehunter123@localhost:5432/bytehunter_lifespan_test')

    def test_healthz_returns_ok_status(self) -> None:
        payload = asyncio.run(healthz())
        self.assertEqual(payload, {'status': 'ok'})

    def test_app_registers_prefixed_api_routes(self) -> None:
        route_paths = set(app.openapi()['paths'].keys())
        self.assertIn('/api/v1/problems', route_paths)
        self.assertIn('/api/v1/submissions', route_paths)
        self.assertIn('/api/v1/analysis/solution', route_paths)


if __name__ == '__main__':
    unittest.main()
