from __future__ import annotations

import json
import sys
import unittest
from pathlib import Path
from unittest.mock import Mock, MagicMock

SRC_DIR = Path(__file__).resolve().parents[1] / 'src'
if str(SRC_DIR) not in sys.path:
    sys.path.insert(0, str(SRC_DIR))

from schemas.agent_run import AgentRunResult, TokenUsage, ToolCallTrace
from schemas.llm_settings import LLMSettings
from services.agent.agent_loop import AgentLoop


def _make_llm_response(content='', tool_calls=None, finish_reason='stop', usage=None):
    if usage is None:
        usage = {'prompt_tokens': 10, 'completion_tokens': 5, 'total_tokens': 15}
    return {
        'choices': [{
            'message': {
                'content': content,
                'tool_calls': tool_calls or [],
            },
            'finish_reason': finish_reason,
        }],
        'usage': usage,
    }


def _make_tool_call(id='call_1', name='search', arguments=None):
    return {
        'id': id,
        'function': {
            'name': name,
            'arguments': json.dumps(arguments or {}),
        },
    }


def _make_settings():
    return LLMSettings(
        id=1, provider='OpenAI Compatible',
        endpoint_url='https://example.com/v1',
        solution_model='test-model', attribution_model='test-model',
        review_model='test-model',
        solution_temperature=0.2, attribution_temperature=0.1,
        review_temperature=0.3, enabled=True,
        api_key_configured=True, api_key_masked='sk-t...1234',
        updated_at='2026-06-24T00:00:00Z',
    )


class AgentLoopRunTests(unittest.TestCase):
    def setUp(self):
        self.settings = _make_settings()
        self.api_key = 'test-key'
        self.context = {'db_url': 'test-db'}
        self.base_messages = [{'role': 'system', 'content': 'sys'}, {'role': 'user', 'content': 'q'}]

    def _make_loop(self, llm_client=None, tool_registry=None):
        llm = llm_client or Mock()
        tools = tool_registry or Mock()
        tools.get_openai_tools.return_value = None
        tools.execute.return_value = 'ok'
        return AgentLoop(llm, tools), llm, tools

    def test_run_returns_content_on_text_response(self):
        loop, llm, _ = self._make_loop()
        llm.chat_with_tools.return_value = _make_llm_response(content='Hello world')

        result = loop.run(self.base_messages, 5, self.settings, self.api_key, 'model', 0.1, self.context)
        self.assertIsInstance(result, AgentRunResult)
        self.assertEqual(result.content, 'Hello world')
        self.assertEqual(result.tool_calls_trace, [])
        self.assertGreaterEqual(result.duration_ms, 0)

    def test_run_handles_single_tool_call(self):
        tool_registry = Mock()
        tool_registry.get_openai_tools.return_value = [{'type': 'function', 'function': {'name': 'search'}}]
        tool_registry.execute.return_value = '{"found": true}'

        llm = Mock()
        llm.chat_with_tools.side_effect = [
            _make_llm_response(content='Searching', tool_calls=[_make_tool_call(name='search', arguments={'q': 'dp'})], finish_reason='tool_calls'),
            _make_llm_response(content='Found it!'),
        ]

        loop = AgentLoop(llm, tool_registry)
        result = loop.run(self.base_messages, 5, self.settings, self.api_key, 'model', 0.1, self.context)

        self.assertEqual(result.content, 'Found it!')
        self.assertEqual(len(result.tool_calls_trace), 1)
        self.assertEqual(result.tool_calls_trace[0].name, 'search')
        self.assertEqual(result.tool_calls_trace[0].arguments, {'q': 'dp'})
        self.assertEqual(result.tool_calls_trace[0].result, '{"found": true}')

    def test_run_max_iterations_exceeded(self):
        loop, llm, _ = self._make_loop()
        llm.chat_with_tools.return_value = _make_llm_response(
            content='Still thinking',
            tool_calls=[_make_tool_call()],
            finish_reason='tool_calls',
        )

        result = loop.run(self.base_messages, 3, self.settings, self.api_key, 'model', 0.1, self.context)
        self.assertIn('最大推理步数', result.content)
        self.assertEqual(result.iterations, 3)

    def test_run_handles_llm_exception(self):
        loop, llm, _ = self._make_loop()
        llm.chat_with_tools.side_effect = RuntimeError('Service unavailable')

        result = loop.run(self.base_messages, 5, self.settings, self.api_key, 'model', 0.1, self.context)
        self.assertIn('LLM 调用失败', result.content)
        self.assertIn('Service unavailable', result.content)

    def test_run_handles_json_decode_error_in_arguments(self):
        tool_registry = Mock()
        tool_registry.get_openai_tools.return_value = [{'type': 'function', 'function': {'name': 'x'}}]
        tool_registry.execute.return_value = 'ok'

        llm = Mock()
        bad_tc = {'id': 'c1', 'function': {'name': 'x', 'arguments': 'bad{json'}}
        llm.chat_with_tools.side_effect = [
            _make_llm_response(tool_calls=[bad_tc], finish_reason='tool_calls'),
            _make_llm_response(content='Done'),
        ]

        loop = AgentLoop(llm, tool_registry)
        result = loop.run(self.base_messages, 5, self.settings, self.api_key, 'model', 0.1, self.context)
        self.assertEqual(result.content, 'Done')
        self.assertEqual(result.tool_calls_trace[0].arguments, {})

    def test_run_tracks_token_usage(self):
        loop, llm, _ = self._make_loop()
        llm.chat_with_tools.side_effect = [
            _make_llm_response(content='Step 1', usage={'prompt_tokens': 20, 'completion_tokens': 3, 'total_tokens': 23}),
        ]

        result = loop.run(self.base_messages, 5, self.settings, self.api_key, 'model', 0.1, self.context)
        self.assertEqual(result.token_usage.prompt_tokens, 20)
        self.assertEqual(result.token_usage.completion_tokens, 3)
        self.assertEqual(result.token_usage.total_tokens, 23)

    def test_run_accumulates_usage_over_iterations(self):
        tool_registry = Mock()
        tool_registry.get_openai_tools.return_value = [{'type': 'function', 'function': {'name': 'x'}}]
        tool_registry.execute.return_value = 'ok'

        llm = Mock()
        llm.chat_with_tools.side_effect = [
            _make_llm_response(tool_calls=[_make_tool_call()], finish_reason='tool_calls', usage={'prompt_tokens': 10, 'completion_tokens': 2, 'total_tokens': 12}),
            _make_llm_response(content='Done', usage={'prompt_tokens': 5, 'completion_tokens': 3, 'total_tokens': 8}),
        ]

        loop = AgentLoop(llm, tool_registry)
        result = loop.run(self.base_messages, 5, self.settings, self.api_key, 'model', 0.1, self.context)
        self.assertEqual(result.token_usage.prompt_tokens, 15)
        self.assertEqual(result.token_usage.completion_tokens, 5)
        self.assertEqual(result.token_usage.total_tokens, 20)

    def test_run_finish_reason_stop_with_tool_calls(self):
        tool_registry = Mock()
        tool_registry.get_openai_tools.return_value = [{'type': 'function', 'function': {'name': 'x'}}]
        tool_registry.execute.return_value = 'ok'

        llm = Mock()
        llm.chat_with_tools.side_effect = [
            _make_llm_response(tool_calls=[_make_tool_call()], finish_reason='tool_calls'),
            _make_llm_response(content='Final', tool_calls=[_make_tool_call()], finish_reason='stop'),
        ]

        loop = AgentLoop(llm, tool_registry)
        result = loop.run(self.base_messages, 5, self.settings, self.api_key, 'model', 0.1, self.context)
        self.assertEqual(result.content, 'Final')
        self.assertEqual(result.iterations, 2)
        self.assertEqual(len(result.tool_calls_trace), 2)

    def test_run_multiple_tool_calls_in_one_response(self):
        tool_registry = Mock()
        tool_registry.get_openai_tools.return_value = [{'type': 'function', 'function': {'name': 't1'}}, {'type': 'function', 'function': {'name': 't2'}}]
        tool_registry.execute.side_effect = ['result1', 'result2']

        llm = Mock()
        llm.chat_with_tools.side_effect = [
            _make_llm_response(
                content='Calling tools',
                tool_calls=[_make_tool_call(id='c1', name='t1', arguments={'a': 1}), _make_tool_call(id='c2', name='t2', arguments={'b': 2})],
                finish_reason='tool_calls',
            ),
            _make_llm_response(content='All done'),
        ]

        loop = AgentLoop(llm, tool_registry)
        result = loop.run(self.base_messages, 5, self.settings, self.api_key, 'model', 0.1, self.context)
        self.assertEqual(len(result.tool_calls_trace), 2)
        self.assertEqual(result.tool_calls_trace[0].name, 't1')
        self.assertEqual(result.tool_calls_trace[1].name, 't2')


if __name__ == '__main__':
    unittest.main()
