--
-- PostgreSQL database dump
--

\restrict uR3Mnek18JCxdRqCoLVUoCngdlq71apeZwUqwP7azmZzvzsaEXHt78UwNamOq1V

-- Dumped from database version 15.18 (Debian 15.18-0+deb12u1)
-- Dumped by pg_dump version 15.18 (Debian 15.18-0+deb12u1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Data for Name: companies; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.companies (id, name, name_en, abbreviation, created_at) VALUES (1, '腾讯', 'Tecent', '腾讯', '2026-06-24T14:48:00Z');
INSERT INTO public.companies (id, name, name_en, abbreviation, created_at) VALUES (2, '阿里巴巴', 'Alibaba', '阿里', '2026-06-24T14:48:16Z');
INSERT INTO public.companies (id, name, name_en, abbreviation, created_at) VALUES (3, '美团', 'Meituan', '美团', '2026-06-24T14:48:33Z');
INSERT INTO public.companies (id, name, name_en, abbreviation, created_at) VALUES (4, '华为', 'Huwei', '华为', '2026-06-26T08:58:27Z');


--
-- Data for Name: problems; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.problems (id, slug, title, company, difficulty, statement_markdown, constraints_text, tags_json, examples_json, supported_languages_json, starter_templates_json, source_type, source_ref, external_id, status, created_at, updated_at, category_slug, source, frequency, year, time_limit_ms, memory_limit_kb) VALUES (1, 'array-partition-max-gap', '数组划分后的最大差值', '字节跳动', 'Medium', '给定一个长度为 n 的整数数组，请将数组划分为左右两个非空部分，使左右部分最大值差的绝对值最大。输出这个最大差值。', '2 <= n <= 2 * 10^5，-10^9 <= nums[i] <= 10^9', '["\u6570\u7ec4", "\u8d2a\u5fc3", "\u524d\u540e\u7f00"]', '[{"input": "5\n1 3 2 5 4", "output": "4", "explanation": "\u5207\u5206\u4e3a [1,3,2] \u548c [5,4] \u65f6\u53ef\u5f97\u5230\u6700\u5927\u5dee\u503c\u3002"}]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass\n\n\nif __name__ == \"__main__\":\n    solve()\n", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}\n", "Java": "import java.io.*;\n\npublic class Main {\n    public static void main(String[] args) throws Exception {\n    }\n}\n"}', 'manual', 'ByteHunter 首批手工题库', 'BH-001', '未开始', '2026-06-23T16:00:00Z', '2026-06-23T16:00:00Z', '', '手工', '中', NULL, 2000, 262144);
INSERT INTO public.problems (id, slug, title, company, difficulty, statement_markdown, constraints_text, tags_json, examples_json, supported_languages_json, starter_templates_json, source_type, source_ref, external_id, status, created_at, updated_at, category_slug, source, frequency, year, time_limit_ms, memory_limit_kb) VALUES (2, 'parentheses-min-fix', '括号序列的最短修复', '腾讯', 'Easy', '给定一个只包含 `(` 和 `)` 的字符串，求最少插入多少个括号能使其合法。', '1 <= len(s) <= 10^5', '["\u6808", "\u5b57\u7b26\u4e32"]', '[{"input": "()))(", "output": "3", "explanation": "\u5728\u9996\u90e8\u4e0e\u672b\u5c3e\u8865\u5145\u62ec\u53f7\u5373\u53ef\u3002"}]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass\n", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}\n", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}\n"}', 'manual', 'ByteHunter 首批手工题库', 'BH-014', '未开始', '2026-06-23T16:05:00Z', '2026-06-23T16:05:00Z', '', '手工', '中', NULL, 2000, 262144);
INSERT INTO public.problems (id, slug, title, company, difficulty, statement_markdown, constraints_text, tags_json, examples_json, supported_languages_json, starter_templates_json, source_type, source_ref, external_id, status, created_at, updated_at, category_slug, source, frequency, year, time_limit_ms, memory_limit_kb) VALUES (3, 'let-it-go', '放它一马', '美团', 'Hard', '小美会按照编号从小到大的顺序依次遇到 $n$ 只怪物（编号为 $1 \sim n$），怪物 $i\ (1 \le i \le n)$ 的生命为 $a_i$。

对于每只怪物，小美都可以选择放走Ta或者击败Ta。
- 如果放走怪物，小美将获得 $i$ 点经验值。
- 如果击败怪物，小美将获得 $a_i$ 点经验值，同时将额外获得 $(x \bmod 10) \times a_i$ 点经验值，$x$ 为击败怪物数量（包括这一个怪物）。

求小美最多可以从这 $n$ 个怪物中获得的经验值。

**时间限制**：C/C++ 1秒，其他语言2秒  
**空间限制**：C/C++ 256M，其他语言512M', '1 ≤ n ≤ 2×10^5
1 ≤ a_i ≤ 10^9', '["DP", "\u8d2a\u5fc3", "\u524d\u540e\u7f00"]', '[{"input": "3\n5 3 2", "output": "27", "explanation": "\u7b2c\u4e00\u4e2a\u602a\u7269\u9009\u62e9\u51fb\u8d25\u83b7\u5f97 5+5\u00d71=10\uff0c\u7b2c\u4e8c\u4e2a\u602a\u7269\u9009\u62e9\u51fb\u8d25\u83b7\u5f97 3+3\u00d72=9\uff0c\u7b2c\u4e09\u53ea\u602a\u7269\u9009\u62e9\u51fb\u8d25\u83b7\u5f97 2+2\u00d73=8\uff0c\u603b\u5171 27\u3002"}]', '["Python", "C++", "Java"]', '{"Python": "import sys\n\ndef solve() -> None:\n    data = sys.stdin.read().split()\n    if not data:\n        return\n    n = int(data[0])\n    a = list(map(int, data[1:1+n]))\n    print(max_experience(n, a))\n\n\ndef max_experience(n: int, a: list[int]) -> int:\n    pass\n\n\nif __name__ == \"__main__\":\n    solve()", "C++": "#include <bits/stdc++.h>\nusing namespace std;\nusing i64 = long long;\n\nint main() {\n    ios::sync_with_stdio(false);\n    cin.tie(nullptr);\n    int n;\n    cin >> n;\n    vector<i64> a(n);\n    for (int i = 0; i < n; ++i) cin >> a[i];\n    cout << solve(n, a) << \n;\n    return 0;\n}", "Java": "import java.io.*;\nimport java.util.*;\n\npublic class Main {\n    public static void main(String[] args) throws Exception {\n        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));\n        int n = Integer.parseInt(br.readLine());\n        long[] a = new long[n];\n        StringTokenizer st = new StringTokenizer(br.readLine());\n        for (int i = 0; i < n; i++) a[i] = Long.parseLong(st.nextToken());\n        System.out.println(solve(n, a));\n    }\n\n    static long solve(int n, long[] a) {\n        return 0;\n    }\n}"}', 'manual', '美团笔试题库', 'MT-001', '未开始', '2026-06-24T14:51:29.490649+00:00', '2026-06-25T15:36:51.596654+00:00', 'dynamic-programming', '手工', '中', 2025, 2000, 262144);


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.users (id, username, display_name, created_at) VALUES (1, 'default', '默认用户', '2026-06-23T17:20:00Z');


--
-- Data for Name: submissions; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.submissions (id, user_id, problem_id, language, run_type, code_text, custom_input, verdict, runtime_ms, memory_kb, compiler_output, stderr_output, failed_case_index, failed_input, failed_expected_output, failed_actual_output, case_results_json, judge_token, created_at) VALUES (1, 1, 3, 'Python', 'run', 'import sys

def solve() -> None:
    data = sys.stdin.read().split()
    if not data:
        return
    n = int(data[0])
    a = list(map(int, data[1:1+n]))
    print(max_experience(n, a))


def max_experience(n: int, a: list[int]) -> int:
    pass


if __name__ == "__main__":
    solve()', '3
5 3 2', 'WA', 1480, 52796, '', '', 1, '3
5 3 2', '27', 'None', '[{"case_index": 1, "case_type": "sample", "stdin_text": "3\n5 3 2", "expected_output_text": "27", "actual_output_text": "None", "verdict": "WA", "runtime_ms": 1480, "memory_kb": 52196, "stderr_output": ""}, {"case_index": 2, "case_type": "sample", "stdin_text": "2\n18 7", "expected_output_text": "57", "actual_output_text": "None", "verdict": "WA", "runtime_ms": 1271, "memory_kb": 52028, "stderr_output": ""}, {"case_index": 3, "case_type": "hidden", "stdin_text": "7\n4 1 9 8 8 5 4", "expected_output_text": "202", "actual_output_text": "None", "verdict": "WA", "runtime_ms": 1202, "memory_kb": 51936, "stderr_output": ""}, {"case_index": 4, "case_type": "hidden", "stdin_text": "3\n8 17 20", "expected_output_text": "147", "actual_output_text": "None", "verdict": "WA", "runtime_ms": 1146, "memory_kb": 52796, "stderr_output": ""}]', 'dbfb1bcd-f32d-4723-b91e-7c2fddbc06fb', '2026-06-24T14:53:37.465723+00:00');
INSERT INTO public.submissions (id, user_id, problem_id, language, run_type, code_text, custom_input, verdict, runtime_ms, memory_kb, compiler_output, stderr_output, failed_case_index, failed_input, failed_expected_output, failed_actual_output, case_results_json, judge_token, created_at) VALUES (2, 1, 3, 'Python', 'run', 'import sys

def solve() -> None:
    data = sys.stdin.read().split()
    if not data:
        return
    n = int(data[0])
    a = list(map(int, data[1:1+n]))
    print(max_experience(n, a))


def max_experience(n: int, a: list[int]) -> int:
    pass


if __name__ == "__main__":
    solve()', '3
5 3 2', 'WA', 1179, 52316, '', '', 1, '3
5 3 2', '27', 'None', '[{"case_index": 1, "case_type": "sample", "stdin_text": "3\n5 3 2", "expected_output_text": "27", "actual_output_text": "None", "verdict": "WA", "runtime_ms": 1148, "memory_kb": 52272, "stderr_output": ""}, {"case_index": 2, "case_type": "sample", "stdin_text": "2\n18 7", "expected_output_text": "57", "actual_output_text": "None", "verdict": "WA", "runtime_ms": 1165, "memory_kb": 52212, "stderr_output": ""}, {"case_index": 3, "case_type": "hidden", "stdin_text": "7\n4 1 9 8 8 5 4", "expected_output_text": "202", "actual_output_text": "None", "verdict": "WA", "runtime_ms": 1179, "memory_kb": 52316, "stderr_output": ""}, {"case_index": 4, "case_type": "hidden", "stdin_text": "3\n8 17 20", "expected_output_text": "147", "actual_output_text": "None", "verdict": "WA", "runtime_ms": 1096, "memory_kb": 51948, "stderr_output": ""}]', 'd199136b-88ce-46b3-b031-e3dad3316d77', '2026-06-24T15:02:50.071390+00:00');
INSERT INTO public.submissions (id, user_id, problem_id, language, run_type, code_text, custom_input, verdict, runtime_ms, memory_kb, compiler_output, stderr_output, failed_case_index, failed_input, failed_expected_output, failed_actual_output, case_results_json, judge_token, created_at) VALUES (3, 1, 3, 'Python', 'submit', 'import sys

def solve() -> None:
    data = sys.stdin.read().split()
    if not data:
        return
    n = int(data[0])
    a = list(map(int, data[1:1+n]))
    print(max_experience(n, a))


def max_experience(n: int, a: list[int]) -> int:
    pass


if __name__ == "__main__":
    solve()', '3
5 3 2', 'WA', 1109, 52288, '', '', 1, '7
4 1 9 8 8 5 4', '202', 'None', '[{"case_index": 1, "case_type": "hidden", "stdin_text": "7\n4 1 9 8 8 5 4", "expected_output_text": "202", "actual_output_text": "None", "verdict": "WA", "runtime_ms": 1109, "memory_kb": 52288, "stderr_output": ""}]', '36ef8cf5-fae6-4b0f-87d4-5d8d66810faf', '2026-06-24T15:03:44.118847+00:00');
INSERT INTO public.submissions (id, user_id, problem_id, language, run_type, code_text, custom_input, verdict, runtime_ms, memory_kb, compiler_output, stderr_output, failed_case_index, failed_input, failed_expected_output, failed_actual_output, case_results_json, judge_token, created_at) VALUES (4, 1, 3, 'Python', 'run', 'import sys


def solve() -> None:
    data =.stdin.read().split()
    if not data:
        return
    n = int(data[0])
    a = list(map(int, data[1: + n]))
    print(max_experience(n, a))


def max_experience(n: int, a: list[int]) -> int:
    NEG = -10 ** 25
    dp = [NEG] * 10
    dp[0] = 0

    for i in range(1, n + ):
        ndp = dp[:]
        for r in range(10):
            cur = dp[r]
            if cur == NEG:
                continue
            nr = (r + 1) % 10
            mult = nr + 1
            ndp[nr] = max(ndp[nr], cur + a[i - 1] * mult)
        dp = ndp

    return max(dp)


if __name__ == "__main__":
    solve()', '3
5 3 2', 'RE', 1430, 52532, '', '  File "/box/script.py", line 5
    data =.stdin.read().split()
          ^
SyntaxError: invalid syntax
', 1, '3
5 3 2', '27', '', '[{"case_index": 1, "case_type": "sample", "stdin_text": "3\n5 3 2", "expected_output_text": "27", "actual_output_text": "", "verdict": "RE", "runtime_ms": 1255, "memory_kb": 52092, "stderr_output": "  File \"/box/script.py\", line 5\n    data =.stdin.read().split()\n          ^\nSyntaxError: invalid syntax\n"}, {"case_index": 2, "case_type": "sample", "stdin_text": "2\n18 7", "expected_output_text": "57", "actual_output_text": "", "verdict": "RE", "runtime_ms": 1430, "memory_kb": 52036, "stderr_output": "  File \"/box/script.py\", line 5\n    data =.stdin.read().split()\n          ^\nSyntaxError: invalid syntax\n"}, {"case_index": 3, "case_type": "hidden", "stdin_text": "7\n4 1 9 8 8 5 4", "expected_output_text": "202", "actual_output_text": "", "verdict": "RE", "runtime_ms": 1160, "memory_kb": 52328, "stderr_output": "  File \"/box/script.py\", line 5\n    data =.stdin.read().split()\n          ^\nSyntaxError: invalid syntax\n"}, {"case_index": 4, "case_type": "hidden", "stdin_text": "3\n8 17 20", "expected_output_text": "147", "actual_output_text": "", "verdict": "RE", "runtime_ms": 1180, "memory_kb": 52532, "stderr_output": "  File \"/box/script.py\", line 5\n    data =.stdin.read().split()\n          ^\nSyntaxError: invalid syntax\n"}]', 'bb79514e-c180-47a4-9951-c4e63a1d882d', '2026-06-24T15:05:40.746251+00:00');
INSERT INTO public.submissions (id, user_id, problem_id, language, run_type, code_text, custom_input, verdict, runtime_ms, memory_kb, compiler_output, stderr_output, failed_case_index, failed_input, failed_expected_output, failed_actual_output, case_results_json, judge_token, created_at) VALUES (5, 1, 3, 'Python', 'submit', 'import sys


def solve() -> None:
    data =.stdin.read().split()
    if not data:
        return
    n = int(data[0])
    a = list(map(int, data[1: + n]))
    print(max_experience(n, a))


def max_experience(n: int, a: list[int]) -> int:
    NEG = -10 ** 25
    dp = [NEG] * 10
    dp[0] = 0

    for i in range(1, n + ):
        ndp = dp[:]
        for r in range(10):
            cur = dp[r]
            if cur == NEG:
                continue
            nr = (r + 1) % 10
            mult = nr + 1
            ndp[nr] = max(ndp[nr], cur + a[i - 1] * mult)
        dp = ndp

    return max(dp)


if __name__ == "__main__":
    solve()', '3
5 3 2', 'RE', 1149, 52076, '', '  File "/box/script.py", line 5
    data =.stdin.read().split()
          ^
SyntaxError: invalid syntax
', 1, '7
4 1 9 8 8 5 4', '202', '', '[{"case_index": 1, "case_type": "hidden", "stdin_text": "7\n4 1 9 8 8 5 4", "expected_output_text": "202", "actual_output_text": "", "verdict": "RE", "runtime_ms": 1149, "memory_kb": 52076, "stderr_output": "  File \"/box/script.py\", line 5\n    data =.stdin.read().split()\n          ^\nSyntaxError: invalid syntax\n"}]', 'a80b97c3-2c33-4d62-8215-ac377e9514bc', '2026-06-24T15:06:27.972879+00:00');


--
-- Data for Name: error_attributions; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.error_attributions (id, submission_id, analysis_type, primary_category, secondary_category, summary, suggestion, bullets_json, line_refs_json, execution_status, status_reason, provider, model, endpoint_url, raw_response_json, created_at) VALUES (1, 1, 'attribution', '', '', '错误归因', '系统已准备好按当前 LLM 配置执行错误归因。 当前返回为降级结果：系统管理中尚未配置 API Key，当前无法发起真实模型请求。', '["\u9898\u76ee\uff1a\u653e\u5b83\u4e00\u9a6c\u3002", "Verdict\uff1aWA\u3002", "\u7a0b\u5e8f\u5df2\u7ecf\u4ea7\u51fa\u7ed3\u679c\uff0c\u4e3b\u8981\u504f\u5dee\u96c6\u4e2d\u5728\u8f93\u51fa\u4e0e\u9884\u671f\u4e0d\u4e00\u81f4\u3002", "\u5efa\u8bae\u4f18\u5148\u6253\u5f00 diff \u9762\u677f\uff0c\u5bf9\u7167 failed case \u68c0\u67e5\u8fb9\u754c\u6761\u4ef6\u548c\u6700\u7ec8\u8f93\u51fa\u683c\u5f0f\u3002", "\u5982\u679c\u6837\u4f8b\u901a\u8fc7\u4f46\u9690\u85cf\u70b9\u5931\u8d25\uff0c\u4f18\u5148\u68c0\u67e5\u6781\u503c\u3001\u7a7a\u8f93\u5165\u548c\u521d\u59cb\u5316\u72b6\u6001\u3002"]', '[{"line": 5, "message": "\u8fd9\u4e00\u6bb5\u901a\u5e38\u627f\u63a5\u72b6\u6001\u8f6c\u79fb\u6216\u6700\u7ec8\u8f93\u51fa\uff0c\u9002\u5408\u4f18\u5148\u6392\u67e5\u3002", "severity": "warning"}]', 'degraded', '系统管理中尚未配置 API Key，当前无法发起真实模型请求。', 'OpenAI Compatible', 'gpt-4.1-mini', 'https://api.openai.com/v1', '{"analysis_type": "attribution", "provider": "OpenAI Compatible", "model": "gpt-4.1-mini", "endpoint_url": "https://api.openai.com/v1", "execution_status": "degraded", "status_reason": "\u7cfb\u7edf\u7ba1\u7406\u4e2d\u5c1a\u672a\u914d\u7f6e API Key\uff0c\u5f53\u524d\u65e0\u6cd5\u53d1\u8d77\u771f\u5b9e\u6a21\u578b\u8bf7\u6c42\u3002", "title": "\u9519\u8bef\u5f52\u56e0", "summary": "\u7cfb\u7edf\u5df2\u51c6\u5907\u597d\u6309\u5f53\u524d LLM \u914d\u7f6e\u6267\u884c\u9519\u8bef\u5f52\u56e0\u3002 \u5f53\u524d\u8fd4\u56de\u4e3a\u964d\u7ea7\u7ed3\u679c\uff1a\u7cfb\u7edf\u7ba1\u7406\u4e2d\u5c1a\u672a\u914d\u7f6e API Key\uff0c\u5f53\u524d\u65e0\u6cd5\u53d1\u8d77\u771f\u5b9e\u6a21\u578b\u8bf7\u6c42\u3002", "bullets": ["\u9898\u76ee\uff1a\u653e\u5b83\u4e00\u9a6c\u3002", "Verdict\uff1aWA\u3002", "\u7a0b\u5e8f\u5df2\u7ecf\u4ea7\u51fa\u7ed3\u679c\uff0c\u4e3b\u8981\u504f\u5dee\u96c6\u4e2d\u5728\u8f93\u51fa\u4e0e\u9884\u671f\u4e0d\u4e00\u81f4\u3002", "\u5efa\u8bae\u4f18\u5148\u6253\u5f00 diff \u9762\u677f\uff0c\u5bf9\u7167 failed case \u68c0\u67e5\u8fb9\u754c\u6761\u4ef6\u548c\u6700\u7ec8\u8f93\u51fa\u683c\u5f0f\u3002", "\u5982\u679c\u6837\u4f8b\u901a\u8fc7\u4f46\u9690\u85cf\u70b9\u5931\u8d25\uff0c\u4f18\u5148\u68c0\u67e5\u6781\u503c\u3001\u7a7a\u8f93\u5165\u548c\u521d\u59cb\u5316\u72b6\u6001\u3002"], "line_refs": [{"line": 5, "message": "\u8fd9\u4e00\u6bb5\u901a\u5e38\u627f\u63a5\u72b6\u6001\u8f6c\u79fb\u6216\u6700\u7ec8\u8f93\u51fa\uff0c\u9002\u5408\u4f18\u5148\u6392\u67e5\u3002", "severity": "warning"}], "verdict": "WA"}', '2026-06-24T14:54:28.383147+00:00');


--
-- Data for Name: problem_categories; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.problem_categories (id, name, slug, sort_order, created_at) VALUES (1, 'Two Pointers', 'two-pointers', 1, '2026-06-24T00:00:00Z');
INSERT INTO public.problem_categories (id, name, slug, sort_order, created_at) VALUES (2, 'Sliding Window', 'sliding-window', 2, '2026-06-24T00:00:00Z');
INSERT INTO public.problem_categories (id, name, slug, sort_order, created_at) VALUES (3, 'Hashing', 'hashing', 3, '2026-06-24T00:00:00Z');
INSERT INTO public.problem_categories (id, name, slug, sort_order, created_at) VALUES (4, 'Binary Search', 'binary-search', 4, '2026-06-24T00:00:00Z');
INSERT INTO public.problem_categories (id, name, slug, sort_order, created_at) VALUES (5, 'Prefix Sum', 'prefix-sum', 5, '2026-06-24T00:00:00Z');
INSERT INTO public.problem_categories (id, name, slug, sort_order, created_at) VALUES (6, 'Intervals', 'intervals', 6, '2026-06-24T00:00:00Z');
INSERT INTO public.problem_categories (id, name, slug, sort_order, created_at) VALUES (7, 'Matrix Grid', 'matrix-grid', 7, '2026-06-24T00:00:00Z');
INSERT INTO public.problem_categories (id, name, slug, sort_order, created_at) VALUES (8, 'Linked List', 'linked-list', 8, '2026-06-24T00:00:00Z');
INSERT INTO public.problem_categories (id, name, slug, sort_order, created_at) VALUES (9, 'Stack Queue', 'stack-queue', 9, '2026-06-24T00:00:00Z');
INSERT INTO public.problem_categories (id, name, slug, sort_order, created_at) VALUES (10, 'Monotonic Stack', 'monotonic-stack', 10, '2026-06-24T00:00:00Z');
INSERT INTO public.problem_categories (id, name, slug, sort_order, created_at) VALUES (11, 'Heap Priority Queue', 'heap-priority-queue', 11, '2026-06-24T00:00:00Z');
INSERT INTO public.problem_categories (id, name, slug, sort_order, created_at) VALUES (12, 'Tree', 'tree', 12, '2026-06-24T00:00:00Z');
INSERT INTO public.problem_categories (id, name, slug, sort_order, created_at) VALUES (13, 'Graphs', 'graphs', 13, '2026-06-24T00:00:00Z');
INSERT INTO public.problem_categories (id, name, slug, sort_order, created_at) VALUES (14, 'Backtracking', 'backtracking', 14, '2026-06-24T00:00:00Z');
INSERT INTO public.problem_categories (id, name, slug, sort_order, created_at) VALUES (15, 'DP', 'dynamic-programming', 15, '2026-06-24T00:00:00Z');
INSERT INTO public.problem_categories (id, name, slug, sort_order, created_at) VALUES (16, 'Greedy', 'greedy', 16, '2026-06-24T00:00:00Z');
INSERT INTO public.problem_categories (id, name, slug, sort_order, created_at) VALUES (17, 'Bit Manipulation', 'bit-manipulation', 17, '2026-06-24T00:00:00Z');
INSERT INTO public.problem_categories (id, name, slug, sort_order, created_at) VALUES (18, 'Simulation', 'simulation', 18, '2026-06-24T00:00:00Z');
INSERT INTO public.problem_categories (id, name, slug, sort_order, created_at) VALUES (19, '数学', 'math', 20, '2026-06-26 10:00:00+00');
INSERT INTO public.problem_categories (id, name, slug, sort_order, created_at) VALUES (20, 'String', 'string', 21, '2026-07-03 10:00:00+00');


--
-- Data for Name: problem_test_cases; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.problem_test_cases (id, problem_id, case_type, stdin_text, expected_output_text, sort_order) VALUES (1, 1, 'sample', '5
1 3 2 5 4', '4', 1);
INSERT INTO public.problem_test_cases (id, problem_id, case_type, stdin_text, expected_output_text, sort_order) VALUES (2, 1, 'hidden', '4
7 1 8 2', '7', 2);
INSERT INTO public.problem_test_cases (id, problem_id, case_type, stdin_text, expected_output_text, sort_order) VALUES (3, 2, 'sample', '()))(', '3', 1);
INSERT INTO public.problem_test_cases (id, problem_id, case_type, stdin_text, expected_output_text, sort_order) VALUES (8, 3, 'sample', '3
5 3 2', '27', 1);
INSERT INTO public.problem_test_cases (id, problem_id, case_type, stdin_text, expected_output_text, sort_order) VALUES (9, 3, 'hidden', '7
4 1 9 8 8 5 4', '202', 2);


--
-- Name: companies_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.companies_id_seq', 4, true);


--
-- Name: error_attributions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.error_attributions_id_seq', 1, true);


--
-- Name: problem_categories_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.problem_categories_id_seq', 20, true);


--
-- Name: problem_test_cases_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.problem_test_cases_id_seq', 21, true);


--
-- Name: problems_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.problems_id_seq', 13, true);


--
-- Name: submissions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.submissions_id_seq', 5, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.users_id_seq', 1, true);


--
-- PostgreSQL database dump complete
--

\unrestrict uR3Mnek18JCxdRqCoLVUoCngdlq71apeZwUqwP7azmZzvzsaEXHt78UwNamOq1V

