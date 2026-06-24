from __future__ import annotations

import sys
import unittest
from pathlib import Path


SRC_DIR = Path(__file__).resolve().parents[1] / 'src'
if str(SRC_DIR) not in sys.path:
    sys.path.insert(0, str(SRC_DIR))

from repositories.submission_repository import SubmissionRepository
from schemas.analysis import AnalysisLineRef, AnalysisResponse
from schemas.submissions import SubmissionCaseResult, SubmissionCreate, SubmissionResult
from tests.test_support import TemporaryDatabase


class FakeJudgeService:
    def evaluate(self, problem, payload, submission_id, created_at):
        return SubmissionResult(
            id=submission_id,
            problem_id=problem.id,
            language=payload.language,
            run_type=payload.run_type,
            code_text=payload.code_text,
            verdict='AC',
            runtime_ms=27,
            memory_kb=4096,
            compiler_output='',
            stderr_output='',
            failed_case_index=None,
            failed_input=None,
            failed_expected_output=None,
            failed_actual_output=None,
            case_results=[
                SubmissionCaseResult(
                    case_index=1,
                    case_type='hidden',
                    stdin_text='4\n7 1 8 2',
                    expected_output_text='7',
                    actual_output_text='7',
                    verdict='AC',
                    runtime_ms=27,
                    memory_kb=4096,
                    stderr_output='',
                )
            ],
            created_at=created_at,
        )


class SubmissionRepositoryTests(unittest.TestCase):
    def setUp(self) -> None:
        self.database = TemporaryDatabase()
        self.repository = SubmissionRepository(self.database.database_url, 'https://judge0.example.com')
        self.repository.judge_service = FakeJudgeService()

    def tearDown(self) -> None:
        self.database.close()

    def test_create_submission_persists_single_problem_and_language_binding(self) -> None:
        payload = SubmissionCreate(
            problem_id=1,
            language='Java',
            run_type='submit',
            code_text='class Main { public static void main(String[] args) { System.out.println(7); } }',
            custom_input='ignored',
        )

        created = self.repository.create_submission(payload)
        stored = self.repository.get_submission(created.id)

        self.assertIsNotNone(stored)
        assert stored is not None
        self.assertEqual(created.problem_id, 1)
        self.assertEqual(created.language, 'Java')
        self.assertEqual(stored.problem_id, 1)
        self.assertEqual(stored.language, 'Java')
        self.assertEqual(stored.run_type, 'submit')
        self.assertEqual(stored.verdict, 'AC')
        self.assertEqual(len(stored.case_results), 1)
        self.assertEqual(stored.case_results[0].verdict, 'AC')

    def test_create_submission_raises_when_problem_missing(self) -> None:
        payload = SubmissionCreate(
            problem_id=999,
            language='Python',
            run_type='run',
            code_text='def solve():\n    print(1)',
            custom_input='',
        )

        with self.assertRaisesRegex(ValueError, 'Problem not found'):
            self.repository.create_submission(payload)

    def test_get_submission_returns_none_for_missing_id(self) -> None:
        self.assertIsNone(self.repository.get_submission(99999))

    def test_list_submissions_filters_by_problem_and_returns_latest_first(self) -> None:
        first = self.repository.create_submission(
            SubmissionCreate(
                problem_id=1,
                language='Python',
                run_type='run',
                code_text='def solve():\n    print(1)',
                custom_input='',
            )
        )
        second = self.repository.create_submission(
            SubmissionCreate(
                problem_id=1,
                language='Java',
                run_type='submit',
                code_text='class Main { public static void main(String[] args) { System.out.println(2); } }',
                custom_input='',
            )
        )
        self.repository.create_submission(
            SubmissionCreate(
                problem_id=2,
                language='Python',
                run_type='submit',
                code_text='def solve():\n    print(3)',
                custom_input='',
            )
        )

        items = self.repository.list_submissions(problem_id=1, limit=10)

        self.assertEqual([item.id for item in items], [second.id, first.id])
        self.assertTrue(all(item.problem_id == 1 for item in items))

    def test_save_submission_analysis_persists_attribution_snapshot(self) -> None:
        created = self.repository.create_submission(
            SubmissionCreate(
                problem_id=1,
                language='Python',
                run_type='submit',
                code_text='def solve():\n    print(7)',
                custom_input='',
            )
        )
        analysis = AnalysisResponse(
            analysis_type='attribution',
            provider='OpenAI Compatible',
            model='attribution-model',
            endpoint_url='https://example.com/v1',
            title='错误归因',
            summary='已写回提交记录。',
            bullets=['先看 failed case。'],
            line_refs=[AnalysisLineRef(line=3, message='检查输出逻辑', severity='warning')],
            verdict='AC',
        )

        self.repository.save_submission_analysis(created.id, analysis)
        stored = self.repository.get_submission(created.id)

        self.assertIsNotNone(stored)
        assert stored is not None
        self.assertIsNotNone(stored.attribution_analysis)
        assert stored.attribution_analysis is not None
        self.assertEqual(stored.attribution_analysis.summary, '已写回提交记录。')
        self.assertEqual(stored.attribution_analysis.line_refs[0].line, 3)

    def test_save_submission_analysis_persists_review_snapshot(self) -> None:
        created = self.repository.create_submission(
            SubmissionCreate(
                problem_id=1,
                language='Python',
                run_type='submit',
                code_text='def solve():\n    print(7)',
                custom_input='',
            )
        )
        analysis = AnalysisResponse(
            analysis_type='review',
            provider='OpenAI Compatible',
            model='review-model',
            endpoint_url='https://example.com/v1',
            title='训练复盘',
            summary='复盘建议已写回。',
            bullets=['记录复杂度表达。'],
            line_refs=[],
            verdict='AC',
        )

        self.repository.save_submission_analysis(created.id, analysis)
        stored = self.repository.get_submission(created.id)

        self.assertIsNotNone(stored)
        assert stored is not None
        self.assertIsNotNone(stored.review_analysis)
        assert stored.review_analysis is not None
        self.assertEqual(stored.review_analysis.title, '训练复盘')
        self.assertEqual(stored.review_analysis.summary, '复盘建议已写回。')


if __name__ == '__main__':
    unittest.main()
