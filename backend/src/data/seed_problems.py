from __future__ import annotations

import json


SEED_PROBLEMS = [
    {
        'slug': 'array-partition-max-gap',
        'title': '数组划分后的最大差值',
        'company': '字节跳动',
        'difficulty': 'Medium',
        'category_slug': 'greedy',
        'statement_markdown': (
            '给定一个长度为 n 的整数数组，请将数组划分为左右两个非空部分，'
            '使左右部分最大值差的绝对值最大。输出这个最大差值。'
        ),
        'constraints_text': '2 <= n <= 2 * 10^5，-10^9 <= nums[i] <= 10^9',
        'tags_json': json.dumps(['数组', '贪心', '前后缀']),
        'examples_json': json.dumps(
            [
                {
                    'input': '5\n1 3 2 5 4',
                    'output': '4',
                    'explanation': '切分为 [1,3,2] 和 [5,4] 时可得到最大差值。',
                }
            ]
        ),
        'supported_languages_json': json.dumps(['Python', 'C++', 'Java']),
        'starter_templates_json': json.dumps(
            {
                'Python': 'def solve() -> None:\n    pass\n\n\nif __name__ == "__main__":\n    solve()\n',
                'C++': '#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}\n',
                'Java': 'import java.io.*;\n\npublic class Main {\n    public static void main(String[] args) throws Exception {\n    }\n}\n',
            }
        ),
        'source_type': 'manual',
        'source': '手工',
        'frequency': '高',
        'year': 2026,
        'source_ref': 'ByteHunter 首批手工题库',
        'external_id': 'BH-001',
        'status': '未开始',
        'created_at': '2026-06-23T16:00:00Z',
        'updated_at': '2026-06-23T16:00:00Z',
        'test_cases': [
            {
                'case_type': 'sample',
                'stdin_text': '5\n1 3 2 5 4',
                'expected_output_text': '4',
                'sort_order': 1,
            },
            {
                'case_type': 'hidden',
                'stdin_text': '4\n7 1 8 2',
                'expected_output_text': '7',
                'sort_order': 2,
            },
        ],
    },
    {
        'slug': 'parentheses-min-fix',
        'title': '括号序列的最短修复',
        'company': '腾讯',
        'difficulty': 'Easy',
        'category_slug': 'stack-queue',
        'statement_markdown': '给定一个只包含 `(` 和 `)` 的字符串，求最少插入多少个括号能使其合法。',
        'constraints_text': '1 <= len(s) <= 10^5',
        'tags_json': json.dumps(['栈', '字符串']),
        'examples_json': json.dumps(
            [
                {
                    'input': '()))(',
                    'output': '3',
                    'explanation': '在首部与末尾补充括号即可。',
                }
            ]
        ),
        'supported_languages_json': json.dumps(['Python', 'C++', 'Java']),
        'starter_templates_json': json.dumps(
            {
                'Python': 'def solve() -> None:\n    pass\n',
                'C++': '#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}\n',
                'Java': 'public class Main {\n    public static void main(String[] args) {\n    }\n}\n',
            }
        ),
        'source_type': 'manual',
        'source': '手工',
        'frequency': '中',
        'year': 2026,
        'source_ref': 'ByteHunter 首批手工题库',
        'external_id': 'BH-014',
        'status': '未开始',
        'created_at': '2026-06-23T16:05:00Z',
        'updated_at': '2026-06-23T16:05:00Z',
        'test_cases': [
            {
                'case_type': 'sample',
                'stdin_text': '()))(',
                'expected_output_text': '3',
                'sort_order': 1,
            }
        ],
    },
]
