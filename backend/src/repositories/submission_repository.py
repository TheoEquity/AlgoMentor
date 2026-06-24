from __future__ import annotations

import json
from datetime import UTC, datetime

from config import Settings
from core.db import get_connection
from schemas.analysis import AnalysisResponse
from schemas.submissions import SubmissionAnalysisSnapshot, SubmissionCreate, SubmissionResult
from services.judge_service import JudgeService
from repositories.problem_repository import ProblemRepository


class SubmissionRepository:
    def __init__(self, database_url: str, judge0_url: str | None = None):
        self.database_url = database_url
        self.problem_repository = ProblemRepository(database_url)
        settings = Settings()
        self.judge_service = JudgeService(judge0_url or settings.judge0_url)

    def create_submission(self, payload: SubmissionCreate, user_id: int = 1) -> SubmissionResult:
        problem = self.problem_repository.get_problem(payload.problem_id)
        if problem is None:
            raise ValueError('Problem not found')

        created_at = datetime.now(UTC).isoformat()
        connection = get_connection(self.database_url)

        with connection, connection.cursor() as cursor:
            cursor.execute(
                '''
                INSERT INTO submissions (
                    user_id, problem_id, language, run_type, code_text, custom_input,
                    verdict, runtime_ms, memory_kb, compiler_output, stderr_output,
                    failed_case_index, failed_input, failed_expected_output, failed_actual_output,
                    case_results_json, judge_token, created_at
                ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                RETURNING id
                ''',
                (
                    user_id,
                    payload.problem_id,
                    payload.language,
                    payload.run_type,
                    payload.code_text,
                    payload.custom_input,
                    'PENDING',
                    0,
                    0,
                    '',
                    '',
                    None,
                    None,
                    None,
                    None,
                    '[]',
                    None,
                    created_at,
                ),
            )
            submission_id = cursor.fetchone()['id']

            result = self.judge_service.evaluate(problem, payload, submission_id, created_at)

            cursor.execute(
                '''
                UPDATE submissions
                SET verdict = %s, runtime_ms = %s, memory_kb = %s,
                    compiler_output = %s, stderr_output = %s,
                    failed_case_index = %s, failed_input = %s,
                    failed_expected_output = %s, failed_actual_output = %s,
                    case_results_json = %s, judge_token = %s
                WHERE id = %s
                ''',
                (
                    result.verdict,
                    result.runtime_ms,
                    result.memory_kb,
                    result.compiler_output,
                    result.stderr_output,
                    result.failed_case_index,
                    result.failed_input,
                    result.failed_expected_output,
                    result.failed_actual_output,
                    json.dumps([item.model_dump() for item in result.case_results]),
                    getattr(result, 'judge_token', None),
                    submission_id,
                ),
            )

        connection.close()
        return result

    def get_submission(self, submission_id: int) -> SubmissionResult | None:
        connection = get_connection(self.database_url)
        with connection, connection.cursor() as cursor:
            cursor.execute('SELECT * FROM submissions WHERE id = %s', (submission_id,))
            row = cursor.fetchone()
        connection.close()
        if row is None:
            return None

        attribution = self._load_analysis_snapshot(submission_id, 'attribution')
        review = self._load_analysis_snapshot(submission_id, 'review')
        return self._row_to_submission(row, attribution, review)

    def list_submissions(self, *, problem_id: int, limit: int = 20) -> list[SubmissionResult]:
        connection = get_connection(self.database_url)
        with connection, connection.cursor() as cursor:
            cursor.execute(
                'SELECT * FROM submissions WHERE problem_id = %s ORDER BY created_at DESC, id DESC LIMIT %s',
                (problem_id, limit),
            )
            rows = cursor.fetchall()
        connection.close()

        result: list[SubmissionResult] = []
        for row in rows:
            attribution = self._load_analysis_snapshot(row['id'], 'attribution')
            review = self._load_analysis_snapshot(row['id'], 'review')
            result.append(self._row_to_submission(row, attribution, review))
        return result

    def _load_analysis_snapshot(self, submission_id: int, analysis_type: str) -> SubmissionAnalysisSnapshot | None:
        connection = get_connection(self.database_url)
        with connection, connection.cursor() as cursor:
            cursor.execute(
                'SELECT * FROM error_attributions WHERE submission_id = %s AND analysis_type = %s ORDER BY id DESC LIMIT 1',
                (submission_id, analysis_type),
            )
            row = cursor.fetchone()
        connection.close()
        if row is None:
            return None

        bullets = json.loads(row['bullets_json']) if row['bullets_json'] else []
        line_refs = json.loads(row['line_refs_json']) if row['line_refs_json'] else []
        return SubmissionAnalysisSnapshot(
            analysis_type=row['analysis_type'],
            provider=row['provider'],
            model=row['model'],
            endpoint_url=row['endpoint_url'],
            execution_status=row['execution_status'],
            status_reason=row['status_reason'],
            title=row['summary'],
            summary=row['suggestion'],
            bullets=bullets,
            line_refs=line_refs,
            verdict=None,
        )

    def _row_to_submission(self, row: dict, attribution: SubmissionAnalysisSnapshot | None, review: SubmissionAnalysisSnapshot | None) -> SubmissionResult:
        case_results = json.loads(row['case_results_json']) if row['case_results_json'] else []
        return SubmissionResult(
            id=row['id'],
            user_id=row['user_id'],
            problem_id=row['problem_id'],
            language=row['language'],
            run_type=row['run_type'],
            code_text=row['code_text'],
            verdict=row['verdict'],
            runtime_ms=row['runtime_ms'],
            memory_kb=row['memory_kb'],
            compiler_output=row['compiler_output'] or '',
            stderr_output=row['stderr_output'] or '',
            failed_case_index=row['failed_case_index'],
            failed_input=row['failed_input'],
            failed_expected_output=row['failed_expected_output'],
            failed_actual_output=row['failed_actual_output'],
            case_results=case_results,
            judge_token=row.get('judge_token'),
            attribution_analysis=attribution,
            review_analysis=review,
            created_at=row['created_at'],
        )

    def save_submission_analysis(self, submission_id: int, analysis: AnalysisResponse) -> None:
        now = datetime.now(UTC).isoformat()
        connection = get_connection(self.database_url)
        with connection, connection.cursor() as cursor:
            cursor.execute(
                '''
                INSERT INTO error_attributions (
                    submission_id, analysis_type,
                    primary_category, secondary_category,
                    summary, suggestion,
                    bullets_json, line_refs_json,
                    execution_status, status_reason,
                    provider, model, endpoint_url,
                    raw_response_json, created_at
                ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                ''',
                (
                    submission_id,
                    analysis.analysis_type,
                    '',
                    '',
                    analysis.title,
                    analysis.summary,
                    json.dumps(analysis.bullets),
                    json.dumps([item.model_dump() for item in analysis.line_refs]),
                    analysis.execution_status,
                    analysis.status_reason,
                    analysis.provider,
                    analysis.model,
                    analysis.endpoint_url,
                    json.dumps(analysis.model_dump()),
                    now,
                ),
            )
        connection.close()
