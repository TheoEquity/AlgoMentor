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

    def create_submission(self, payload: SubmissionCreate) -> SubmissionResult:
        problem = self.problem_repository.get_problem(payload.problem_id)
        if problem is None:
            raise ValueError('Problem not found')

        created_at = datetime.now(UTC).isoformat()
        connection = get_connection(self.database_url)

        with connection:
            cursor = connection.execute(
                '''
                INSERT INTO submissions (
                    problem_id,
                    language,
                    run_type,
                    code_text,
                    custom_input,
                    verdict,
                    runtime_ms,
                    memory_kb,
                    compiler_output,
                    stderr_output,
                    failed_case_index,
                    failed_input,
                    failed_expected_output,
                    failed_actual_output,
                    case_results_json,
                    attribution_analysis_json,
                    review_analysis_json,
                    created_at
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                ''',
                (
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
                    '',
                    '',
                    created_at,
                ),
            )
            submission_id = cursor.lastrowid

            result = self.judge_service.evaluate(problem, payload, submission_id, created_at)

            connection.execute(
                '''
                UPDATE submissions
                SET verdict = ?,
                    runtime_ms = ?,
                    memory_kb = ?,
                    compiler_output = ?,
                    stderr_output = ?,
                    failed_case_index = ?,
                    failed_input = ?,
                    failed_expected_output = ?,
                    failed_actual_output = ?,
                    case_results_json = ?
                WHERE id = ?
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
                    submission_id,
                ),
            )

        connection.close()
        return result

    def get_submission(self, submission_id: int) -> SubmissionResult | None:
        connection = get_connection(self.database_url)
        row = connection.execute('SELECT * FROM submissions WHERE id = ?', (submission_id,)).fetchone()
        connection.close()
        if row is None:
            return None

        return self._row_to_submission(row)

    def list_submissions(self, *, problem_id: int, limit: int = 20) -> list[SubmissionResult]:
        connection = get_connection(self.database_url)
        rows = connection.execute(
            'SELECT * FROM submissions WHERE problem_id = ? ORDER BY created_at DESC, id DESC LIMIT ?',
            (problem_id, limit),
        ).fetchall()
        connection.close()
        return [self._row_to_submission(row) for row in rows]

    def _row_to_submission(self, row) -> SubmissionResult:
        case_results = json.loads(row['case_results_json'])
        return SubmissionResult(
            id=row['id'],
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
            attribution_analysis=self._parse_analysis_snapshot(row['attribution_analysis_json']),
            review_analysis=self._parse_analysis_snapshot(row['review_analysis_json']),
            created_at=row['created_at'],
        )

    def save_submission_analysis(self, submission_id: int, analysis: AnalysisResponse) -> None:
        column_name = self._analysis_column_name(analysis.analysis_type)
        connection = get_connection(self.database_url)
        with connection:
            connection.execute(
                f'UPDATE submissions SET {column_name} = ? WHERE id = ?',
                (json.dumps(analysis.model_dump()), submission_id),
            )
        connection.close()

    def _analysis_column_name(self, analysis_type: str) -> str:
        if analysis_type == 'attribution':
            return 'attribution_analysis_json'
        if analysis_type == 'review':
            return 'review_analysis_json'
        raise ValueError(f'Unsupported analysis type: {analysis_type}')

    def _parse_analysis_snapshot(self, raw_payload: str | None) -> SubmissionAnalysisSnapshot | None:
        if not raw_payload:
            return None

        try:
            payload = json.loads(raw_payload)
        except json.JSONDecodeError:
            return None

        if not isinstance(payload, dict):
            return None

        return SubmissionAnalysisSnapshot(**payload)
