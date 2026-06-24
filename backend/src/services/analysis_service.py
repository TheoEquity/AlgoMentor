from __future__ import annotations

import re
from collections.abc import Iterator

from schemas.analysis import AnalysisLineRef, AnalysisResponse
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
            'title 是短标题，summary 是一段总结，bullets 是 3 到 5 条建议，line_refs 是可选的行号提示。\n'
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
            title='解题分析',
            summary='系统已准备好按当前 LLM 配置执行解题分析。',
            bullets=bullets,
            line_refs=line_refs,
            verdict=None,
        )

    def _fallback_attribution(self, settings: LLMSettings, problem: ProblemDetail, submission: SubmissionResult) -> AnalysisResponse:
        bullets: list[str] = [f'题目：{problem.title}。', f'Verdict：{submission.verdict}。']
        line_refs: list[AnalysisLineRef] = []
        if submission.verdict == 'RE':
            bullets.extend([
                f'运行时上下文：{submission.stderr_output or "检测到运行时异常。"}',
                '优先检查输入解析、空值访问、数组越界和循环终止条件。',
                '建议先定位最近一次异常行，再缩小到单个失败测试点复现。',
            ])
            line_refs.append(AnalysisLineRef(line=7, message=submission.stderr_output or '优先检查这一段附近的运行时访问路径。', severity='error'))
        elif submission.verdict == 'WA':
            bullets.extend([
                '程序已经产出结果，主要偏差集中在输出与预期不一致。',
                '建议优先打开 diff 面板，对照 failed case 检查边界条件和最终输出格式。',
                '如果样例通过但隐藏点失败，优先检查极值、空输入和初始化状态。',
            ])
            line_refs.append(AnalysisLineRef(line=5, message='这一段通常承接状态转移或最终输出，适合优先排查。', severity='warning'))
        elif submission.verdict == 'CE':
            bullets.extend([
                f'编译信息：{submission.compiler_output or "检测到编译错误。"}',
                '优先修复语法、模板入口或语言特定 API 调用。',
            ])
            line_refs.append(AnalysisLineRef(line=1, message=submission.compiler_output or '先修复编译入口和语法错误。', severity='error'))
        elif submission.verdict == 'AC':
            bullets.extend(['当前提交已经通过。', '下一步适合复盘复杂度、模板复用点和同类题迁移策略。'])
        else:
            bullets.extend(['当前问题集中在执行时限或未完成状态。', '建议先缩小循环范围、检查复杂度和状态更新次数。'])

        return AnalysisResponse(
            analysis_type='attribution',
            provider=settings.provider,
            model=settings.attribution_model,
            endpoint_url=settings.endpoint_url,
            execution_status='completed',
            status_reason='',
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
            title='训练复盘',
            summary='系统已准备好按当前 LLM 配置执行复盘建议生成。',
            bullets=bullets,
            line_refs=[],
            verdict=submission.verdict,
        )
