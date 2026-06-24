from __future__ import annotations

import asyncio
import sys
import unittest
from pathlib import Path

from fastapi import HTTPException


SRC_DIR = Path(__file__).resolve().parents[1] / 'src'
if str(SRC_DIR) not in sys.path:
    sys.path.insert(0, str(SRC_DIR))

import json

from api.routes.analysis import analyze_attribution, analyze_attribution_stream
from schemas.analysis import AnalysisResponse, AttributionAnalysisRequest
from schemas.llm_settings import LLMSettings
from schemas.problems import ExampleItem, ProblemDetail, ProblemTestCase
from schemas.submissions import SubmissionCaseResult, SubmissionResult


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


class FakeSubmissionRepository:
    def __init__(self, submission: SubmissionResult | None):
        self.submission = submission
        self.saved_analyses: list[tuple[int, str, str]] = []

    def get_submission(self, submission_id: int) -> SubmissionResult | None:
        if self.submission and self.submission.id == submission_id:
            return self.submission
        return None

    def save_submission_analysis(self, submission_id: int, analysis: AnalysisResponse) -> None:
        self.saved_analyses.append((submission_id, analysis.analysis_type, analysis.summary))


class FakeAnalysisService:
    def __init__(self):
        self.calls: list[tuple[str, str, int, str]] = []

    def attribute_error(self, settings, api_key, problem, submission) -> AnalysisResponse:
        self.calls.append((settings.provider, api_key, problem.id, submission.verdict))
        return AnalysisResponse(
            analysis_type='attribution',
            provider=settings.provider,
            model=settings.attribution_model,
            endpoint_url=settings.endpoint_url,
            title='错误归因',
            summary='已绑定到对应提交。',
            bullets=['先复现当前失败提交。'],
            line_refs=[],
            verdict=submission.verdict,
        )

    def stream_error_attribution(self, settings, api_key, problem, submission):
        self.calls.append((settings.provider, api_key, problem.id, submission.verdict))
        yield ('meta', {'analysis_type': 'attribution', 'provider': settings.provider})
        yield ('chunk', {'text': '{"summary":"逐步归因"}'})
        yield ('title', {'title': '错误归因'})
        yield ('summary', {'summary': '逐步归因'})
        yield ('bullet', {'bullet': '先复现当前失败提交。'})
        yield ('line_ref', {'line': 7, 'message': '优先检查异常触发点。', 'severity': 'error'})
        yield (
            'done',
            AnalysisResponse(
                analysis_type='attribution',
                provider=settings.provider,
                model=settings.attribution_model,
                endpoint_url=settings.endpoint_url,
                title='错误归因',
                summary='流式结果已写回。',
                bullets=['先复现当前失败提交。'],
                line_refs=[],
                verdict=submission.verdict,
            ),
        )


async def collect_streaming_response(response) -> list[str]:
    chunks: list[str] = []
    async for item in response.body_iterator:
        chunks.append(item.decode('utf-8') if isinstance(item, bytes) else item)
    return chunks


class AnalysisRouteTests(unittest.TestCase):
    def setUp(self) -> None:
        self.problem = ProblemDetail(
            id=1,
            slug='array-partition-max-gap',
            title='数组划分后的最大差值',
            company='字节跳动',
            difficulty='Medium',
            category_slug='greedy',
            tags=['数组', '前后缀'],
            supported_languages=['Python', 'C++', 'Java'],
            status='published',
            updated_at='2026-06-23T16:00:00Z',
            statement_markdown='给定一个数组，求最大差值。',
            constraints_text='2 <= n <= 2 * 10^5',
            starter_templates={'Python': 'def solve():\n    pass'},
            examples=[ExampleItem(input='5\n1 3 2 5 4', output='4', explanation='sample')],
            test_cases=[
                ProblemTestCase(case_type='sample', stdin_text='5\n1 3 2 5 4', expected_output_text='4', sort_order=1)
            ],
        )
        self.submission = SubmissionResult(
            id=42,
            user_id=1,
            problem_id=1,
            language='Python',
            run_type='submit',
            code_text='def solve():\n    print(0)',
            verdict='RE',
            runtime_ms=20,
            memory_kb=2048,
            compiler_output='',
            stderr_output='IndexError on line 7',
            failed_case_index=1,
            failed_input='5\n1 3 2 5 4',
            failed_expected_output='4',
            failed_actual_output='',
            case_results=[
                SubmissionCaseResult(
                    case_index=1,
                    case_type='sample',
                    stdin_text='5\n1 3 2 5 4',
                    expected_output_text='4',
                    actual_output_text='',
                    verdict='RE',
                    runtime_ms=20,
                    memory_kb=2048,
                    stderr_output='IndexError on line 7',
                )
            ],
            judge_token=None,
            created_at='2026-06-24T00:00:00Z',
        )
        self.settings_repository = FakeSettingsRepository()

    def test_analyze_attribution_binds_existing_submission_to_problem_context(self) -> None:
        service = FakeAnalysisService()
        submission_repository = FakeSubmissionRepository(self.submission)
        response = asyncio.run(
            analyze_attribution(
                AttributionAnalysisRequest(submission_id=42),
                settings_repository=self.settings_repository,
                problem_repository=FakeProblemRepository(self.problem),
                submission_repository=submission_repository,
                analysis_service=service,
            )
        )

        self.assertEqual(response.analysis_type, 'attribution')
        self.assertEqual(response.verdict, 'RE')
        self.assertEqual(service.calls, [('OpenAI Compatible', 'sk-test', 1, 'RE')])
        self.assertEqual(submission_repository.saved_analyses, [(42, 'attribution', '已绑定到对应提交。')])

    def test_analyze_attribution_returns_404_when_submission_missing(self) -> None:
        with self.assertRaises(HTTPException) as ctx:
            asyncio.run(
                analyze_attribution(
                    AttributionAnalysisRequest(submission_id=999),
                    settings_repository=self.settings_repository,
                    problem_repository=FakeProblemRepository(self.problem),
                    submission_repository=FakeSubmissionRepository(None),
                    analysis_service=FakeAnalysisService(),
                )
            )

        self.assertEqual(ctx.exception.status_code, 404)
        self.assertEqual(ctx.exception.detail, 'Submission not found')

    def test_analyze_attribution_returns_404_when_problem_missing(self) -> None:
        with self.assertRaises(HTTPException) as ctx:
            asyncio.run(
                analyze_attribution(
                    AttributionAnalysisRequest(submission_id=42),
                    settings_repository=self.settings_repository,
                    problem_repository=FakeProblemRepository(None),
                    submission_repository=FakeSubmissionRepository(self.submission),
                    analysis_service=FakeAnalysisService(),
                )
            )

        self.assertEqual(ctx.exception.status_code, 404)
        self.assertEqual(ctx.exception.detail, 'Problem not found')

    def test_analyze_attribution_stream_persists_done_payload(self) -> None:
        service = FakeAnalysisService()
        submission_repository = FakeSubmissionRepository(self.submission)
        response = asyncio.run(
            analyze_attribution_stream(
                AttributionAnalysisRequest(submission_id=42),
                settings_repository=self.settings_repository,
                problem_repository=FakeProblemRepository(self.problem),
                submission_repository=submission_repository,
                analysis_service=service,
            )
        )

        chunks = asyncio.run(collect_streaming_response(response))

        self.assertTrue(any('event: meta' in chunk for chunk in chunks))
        self.assertTrue(any('event: chunk' in chunk for chunk in chunks))
        self.assertTrue(any('event: title' in chunk for chunk in chunks))
        self.assertTrue(any('event: summary' in chunk for chunk in chunks))
        self.assertTrue(any('event: bullet' in chunk for chunk in chunks))
        self.assertTrue(any('event: line_ref' in chunk for chunk in chunks))
        self.assertTrue(any('event: done' in chunk for chunk in chunks))
        self.assertEqual(submission_repository.saved_analyses, [(42, 'attribution', '流式结果已写回。')])

        done_payload = next(chunk for chunk in chunks if 'event: done' in chunk)
        data_text = done_payload.split('data:', 1)[1].strip()
        parsed = json.loads(data_text)
        self.assertEqual(parsed['summary'], '流式结果已写回。')


if __name__ == '__main__':
    unittest.main()
