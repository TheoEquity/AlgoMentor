from __future__ import annotations

import json
from collections import Counter

from core.db import get_connection
from schemas.training import (
    TrainingErrorBucket,
    TrainingOverviewResponse,
    TrainingRecentItem,
    TrainingRecommendation,
    TrainingSummary,
)


class TrainingRepository:
    def __init__(self, database_url: str):
        self.database_url = database_url

    def get_overview(self) -> TrainingOverviewResponse:
        connection = get_connection(self.database_url)
        with connection, connection.cursor() as cursor:
            cursor.execute(
                '''
                SELECT
                    s.id AS submission_id, s.problem_id, s.language, s.run_type, s.verdict,
                    s.created_at, p.title, p.company, p.tags_json
                FROM submissions s
                INNER JOIN problems p ON p.id = s.problem_id
                ORDER BY s.created_at DESC, s.id DESC
                LIMIT 20
                '''
            )
            recent_rows = cursor.fetchall()

            cursor.execute(
                '''
                SELECT
                    p.id, p.title, p.company, p.tags_json, p.updated_at,
                    COALESCE(MAX(s.created_at), '') AS last_submission_at,
                    COALESCE(SUM(CASE WHEN s.verdict = 'AC' THEN 1 ELSE 0 END), 0) AS ac_count,
                    COALESCE(SUM(CASE WHEN s.verdict != 'AC' THEN 1 ELSE 0 END), 0) AS wrong_count
                FROM problems p
                LEFT JOIN submissions s ON s.problem_id = p.id
                GROUP BY p.id, p.title, p.company, p.tags_json, p.updated_at
                ORDER BY wrong_count DESC, last_submission_at DESC, p.updated_at DESC
                LIMIT 6
                '''
            )
            recommendation_rows = cursor.fetchall()
        connection.close()

        recent_items = [
            TrainingRecentItem(
                submission_id=row['submission_id'],
                problem_id=row['problem_id'],
                title=row['title'],
                company=row['company'],
                language=row['language'],
                run_type=row['run_type'],
                verdict=row['verdict'],
                created_at=row['created_at'],
            )
            for row in recent_rows
        ]

        verdict_counter = Counter(item.verdict for item in recent_items)
        tag_counter = Counter()
        for row in recent_rows:
            for tag in json.loads(row['tags_json']):
                tag_counter[tag] += 1

        summary = TrainingSummary(
            total_runs=len(recent_items),
            ac_count=sum(1 for item in recent_items if item.verdict == 'AC'),
            wrong_count=sum(1 for item in recent_items if item.verdict != 'AC'),
            submit_count=sum(1 for item in recent_items if item.run_type == 'submit'),
            strongest_tag=tag_counter.most_common(1)[0][0] if tag_counter else None,
            main_error_type=self._most_common_error(verdict_counter),
        )

        error_buckets = [
            TrainingErrorBucket(verdict=verdict, count=count)
            for verdict, count in verdict_counter.items()
            if verdict != 'AC'
        ]
        error_buckets.sort(key=lambda item: item.count, reverse=True)

        recommendations = [self._build_recommendation(row) for row in recommendation_rows]
        return TrainingOverviewResponse(
            summary=summary,
            recent_items=recent_items[:8],
            error_buckets=error_buckets,
            recommendations=recommendations,
        )

    @staticmethod
    def _most_common_error(verdict_counter: Counter[str]) -> str | None:
        error_items = [(verdict, count) for verdict, count in verdict_counter.items() if verdict != 'AC']
        if not error_items:
            return None
        error_items.sort(key=lambda item: item[1], reverse=True)
        return error_items[0][0]

    @staticmethod
    def _build_recommendation(row: dict) -> TrainingRecommendation:
        tags = json.loads(row['tags_json'])
        wrong_count = row['wrong_count'] or 0
        ac_count = row['ac_count'] or 0

        if wrong_count > 0:
            reason = f'这道题最近出现 {wrong_count} 次未通过记录，适合立刻回炉。'
        elif ac_count > 0:
            reason = '这道题已经通过，适合二刷巩固思路和复杂度表达。'
        else:
            reason = '这道题已有手工题面和模板，可作为下一道继续训练题。'

        return TrainingRecommendation(
            problem_id=row['id'],
            title=row['title'],
            company=row['company'],
            tags=tags,
            recommendation_reason=reason,
        )
