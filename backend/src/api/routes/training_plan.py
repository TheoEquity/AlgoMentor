from __future__ import annotations

import json
import random
import re
from datetime import UTC, datetime

from fastapi import APIRouter, Depends, HTTPException, Query
from fastapi import status as http_status
from pydantic import BaseModel

from config import Settings
from core.db import get_connection
from repositories.problem_repository import ProblemRepository
from repositories.training_plan_repository import TrainingPlanRepository
from repositories.training_repository import TrainingRepository
from schemas.training_plan import TrainingPlanCreate, TrainingPlanDetail, TrainingPlanListItem, PlanPreview, PlanPreviewProblem

router = APIRouter(prefix='/training-plans', tags=['Training Plans'])

_CATEGORY_KEYWORDS: list[tuple[str, str]] = [
    ('双指针|two.pointer', 'two-pointers'),
    ('滑动窗口|sliding.window', 'sliding-window'),
    ('哈希|散列|hash|hashing', 'hashing'),
    ('二分|binary.search', 'binary-search'),
    ('前缀和|prefix.sum', 'prefix-sum'),
    ('区间|interval', 'intervals'),
    ('矩阵|网格|matrix|grid', 'matrix-grid'),
    ('链表|linked.list', 'linked-list'),
    ('栈|队列|stack|queue', 'stack-queue'),
    ('单调栈|monotonic.stack', 'monotonic-stack'),
    ('堆|优先队列|heap|priority.queue', 'heap-priority-queue'),
    ('树|tree|二叉树|BST', 'tree'),
    ('图|graph|BFS|DFS|图论', 'graphs'),
    ('回溯|backtrack', 'backtracking'),
    ('动态规划|DP|dp|动规', 'dynamic-programming'),
    ('贪心|greedy', 'greedy'),
    ('位运算|bit.manipulation|位操作', 'bit-manipulation'),
    ('模拟|simulation', 'simulation'),
    ('数学|math', 'math'),
    ('字符串|string', 'string'),
]


def _extract_categories(text: str) -> list[str]:
    matched: list[str] = []
    seen: set[str] = set()
    for pattern, slug in _CATEGORY_KEYWORDS:
        if slug in seen:
            continue
        if re.search(pattern, text, re.IGNORECASE):
            matched.append(slug)
            seen.add(slug)
    return matched


class AIGenerateRequest(BaseModel):
    analysis_text: str = ''


def _get_repo() -> TrainingPlanRepository:
    return TrainingPlanRepository(Settings().database_url)


def _get_problem_repo() -> ProblemRepository:
    return ProblemRepository(Settings().database_url)


def _get_training_repo() -> TrainingRepository:
    return TrainingRepository(Settings().database_url)


def _row_to_preview(row: dict) -> PlanPreviewProblem:
    tags = row.get('tags_json', '[]') or '[]'
    try:
        tags_list = json.loads(tags)
    except (json.JSONDecodeError, TypeError):
        tags_list = []
    return PlanPreviewProblem(
        problem_id=row['id'],
        title=row.get('title', ''),
        company=row.get('company', ''),
        difficulty=row.get('difficulty', ''),
        category_slug=row.get('category_slug', ''),
        tags=tags_list,
    )


def _select_problems(rows: list[dict], max_count: int) -> list[int]:
    candidate_ids = []
    for row in rows:
        wc = row.get('wrong_count') or 0
        if wc > 0:
            candidate_ids.append(row['id'])

    if not candidate_ids:
        for row in rows:
            candidate_ids.append(row['id'])

    if len(candidate_ids) > max_count:
        return random.sample(candidate_ids, max_count)
    return candidate_ids[:max(len(candidate_ids), 5)]


def _query_problems_by_categories(target_categories: list[str], connection) -> list[dict]:
    rows: list[dict] = []
    with connection.cursor() as cursor:
        if target_categories:
            placeholders = ','.join(['%s'] * len(target_categories))
            cursor.execute(
                f'''SELECT p.id, p.title, p.company, p.difficulty, p.category_slug, p.tags_json,
                           COUNT(s.id) AS submission_count,
                           SUM(CASE WHEN s.verdict = 'AC' THEN 1 ELSE 0 END) AS ac_count,
                           SUM(CASE WHEN s.verdict != 'AC' THEN 1 ELSE 0 END) AS wrong_count
                    FROM problems p
                    LEFT JOIN submissions s ON s.problem_id = p.id
                    WHERE p.category_slug IN ({placeholders})
                    GROUP BY p.id
                    ORDER BY wrong_count DESC, p.id ASC
                    LIMIT 50''',
                target_categories,
            )
            rows = cursor.fetchall()

            if len(rows) < 5:
                cursor.execute(
                    '''SELECT p.id, p.title, p.company, p.difficulty, p.category_slug, p.tags_json,
                               COUNT(s.id) AS submission_count,
                               SUM(CASE WHEN s.verdict = 'AC' THEN 1 ELSE 0 END) AS ac_count,
                               SUM(CASE WHEN s.verdict != 'AC' THEN 1 ELSE 0 END) AS wrong_count
                        FROM problems p
                        LEFT JOIN submissions s ON s.problem_id = p.id
                        GROUP BY p.id
                        ORDER BY wrong_count DESC, p.id ASC
                        LIMIT 30''',
                )
                fallback = cursor.fetchall()
                existing = {r['id'] for r in rows}
                for r in fallback:
                    if r['id'] not in existing:
                        rows.append(r)
                        existing.add(r['id'])
                        if len(rows) >= 30:
                            break
        else:
            cursor.execute(
                '''SELECT p.id, p.title, p.company, p.difficulty, p.category_slug, p.tags_json,
                           COUNT(s.id) AS submission_count,
                           SUM(CASE WHEN s.verdict = 'AC' THEN 1 ELSE 0 END) AS ac_count,
                           SUM(CASE WHEN s.verdict != 'AC' THEN 1 ELSE 0 END) AS wrong_count
                    FROM problems p
                    LEFT JOIN submissions s ON s.problem_id = p.id
                    GROUP BY p.id
                    ORDER BY wrong_count DESC, p.id ASC
                    LIMIT 30''',
            )
            rows = cursor.fetchall()
    return rows


@router.get('', response_model=list[TrainingPlanListItem])
def list_plans(repo: TrainingPlanRepository = Depends(_get_repo)):
    return repo.list_plans()


@router.get('/{plan_id}', response_model=TrainingPlanDetail)
def get_plan(plan_id: int, repo: TrainingPlanRepository = Depends(_get_repo)):
    plan = repo.get_plan(plan_id)
    if plan is None:
        raise HTTPException(status_code=404, detail='训练计划不存在')
    return plan


@router.post('', response_model=TrainingPlanDetail, status_code=http_status.HTTP_201_CREATED)
def create_plan(payload: TrainingPlanCreate, repo: TrainingPlanRepository = Depends(_get_repo)):
    return repo.create_plan(payload)


@router.post('/ai-generate', response_model=TrainingPlanDetail | PlanPreview, status_code=http_status.HTTP_201_CREATED)
def ai_generate_plan(
    body: AIGenerateRequest = AIGenerateRequest(),
    preview: bool = False,
    repo: TrainingPlanRepository = Depends(_get_repo),
    problem_repo: ProblemRepository = Depends(_get_problem_repo),
):
    database_url = Settings().database_url
    connection = get_connection(database_url)
    try:
        target_categories = _extract_categories(body.analysis_text) if body.analysis_text else []
        with connection:
            rows = _query_problems_by_categories(target_categories, connection)
        connection.close()

        selected = _select_problems(rows, 21)

        if preview:
            problem_map = {r['id']: r for r in rows}
            problems = [_row_to_preview(problem_map[pid]) for pid in selected if pid in problem_map]
            return PlanPreview(
                name='综合训练',
                plan_type='comprehensive',
                duration_days=7,
                problems=problems,
            )

        payload = TrainingPlanCreate(
            name='综合训练',
            plan_type='comprehensive',
            duration_days=7,
            problem_ids=selected,
        )
        return repo.create_plan(payload)
    finally:
        try:
            connection.close()
        except Exception:
            pass


@router.post('/derived-generate', response_model=TrainingPlanDetail | PlanPreview, status_code=http_status.HTTP_201_CREATED)
def derived_generate_plan(
    problem_id: int,
    preview: bool = False,
    repo: TrainingPlanRepository = Depends(_get_repo),
    problem_repo: ProblemRepository = Depends(_get_problem_repo),
):
    connection = get_connection(Settings().database_url)
    try:
        with connection, connection.cursor() as cursor:
            cursor.execute(
                'SELECT id FROM problems WHERE source_problem_id = %s ORDER BY id',
                (problem_id,),
            )
            derived_ids = [r['id'] for r in cursor.fetchall()]

            all_ids = [problem_id] + derived_ids
            placeholders = ','.join(['%s'] * len(all_ids))
            cursor.execute(
                f'''SELECT id, title, company, difficulty, category_slug, tags_json
                    FROM problems WHERE id IN ({placeholders})
                    ORDER BY id''',
                all_ids,
            )
            rows = cursor.fetchall()
        connection.close()

        if not derived_ids and not preview:
            raise HTTPException(
                status_code=http_status.HTTP_400_BAD_REQUEST,
                detail='该题目暂无派生题目，请先生成派生题目',
            )

        if preview:
            return PlanPreview(
                name='派生训练',
                plan_type='derived',
                duration_days=7,
                problems=[_row_to_preview(r) for r in rows],
            )

        payload = TrainingPlanCreate(
            name='派生训练',
            plan_type='derived',
            duration_days=7,
            problem_ids=[problem_id] + derived_ids,
        )
        return repo.create_plan(payload)
    finally:
        try:
            connection.close()
        except Exception:
            pass


@router.post('/review-generate', response_model=TrainingPlanDetail | PlanPreview, status_code=http_status.HTTP_201_CREATED)
def review_generate_plan(
    preview: bool = False,
    repo: TrainingPlanRepository = Depends(_get_repo),
):
    connection = get_connection(Settings().database_url)
    try:
        with connection, connection.cursor() as cursor:
            cursor.execute(
                '''SELECT p.id, p.title, p.company, p.difficulty, p.category_slug, p.tags_json,
                          COUNT(s.id) AS submission_count,
                          SUM(CASE WHEN s.verdict = 'AC' THEN 1 ELSE 0 END) AS ac_count,
                          SUM(CASE WHEN s.verdict != 'AC' THEN 1 ELSE 0 END) AS wrong_count
                   FROM problems p
                   LEFT JOIN submissions s ON s.problem_id = p.id
                   GROUP BY p.id
                   HAVING COUNT(s.id) > 0
                   ORDER BY wrong_count DESC, COUNT(s.id) DESC, p.id ASC
                   LIMIT 10''',
            )
            rows = cursor.fetchall()
        connection.close()

        problem_ids = [r['id'] for r in rows]

        if not problem_ids:
            raise HTTPException(
                status_code=http_status.HTTP_400_BAD_REQUEST,
                detail='暂无训练记录，无法生成回炉计划',
            )

        if preview:
            return PlanPreview(
                name='回炉训练',
                plan_type='review',
                duration_days=7,
                problems=[_row_to_preview(r) for r in rows],
            )

        payload = TrainingPlanCreate(
            name='回炉训练',
            plan_type='review',
            duration_days=7,
            problem_ids=problem_ids,
        )
        return repo.create_plan(payload)
    finally:
        try:
            connection.close()
        except Exception:
            pass


@router.delete('/{plan_id}', status_code=http_status.HTTP_204_NO_CONTENT)
def delete_plan(plan_id: int, repo: TrainingPlanRepository = Depends(_get_repo)):
    deleted = repo.delete_plan(plan_id)
    if not deleted:
        raise HTTPException(status_code=404, detail='训练计划不存在')


@router.patch('/items/{item_id}/status')
def update_item_status(item_id: int, status: str = Query(..., alias='status'), repo: TrainingPlanRepository = Depends(_get_repo)):
    updated = repo.update_item_status(item_id, status_param)
    if not updated:
        raise HTTPException(status_code=404, detail='计划题目不存在')
    return {'ok': True}
