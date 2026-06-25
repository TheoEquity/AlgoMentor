from __future__ import annotations

import asyncio
import sys
import unittest
from pathlib import Path


SRC_DIR = Path(__file__).resolve().parents[1] / 'src'
if str(SRC_DIR) not in sys.path:
    sys.path.insert(0, str(SRC_DIR))

from api.routes.problems import create_problem, delete_problem, get_problem, list_problems, update_problem
from repositories.problem_repository import ProblemRepository
from schemas.problems import ExampleItem, ProblemCreate, ProblemTestCase
from tests.test_support import TEST_DATABASE_URL, reset_test_database


class ProblemRepositoryAndRouteTests(unittest.TestCase):
    def setUp(self) -> None:
        reset_test_database()
        self.repository = ProblemRepository(TEST_DATABASE_URL)

    def test_list_problems_filters_by_company_category_and_difficulty_and_tag(self) -> None:
        by_company = self.repository.list_problems(company='字节跳动', department=None, difficulty=None, category_slug=None, tag=None)
        by_category = self.repository.list_problems(company=None, department=None, difficulty=None, category_slug='stack-queue', tag=None)
        by_difficulty = self.repository.list_problems(company=None, department=None, difficulty='Easy', category_slug=None, tag=None)
        by_tag = self.repository.list_problems(company=None, department=None, difficulty=None, category_slug=None, tag='栈')

        self.assertEqual(len(by_company), 1)
        self.assertEqual(by_company[0].company, '字节跳动')
        self.assertEqual(len(by_category), 1)
        self.assertEqual(by_category[0].category_slug, 'stack-queue')
        self.assertEqual(len(by_difficulty), 1)
        self.assertEqual(by_difficulty[0].difficulty, 'Easy')
        self.assertEqual(len(by_tag), 1)
        self.assertEqual(by_tag[0].title, '括号序列的最短修复')

    def test_create_problem_preserves_source_metadata_and_test_cases(self) -> None:
        payload = ProblemCreate(
            slug='manual-two-sum-variant',
            title='双指针变体求和',
            company='美团',
            difficulty='Medium',
            category_slug='two-pointers',
            statement_markdown='给定一个有序数组，找到满足条件的两个数。',
            constraints_text='2 <= n <= 10^5',
            tags=['双指针', '数组'],
            examples=[ExampleItem(input='4\n1 2 3 4', output='5', explanation='1 + 4 = 5')],
            supported_languages=['Python', 'C++', 'Java'],
            starter_templates={'Python': 'def solve():\n    pass'},
            source_type='interview-note',
            source='牛客',
            frequency='高',
            year=2026,
            source_ref='campus-2026-round1',
            external_id='EXT-2048',
            status='未开始',
            test_cases=[
                ProblemTestCase(case_type='sample', stdin_text='4\n1 2 3 4', expected_output_text='5', sort_order=1),
                ProblemTestCase(case_type='hidden', stdin_text='5\n2 3 4 6 9', expected_output_text='11', sort_order=2),
            ],
        )

        created = self.repository.create_problem(payload)
        fetched = self.repository.get_problem(created.id)

        self.assertIsNotNone(fetched)
        assert fetched is not None
        self.assertEqual(fetched.source_type, 'interview-note')
        self.assertEqual(fetched.source, '牛客')
        self.assertEqual(fetched.frequency, '高')
        self.assertEqual(fetched.year, 2026)
        self.assertEqual(fetched.source_ref, 'campus-2026-round1')
        self.assertEqual(fetched.external_id, 'EXT-2048')
        self.assertEqual(len(fetched.test_cases), 2)
        self.assertEqual(fetched.test_cases[1].case_type, 'hidden')

    def test_problem_routes_return_repository_results(self) -> None:
        created = asyncio.run(
            create_problem(
                ProblemCreate(
                    slug='route-created-problem',
                    title='区间求和校验',
                    company='阿里巴巴',
                    difficulty='Easy',
                    category_slug='prefix-sum',
                    statement_markdown='给定数组和多个查询，输出每个区间和。',
                    constraints_text='1 <= n <= 10^5',
                    tags=['前缀和'],
                    examples=[ExampleItem(input='3\n1 2 3', output='6', explanation='全部求和')],
                    supported_languages=['Python', 'C++', 'Java'],
                    starter_templates={'Python': 'def solve():\n    pass'},
                    test_cases=[
                        ProblemTestCase(case_type='sample', stdin_text='3\n1 2 3', expected_output_text='6', sort_order=1)
                    ],
                ),
                repository=self.repository,
            )
        )
        listing = asyncio.run(
            list_problems(company='阿里巴巴', difficulty=None, category_slug=None, tag=None, repository=self.repository)
        )
        detail = asyncio.run(get_problem(created.id, repository=self.repository))

        self.assertEqual(created.title, '区间求和校验')
        self.assertEqual(len(listing), 1)
        self.assertEqual(listing[0].title, '区间求和校验')
        self.assertEqual(detail.id, created.id)

    def test_delete_problem_removes_problem(self) -> None:
        deleted_problem = asyncio.run(delete_problem(1, repository=self.repository))
        fetched = self.repository.get_problem(1)

        self.assertIsNone(deleted_problem)
        self.assertIsNone(fetched)

    def test_update_problem_replaces_problem_metadata_and_cases(self) -> None:
        payload = ProblemCreate(
            slug='updated-problem-slug',
            title='更新后的题目',
            company='美团',
            difficulty='Hard',
            category_slug='dynamic-programming',
            statement_markdown='更新后的题面内容，包含足够长度。',
            constraints_text='1 <= n <= 10^5',
            tags=['动态规划', '状态压缩'],
            examples=[ExampleItem(input='1', output='1', explanation='最小样例')],
            supported_languages=['Python', 'C++', 'Java'],
            starter_templates={'Python': 'def solve():\n    pass'},
            source_type='manual',
            source='手工',
            frequency='高',
            year=2026,
            source_ref='updated-source',
            external_id='UPDATED-1',
            status='待复盘',
            test_cases=[ProblemTestCase(case_type='sample', stdin_text='1', expected_output_text='1', sort_order=1)],
        )

        updated = asyncio.run(update_problem(1, payload, repository=self.repository))

        self.assertEqual(updated.title, '更新后的题目')
        self.assertEqual(updated.company, '美团')
        self.assertEqual(updated.frequency, '高')
        self.assertEqual(updated.test_cases[0].expected_output_text, '1')


if __name__ == '__main__':
    unittest.main()
