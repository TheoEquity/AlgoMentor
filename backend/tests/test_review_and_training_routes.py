from __future__ import annotations

import asyncio
import sys
import unittest
from pathlib import Path


SRC_DIR = Path(__file__).resolve().parents[1] / 'src'
if str(SRC_DIR) not in sys.path:
    sys.path.insert(0, str(SRC_DIR))

from api.routes.review import list_reviews
from api.routes.training import get_training_overview
from repositories.review_repository import ReviewRepository
from repositories.training_repository import TrainingRepository
from tests.test_support import TEST_DATABASE_URL, insert_submission, reset_test_database


class ReviewAndTrainingRouteTests(unittest.TestCase):
    def setUp(self) -> None:
        reset_test_database()
        self.review_repository = ReviewRepository(TEST_DATABASE_URL)
        self.training_repository = TrainingRepository(TEST_DATABASE_URL)

        insert_submission(
            problem_id=1,
            language='Python',
            run_type='submit',
            verdict='WA',
            created_at='2026-06-23T09:00:00Z',
            failed_input='5\n1 2 3 4 5\n',
            failed_expected_output='9\n',
            failed_actual_output='8\n',
        )
        insert_submission(
            problem_id=1,
            language='Python',
            run_type='submit',
            verdict='AC',
            created_at='2026-06-23T10:00:00Z',
        )
        insert_submission(
            problem_id=2,
            language='Java',
            run_type='run',
            verdict='RE',
            created_at='2026-06-23T11:00:00Z',
            failed_input='(()\n',
        )

    def test_review_route_filters_wrong_submissions_and_company(self) -> None:
        payload = asyncio.run(
            list_reviews(
                wrong_only=True,
                company='字节跳动',
                tag=None,
                error_type=None,
                repository=self.review_repository,
            )
        )

        self.assertEqual(payload.summary.total_submissions, 1)
        self.assertEqual(payload.summary.wrong_submissions, 1)
        self.assertEqual(payload.summary.top_error_type, 'WA')
        self.assertEqual([item.verdict for item in payload.items], ['WA'])
        self.assertIn('Expected: 9', payload.items[0].failed_case_summary)

    def test_review_route_filters_by_tag_and_error_type(self) -> None:
        payload = asyncio.run(
            list_reviews(
                wrong_only=False,
                company=None,
                tag='栈',
                error_type='RE',
                repository=self.review_repository,
            )
        )

        self.assertEqual(payload.summary.total_submissions, 1)
        self.assertEqual(payload.items[0].problem_id, 2)
        self.assertEqual(payload.items[0].error_type, 'RE')

    def test_training_overview_returns_summary_buckets_and_recommendations(self) -> None:
        payload = asyncio.run(get_training_overview(repository=self.training_repository))

        self.assertEqual(payload.summary.total_runs, 3)
        self.assertEqual(payload.summary.ac_count, 1)
        self.assertEqual(payload.summary.wrong_count, 2)
        self.assertEqual(payload.summary.submit_count, 2)
        self.assertEqual(payload.summary.main_error_type, 'RE')
        self.assertTrue(any(bucket.verdict == 'WA' for bucket in payload.error_buckets))
        self.assertTrue(any(bucket.verdict == 'RE' for bucket in payload.error_buckets))
        self.assertEqual(payload.recent_items[0].submission_id, 3)
        self.assertGreaterEqual(len(payload.recommendations), 2)


if __name__ == '__main__':
    unittest.main()
