"""Import Huawei 2025 AI Written Test Problem: Simplified Attention Output Element Sum"""

import json
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'src'))

DATABASE_URL = os.environ.get('DATABASE_URL', 'postgresql://bytehunter:bytehunter123@localhost:5432/bytehunter')

from core.db import get_connection

STATEMENT = """## 题目描述

给定三个正整数 n、m、h（均小于 100），构造如下数据并计算结果。

**数据构造规则：**

1. 输入特征矩阵 X 为 n×m 的全 1 矩阵。
2. 三个权重矩阵 W1、W2、W3 均为 m×h 的「上三角全 1」矩阵（行列索引满足 i ≤ j 的位置为 1，其余为 0；当 m ≠ h 时按行列索引自然扩展）。
3. 令 $Q = X \\cdot W1$，$K = X \\cdot W2$，$V = X \\cdot W3$。
4. 计算 $S = \\frac{Q \\cdot K^T}{\\sqrt{h}}$。
5. softmax 按行做归一化：对任意行向量 r，$\\text{softmax}(r)_i = r_i / \\sum_j r_j$。
6. $Y = \\text{softmax}(S) \\cdot V$。

## 输出要求

求矩阵 Y 所有元素的和，四舍五入到整数后输出。

## 输入格式

一行，三个正整数 n m h（均小于 100，且均大于 0）。

## 输出格式

一行，一个整数：矩阵 Y 的元素和。

## 补充说明

本题由牛友 @Charles 整理上传。

## 样例

### 样例 1

**输入：**
```
5 4 3
```
**输出：**
```
30
```
**说明：**
h ≤ m，单行和为 1+2+3=6，总和 = n×6 = 5×6=30。

### 样例 2

**输入：**
```
2 3 5
```
**输出：**
```
24
```
**说明：**
h > m，q = [1, 2, 3, 3, 3]，行和 = 12，总和 = 2×12=24。
"""

PYTHON_TEMPLATE = """def solve() -> None:
    n, m, h = map(int, input().split())
    # 计算每列值 q[j]
    total = 0
    for j in range(h):
        val = j + 1 if j < m else m
        total += val
    print(n * total)

if __name__ == '__main__':
    solve()
"""

CPP_TEMPLATE = """#include <bits/stdc++.h>
using namespace std;

int main() {
    int n, m, h;
    cin >> n >> m >> h;
    long long sum_q = 0;
    for (int j = 0; j < h; ++j) {
        sum_q += (j < m) ? (j + 1) : m;
    }
    cout << static_cast<long long>(n) * sum_q << endl;
    return 0;
}
"""

JAVA_TEMPLATE = """import java.util.*;

public class Main {
    public static void main(String[] args) {
        Scanner sc = new Scanner(System.in);
        int n = sc.nextInt();
        int m = sc.nextInt();
        int h = sc.nextInt();
        long sumQ = 0;
        for (int j = 0; j < h; j++) {
            sumQ += (j < m) ? (j + 1) : m;
        }
        System.out.println((long) n * sumQ);
    }
}
"""


def import_problem():
    slug = 'simplified-attention-sum'
    problem = {
        'slug': slug,
        'title': '简化Attention输出的元素总和',
        'company': '华为',
        'difficulty': 'Medium',
        'category_slug': 'math',
        'statement_markdown': STATEMENT,
        'constraints_text': '',
        'tags_json': json.dumps(['数学', '矩阵', '模拟']),
        'examples_json': json.dumps([
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
        ]),
        'supported_languages_json': json.dumps(['Python', 'C++', 'Java']),
        'starter_templates_json': json.dumps({
            'Python': PYTHON_TEMPLATE,
            'C++': CPP_TEMPLATE,
            'Java': JAVA_TEMPLATE,
        }),
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
    }

    test_cases = [
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
    ]

    with get_connection(DATABASE_URL) as conn:
        with conn.cursor() as cur:
            # Check if already exists
            cur.execute('SELECT id FROM problems WHERE slug = %s', (slug,))
            existing = cur.fetchone()
            if existing:
                pid = existing['id']
                print(f'Problem already exists with id={pid}, deleting and re-importing...')
                cur.execute('DELETE FROM problem_test_cases WHERE problem_id = %s', (pid,))
                cur.execute('DELETE FROM problems WHERE id = %s', (pid,))

            cur.execute(
                '''INSERT INTO problems (
                    slug, title, company, difficulty, category_slug,
                    statement_markdown, constraints_text, tags_json,
                    examples_json, supported_languages_json, starter_templates_json,
                    source_type, source, frequency, year, source_ref, external_id,
                    status, time_limit_ms, memory_limit_kb, created_at, updated_at
                ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                RETURNING id
                ''',
                (
                    problem['slug'],
                    problem['title'],
                    problem['company'],
                    problem['difficulty'],
                    problem['category_slug'],
                    problem['statement_markdown'],
                    problem['constraints_text'],
                    problem['tags_json'],
                    problem['examples_json'],
                    problem['supported_languages_json'],
                    problem['starter_templates_json'],
                    problem['source_type'],
                    problem['source'],
                    problem['frequency'],
                    problem['year'],
                    problem['source_ref'],
                    problem['external_id'],
                    problem['status'],
                    problem.get('time_limit_ms', 2000),
                    problem.get('memory_limit_kb', 262144),
                    problem['created_at'],
                    problem['updated_at'],
                ),
            )
            row = cur.fetchone()
            problem_id = row['id']

            for tc in test_cases:
                cur.execute(
                    'INSERT INTO problem_test_cases (problem_id, case_type, stdin_text, expected_output_text, sort_order) VALUES (%s, %s, %s, %s, %s)',
                    (problem_id, tc['case_type'], tc['stdin_text'], tc['expected_output_text'], tc['sort_order']),
                )

            conn.commit()
            print(f'Imported problem id={problem_id}, slug={slug}')
            print(f'Test cases: {len(test_cases)} (2 sample + {len(test_cases)-2} hidden)')


if __name__ == '__main__':
    import_problem()
