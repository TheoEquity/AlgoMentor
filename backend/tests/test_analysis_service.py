from __future__ import annotations

import sys
import unittest
from pathlib import Path
from unittest.mock import Mock


SRC_DIR = Path(__file__).resolve().parents[1] / 'src'
if str(SRC_DIR) not in sys.path:
    sys.path.insert(0, str(SRC_DIR))

from schemas.analysis import AnalysisResponse
from schemas.llm_settings import LLMSettings
from schemas.problems import ExampleItem, ProblemDetail, ProblemTestCase
from schemas.submissions import SubmissionCaseResult, SubmissionResult
from services.analysis_service import AnalysisService
from services.llm_client import LLMClientError


class AnalysisServiceTests(unittest.TestCase):
    def setUp(self) -> None:
        self.service = AnalysisService()
        self.service.client = Mock()
        self.settings = LLMSettings(
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
            id=11,
            user_id=1,
            problem_id=1,
            language='Python',
            run_type='submit',
            code_text='def solve():\n    print(0)',
            verdict='WA',
            runtime_ms=18,
            memory_kb=2048,
            compiler_output='',
            stderr_output='',
            failed_case_index=1,
            failed_input='5\n1 3 2 5 4',
            failed_expected_output='4',
            failed_actual_output='0',
            case_results=[
                SubmissionCaseResult(
                    case_index=1,
                    case_type='sample',
                    stdin_text='5\n1 3 2 5 4',
                    expected_output_text='4',
                    actual_output_text='0',
                    verdict='WA',
                    runtime_ms=18,
                    memory_kb=2048,
                    stderr_output='',
                )
            ],
            judge_token=None,
            created_at='2026-06-24T00:00:00Z',
        )

    def test_solution_analysis_normalizes_object_payload(self) -> None:
        self.service.client.generate_json.return_value = {
            'title': '前后缀思路',
            'summary': '可以用线性扫描完成。',
            'bullets': [{'title': '复杂度', 'summary': '时间 O(n)，空间 O(1)。'}],
            'line_refs': {'line': 3, 'message': '关注状态转移', 'severity': 'warning'},
        }

        response = self.service.analyze_solution(
            self.settings,
            'sk-test',
            self.problem,
            'Python',
            'def solve():\n    prefix = 0\n    print(prefix)',
        )

        self.assertEqual(response.analysis_type, 'solution')
        self.assertEqual(response.title, '前后缀思路')
        self.assertEqual(response.bullets, ['复杂度: 时间 O(n)，空间 O(1)。'])
        self.assertEqual(len(response.line_refs), 1)
        self.assertEqual(response.line_refs[0].line, 3)

    def test_attribution_analysis_normalizes_list_payload(self) -> None:
        self.service.client.generate_json.return_value = [
            '先检查边界条件。',
            '再检查最终输出格式。',
        ]

        response = self.service.attribute_error(self.settings, 'sk-test', self.problem, self.submission)

        self.assertEqual(response.analysis_type, 'attribution')
        self.assertEqual(response.verdict, 'WA')
        self.assertEqual(response.title, '错误归因')
        self.assertIn('先检查边界条件。', response.bullets)

    def test_review_analysis_falls_back_when_model_fails(self) -> None:
        self.service.client.generate_json.side_effect = LLMClientError('系统管理中尚未配置 API Key')

        response = self.service.review_submission(self.settings, '', self.problem, self.submission)

        self.assertEqual(response.analysis_type, 'review')
        self.assertEqual(response.verdict, 'WA')
        self.assertIn('降级结果', response.summary)
        self.assertGreaterEqual(len(response.bullets), 3)

    def test_solution_analysis_clamps_invalid_line_and_severity(self) -> None:
        self.service.client.generate_json.return_value = {
            'title': '细节检查',
            'summary': '关注入口。',
            'bullets': ['检查模板入口'],
            'line_refs': [{'line': 0, 'message': '无效行号', 'severity': 'fatal'}],
        }

        response = self.service.analyze_solution(
            self.settings,
            'sk-test',
            self.problem,
            'Python',
            'def solve():\n    pass',
        )

        self.assertEqual(response.line_refs[0].line, 1)
        self.assertEqual(response.line_refs[0].severity, 'warning')

    def test_stream_solution_analysis_emits_meta_chunk_and_done(self) -> None:
        self.service.client.stream_text.return_value = iter([
            '{"title":"流式归因","summary":"',
            '逐步输出","bullets":["先看边界"],"line_refs":[{"line":3,"message":"关注边界","severity":"warning"}]}',
        ])
        self.service.client.parse_json_content.return_value = {
            'title': '流式归因',
            'summary': '逐步输出',
            'bullets': ['先看边界'],
            'line_refs': [{'line': 3, 'message': '关注边界', 'severity': 'warning'}],
        }

        events = list(
            self.service.stream_solution_analysis(
                self.settings,
                'sk-test',
                self.problem,
                'Python',
                'def solve():\n    pass',
            )
        )

        self.assertEqual(events[0][0], 'meta')
        self.assertEqual(events[1][0], 'chunk')
        event_names = [event[0] for event in events]
        self.assertIn('title', event_names)
        self.assertIn('summary', event_names)
        self.assertIn('bullet', event_names)
        self.assertIn('line_ref', event_names)
        self.assertEqual(events[-1][0], 'done')
        self.assertIsInstance(events[-1][1], AnalysisResponse)
        final_response = events[-1][1]
        assert isinstance(final_response, AnalysisResponse)
        self.assertEqual(final_response.summary, '逐步输出')
        self.assertEqual(final_response.bullets, ['先看边界'])
        self.assertEqual(final_response.line_refs[0].line, 3)


if __name__ == '__main__':
    unittest.main()
