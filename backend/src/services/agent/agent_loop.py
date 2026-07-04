from __future__ import annotations

import json
import time
from collections.abc import Iterator, Callable

from schemas.agent_run import AgentRunResult, ToolCallTrace, TokenUsage
from schemas.llm_settings import LLMSettings


class AgentLoop:
    def __init__(self, llm_client, tool_registry) -> None:
        self._llm = llm_client
        self._tools = tool_registry

    def run(
        self,
        messages: list[dict],
        max_iterations: int,
        settings: LLMSettings,
        api_key: str,
        model: str,
        temperature: float,
        context: dict,
    ) -> AgentRunResult:
        start = time.monotonic()
        trace: list[ToolCallTrace] = []
        total_usage = TokenUsage()
        iteration = 0

        tool_schemas = self._tools.get_openai_tools() if self._tools else None

        while iteration < max_iterations:
            iteration += 1

            try:
                response = self._llm.chat_with_tools(
                    settings=settings,
                    api_key=api_key,
                    model=model,
                    messages=messages,
                    temperature=temperature,
                    tools=tool_schemas,
                )
            except Exception as exc:
                return AgentRunResult(
                    content=f'LLM 调用失败: {exc}',
                    tool_calls_trace=trace,
                    token_usage=total_usage,
                    iterations=iteration,
                    duration_ms=int((time.monotonic() - start) * 1000),
                )

            choices = response.get('choices') or [{}]
            choice = choices[0] if choices else {}
            message = choice.get('message', {})
            finish_reason = choice.get('finish_reason', '')

            total_usage.prompt_tokens += response.get('usage', {}).get('prompt_tokens', 0)
            total_usage.completion_tokens += response.get('usage', {}).get('completion_tokens', 0)
            total_usage.total_tokens += response.get('usage', {}).get('total_tokens', 0)

            tool_calls = message.get('tool_calls', [])
            if tool_calls:
                messages.append({
                    'role': 'assistant',
                    'content': message.get('content') or '',
                    'tool_calls': tool_calls,
                })

                for tc in tool_calls:
                    func = tc.get('function', {})
                    name = func.get('name', '')
                    try:
                        args = json.loads(func.get('arguments', '{}'))
                    except json.JSONDecodeError:
                        args = {}

                    t_start = time.monotonic()
                    result = self._tools.execute(name, args, context)
                    t_ms = int((time.monotonic() - t_start) * 1000)

                    trace.append(ToolCallTrace(
                        name=name,
                        arguments=args,
                        result=result,
                        duration_ms=t_ms,
                    ))

                    messages.append({
                        'role': 'tool',
                        'tool_call_id': tc.get('id', ''),
                        'content': result,
                    })
            else:
                content = message.get('content', '')
                return AgentRunResult(
                    content=content,
                    tool_calls_trace=trace,
                    token_usage=total_usage,
                    iterations=iteration,
                    duration_ms=int((time.monotonic() - start) * 1000),
                )

            if finish_reason == 'stop':
                content = message.get('content', '')
                return AgentRunResult(
                    content=content,
                    tool_calls_trace=trace,
                    token_usage=total_usage,
                    iterations=iteration,
                    duration_ms=int((time.monotonic() - start) * 1000),
                )

        return AgentRunResult(
            content='已达到最大推理步数限制，请重新提问或简化问题。',
            tool_calls_trace=trace,
            token_usage=total_usage,
            iterations=iteration,
            duration_ms=int((time.monotonic() - start) * 1000),
        )

    def run_stream(
        self,
        messages: list[dict],
        max_iterations: int,
        settings: LLMSettings,
        api_key: str,
        model: str,
        temperature: float,
        context: dict,
    ) -> Iterator[dict]:
        start = time.monotonic()
        tool_schemas = self._tools.get_openai_tools() if self._tools else None
        iteration = 0

        while iteration < max_iterations:
            iteration += 1

            chunks = []
            try:
                for chunk in self._llm.stream_chat(
                    settings=settings,
                    api_key=api_key,
                    model=model,
                    messages=messages,
                    temperature=temperature,
                ):
                    chunks.append(chunk)
                    yield {'type': 'chunk', 'data': chunk}
            except Exception as exc:
                yield {'type': 'error', 'data': str(exc)}
                return

            # Parse accumulated content for tool calls
            full_text = ''.join(chunks)
            # In streaming mode, we don't support tool calls yet
            # Just yield the final content
            yield {'type': 'content', 'data': full_text}
            yield {'type': 'done', 'data': {
                'duration_ms': int((time.monotonic() - start) * 1000),
                'iterations': iteration,
            }}
            return

        yield {'type': 'done', 'data': {
            'duration_ms': int((time.monotonic() - start) * 1000),
            'iterations': iteration,
        }}
