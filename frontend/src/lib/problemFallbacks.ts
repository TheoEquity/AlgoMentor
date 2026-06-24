import type { ProblemDetail, ProblemListItem } from '../types/problem'

export const fallbackProblemList: ProblemListItem[] = [
  {
    id: 1,
    slug: 'array-partition-max-gap',
    title: '数组划分后的最大差值',
    company: '字节跳动',
    difficulty: 'Medium',
    category_slug: 'greedy',
    tags: ['数组', '贪心', '前后缀'],
    supported_languages: ['Python', 'C++', 'Java'],
    status: 'published',
    updated_at: '2026-06-23T16:00:00Z',
  },
  {
    id: 2,
    slug: 'parentheses-min-fix',
    title: '括号序列的最短修复',
    company: '腾讯',
    difficulty: 'Easy',
    category_slug: 'stack-queue',
    tags: ['栈', '字符串'],
    supported_languages: ['Python', 'C++', 'Java'],
    status: 'published',
    updated_at: '2026-06-23T16:05:00Z',
  },
]

export const fallbackProblemDetails: Record<number, ProblemDetail> = {
  1: {
    id: 1,
    slug: 'array-partition-max-gap',
    title: '数组划分后的最大差值',
    company: '字节跳动',
    difficulty: 'Medium',
    category_slug: 'greedy',
    tags: ['数组', '贪心', '前后缀'],
    supported_languages: ['Python', 'C++', 'Java'],
    status: 'published',
    updated_at: '2026-06-23T16:00:00Z',
    statement_markdown: '给定一个长度为 n 的整数数组，请将数组划分为左右两个非空部分，使左右部分最大值差的绝对值最大。',
    constraints_text: '2 <= n <= 2 * 10^5，-10^9 <= nums[i] <= 10^9',
    starter_templates: {
      Python: 'def solve() -> None:\n    pass\n',
      'C++': '#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}\n',
      Java: 'public class Main {\n    public static void main(String[] args) {\n    }\n}\n',
    },
    source_type: 'manual',
    source_ref: 'ByteHunter 首批手工题库',
    external_id: 'BH-001',
    examples: [
      {
        input: '5\n1 3 2 5 4',
        output: '4',
        explanation: '切分为 [1,3,2] 和 [5,4] 时可得到最大差值。',
      },
    ],
    test_cases: [
      {
        case_type: 'sample',
        stdin_text: '5\n1 3 2 5 4',
        expected_output_text: '4',
        sort_order: 1,
      },
    ],
  },
  2: {
    id: 2,
    slug: 'parentheses-min-fix',
    title: '括号序列的最短修复',
    company: '腾讯',
    difficulty: 'Easy',
    category_slug: 'stack-queue',
    tags: ['栈', '字符串'],
    supported_languages: ['Python', 'C++', 'Java'],
    status: 'published',
    updated_at: '2026-06-23T16:05:00Z',
    statement_markdown: '给定一个只包含 `(` 和 `)` 的字符串，求最少插入多少个括号能使其合法。',
    constraints_text: '1 <= len(s) <= 10^5',
    starter_templates: {
      Python: 'def solve() -> None:\n    pass\n',
      'C++': '#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}\n',
      Java: 'public class Main {\n    public static void main(String[] args) {\n    }\n}\n',
    },
    source_type: 'manual',
    source_ref: 'ByteHunter 首批手工题库',
    external_id: 'BH-014',
    examples: [
      {
        input: '()))(',
        output: '3',
        explanation: '在首部与末尾补充括号即可。',
      },
    ],
    test_cases: [
      {
        case_type: 'sample',
        stdin_text: '()))(',
        expected_output_text: '3',
        sort_order: 1,
      },
    ],
  },
}
