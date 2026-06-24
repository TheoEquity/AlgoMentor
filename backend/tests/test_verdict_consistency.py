from __future__ import annotations

import sys
import unittest
from pathlib import Path


SRC_DIR = Path(__file__).resolve().parents[1] / 'src'
if str(SRC_DIR) not in sys.path:
    sys.path.insert(0, str(SRC_DIR))

from repositories.review_repository import ReviewRepository
from repositories.submission_repository import SubmissionRepository
from repositories.training_repository import TrainingRepository
from schemas.submissions import SubmissionCaseResult, SubmissionCreate, SubmissionResult
from tests.test_support import TEST_DATABASE_URL, reset_test_database


class FakeJudgeService:
    def evaluate(self, problem, payload, submission_id, created_at):
        return SubmissionResult(
            id=submission_id,
            user_id=1,
            problem_id=problem.id,
            language=payload.language,
            run_type=payload.run_type,
            code_text=payload.code_text,
            verdict='WA',
            runtime_ms=321,
            memory_kb=65432,
            compiler_output='',
            stderr_output='',
            failed_case_index=1,
            failed_input='4\n7 1 8 2',
            failed_expected_output='7',
            failed_actual_output='6',
            case_results=[
                SubmissionCaseResult(
                    case_index=1,
                    case_type='hidden',
                    stdin_text='4\n7 1 8 2',
                    expected_output_text='7',
                    actual_output_text='6',
                    verdict='WA',
                    runtime_ms=321,
                    memory_kb=65432,
                    stderr_output='',
                )
            ],
            judge_token=None,
            created_at=created_at,
        )


class VerdictConsistencyTests(unittest.TestCase):
    def setUp(self) -> None:
        reset_test_database()
        self.submission_repository = SubmissionRepository(TEST_DATABASE_URL, 'https://judge0.example.com')
        self.submission_repository.judge_service = FakeJudgeService()
        self.review_repository = ReviewRepository(TEST_DATABASE_URL)
        self.training_repository = TrainingRepository(TEST_DATABASE_URL)

    def test_review_and_training_use_same_normalized_verdict_runtime_memory(self) -> None:
        created = self.submission_repository.create_submission(
            SubmissionCreate(
                problem_id=1,
                language='Python',
                run_type='submit',
                code_text='def solve():\n    print(6)',
                custom_input='',
            )
        )
        stored = self.submission_repository.get_submission(created.id)
        review_payload = self.review_repository.list_reviews(
            wrong_only=False,
            company=None,
            tag=None,
            error_type='WA',
        )
        training_payload = self.training_repository.get_overview()

        self.assertIsNotNone(stored)
        assert stored is not None
        review_item = next(item for item in review_payload.items if item.submission_id == created.id)
        training_item = next(item for item in training_payload.recent_items if item.submission_id == created.id)
        wa_bucket = next(bucket for bucket in training_payload.error_buckets if bucket.verdict == 'WA')

        self.assertEqual(stored.verdict, 'WA')
        self.assertEqual(stored.runtime_ms, 321)
        self.assertEqual(stored.memory_kb, 65432)
        self.assertEqual(review_item.verdict, stored.verdict)
        self.assertEqual(review_item.runtime_ms, stored.runtime_ms)
        self.assertEqual(review_item.memory_kb, stored.memory_kb)
        self.assertEqual(training_item.verdict, stored.verdict)
        self.assertEqual(wa_bucket.count, 1)


if __name__ == '__main__':
    unittest.main()
