from __future__ import annotations

import json
import sys
import unittest
from pathlib import Path

SRC_DIR = Path(__file__).resolve().parents[1] / 'src'
if str(SRC_DIR) not in sys.path:
    sys.path.insert(0, str(SRC_DIR))

from schemas.agent import AgentConfig
from schemas.chat import ChatMessage
from services.agent.prompt_builder import PromptBuilder


def _make_agent(**overrides) -> AgentConfig:
    defaults = {
        'id': 1, 'slug': 'test-agent', 'name': 'Test', 'description': '',
        'icon': 'bot', 'system_prompt': 'You are a helpful assistant.',
        'user_prompt_template': 'Context: {{ context_info }}',
        'model': 'gpt-4', 'temperature': 0.0, 'max_tokens': 2048,
        'max_iterations': 5, 'is_enabled': True, 'sort_order': 0,
        'created_at': '2026-06-24T00:00:00Z', 'updated_at': '2026-06-24T00:00:00Z',
        'tools': [], 'skills': [],
    }
    defaults.update(overrides)
    return AgentConfig(**defaults)


class MockSkill:
    def __init__(self, name, prompt_text, is_enabled=True):
        self.name = name
        self.prompt_text = prompt_text
        self.is_enabled = is_enabled


class PromptBuilderSystemTests(unittest.TestCase):
    def setUp(self):
        self.builder = PromptBuilder()

    def test_system_prompt_included(self):
        agent = _make_agent(system_prompt='Hello system')
        msgs = self.builder.build_messages(agent, {})
        self.assertEqual(msgs[0]['role'], 'system')
        self.assertEqual(msgs[0]['content'], 'Hello system')

    def test_skills_appended_to_system(self):
        agent = _make_agent(system_prompt='Base.', skills=[
            MockSkill('s1', 'Skill one text'),
            MockSkill('s2', 'Skill two text'),
        ])
        msgs = self.builder.build_messages(agent, {})
        content = msgs[0]['content']
        self.assertIn('[技能: s1]', content)
        self.assertIn('Skill one text', content)
        self.assertIn('[技能: s2]', content)
        self.assertIn('Skill two text', content)

    def test_disabled_skill_excluded(self):
        agent = _make_agent(system_prompt='Base.', skills=[
            MockSkill('s1', 'Text 1', is_enabled=False),
            MockSkill('s2', 'Text 2', is_enabled=True),
        ])
        msgs = self.builder.build_messages(agent, {})
        content = msgs[0]['content']
        self.assertNotIn('[技能: s1]', content)
        self.assertIn('[技能: s2]', content)

    def test_history_summary_injected(self):
        agent = _make_agent(system_prompt='Base.')
        msgs = self.builder.build_messages(agent, {}, history_summary='Prior conversation about DP.')
        content = msgs[0]['content']
        self.assertIn('[历史摘要]', content)
        self.assertIn('Prior conversation about DP.', content)

    def test_no_history_summary(self):
        agent = _make_agent(system_prompt='Base.')
        msgs = self.builder.build_messages(agent, {}, history_summary=None)
        content = msgs[0]['content']
        self.assertNotIn('[历史摘要]', content)


class PromptBuilderTemplateTests(unittest.TestCase):
    def setUp(self):
        self.builder = PromptBuilder()

    def test_jinja2_variable_substitution(self):
        agent = _make_agent(user_prompt_template='Solve {{ problem.title }} ({{ problem.difficulty }})')
        context = {'problem': {'title': 'Two Sum', 'difficulty': 'Easy'}}
        msgs = self.builder.build_messages(agent, context)
        user_msg = msgs[1]
        self.assertEqual(user_msg['role'], 'user')
        self.assertIn('Two Sum', user_msg['content'])
        self.assertIn('Easy', user_msg['content'])

    def test_empty_template_returns_empty(self):
        agent = _make_agent(user_prompt_template='')
        msgs = self.builder.build_messages(agent, {})
        self.assertEqual(msgs[1]['content'], '')

    def test_invalid_template_returns_raw(self):
        agent = _make_agent(user_prompt_template='Hello {{ missing_var }}')
        # Jinja2 StrictUndefined would raise, but default Undefined renders empty
        msgs = self.builder.build_messages(agent, {})
        self.assertIn('Hello', msgs[1]['content'])

    def test_complex_nested_context(self):
        agent = _make_agent(user_prompt_template='Title: {{ problem.title }}, Tags: {{ problem.tags | join(", ") }}')
        context = {'problem': {'title': 'DP', 'tags': ['hard', 'dp']}}
        msgs = self.builder.build_messages(agent, context)
        self.assertIn('hard, dp', msgs[1]['content'])


class PromptBuilderHistoryTests(unittest.TestCase):
    def setUp(self):
        self.builder = PromptBuilder()

    def test_history_messages_after_user(self):
        agent = _make_agent()
        history = [
            {'role': 'assistant', 'content': 'Hello!'},
            {'role': 'user', 'content': 'Hi back'},
        ]
        msgs = self.builder.build_messages(agent, {}, history=history)
        roles = [m['role'] for m in msgs]
        self.assertEqual(roles, ['system', 'user', 'assistant', 'user'])
        self.assertEqual(msgs[2]['content'], 'Hello!')
        self.assertEqual(msgs[3]['content'], 'Hi back')

    def test_history_with_tool_calls(self):
        agent = _make_agent()
        history = [
            {
                'role': 'assistant',
                'content': 'Let me search',
                'tool_calls': [{'id': 'call_1', 'function': {'name': 'search', 'arguments': '{}'}}],
            },
            {'role': 'tool', 'tool_call_id': 'call_1', 'content': 'result'},
        ]
        msgs = self.builder.build_messages(agent, {}, history=history)
        # assistant message with tool_calls
        self.assertEqual(msgs[2]['role'], 'assistant')
        self.assertIn('tool_calls', msgs[2])
        # tool message
        self.assertEqual(msgs[3]['role'], 'tool')
        self.assertEqual(msgs[3]['tool_call_id'], 'call_1')
        self.assertEqual(msgs[3]['content'], 'result')

    def test_build_chat_history_from_db_messages(self):
        msgs = [
            ChatMessage(id=1, session_id=1, role='user', content='question',
                        tool_calls=None, tool_results=None, token_usage=None,
                        created_at='2026-06-24T00:00:00Z'),
            ChatMessage(id=2, session_id=1, role='assistant', content='answer',
                        tool_calls=json.dumps([{'id': 'c1', 'function': {'name': 'f', 'arguments': '{}'}}]),
                        tool_results=None, token_usage=None,
                        created_at='2026-06-24T00:00:00Z'),
        ]
        history = self.builder.build_chat_history(msgs)
        self.assertEqual(len(history), 2)
        self.assertEqual(history[0]['content'], 'question')
        self.assertEqual(history[1]['content'], 'answer')
        self.assertEqual(len(history[1]['tool_calls']), 1)

    def test_build_chat_history_invalid_tool_calls(self):
        msgs = [
            ChatMessage(id=1, session_id=1, role='assistant', content='answer',
                        tool_calls='not-json', tool_results=None, token_usage=None,
                        created_at='2026-06-24T00:00:00Z'),
        ]
        history = self.builder.build_chat_history(msgs)
        self.assertEqual(len(history), 1)
        self.assertNotIn('tool_calls', history[0])


if __name__ == '__main__':
    unittest.main()
