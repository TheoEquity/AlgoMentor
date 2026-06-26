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
        'time_limit_ms': 2000,
        'memory_limit_kb': 262144,
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
        'time_limit_ms': 2000,
        'memory_limit_kb': 262144,
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
    {
        'slug': 'simplified-attention-sum',
        'title': '简化Attention输出的元素总和',
        'company': '华为',
        'difficulty': 'Medium',
        'category_slug': 'math',
        'statement_markdown': (
            '## 题目描述\n\n'
            '给定三个正整数 n、m、h（均小于 100），构造如下数据并计算结果。\n\n'
            '**数据构造规则：**\n\n'
            '1. 输入特征矩阵 X 为 n×m 的全 1 矩阵。\n'
            '2. 三个权重矩阵 W1、W2、W3 均为 m×h 的「上三角全 1」矩阵（行列索引满足 i ≤ j 的位置为 1，其余为 0；当 m ≠ h 时按行列索引自然扩展）。\n'
            '3. 令 $Q = X \\cdot W1$，$K = X \\cdot W2$，$V = X \\cdot W3$。\n'
            '4. 计算 $S = \\frac{Q \\cdot K^T}{\\sqrt{h}}$。\n'
            '5. softmax 按行做归一化：对任意行向量 r，$\\text{softmax}(r)_i = r_i / \\sum_j r_j$。\n'
            '6. $Y = \\text{softmax}(S) \\cdot V$。\n\n'
            '## 输出要求\n\n'
            '求矩阵 Y 所有元素的和，四舍五入到整数后输出。\n\n'
            '## 输入格式\n\n'
            '一行，三个正整数 n m h（均小于 100，且均大于 0）。\n\n'
            '## 输出格式\n\n'
            '一行，一个整数：矩阵 Y 的元素和。\n\n'
            '## 补充说明\n\n'
            '本题由牛友 @Charles 整理上传。\n\n'
            '## 样例\n\n'
            '### 样例 1\n\n'
            '**输入：**\n```\n5 4 3\n```\n'
            '**输出：**\n```\n30\n```\n'
            '**说明：** h ≤ m，单行和为 1+2+3=6，总和 = n×6 = 5×6=30。\n\n'
            '### 样例 2\n\n'
            '**输入：**\n```\n2 3 5\n```\n'
            '**输出：**\n```\n24\n```\n'
            '**说明：** h > m，q = [1, 2, 3, 3, 3]，行和 = 12，总和 = 2×12=24。'
        ),
        'constraints_text': '',
        'tags_json': json.dumps(['数学', '矩阵', '模拟']),
        'examples_json': json.dumps(
            [
                {
                    'input': '5 4 3',
                    'output': '30',
                    'explanation': 'h ≤ m，单行和为 1+2+3=6，总和 = n×6 = 5×6=30。',
                },
                {
                    'input': '2 3 5',
                    'output': '24',
                    'explanation': 'h > m，q = [1, 2, 3, 3, 3]，行和 = 12，总和 = 2×12=24。',
                },
            ]
        ),
        'supported_languages_json': json.dumps(['Python', 'C++', 'Java']),
        'starter_templates_json': json.dumps(
            {
                'Python': 'def solve() -> None:\n    n, m, h = map(int, input().split())\n    total = 0\n    for j in range(h):\n        total += j + 1 if j < m else m\n    print(n * total)\n\nif __name__ == \'__main__\':\n    solve()\n',
                'C++': '#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    int n, m, h;\n    cin >> n >> m >> h;\n    long long sum_q = 0;\n    for (int j = 0; j < h; ++j) {\n        sum_q += (j < m) ? (j + 1) : m;\n    }\n    cout << static_cast<long long>(n) * sum_q << endl;\n    return 0;\n}\n',
                'Java': 'import java.util.*;\n\npublic class Main {\n    public static void main(String[] args) {\n        Scanner sc = new Scanner(System.in);\n        int n = sc.nextInt();\n        int m = sc.nextInt();\n        int h = sc.nextInt();\n        long sumQ = 0;\n        for (int j = 0; j < h; j++) {\n            sumQ += (j < m) ? (j + 1) : m;\n        }\n        System.out.println((long) n * sumQ);\n    }\n}\n',
            }
        ),
        'source_type': '牛客',
        'source': '牛客',
        'frequency': '中',
        'year': 2025,
        'source_ref': '华为2025AI笔试',
        'external_id': 'NK-HW-2025-001',
        'status': '未开始',
        'time_limit_ms': 2000,
        'memory_limit_kb': 262144,
        'created_at': '2026-06-26T10:00:00Z',
        'updated_at': '2026-06-26T10:00:00Z',
        'test_cases': [
            {
                'case_type': 'sample',
                'stdin_text': '5 4 3',
                'expected_output_text': '30',
                'sort_order': 1,
            },
            {
                'case_type': 'sample',
                'stdin_text': '2 3 5',
                'expected_output_text': '24',
                'sort_order': 2,
            },
            {
                'case_type': 'hidden',
                'stdin_text': '3 5 2',
                'expected_output_text': '9',
                'sort_order': 3,
            },
            {
                'case_type': 'hidden',
                'stdin_text': '1 1 1',
                'expected_output_text': '1',
                'sort_order': 4,
            },
            {
                'case_type': 'hidden',
                'stdin_text': '10 50 2',
                'expected_output_text': '30',
                'sort_order': 5,
            },
        ],
    },
]
