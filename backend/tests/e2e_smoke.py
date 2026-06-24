from __future__ import annotations

import asyncio
import sys
from pathlib import Path


SRC_DIR = Path(__file__).resolve().parents[1] / 'src'
if str(SRC_DIR) not in sys.path:
    sys.path.insert(0, str(SRC_DIR))

from api.routes.analysis import analyze_attribution, analyze_review, analyze_solution
from api.routes.problems import get_problem
from api.routes.review import list_reviews
from api.routes.training import get_training_overview
from repositories.llm_settings_repository import LLMSettingsRepository
from repositories.problem_repository import ProblemRepository
from repositories.review_repository import ReviewRepository
from repositories.submission_repository import SubmissionRepository
from repositories.training_repository import TrainingRepository
from schemas.analysis import AnalysisResponse, AttributionAnalysisRequest, SolutionAnalysisRequest
from schemas.submissions import SubmissionCaseResult, SubmissionCreate, SubmissionResult
from test_support import TemporaryDatabase


class FakeJudgeService:
    def evaluate(self, problem, payload, submission_id, created_at):
        verdict = 'AC' if 'prefix' in payload.code_text.lower() else 'WA'
        actual_output = '7' if verdict == 'AC' else '6'
        return SubmissionResult(
            id=submission_id,
            problem_id=problem.id,
            language=payload.language,
            run_type=payload.run_type,
            code_text=payload.code_text,
            verdict=verdict,
            runtime_ms=42,
            memory_kb=20480,
            compiler_output='',
            stderr_output='',
            failed_case_index=None if verdict == 'AC' else 1,
            failed_input=None if verdict == 'AC' else '4\n7 1 8 2',
            failed_expected_output=None if verdict == 'AC' else '7',
            failed_actual_output=None if verdict == 'AC' else actual_output,
            case_results=[
                SubmissionCaseResult(
                    case_index=1,
                    case_type='hidden',
                    stdin_text='4\n7 1 8 2',
                    expected_output_text='7',
                    actual_output_text=actual_output,
                    verdict=verdict,
                    runtime_ms=42,
                    memory_kb=20480,
                    stderr_output='',
                )
            ],
            created_at=created_at,
        )


class FakeAnalysisService:
    def analyze_solution(self, settings, api_key, problem, language, code_text) -> AnalysisResponse:
        return AnalysisResponse(
            analysis_type='solution',
            provider=settings.provider,
            model=settings.solution_model,
            endpoint_url=settings.endpoint_url,
            title='解题分析',
            summary=f'题目 {problem.title} 已触发解题分析。',
            bullets=[f'语言：{language}', '先写出主思路，再检查复杂度。'],
            line_refs=[],
            verdict=None,
        )

    def attribute_error(self, settings, api_key, problem, submission) -> AnalysisResponse:
        return AnalysisResponse(
            analysis_type='attribution',
            provider=settings.provider,
            model=settings.attribution_model,
            endpoint_url=settings.endpoint_url,
            title='错误归因',
            summary=f'提交 {submission.id} 已关联到题目 {problem.id}。',
            bullets=['优先检查 failed case。'],
            line_refs=[],
            verdict=submission.verdict,
        )

    def review_submission(self, settings, api_key, problem, submission) -> AnalysisResponse:
        return AnalysisResponse(
            analysis_type='review',
            provider=settings.provider,
            model=settings.review_model,
            endpoint_url=settings.endpoint_url,
            title='训练复盘',
            summary='已生成训练复盘建议。',
            bullets=['整理本题思路卡片。'],
            line_refs=[],
            verdict=submission.verdict,
        )


def main() -> int:
    database = TemporaryDatabase()
    try:
        problem_repository = ProblemRepository(database.database_url)
        submission_repository = SubmissionRepository(database.database_url, 'https://judge0.example.com')
        submission_repository.judge_service = FakeJudgeService()
        settings_repository = LLMSettingsRepository(database.database_url)
        review_repository = ReviewRepository(database.database_url)
        training_repository = TrainingRepository(database.database_url)
        analysis_service = FakeAnalysisService()

        problem = asyncio.run(get_problem(1, repository=problem_repository))
        assert problem.id == 1

        submission = submission_repository.create_submission(
            SubmissionCreate(
                problem_id=problem.id,
                language='Python',
                run_type='submit',
                code_text='def solve():\n    prefix = 7\n    print(prefix)',
                custom_input='',
            )
        )
        assert submission.verdict == 'AC'
        assert submission.runtime_ms == 42

        solution = asyncio.run(
            analyze_solution(
                SolutionAnalysisRequest(problem_id=problem.id, language='Python', code_text=submission.code_text),
                settings_repository=settings_repository,
                problem_repository=problem_repository,
                analysis_service=analysis_service,
            )
        )
        assert solution.analysis_type == 'solution'

        attribution = asyncio.run(
            analyze_attribution(
                AttributionAnalysisRequest(submission_id=submission.id),
                settings_repository=settings_repository,
                problem_repository=problem_repository,
                submission_repository=submission_repository,
                analysis_service=analysis_service,
            )
        )
        assert attribution.verdict == 'AC'

        review = asyncio.run(
            analyze_review(
                AttributionAnalysisRequest(submission_id=submission.id),
                settings_repository=settings_repository,
                problem_repository=problem_repository,
                submission_repository=submission_repository,
                analysis_service=analysis_service,
            )
        )
        assert review.analysis_type == 'review'

        review_payload = asyncio.run(
            list_reviews(
                wrong_only=False,
                company=None,
                tag=None,
                error_type=None,
                repository=review_repository,
            )
        )
        training_payload = asyncio.run(get_training_overview(repository=training_repository))
        assert any(item.submission_id == submission.id for item in review_payload.items)
        assert any(item.submission_id == submission.id for item in training_payload.recent_items)

        print('E2E smoke passed: open problem, submit code, trigger AI, browse review/training.')
        return 0
    finally:
        database.close()


if __name__ == '__main__':
    raise SystemExit(main())
