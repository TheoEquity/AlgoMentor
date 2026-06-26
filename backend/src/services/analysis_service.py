from __future__ import annotations

import re
from collections.abc import Iterator

from schemas.analysis import AnalysisLineRef, AnalysisResponse, ParsedProblemResult, ProblemChatMessage
from schemas.llm_settings import LLMSettings
from schemas.problems import ProblemDetail
from schemas.submissions import SubmissionResult
from services.llm_client import LLMClient, LLMClientError



class AnalysisService:
    def __init__(self):
        self.client = LLMClient()

    def analyze_solution(self, settings: LLMSettings, api_key: str, problem: ProblemDetail, language: str, code_text: str) -> AnalysisResponse:
        prompt = self._build_solution_prompt(problem, language, code_text)
        return self._run_model(
            analysis_type='solution',
            settings=settings,
            api_key=api_key,
            model=settings.solution_model,
            temperature=settings.solution_temperature,
            prompt=prompt,
            fallback=self._fallback_solution(settings, problem, language, code_text),
            verdict=None,
        )

    def attribute_error(self, settings: LLMSettings, api_key: str, problem: ProblemDetail, submission: SubmissionResult) -> AnalysisResponse:
        prompt = self._build_attribution_prompt(problem, submission)
        return self._run_model(
            analysis_type='attribution',
            settings=settings,
            api_key=api_key,
            model=settings.attribution_model,
            temperature=settings.attribution_temperature,
            prompt=prompt,
            fallback=self._fallback_attribution(settings, problem, submission),
            verdict=submission.verdict,
        )

    def review_submission(self, settings: LLMSettings, api_key: str, problem: ProblemDetail, submission: SubmissionResult) -> AnalysisResponse:
        prompt = self._build_review_prompt(problem, submission)
        return self._run_model(
            analysis_type='review',
            settings=settings,
            api_key=api_key,
            model=settings.review_model,
            temperature=settings.review_temperature,
            prompt=prompt,
            fallback=self._fallback_review(settings, problem, submission),
            verdict=submission.verdict,
        )

    def generate_hint(
        self,
        settings: LLMSettings,
        api_key: str,
        problem: ProblemDetail,
        language: str,
        code_text: str,
        hint_step: int,
        hint_strength: str,
        submission: SubmissionResult | None = None,
    ) -> AnalysisResponse:
        prompt = self._build_hint_prompt(problem, language, code_text, hint_step, hint_strength, submission)
        return self._run_model(
            analysis_type='hint',
            settings=settings,
            api_key=api_key,
            model=settings.solution_model,
            temperature=settings.solution_temperature,
            prompt=prompt,
            fallback=self._fallback_hint(settings, problem, hint_step, hint_strength, submission),
            verdict=submission.verdict if submission is not None else None,
        )

    def analyze_problem_thinking(self, settings: LLMSettings, api_key: str, problem: ProblemDetail) -> AnalysisResponse:
        prompt = self._build_problem_analysis_prompt(problem)
        return self._run_model(
            analysis_type='problem_analysis',
            settings=settings,
            api_key=api_key,
            model=settings.solution_model,
            temperature=settings.solution_temperature,
            prompt=prompt,
            fallback=self._fallback_problem_analysis(settings, problem),
            verdict=None,
        )

    def chat_problem_thinking(self, settings: LLMSettings, api_key: str, problem: ProblemDetail, messages: list[ProblemChatMessage], question: str) -> AnalysisResponse:
        prompt = self._build_problem_chat_prompt(problem, messages, question)
        return self._run_model(
            analysis_type='problem_qa',
            settings=settings,
            api_key=api_key,
            model=settings.solution_model,
            temperature=settings.solution_temperature,
            prompt=prompt,
            fallback=self._fallback_problem_chat(settings, problem, question),
            verdict=None,
        )

    def stream_solution_analysis(self, settings: LLMSettings, api_key: str, problem: ProblemDetail, language: str, code_text: str) -> Iterator[tuple[str, dict | AnalysisResponse]]:
        prompt = self._build_solution_prompt(problem, language, code_text)
        yield from self._stream_model(
            analysis_type='solution',
            settings=settings,
            api_key=api_key,
            model=settings.solution_model,
            temperature=settings.solution_temperature,
            prompt=prompt,
            fallback=self._fallback_solution(settings, problem, language, code_text),
            verdict=None,
        )

    def stream_error_attribution(self, settings: LLMSettings, api_key: str, problem: ProblemDetail, submission: SubmissionResult) -> Iterator[tuple[str, dict | AnalysisResponse]]:
        prompt = self._build_attribution_prompt(problem, submission)
        yield from self._stream_model(
            analysis_type='attribution',
            settings=settings,
            api_key=api_key,
            model=settings.attribution_model,
            temperature=settings.attribution_temperature,
            prompt=prompt,
            fallback=self._fallback_attribution(settings, problem, submission),
            verdict=submission.verdict,
        )

    def stream_review_submission(self, settings: LLMSettings, api_key: str, problem: ProblemDetail, submission: SubmissionResult) -> Iterator[tuple[str, dict | AnalysisResponse]]:
        prompt = self._build_review_prompt(problem, submission)
        yield from self._stream_model(
            analysis_type='review',
            settings=settings,
            api_key=api_key,
            model=settings.review_model,
            temperature=settings.review_temperature,
            prompt=prompt,
            fallback=self._fallback_review(settings, problem, submission),
            verdict=submission.verdict,
        )

    def _run_model(
        self,
        *,
        analysis_type: str,
        settings: LLMSettings,
        api_key: str,
        model: str,
        temperature: float,
        prompt: str,
        fallback: AnalysisResponse,
        verdict: str | None,
    ) -> AnalysisResponse:
        try:
            payload = self.client.generate_json(settings, api_key, model, prompt, temperature)
        except LLMClientError as exc:
            fallback.execution_status = 'degraded'
            fallback.status_reason = str(exc)
            fallback.summary = f'{fallback.summary} 当前返回为降级结果：{exc}'
            return fallback

        return self._build_response(
            analysis_type=analysis_type,
            settings=settings,
            model=model,
            payload=payload,
            fallback=fallback,
            verdict=verdict,
        )

    def _stream_model(
        self,
        *,
        analysis_type: str,
        settings: LLMSettings,
        api_key: str,
        model: str,
        temperature: float,
        prompt: str,
        fallback: AnalysisResponse,
        verdict: str | None,
    ) -> Iterator[tuple[str, dict | AnalysisResponse]]:
        yield (
            'meta',
            {
                'analysis_type': analysis_type,
                'provider': settings.provider,
                'model': model,
                'endpoint_url': settings.endpoint_url,
                'verdict': verdict,
                'execution_status': 'streaming',
                'status_reason': '',
            },
        )

        chunks: list[str] = []
        try:
            emitted_bullets: set[str] = set()
            emitted_line_refs: set[tuple[int, str, str]] = set()
            last_title = ''
            last_summary = ''
            for chunk in self.client.stream_text(settings, api_key, model, prompt, temperature):
                if not chunk:
                    continue
                chunks.append(chunk)
                yield ('chunk', {'text': chunk})

                preview_payload = self._extract_stream_preview(''.join(chunks))
                title = str(preview_payload.get('title', '')).strip()
                if title and title != last_title:
                    last_title = title
                    yield ('title', {'title': title})

                summary = str(preview_payload.get('summary', '')).strip()
                if summary and summary != last_summary:
                    last_summary = summary
                    yield ('summary', {'summary': summary})

                for bullet in preview_payload.get('bullets', []):
                    bullet_text = str(bullet).strip()
                    if bullet_text and bullet_text not in emitted_bullets:
                        emitted_bullets.add(bullet_text)
                        yield ('bullet', {'bullet': bullet_text})

                for item in preview_payload.get('line_refs', []):
                    if not isinstance(item, dict):
                        continue
                    line = max(1, int(item.get('line', 1)))
                    message = str(item.get('message', '请检查这一行附近的逻辑。')).strip()
                    severity = 'error' if str(item.get('severity', 'warning')) == 'error' else 'warning'
                    key = (line, message, severity)
                    if message and key not in emitted_line_refs:
                        emitted_line_refs.add(key)
                        yield ('line_ref', {'line': line, 'message': message, 'severity': severity})
        except LLMClientError as exc:
            fallback.execution_status = 'degraded'
            fallback.status_reason = str(exc)
            fallback.summary = f'{fallback.summary} 当前返回为降级结果：{exc}'
            yield ('status', {'execution_status': 'degraded', 'status_reason': str(exc)})
            yield ('done', fallback)
            return

        payload = self.client.parse_json_content(''.join(chunks))
        yield ('status', {'execution_status': 'completed', 'status_reason': ''})
        yield (
            'done',
            self._build_response(
                analysis_type=analysis_type,
                settings=settings,
                model=model,
                payload=payload,
                fallback=fallback,
                verdict=verdict,
            ),
        )

    def _build_response(
        self,
        *,
        analysis_type: str,
        settings: LLMSettings,
        model: str,
        payload: object,
        fallback: AnalysisResponse,
        verdict: str | None,
    ) -> AnalysisResponse:

        if isinstance(payload, list):
            payload = self._normalize_list_payload(payload, fallback)
        elif not isinstance(payload, dict):
            payload = {
                'title': fallback.title,
                'summary': str(payload),
                'bullets': fallback.bullets,
                'line_refs': [],
            }

        payload = self._normalize_object_payload(payload, fallback)

        line_refs = [
            AnalysisLineRef(
                line=max(1, int(item.get('line', 1))),
                message=str(item.get('message', '请检查这一行附近的逻辑。')),
                severity='error' if str(item.get('severity', 'warning')) == 'error' else 'warning',
            )
            for item in payload.get('line_refs', [])
            if isinstance(item, dict)
        ]
        bullets = [str(item) for item in payload.get('bullets', []) if str(item).strip()]

        return AnalysisResponse(
            analysis_type=analysis_type,
            provider=settings.provider,
            model=model,
            endpoint_url=settings.endpoint_url,
            execution_status='completed',
            status_reason='',
            primary_category=str(payload.get('primary_category') or fallback.primary_category),
            secondary_category=str(payload.get('secondary_category') or fallback.secondary_category),
            title=str(payload.get('title') or fallback.title),
            summary=str(payload.get('summary') or fallback.summary),
            bullets=bullets or fallback.bullets,
            line_refs=line_refs or fallback.line_refs,
            verdict=verdict,
        )

    def _normalize_list_payload(self, payload: list, fallback: AnalysisResponse) -> dict:
        dict_items = [item for item in payload if isinstance(item, dict)]
        if len(dict_items) == 1:
            return self._normalize_object_payload(dict_items[0], fallback)

        bullet_items = [str(item) for item in payload if str(item).strip()]
        return {
            'title': fallback.title,
            'summary': fallback.summary,
            'bullets': bullet_items,
            'line_refs': [],
        }

    def _normalize_object_payload(self, payload: dict, fallback: AnalysisResponse) -> dict:
        normalized = dict(payload)
        bullets = normalized.get('bullets', [])
        if isinstance(bullets, dict):
            bullets = [self._stringify_dict_brief(bullets)]
        elif isinstance(bullets, list):
            flattened: list[str] = []
            for item in bullets:
                if isinstance(item, dict):
                    nested_bullets = item.get('bullets')
                    if isinstance(nested_bullets, list) and nested_bullets:
                        flattened.extend(str(entry) for entry in nested_bullets if str(entry).strip())
                    else:
                        flattened.append(self._stringify_dict_brief(item))
                elif str(item).strip():
                    flattened.append(str(item))
            bullets = flattened
        else:
            bullets = [str(bullets)] if str(bullets).strip() else []

        line_refs = normalized.get('line_refs', [])
        if isinstance(line_refs, dict):
            line_refs = [line_refs]
        elif not isinstance(line_refs, list):
            line_refs = []

        normalized['title'] = str(normalized.get('title') or fallback.title)
        normalized['summary'] = str(normalized.get('summary') or fallback.summary)
        normalized['primary_category'] = str(normalized.get('primary_category') or fallback.primary_category)
        normalized['secondary_category'] = str(normalized.get('secondary_category') or fallback.secondary_category)
        normalized['bullets'] = bullets
        normalized['line_refs'] = line_refs
        return normalized

    def _stringify_dict_brief(self, payload: dict) -> str:
        title = str(payload.get('title', '')).strip()
        summary = str(payload.get('summary', '')).strip()
        if title and summary:
            return f'{title}: {summary}'
        if title:
            return title
        if summary:
            return summary
        return str(payload)

    def _extract_stream_preview(self, stream_text: str) -> dict:
        if not stream_text.strip():
            return {'title': '', 'summary': '', 'bullets': [], 'line_refs': []}

        try:
            payload = self.client.parse_json_content(stream_text)
            return self._normalize_object_payload(payload, self._empty_fallback())
        except Exception:
            return {
                'title': self._extract_string_field(stream_text, 'title'),
                'summary': self._extract_string_field(stream_text, 'summary'),
                'bullets': self._extract_string_array(stream_text, 'bullets'),
                'line_refs': self._extract_line_refs(stream_text),
            }

    def _extract_string_field(self, stream_text: str, field_name: str) -> str:
        pattern = re.compile(rf'"{re.escape(field_name)}"\s*:\s*"((?:\\.|[^"])*)"')
        match = pattern.search(stream_text)
        if not match:
            return ''
        return self._decode_json_string(match.group(1))

    def _extract_string_array(self, stream_text: str, field_name: str) -> list[str]:
        pattern = re.compile(rf'"{re.escape(field_name)}"\s*:\s*\[([\s\S]*?)\]')
        match = pattern.search(stream_text)
        if not match:
            return []
        item_pattern = re.compile(r'"((?:\\.|[^"])*)"')
        return [self._decode_json_string(item.group(1)) for item in item_pattern.finditer(match.group(1)) if item.group(1).strip()]

    def _extract_line_refs(self, stream_text: str) -> list[dict]:
        pattern = re.compile(r'"line_refs"\s*:\s*\[([\s\S]*?)\]')
        match = pattern.search(stream_text)
        if not match:
            return []
        object_pattern = re.compile(
            r'\{[^{}]*?"line"\s*:\s*(\d+)[^{}]*?"message"\s*:\s*"((?:\\.|[^"])*)"[^{}]*?(?:"severity"\s*:\s*"(warning|error)")?[^{}]*?\}'
        )
        return [
            {
                'line': max(1, int(item.group(1))),
                'message': self._decode_json_string(item.group(2)),
                'severity': item.group(3) if item.group(3) == 'error' else 'warning',
            }
            for item in object_pattern.finditer(match.group(1))
        ]

    def _decode_json_string(self, value: str) -> str:
        try:
            return self.client.parse_json_content(f'{{"value":"{value}"}}').get('value', value)
        except Exception:
            return value

    def _empty_fallback(self) -> AnalysisResponse:
        return AnalysisResponse(
            analysis_type='solution',
            provider='',
            model='',
            endpoint_url='',
            execution_status='completed',
            status_reason='',
            primary_category='',
            secondary_category='',
            title='',
            summary='',
            bullets=[],
            line_refs=[],
            verdict=None,
        )

    def _build_solution_prompt(self, problem: ProblemDetail, language: str, code_text: str) -> str:
        return (
            '请分析下面的算法题代码，并返回 JSON。'
            'title 是短标题，summary 是一段总结，bullets 是 3 到 5 条建议，line_refs 是可选的行号提示。\n'
            f'题目标题：{problem.title}\n'
            f'题目标签：{", ".join(problem.tags)}\n'
            f'约束：{problem.constraints_text}\n'
            f'语言：{language}\n'
            f'代码：\n{code_text}\n'
        )

    def _build_attribution_prompt(self, problem: ProblemDetail, submission: SubmissionResult) -> str:
        return (
            '请对下面的判题结果做错误归因，并返回 JSON。'
            'primary_category 是主要错误类型，secondary_category 是次级错误类型，title 是短标题，summary 是一段总结，bullets 是 3 到 5 条建议，line_refs 是可选的行号提示。\n'
            f'题目标题：{problem.title}\n'
            f'题目标签：{", ".join(problem.tags)}\n'
            f'Verdict：{submission.verdict}\n'
            f'运行时错误：{submission.stderr_output}\n'
            f'编译输出：{submission.compiler_output}\n'
            f'失败输入：{submission.failed_input}\n'
            f'预期输出：{submission.failed_expected_output}\n'
            f'实际输出：{submission.failed_actual_output}\n'
            f'代码：\n{submission.code_text}\n'
        )

    def _build_review_prompt(self, problem: ProblemDetail, submission: SubmissionResult) -> str:
        return (
            '请基于下面的做题记录生成复盘建议，并返回 JSON。'
            'title 是短标题，summary 是一段总结，bullets 是 3 到 5 条复盘建议，line_refs 可以为空。\n'
            f'题目标题：{problem.title}\n'
            f'题目标签：{", ".join(problem.tags)}\n'
            f'Verdict：{submission.verdict}\n'
            f'运行时间：{submission.runtime_ms} ms\n'
            f'内存：{submission.memory_kb} KB\n'
            f'失败输入：{submission.failed_input}\n'
            f'预期输出：{submission.failed_expected_output}\n'
            f'实际输出：{submission.failed_actual_output}\n'
            f'代码：\n{submission.code_text}\n'
            '请重点输出下次训练建议、薄弱点和继续训练动作。\n'
        )

    def _build_hint_prompt(self, problem: ProblemDetail, language: str, code_text: str, hint_step: int, hint_strength: str, submission: SubmissionResult | None) -> str:
        step_names = {
            1: '读题澄清',
            2: '关键观察',
            3: '算法方向',
            4: '边界条件',
            5: '伪代码骨架',
            6: '代码风险点',
        }
        verdict_text = submission.verdict if submission is not None else '尚未判题'
        failed_context = ''
        if submission is not None:
            failed_context = (
                f'失败输入：{submission.failed_input}\n'
                f'预期输出：{submission.failed_expected_output}\n'
                f'实际输出：{submission.failed_actual_output}\n'
                f'错误输出：{submission.stderr_output or submission.compiler_output}\n'
            )

        return (
            '请为 ACM 编程训练生成渐进式提示，并返回 JSON。'
            'title 是本步提示标题，summary 是克制提示，bullets 是 2 到 4 条可执行提示，line_refs 可指出当前代码风险。'
            '避免直接给完整代码；strong 强度可以给伪代码片段或关键状态定义。\n'
            f'提示步骤：第 {hint_step} 步 - {step_names.get(hint_step, "提示")}\n'
            f'提示强度：{hint_strength}\n'
            f'题目标题：{problem.title}\n'
            f'题目标签：{", ".join(problem.tags)}\n'
            f'题面：{problem.statement_markdown}\n'
            f'约束：{problem.constraints_text}\n'
            f'语言：{language}\n'
            f'Verdict：{verdict_text}\n'
            f'{failed_context}'
            f'当前代码：\n{code_text}\n'
        )

    def _build_problem_analysis_prompt(self, problem: ProblemDetail) -> str:
        examples = '\n'.join(f'输入：{item.input}\n输出：{item.output}\n解释：{item.explanation}' for item in problem.examples)
        return (
            '请分析这道算法题本身的解题思路，并返回 JSON。'
            'title 是短标题，summary 是总体思路，bullets 覆盖题意拆解、关键观察、算法选择、复杂度和易错点，line_refs 返回空数组。'
            '聚焦解题思想和证明，不聚焦用户代码实现。\n'
            f'题目标题：{problem.title}\n'
            f'题目标签：{", ".join(problem.tags)}\n'
            f'题面：{problem.statement_markdown}\n'
            f'约束：{problem.constraints_text}\n'
            f'样例：\n{examples}\n'
        )

    def _build_problem_chat_prompt(self, problem: ProblemDetail, messages: list[ProblemChatMessage], question: str) -> str:
        history = '\n'.join(f'{item.role}: {item.content}' for item in messages[-8:])
        return (
            '请作为算法题解题助教回答用户追问，并返回 JSON。'
            'title 是回答主题，summary 是直接回答，bullets 是推理步骤或补充说明，line_refs 返回空数组。'
            '聚焦题目思路、复杂度证明、反例、边界条件和同类题迁移。\n'
            f'题目标题：{problem.title}\n'
            f'题目标签：{", ".join(problem.tags)}\n'
            f'题面：{problem.statement_markdown}\n'
            f'约束：{problem.constraints_text}\n'
            f'对话历史：\n{history}\n'
            f'用户问题：{question}\n'
        )

    def _fallback_solution(self, settings: LLMSettings, problem: ProblemDetail, language: str, code_text: str) -> AnalysisResponse:
        code_lower = code_text.lower()
        bullets = [
            f'题目核心标签：{", ".join(problem.tags)}。',
            f'当前使用语言：{language}，建议先围绕样例与隐藏边界统一输入输出格式。',
            '系统已读取当前模型配置，并在真实模型不可用时返回结构化降级分析。',
        ]
        line_refs: list[AnalysisLineRef] = []
        if 'prefix' in code_lower or 'suffix' in code_lower:
            bullets.insert(1, '代码已经出现前后缀思路信号，适合继续压缩到单次线性扫描。')
        else:
            bullets.insert(1, '当前代码还缺少明确策略信号，建议先写出状态定义或关键不变量。')
            line_refs.append(AnalysisLineRef(line=1, message='先在入口附近补出核心状态定义，再继续展开实现。', severity='warning'))

        return AnalysisResponse(
            analysis_type='solution',
            provider=settings.provider,
            model=settings.solution_model,
            endpoint_url=settings.endpoint_url,
            execution_status='completed',
            status_reason='',
            primary_category='',
            secondary_category='',
            title='解题分析',
            summary='系统已准备好按当前 LLM 配置执行解题分析。',
            bullets=bullets,
            line_refs=line_refs,
            verdict=None,
        )

    def _fallback_attribution(self, settings: LLMSettings, problem: ProblemDetail, submission: SubmissionResult) -> AnalysisResponse:
        bullets: list[str] = [f'题目：{problem.title}。', f'Verdict：{submission.verdict}。']
        line_refs: list[AnalysisLineRef] = []
        primary_category = '执行异常'
        secondary_category = '运行时错误'
        if submission.verdict == 'RE':
            bullets.extend([
                f'运行时上下文：{submission.stderr_output or "检测到运行时异常。"}',
                '优先检查输入解析、空值访问、数组越界和循环终止条件。',
                '建议先定位最近一次异常行，再缩小到单个失败测试点复现。',
            ])
            line_refs.append(AnalysisLineRef(line=7, message=submission.stderr_output or '优先检查这一段附近的运行时访问路径。', severity='error'))
        elif submission.verdict == 'WA':
            primary_category = '答案错误'
            secondary_category = '边界条件或状态转移偏差'
            bullets.extend([
                '程序已经产出结果，主要偏差集中在输出与预期不一致。',
                '建议优先打开 diff 面板，对照 failed case 检查边界条件和最终输出格式。',
                '如果样例通过但隐藏点失败，优先检查极值、空输入和初始化状态。',
            ])
            line_refs.append(AnalysisLineRef(line=5, message='这一段通常承接状态转移或最终输出，适合优先排查。', severity='warning'))
        elif submission.verdict == 'CE':
            primary_category = '编译错误'
            secondary_category = '语法或入口配置问题'
            bullets.extend([
                f'编译信息：{submission.compiler_output or "检测到编译错误。"}',
                '优先修复语法、模板入口或语言特定 API 调用。',
            ])
            line_refs.append(AnalysisLineRef(line=1, message=submission.compiler_output or '先修复编译入口和语法错误。', severity='error'))
        elif submission.verdict == 'AC':
            primary_category = '已通过'
            secondary_category = '复盘建议'
            bullets.extend(['当前提交已经通过。', '下一步适合复盘复杂度、模板复用点和同类题迁移策略。'])
        else:
            primary_category = '性能或执行状态问题'
            secondary_category = '复杂度或执行超时'
            bullets.extend(['当前问题集中在执行时限或未完成状态。', '建议先缩小循环范围、检查复杂度和状态更新次数。'])

        return AnalysisResponse(
            analysis_type='attribution',
            provider=settings.provider,
            model=settings.attribution_model,
            endpoint_url=settings.endpoint_url,
            execution_status='completed',
            status_reason='',
            primary_category=primary_category,
            secondary_category=secondary_category,
            title='错误归因',
            summary='系统已准备好按当前 LLM 配置执行错误归因。',
            bullets=bullets,
            line_refs=line_refs,
            verdict=submission.verdict,
        )

    def _fallback_review(self, settings: LLMSettings, problem: ProblemDetail, submission: SubmissionResult) -> AnalysisResponse:
        bullets = [
            f'本次题目：{problem.title}。',
            f'本次 Verdict：{submission.verdict}。',
            '先记录本题使用的思路，再补一题同标签训练，形成相邻迁移。',
        ]

        if submission.verdict == 'AC':
            bullets.extend([
                '当前结果已通过，建议补一次复杂度口述和边界条件清单。',
                '下一轮训练可切到同标签但输入结构不同的题目。',
            ])
        else:
            bullets.extend([
                '优先重做当前失败 case，并把触发错误的输入单独记到复盘清单。',
                '继续训练前先总结这次错误类型，避免重复犯错。',
            ])

        return AnalysisResponse(
            analysis_type='review',
            provider=settings.provider,
            model=settings.review_model,
            endpoint_url=settings.endpoint_url,
            execution_status='completed',
            status_reason='',
            primary_category='',
            secondary_category='',
            title='训练复盘',
            summary='系统已准备好按当前 LLM 配置执行复盘建议生成。',
            bullets=bullets,
            line_refs=[],
            verdict=submission.verdict,
        )

    def _fallback_hint(self, settings: LLMSettings, problem: ProblemDetail, hint_step: int, hint_strength: str, submission: SubmissionResult | None) -> AnalysisResponse:
        step_names = ['读题澄清', '关键观察', '算法方向', '边界条件', '伪代码骨架', '代码风险点']
        step_name = step_names[min(max(hint_step, 1), 6) - 1]
        bullets = [
            f'本步聚焦：{step_name}。',
            f'题目标签线索：{", ".join(problem.tags) or problem.category_slug}。',
            '先用样例手推一遍输入到输出的变化，再写出必须维护的状态。',
        ]
        if hint_strength == 'strong':
            bullets.append('可以把关键状态、转移条件和最终答案位置先写成伪代码，再补语言细节。')
        if submission is not None and submission.verdict != 'AC':
            bullets.append(f'最近 Verdict 是 {submission.verdict}，优先围绕失败样例收缩排查范围。')

        return AnalysisResponse(
            analysis_type='hint',
            provider=settings.provider,
            model=settings.solution_model,
            endpoint_url=settings.endpoint_url,
            execution_status='completed',
            status_reason='',
            primary_category='训练提示',
            secondary_category=step_name,
            title=f'第 {hint_step} 步：{step_name}',
            summary='系统已准备好按当前题目和训练上下文生成渐进式提示。',
            bullets=bullets,
            line_refs=[],
            verdict=submission.verdict if submission is not None else None,
        )

    def _fallback_problem_analysis(self, settings: LLMSettings, problem: ProblemDetail) -> AnalysisResponse:
        return AnalysisResponse(
            analysis_type='problem_analysis',
            provider=settings.provider,
            model=settings.solution_model,
            endpoint_url=settings.endpoint_url,
            execution_status='completed',
            status_reason='',
            primary_category='题目解析',
            secondary_category=problem.category_slug,
            title='解题思路分析',
            summary='先从输入规模和输出目标反推可用算法，再用样例验证关键状态或不变量。',
            bullets=[
                f'题型线索：{problem.category_slug or "基础算法"}。',
                f'标签线索：{", ".join(problem.tags) or "暂无标签"}。',
                '用约束判断复杂度上限，再选择可证明正确性的状态、贪心准则或数据结构。',
                '实现前列出最小规模、重复值、极值和输出格式四类边界。',
            ],
            line_refs=[],
            verdict=None,
        )

    def _fallback_problem_chat(self, settings: LLMSettings, problem: ProblemDetail, question: str) -> AnalysisResponse:
        return AnalysisResponse(
            analysis_type='problem_qa',
            provider=settings.provider,
            model=settings.solution_model,
            endpoint_url=settings.endpoint_url,
            execution_status='completed',
            status_reason='',
            primary_category='题目问答',
            secondary_category=problem.category_slug,
            title='解题思路问答',
            summary=f'围绕"{question}"先回到题目目标、输入规模和样例变化来判断。',
            bullets=[
                '把问题拆成状态含义、状态转移、初始化和答案位置四部分。',
                '如果在贪心和动态规划之间摇摆，优先寻找局部选择是否影响后续全局最优。',
                '复杂度证明需要和约束规模对应，避免只描述直觉。',
            ],
            line_refs=[],
            verdict=None,
        )

    def parse_problem_text(self, settings: LLMSettings, api_key: str, raw_text: str) -> ParsedProblemResult:
        result = self._parse_rule_based(raw_text)
        if result and self._needs_formula_enrichment(raw_text):
            result = self._enrich_formulas(result)
        if result:
            return result
        prompt = self._build_parse_prompt(raw_text)
        try:
            payload = self.client.generate_json(settings, api_key, settings.solution_model, settings.solution_temperature, prompt)
        except LLMClientError:
            return self._fallback_parse(settings, raw_text)
        return self._build_parse_result(settings, payload)

    def _needs_formula_enrichment(self, text: str) -> bool:
        import re
        patterns = [
            r'[Σ∏∫√∞≤≥≠≈]',
            r'概率', r'期望', r'方差', r'组合数', r'排列', r'阶乘',
            r'[CPE]\s*[(\[]', 
            r'\^\{', r'_\{(?!\d+\})',
            r'\\frac', r'\\sum', r'\\binom',
            r'\d+/\d+', r'\([^)]*\)\s*\^\s*[a-z]',
        ]
        return any(re.search(p, text) for p in patterns)

    def _enrich_formulas(self, result: ParsedProblemResult) -> ParsedProblemResult:
        import re

        md = result.statement_markdown

        def _latex_inline(text: str) -> str:
            return f'${text}$'

        def _protect_code_blocks(text: str) -> tuple[str, list[str]]:
            blocks: list[str] = []
            def _save(m: re.Match) -> str:
                blocks.append(m.group(0))
                return f'<<<CODEBLOCK{len(blocks) - 1}>>>'
            protected = re.sub(r'```[\s\S]*?```|`[^`\n]+`', _save, text)
            return protected, blocks

        def _restore(text: str, blocks: list[str]) -> str:
            for i, blk in enumerate(blocks):
                text = text.replace(f'<<<CODEBLOCK{i}>>>', blk)
            return text

        def _restore_math_spans(text: str, spans: list[str]) -> str:
            for i, span in enumerate(spans):
                text = text.replace(f'<<<MATHSPAN{i}>>>', span)
            return text

        def _protect_math_spans(text: str) -> tuple[str, list[str]]:
            spans: list[str] = []
            def _save(m: re.Match) -> str:
                spans.append(m.group(0))
                return f'<<<MATHSPAN{len(spans) - 1}>>>'
            protected_text = re.sub(r'\$\$[\s\S]*?\$\$|\$[^$\n]+?\$|`[^`\n]+`', _save, text)
            return protected_text, spans

        def _apply_outside_math(text: str, pattern: str, repl) -> str:
            protected_text, spans = _protect_math_spans(text)
            protected_text = re.sub(pattern, repl, protected_text)
            return _restore_math_spans(protected_text, spans)

        protected, code_blocks = _protect_code_blocks(md)

        # 输入字段列表用代码片段保护，避免 avg_write_ms 这类字段被 Markdown 当成强调或下标
        protected = _apply_outside_math(
            protected,
            r'\b[a-zA-Z_][a-zA-Z0-9_]*(?:,[a-zA-Z_][a-zA-Z0-9_]*){2,}\b',
            lambda m: f'`{m.group(0)}`',
        )

        # 1. sigmoid 常见概率公式 P(y=1)=1/(1+e^{-z})
        protected = _apply_outside_math(
            protected,
            r'P\s*\(\s*([^)]+?)\s*\)\s*=\s*1\s*/\s*\(\s*1\s*\+\s*e\^\{?(-?[a-zA-Z0-9_]+)\}?\s*\)',
            lambda m: _latex_inline(r'P(' + m.group(1).strip() + r') = \frac{1}{1+e^{' + m.group(2).strip() + '}}'),
        )

        # 2. 线性模型 z = w0 + sum wi xi
        protected = _apply_outside_math(
            protected,
            r'z\s*=\s*w0\s*\+\s*Σ\s*i\s*=\s*1\s*5\s*w\s*i\s*x\s*i',
            lambda m: _latex_inline(r'z = w_0 + \sum_{i=1}^{5} w_i x_i'),
        )

        # 3. 组合数 C(n,k) / C(n, k) → $\binom{n}{k}$
        protected = _apply_outside_math(
            protected,
            r'\bC\s*\(\s*([a-zA-Z0-9_]+)\s*,\s*([a-zA-Z0-9_]+)\s*\)',
            lambda m: _latex_inline(r'\binom{' + m.group(1) + '}{' + m.group(2) + '}'),
        )

        # 4. P(X=k) → $P(X=k)$
        protected = _apply_outside_math(
            protected,
            r'\bP\s*\(\s*([^)]+?)\s*\)',
            lambda m: _latex_inline('P(' + m.group(1).strip() + ')'),
        )

        # 5. E[X] → $E[X]$
        protected = _apply_outside_math(
            protected,
            r'\bE\s*\[([^\]]+)\]',
            lambda m: _latex_inline('E[' + m.group(1).strip() + ']'),
        )

        # 4. 分数 a/b → $\frac{a}{b}$ (a,b为简单表达式，仅ASCII)
        _W = r'[a-zA-Z0-9_]+'
        _WX = r'[a-zA-Z0-9_]+(?:[-+][a-zA-Z0-9_]+)*'
        _LB = r'(?<![$\w\\])'
        _LA = r'(?![$\w}])'
        protected = _apply_outside_math(
            protected,
            _LB + '(' + _WX + r')\s*/\s*(' + _WX + ')' + _LA,
            lambda m: _latex_inline(r'\frac{' + m.group(1) + '}{' + m.group(2) + '}'),
        )
        protected = _apply_outside_math(
            protected,
            _LB + '(' + _WX + r')\s*/\s*\(([^()]+)\)' + _LA,
            lambda m: _latex_inline(r'\frac{' + m.group(1) + '}{' + m.group(2).strip() + '}'),
        )
        protected = _apply_outside_math(
            protected,
            _LB + r'\(([^()]+)\)\s*/\s*\(([^()]+)\)' + _LA,
            lambda m: _latex_inline(r'\frac{' + m.group(1).strip() + '}{' + m.group(2).strip() + '}'),
        )
        protected = _apply_outside_math(
            protected,
            _LB + r'\(([^()]+)\)\s*/\s*(' + _WX + ')' + _LA,
            lambda m: _latex_inline(r'\frac{' + m.group(1).strip() + '}{' + m.group(2) + '}'),
        )

        # 5. x^{k} / e^{-z} → $x^{k}$ / $e^{-z}$
        _LB2 = r'(?<![$\w])'
        protected = _apply_outside_math(
            protected,
            _LB2 + '(' + _W + r')\^\{([-\w]+)\}' + _LA,
            lambda m: _latex_inline(m.group(1) + '^{' + m.group(2) + '}'),
        )

        # 6. x^2 → $x^2$ (单数字指数)
        protected = _apply_outside_math(protected, _LB + '(' + _W + r')\^(\d)' + _LA, lambda m: _latex_inline(m.group(1) + '^{' + m.group(2) + '}'))

        # 7. x_i → $x_i$
        protected = _apply_outside_math(protected, _LB2 + '(' + _W + r')_(' + _W + ')' + _LA, lambda m: _latex_inline(m.group(1) + '_' + m.group(2)))

        # 8. Σ → $\sum$
        protected = _apply_outside_math(protected, r'Σ', lambda m: _latex_inline(r'\sum'))

        # 9. ∏ → $\prod$
        protected = _apply_outside_math(protected, r'∏', lambda m: _latex_inline(r'\prod'))

        # 10. √x → $\sqrt{x}$
        protected = _apply_outside_math(protected, r'√([a-zA-Z0-9_]+)', lambda m: _latex_inline(r'\sqrt{' + m.group(1) + '}'))

        # 11. ≤ ≥ ≠ ≈ ∞
        protected = _apply_outside_math(protected, r'≤', lambda m: _latex_inline(r'\leq'))
        protected = _apply_outside_math(protected, r'≥', lambda m: _latex_inline(r'\geq'))
        protected = _apply_outside_math(protected, r'≠', lambda m: _latex_inline(r'\neq'))
        protected = _apply_outside_math(protected, r'≈', lambda m: _latex_inline(r'\approx'))
        protected = _apply_outside_math(protected, r'∞', lambda m: _latex_inline(r'\infty'))
        protected = re.sub(r'\$(P\([^)]+\))\$\s*\$\\geq\$\s*([0-9.]+)', r'$\1 \\geq \2$', protected)
        protected = re.sub(r'\$(P\([^)]+\))\$\s*\$\\leq\$\s*([0-9.]+)', r'$\1 \\leq \2$', protected)

        # 12. 数学中文后紧跟的数学表达式 (如: 概率 P(X=k))
        protected = _apply_outside_math(protected, r'(概率|期望|方差)\s*([=＝]\s*[a-zA-Z0-9_\s\+\-\*/\(\)\^\.]+)', lambda m: f'{m.group(1)} {_latex_inline(m.group(2).strip())}')

        result.statement_markdown = _restore(protected, code_blocks)
        return result

    def _parse_rule_based(self, raw_text: str) -> ParsedProblemResult | None:
        import re

        text = raw_text.strip()
        if not text or len(text) < 20:
            return None

        time_ms = 2000
        memory_kb = 262144
        time_match = re.search(r'时间限制[：:]\s*C/?C\+\+\s*(\d+)\s*秒.*?其他语言\s*(\d+)\s*秒', text)
        if time_match:
            time_ms = max(int(time_match.group(1)), int(time_match.group(2))) * 1000
        mem_match = re.search(r'空间限制[：:]\s*C/?C\+\+\s*(\d+)\s*(M|MB|K|KB).*?其他语言\s*(\d+)\s*(M|MB|K|KB)', text)
        if mem_match:
            val1, unit1, val2, unit2 = int(mem_match.group(1)), mem_match.group(2), int(mem_match.group(3)), mem_match.group(4)
            kb1 = val1 * 1024 if unit1 in ('M', 'MB') else val1
            kb2 = val2 * 1024 if unit2 in ('M', 'MB') else val2
            memory_kb = max(kb1, kb2)

        clean = text
        limits_block = re.search(r'.*?时间限制.+\n空间限制.+\n', clean)
        if limits_block:
            clean = clean.replace(limits_block.group(0), '')

        section_keywords = [
            (r'\n输入描述[：:]', '## 输入格式'),
            (r'\n输入格式[：:]', '## 输入格式'),
            (r'\n输出描述[：:]', '## 输出格式'),
            (r'\n输出格式[：:]', '## 输出格式'),
            (r'\n补充说明[：:]', '## 补充说明'),
            (r'\n备注[：:]', '## 补充说明'),
        ]
        for pattern, replacement in section_keywords:
            clean = re.sub(pattern, '\n\n' + replacement + '\n\n', clean)

        clean = re.sub(r'\n示例\s*(\d+)\s*\n', r'\n\n### 样例 \1\n\n', clean)
        clean = re.sub(r'\n样例\s*(\d+)\s*\n', r'\n\n### 样例 \1\n\n', clean)

        clean = re.sub(r'\n输入例子[：:]', '\n\n**输入：**\n```\n', clean)
        clean = re.sub(r'\n输出例子[：:]', '\n```\n\n**输出：**\n```\n', clean)
        clean = re.sub(r'\n例子说明[：:]', '\n```\n\n**说明：**\n', clean)
        clean = re.sub(r'\n{3,}', '\n\n', clean)
        clean = '\n' + clean

        lines = [l.rstrip() for l in clean.split('\n')]
        stripped_lines = [l.strip() for l in lines if l.strip()]
        first_line = stripped_lines[0].lstrip('#').strip() if stripped_lines else ''
        title = first_line if first_line and not first_line.startswith(('##', '输入', '输出', '示例', '样例', '**')) else '未命名题目'

        desc_start = 0
        for i, line in enumerate(lines):
            stripped = line.strip()
            if stripped and stripped.lstrip('#').strip() == title:
                desc_start = i + 1
                break
            if stripped.startswith('## 题目描述') or stripped.startswith('## 输入') or stripped.startswith('**输入：**'):
                desc_start = i
                break

        desc_end = len(lines)
        for i in range(desc_start, len(lines)):
            stripped = lines[i].strip()
            if stripped.startswith('## ') or stripped.startswith('**输入：**') or stripped.startswith('### 样例'):
                desc_end = i
                break

        description_lines = lines[desc_start:desc_end]
        description = '\n'.join(description_lines).strip()
        rest_lines = lines[desc_end:]
        rest = '\n'.join(rest_lines).strip()

        has_markdown_headings = any(l.strip().startswith('## ') for l in rest_lines)
        if has_markdown_headings:
            markdown = f'## 题目描述\n\n{description}\n\n{rest}'
        else:
            markdown = f'## 题目描述\n\n{description}' if description else clean.strip()

        examples: list[dict] = []
        example_blocks = re.split(r'\n### 样例 \d+\n\n', '\n' + markdown)
        main_text = example_blocks[0] if example_blocks else markdown

        for block in example_blocks[1:]:
            inp_match = re.search(r'\*\*输入[：:]\*\*\s*\n```\s*\n(.*?)```', block, re.DOTALL)
            out_match = re.search(r'\*\*输出[：:]\*\*\s*\n```\s*\n(.*?)```', block, re.DOTALL)
            expl_match = re.search(r'\*\*说明[：:]\*\*\s*\n(.*?)(?=\n###|\Z)', block, re.DOTALL)
            if inp_match and out_match:
                examples.append({
                    'input': inp_match.group(1).strip(),
                    'output': out_match.group(1).strip(),
                    'explanation': expl_match.group(1).strip() if expl_match else '',
                })

        source_ref = ''
        ref_match = re.search(r'@(\S+)\s*整理上传', text)
        if ref_match:
            source_ref = f'牛友 @{ref_match.group(1)} 整理上传'

        markdown = self._normalize_markdown(main_text.strip())
        if examples:
            examples_section = '\n\n## 样例\n\n'
            for i, ex in enumerate(examples, 1):
                explanation = ex['explanation']
                if '\n' in explanation:
                    explanation = '\n\n'.join(line.strip() for line in explanation.split('\n') if line.strip())
                examples_section += f'### 样例 {i}\n\n'
                examples_section += f'**输入：**\n```\n{ex["input"]}\n```\n\n'
                examples_section += f'**输出：**\n```\n{ex["output"]}\n```\n'
                if explanation:
                    examples_section += f'**说明：**\n{explanation}\n\n'
            markdown = markdown.strip() + examples_section

        _CATEGORY_KW: dict[str, list[str]] = {
            'two-pointers': ['双指针', '快慢指针', '对撞指针'],
            'sliding-window': ['滑动窗口', '窗口', '子串'],
            'hashing': ['哈希', '散列', 'hash', '字典', '映射'],
            'binary-search': ['二分查找', '二分答案', '二分'],
            'prefix-sum': ['前缀和', '前缀', '差分'],
            'intervals': ['区间', '合并区间'],
            'matrix-grid': ['矩阵', '网格', '二维数组'],
            'linked-list': ['链表'],
            'stack-queue': ['栈', '队列', '单调队列', '双端队列'],
            'monotonic-stack': ['单调栈'],
            'heap-priority-queue': ['堆', '优先队列', '大根堆', '小根堆', 'topk'],
            'tree': ['树', '二叉树', '层序', '先序', '中序', '后序'],
            'graphs': ['图', '最短路径', '拓扑排序', '并查集', '连通'],
            'backtracking': ['回溯', '全排列', '组合', '子集'],
            'dynamic-programming': ['动态规划', 'dp', '最优子结构', '状态转移', '记搜', '记忆化'],
            'greedy': ['贪心', '贪心算法', '最优策略'],
            'bit-manipulation': ['位运算', '异或', '按位', '二进制'],
            'simulation': ['模拟', '构造', '实现'],
        }
        category = 'simulation'
        max_score = 0
        text_lower = text.lower()
        for slug, keywords in _CATEGORY_KW.items():
            score = sum(1 for kw in keywords if kw in text)
            if score > max_score:
                max_score = score
                category = slug

        return ParsedProblemResult(
            slug=re.sub(r'[^\w-]', '', title.lower().replace(' ', '-'))[:48],
            title=title,
            company='',
            difficulty='Medium',
            category_slug=category,
            statement_markdown=markdown,
            tags=[],
            time_limit_ms=time_ms,
            memory_limit_kb=memory_kb,
            source='牛客',
            source_type='牛客',
            frequency='中',
            year=None,
            source_ref=source_ref,
            external_id='',
            examples=examples,
            analysis='',
        )

    def _build_parse_prompt(self, raw_text: str) -> str:
        return (
            '你是一个算法竞赛题目结构化的专家。请将以下原始题目文本解析为结构化的 JSON 字段。\n\n'
            '要求：\n'
            '1. slug 使用英文小写连字符，从标题翻译。\n'
            '2. title 保留原标题。\n'
            '3. company 从上下文中识别公司名（如华为、字节跳动、腾讯、阿里巴巴等），无法识别则为空字符串。\n'
            '4. difficulty 必须是 Easy / Medium / Hard 之一。\n'
            '5. category_slug 必须从以下列表中选最匹配的：two-pointers, sliding-window, hashing, binary-search, prefix-sum, intervals, matrix-grid, linked-list, stack-queue, monotonic-stack, heap-priority-queue, tree, graphs, backtracking, dynamic-programming, greedy, bit-manipulation, simulation。\n'
            '6. statement_markdown 必须严格按照下面格式逐字生成，段落间保留空行，样例输入输出必须用代码块包裹：\n'
            '\n'
            '## 题目描述\n\n'
            '(题目描述内容，多段落间空一行分隔)\n\n'
            '## 输入格式\n\n'
            '(输入格式说明)\n\n'
            '## 输出格式\n\n'
            '(输出格式说明)\n\n'
            '(如有约束条件或补充说明则加下面的段落)\n\n'
            '## 补充说明\n\n'
            '(补充内容)\n\n'
            '## 样例\n\n'
            '### 样例 1\n\n'
            '**输入：**\n```\n(样例1输入)\n```\n'
            '**输出：**\n```\n(样例1输出)\n```\n'
            '**说明：**\n(样例1解释)\n\n'
            '(多样例继续按同样格式追加 ### 样例 2 ...)\n\n'
            '要点：1) 数学用 $LaTeX$ 语法；2) 列表项独立成段；3) 输入输出必须用 ``` 代码块；4) 段落间必须有空行。\n'
            '7. tags 从原文提取最多 5 个中文标签。\n'
            '8. time_limit_ms 从原文提取时间限制毫秒数，C/C++ 1秒=1000，其他语言2秒=2000，取最大值。\n'
            '9. memory_limit_kb 从原文提取空间限制，如 256M = 262144 KB。\n'
            '10. source 原文来源（如牛客、Leetcode、手工等）。\n'
            '11. source_type 原文来源类型（如 牛客、Leetcode、manual）。\n'
            '12. frequency 根据公司出现频率推断（高/中/低），默认中。\n'
            '13. year 从原文提取年份，无法识别则为 null。\n'
            '14. source_ref 来源引用说明，如"华为2025AI笔试"。\n'
            '15. external_id 外部编号（若有）。\n'
            '16. examples 提取所有样例，每个包含 input/output/explanation 三个字符串字段。\n'
            '17. analysis 简要分析此题考察的算法点和解题思路（1-2 句）。\n\n'
            '返回 JSON 格式，不要包含 markdown 代码块标记。\n\n'
            f'原始文本：\n{raw_text}'
        )

    def _build_parse_result(self, settings: LLMSettings, payload: dict) -> ParsedProblemResult:
        examples = []
        for item in payload.get('examples', []):
            if isinstance(item, dict):
                examples.append({
                    'input': str(item.get('input', '')).strip(),
                    'output': str(item.get('output', '')).strip(),
                    'explanation': str(item.get('explanation', '')).strip(),
                })

        statement = str(payload.get('statement_markdown', '')).strip()
        statement = self._normalize_markdown(statement)

        valid_difficulties = {'Easy', 'Medium', 'Hard'}
        difficulty = str(payload.get('difficulty', 'Medium'))
        if difficulty not in valid_difficulties:
            difficulty = 'Medium'

        valid_categories = {
            'two-pointers', 'sliding-window', 'hashing', 'binary-search',
            'prefix-sum', 'intervals', 'matrix-grid', 'linked-list',
            'stack-queue', 'monotonic-stack', 'heap-priority-queue',
            'tree', 'graphs', 'backtracking', 'dynamic-programming',
            'greedy', 'bit-manipulation', 'simulation',
        }
        category = str(payload.get('category_slug', 'simulation')).strip()
        if category not in valid_categories:
            category = 'simulation'

        tags = payload.get('tags', [])
        if isinstance(tags, list):
            tags = [str(t).strip() for t in tags[:5]]
        else:
            tags = []

        return ParsedProblemResult(
            slug=str(payload.get('slug', '')).strip()[:64],
            title=str(payload.get('title', '')).strip(),
            company=str(payload.get('company', '')).strip(),
            difficulty=difficulty,
            category_slug=category,
            statement_markdown=statement,
            tags=tags,
            time_limit_ms=int(payload.get('time_limit_ms', 2000)),
            memory_limit_kb=int(payload.get('memory_limit_kb', 262144)),
            source=str(payload.get('source', '手工')).strip(),
            source_type=str(payload.get('source_type', 'manual')).strip(),
            frequency=str(payload.get('frequency', '中')).strip(),
            year=int(payload['year']) if payload.get('year') is not None else None,
            source_ref=str(payload.get('source_ref', '')).strip(),
            external_id=str(payload.get('external_id', '')).strip(),
            examples=examples,
            analysis=str(payload.get('analysis', '')).strip(),
        )

    def _normalize_markdown(self, text: str) -> str:
        if not text:
            return text
        result = re.sub(r'\n{3,}', '\n\n', text)
        sections = ['## 题目描述', '## 输入格式', '## 输出格式', '## 补充说明', '## 样例']
        for section in sections:
            result = re.sub(rf'(?<!\n)\n({re.escape(section)})', r'\n\n\1', result)
            result = re.sub(rf'\n({re.escape(section)})', r'\n\n\1', result, re.DOTALL)
        result = re.sub(r'(?<!\n)\n\*\*输入', r'\n\n**输入', result)
        result = re.sub(r'\n\*\*输出', r'\n\n**输出', result)
        result = re.sub(r'\n\*\*说明', r'\n\n**说明', result)
        result = result.strip()
        return result

    def _fallback_parse(self, settings: LLMSettings, raw_text: str) -> ParsedProblemResult:
        lines = [line.strip() for line in raw_text.strip().split('\n') if line.strip()]
        title = lines[0] if lines else '未命名题目'
        return ParsedProblemResult(
            slug='',
            title=title,
            company='',
            difficulty='Medium',
            category_slug='simulation',
            statement_markdown=self._normalize_markdown(f'## 题目描述\n\n{raw_text.strip()}\n\n## 输入格式\n\n(待补充)\n\n## 输出格式\n\n(待补充)\n'),
            tags=[],
            time_limit_ms=2000,
            memory_limit_kb=262144,
            source='手工',
            source_type='manual',
            frequency='中',
            year=None,
            source_ref='',
            external_id='',
            examples=[],
            analysis='AI 解析不可用，已将原始文本作为题面。',
        )
