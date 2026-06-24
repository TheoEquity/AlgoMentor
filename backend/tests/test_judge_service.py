from __future__ import annotations

import sys
import unittest
from pathlib import Path
from unittest.mock import patch


SRC_DIR = Path(__file__).resolve().parents[1] / 'src'
if str(SRC_DIR) not in sys.path:
    sys.path.insert(0, str(SRC_DIR))

from schemas.problems import ExampleItem, ProblemDetail, ProblemTestCase
from schemas.submissions import SubmissionCreate
from services.judge_service import JudgeService


class JudgeServiceTests(unittest.TestCase):
    def setUp(self) -> None:
        self.service = JudgeService('https://judge0.example.com')
        self.problem = ProblemDetail(
            id=99,
            slug='test-problem',
            title='Test Problem',
            company='ByteDance',
            department='Infra',
            difficulty='Medium',
            tags=['array'],
            supported_languages=['Python', 'C++', 'Java'],
            status='published',
            updated_at='2026-06-23T00:00:00Z',
            statement_markdown='Solve the sample problem correctly.',
            constraints_text='1 <= n <= 10^5',
            starter_templates={
                'Python': 'def solve():\n    pass',
                'C++': 'int main() { return 0; }',
                'Java': 'class Main { public static void main(String[] args) {} }',
            },
            examples=[ExampleItem(input='1\n', output='1\n', explanation='sample')],
            test_cases=[
                ProblemTestCase(
                    case_type='sample',
                    stdin_text='1\n',
                    expected_output_text='1\n',
                    sort_order=1,
                ),
                ProblemTestCase(
                    case_type='hidden',
                    stdin_text='2\n',
                    expected_output_text='2\n',
                    sort_order=2,
                )
            ],
        )

    def _payload(self, language: str) -> SubmissionCreate:
        code_by_language = {
            'Python': 'def solve():\n    print(1)',
            'C++': '#include <bits/stdc++.h>\nint main(){std::cout << 1; return 0;}',
            'Java': 'class Main { public static void main(String[] args) { System.out.println(1); } }',
        }
        return SubmissionCreate(
            problem_id=self.problem.id,
            language=language,
            run_type='submit',
            code_text=code_by_language[language],
            custom_input='',
        )

    def _assert_verdict(self, language: str, judge0_result: dict, expected_verdict: str) -> None:
        with patch.object(self.service, '_create_submission_and_wait', return_value=judge0_result):
            result = self.service.evaluate(
                self.problem,
                self._payload(language),
                submission_id=1,
                created_at='2026-06-23T00:00:00Z',
            )

        self.assertEqual(result.language, language)
        self.assertEqual(result.verdict, expected_verdict)
        self.assertEqual(len(result.case_results), 1)
        self.assertEqual(result.case_results[0].verdict, expected_verdict)

    def test_python_ac_result_is_normalized(self) -> None:
        self._assert_verdict(
            'Python',
            {
                'status': {'id': 3, 'description': 'Accepted'},
                'stdout': '1\n',
                'stderr': '',
                'compile_output': '',
                'message': '',
                'time': '0.011',
                'memory': 2048,
            },
            'AC',
        )

    def test_python_wa_result_exposes_failed_case(self) -> None:
        with patch.object(
            self.service,
            '_create_submission_and_wait',
            return_value={
                'status': {'id': 4, 'description': 'Wrong Answer'},
                'stdout': '0\n',
                'stderr': '',
                'compile_output': '',
                'message': '',
                'time': '0.022',
                'memory': 3072,
            },
        ):
            result = self.service.evaluate(
                self.problem,
                self._payload('Python'),
                submission_id=2,
                created_at='2026-06-23T00:00:00Z',
            )

        self.assertEqual(result.verdict, 'WA')
        self.assertEqual(result.failed_case_index, 1)
        self.assertEqual(result.failed_expected_output, '2\n')
        self.assertEqual(result.failed_actual_output, '0')

    def test_cpp_compilation_error_uses_compiler_output(self) -> None:
        with patch.object(
            self.service,
            '_create_submission_and_wait',
            return_value={
                'status': {'id': 6, 'description': 'Compilation Error'},
                'stdout': '',
                'stderr': '',
                'compile_output': 'main.cpp:1: error: expected ;',
                'message': '',
                'time': None,
                'memory': None,
            },
        ):
            result = self.service.evaluate(
                self.problem,
                self._payload('C++'),
                submission_id=3,
                created_at='2026-06-23T00:00:00Z',
            )

        self.assertEqual(result.verdict, 'CE')
        self.assertIn('expected ;', result.compiler_output)

    def test_cpp_runtime_error_uses_stderr(self) -> None:
        with patch.object(
            self.service,
            '_create_submission_and_wait',
            return_value={
                'status': {'id': 7, 'description': 'Runtime Error (NZEC)'},
                'stdout': '',
                'stderr': 'Segmentation fault',
                'compile_output': '',
                'message': '',
                'time': '0.015',
                'memory': 4096,
            },
        ):
            result = self.service.evaluate(
                self.problem,
                self._payload('C++'),
                submission_id=4,
                created_at='2026-06-23T00:00:00Z',
            )

        self.assertEqual(result.verdict, 'RE')
        self.assertEqual(result.stderr_output, 'Segmentation fault')

    def test_java_time_limit_exceeded_is_normalized(self) -> None:
        self._assert_verdict(
            'Java',
            {
                'status': {'id': 5, 'description': 'Time Limit Exceeded'},
                'stdout': '',
                'stderr': '',
                'compile_output': '',
                'message': 'Time limit exceeded',
                'time': '2.000',
                'memory': 8192,
            },
            'TLE',
        )

    def test_judge0_failure_falls_back_to_simulated_result(self) -> None:
        payload = SubmissionCreate(
            problem_id=self.problem.id,
            language='Python',
            run_type='submit',
            code_text='def solve():\n    while True:\n        pass',
            custom_input='',
        )
        with patch.object(self.service, '_create_submission_and_wait', side_effect=RuntimeError('judge0 down')):
            result = self.service.evaluate(
                self.problem,
                payload,
                submission_id=5,
                created_at='2026-06-23T00:00:00Z',
            )

        self.assertEqual(result.verdict, 'TLE')
        self.assertIn('timeout', result.stderr_output.lower())


if __name__ == '__main__':
    unittest.main()
