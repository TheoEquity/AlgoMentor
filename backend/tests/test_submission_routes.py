from __future__ import annotations

import asyncio
import sys
import unittest
from pathlib import Path


SRC_DIR = Path(__file__).resolve().parents[1] / 'src'
if str(SRC_DIR) not in sys.path:
    sys.path.insert(0, str(SRC_DIR))

from api.routes.submissions import create_submission
from schemas.analysis import AnalysisResponse
from schemas.llm_settings import LLMSettings
from schemas.problems import ExampleItem, ProblemDetail, ProblemTestCase
from schemas.submissions import SubmissionCaseResult, SubmissionCreate, SubmissionResult


class FakeSubmissionRepository:
    def __init__(self, result: SubmissionResult):
        self.result = result
        self.saved_analyses: list[tuple[int, str, str]] = []

    def create_submission(self, payload: SubmissionCreate) -> SubmissionResult:
        return self.result.model_copy(update={'code_text': payload.code_text})

    def save_submission_analysis(self, submission_id: int, analysis: AnalysisResponse) -> None:
        self.saved_analyses.append((submission_id, analysis.analysis_type, analysis.primary_category))


class FakeSettingsRepository:
    def get_settings(self) -> LLMSettings:
        return LLMSettings(
            id=1,
            provider='OpenAI Compatible',
            endpoint_url='https://example.com/v1',
            solution_model='solution-model',
            attribution_model='attribution-model',
            review_model='review-model',
            solution_temperature=0.2,
            attribution_temperature=0.1,
            review_temperature=0.3,
            enabled=True,
            api_key_configured=True,
            api_key_masked='sk-t...1234',
            updated_at='2026-06-24T00:00:00Z',
        )

    def get_api_key(self) -> str:
        return 'sk-test'


class FakeProblemRepository:
    def __init__(self, problem: ProblemDetail | None):
        self.problem = problem

    def get_problem(self, problem_id: int) -> ProblemDetail | None:
        if self.problem and self.problem.id == problem_id:
            return self.problem
        return None


class FakeAnalysisService:
    def __init__(self, should_fail: bool = False):
        self.should_fail = should_fail
        self.calls: list[tuple[int, str]] = []

    def attribute_error(self, settings, api_key, problem, submission) -> AnalysisResponse:
        self.calls.append((problem.id, submission.verdict))
        if self.should_fail:
            raise RuntimeError('analysis unavailable')
        return AnalysisResponse(
            analysis_type='attribution',
            provider=settings.provider,
            model=settings.attribution_model,
            endpoint_url=settings.endpoint_url,
            primary_category='答案错误',
            secondary_category='边界条件偏差',
            title='错误归因',
            summary='失败提交已自动归因。',
            bullets=['复现 failed case。'],
            line_refs=[],
            verdict=submission.verdict,
        )


def build_problem() -> ProblemDetail:
    return ProblemDetail(
        id=1,
        slug='array-partition-max-gap',
        title='数组划分后的最大差值',
        company='字节跳动',
        difficulty='Medium',
        category_slug='greedy',
        tags=['数组', '前后缀'],
        supported_languages=['Python', 'C++', 'Java'],
        status='未开始',
        updated_at='2026-06-23T16:00:00Z',
        statement_markdown='给定一个数组，求最大差值。',
        constraints_text='2 <= n <= 2 * 10^5',
        starter_templates={'Python': 'def solve():\n    pass'},
        examples=[ExampleItem(input='5\n1 3 2 5 4', output='4', explanation='sample')],
        test_cases=[ProblemTestCase(case_type='sample', stdin_text='5\n1 3 2 5 4', expected_output_text='4', sort_order=1)],
    )


def build_submission(verdict: str) -> SubmissionResult:
    return SubmissionResult(
        id=42,
        user_id=1,
        problem_id=1,
        language='Python',
        run_type='submit',
        code_text='def solve():\n    print(0)',
        verdict=verdict,
        runtime_ms=20,
        memory_kb=2048,
        compiler_output='',
        stderr_output='',
        failed_case_index=1 if verdict != 'AC' else None,
        failed_input='5\n1 3 2 5 4' if verdict != 'AC' else None,
        failed_expected_output='4' if verdict != 'AC' else None,
        failed_actual_output='0' if verdict != 'AC' else None,
        case_results=[
            SubmissionCaseResult(
                case_index=1,
                case_type='sample',
                stdin_text='5\n1 3 2 5 4',
                expected_output_text='4',
                actual_output_text='0' if verdict != 'AC' else '4',
                verdict=verdict,
                runtime_ms=20,
                memory_kb=2048,
                stderr_output='',
            )
        ],
        judge_token=None,
        created_at='2026-06-24T00:00:00Z',
    )


class SubmissionRouteTests(unittest.TestCase):
    def test_create_submission_auto_attributes_failed_result(self) -> None:
        repository = FakeSubmissionRepository(build_submission('WA'))
        service = FakeAnalysisService()

        response = asyncio.run(
            create_submission(
                SubmissionCreate(problem_id=1, language='Python', run_type='submit', code_text='def solve():\n    print(0)'),
                repository=repository,
                settings_repository=FakeSettingsRepository(),
                problem_repository=FakeProblemRepository(build_problem()),
                analysis_service=service,
            )
        )

        self.assertEqual(response.verdict, 'WA')
        self.assertEqual(service.calls, [(1, 'WA')])
        self.assertEqual(repository.saved_analyses, [(42, 'attribution', '答案错误')])

    def test_create_submission_skips_auto_attribution_for_ac(self) -> None:
        repository = FakeSubmissionRepository(build_submission('AC'))
        service = FakeAnalysisService()

        response = asyncio.run(
            create_submission(
                SubmissionCreate(problem_id=1, language='Python', run_type='submit', code_text='def solve():\n    print(4)'),
                repository=repository,
                settings_repository=FakeSettingsRepository(),
                problem_repository=FakeProblemRepository(build_problem()),
                analysis_service=service,
            )
        )

        self.assertEqual(response.verdict, 'AC')
        self.assertEqual(service.calls, [])
        self.assertEqual(repository.saved_analyses, [])

    def test_create_submission_returns_result_when_auto_attribution_fails(self) -> None:
        repository = FakeSubmissionRepository(build_submission('RE'))
        service = FakeAnalysisService(should_fail=True)

        response = asyncio.run(
            create_submission(
                SubmissionCreate(problem_id=1, language='Python', run_type='submit', code_text='def solve():\n    raise RuntimeError()'),
                repository=repository,
                settings_repository=FakeSettingsRepository(),
                problem_repository=FakeProblemRepository(build_problem()),
                analysis_service=service,
            )
        )

        self.assertEqual(response.verdict, 'RE')
        self.assertEqual(service.calls, [(1, 'RE')])
        self.assertEqual(repository.saved_analyses, [])


if __name__ == '__main__':
    unittest.main()
