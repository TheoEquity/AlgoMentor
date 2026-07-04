from __future__ import annotations

import json
import sys
import unittest
from pathlib import Path
from unittest.mock import Mock, patch

SRC_DIR = Path(__file__).resolve().parents[1] / 'src'
if str(SRC_DIR) not in sys.path:
    sys.path.insert(0, str(SRC_DIR))

from schemas.tool import ToolConfig
from services.agent.tool_registry import ToolRegistry


def _make_tool(id=1, slug='query_problems', name='query_problems', description='', parameters_schema=None,
               handler_type='python_function', handler_config=None, is_enabled=True) -> ToolConfig:
    if parameters_schema is None:
        parameters_schema = json.dumps({
            'type': 'object',
            'properties': {'keyword': {'type': 'string'}},
        })
    if handler_config is None:
        handler_config = json.dumps({
            'module': 'services.agent.builtin_tools',
            'function': 'query_problems',
        })
    return ToolConfig(
        id=id, slug=slug, name=name, description=description,
        parameters_schema=parameters_schema, handler_type=handler_type,
        handler_config=handler_config, is_enabled=is_enabled,
        created_at='2026-06-24T00:00:00Z',
    )


class ToolRegistryRegistrationTests(unittest.TestCase):
    def test_register_enabled_tool(self):
        registry = ToolRegistry()
        tool = _make_tool(slug='find')
        registry.register(tool)
        self.assertIn('find', registry._tools)

    def test_skip_disabled_tool(self):
        registry = ToolRegistry()
        tool = _make_tool(slug='find', is_enabled=False)
        registry.register(tool)
        self.assertNotIn('find', registry._tools)

    def test_init_with_tools_filter(self):
        t1 = _make_tool(id=1, slug='a', is_enabled=True)
        t2 = _make_tool(id=2, slug='b', is_enabled=False)
        registry = ToolRegistry([t1, t2])
        self.assertIn('a', registry._tools)
        self.assertNotIn('b', registry._tools)

    def test_init_with_none(self):
        registry = ToolRegistry(None)
        self.assertEqual(len(registry._tools), 0)


class ToolRegistryOpenAITests(unittest.TestCase):
    def test_get_openai_tools_format(self):
        schema = json.dumps({
            'type': 'object',
            'properties': {'x': {'type': 'integer'}},
            'required': ['x'],
        })
        tool = _make_tool(slug='calc', description='calculate', parameters_schema=schema)
        registry = ToolRegistry([tool])
        tools = registry.get_openai_tools()
        self.assertEqual(len(tools), 1)
        self.assertEqual(tools[0]['type'], 'function')
        self.assertEqual(tools[0]['function']['name'], 'calc')
        self.assertEqual(tools[0]['function']['description'], 'calculate')
        self.assertEqual(tools[0]['function']['parameters']['properties']['x']['type'], 'integer')

    def test_skip_tool_with_invalid_schema(self):
        tool = _make_tool(slug='bad', parameters_schema='not-json')
        registry = ToolRegistry([tool])
        tools = registry.get_openai_tools()
        self.assertEqual(len(tools), 0)

    def test_empty_registry_returns_empty_list(self):
        registry = ToolRegistry()
        self.assertEqual(registry.get_openai_tools(), [])

    def test_schema_already_dict(self):
        schema = {'type': 'object', 'properties': {}}
        tool = _make_tool(slug='calc', parameters_schema=schema)
        registry = ToolRegistry([tool])
        tools = registry.get_openai_tools()
        self.assertEqual(len(tools), 1)


class ToolRegistryExecutionTests(unittest.TestCase):
    def test_execute_unknown_tool(self):
        registry = ToolRegistry()
        result = registry.execute('ghost', {}, {})
        self.assertIn('不存在', result)

    def test_execute_python_function_success(self):
        def mock_func(args, ctx):
            return json.dumps({'count': 42})
        with patch('importlib.import_module') as mock_import:
            mock_module = Mock()
            mock_module.query_problems = mock_func
            mock_import.return_value = mock_module

            tool = _make_tool(slug='query_problems')
            registry = ToolRegistry([tool])
            result = registry.execute('query_problems', {'keyword': 'dp'}, {'db': 'test'})
            self.assertIn('42', result)
            mock_import.assert_called_once_with('services.agent.builtin_tools')

    def test_execute_python_function_import_error(self):
        with patch('importlib.import_module', side_effect=ImportError('no module')):
            tool = _make_tool(slug='query_problems')
            registry = ToolRegistry([tool])
            result = registry.execute('query_problems', {'keyword': 'dp'}, {})
            self.assertIn('加载失败', result)

    def test_execute_python_function_attribute_error(self):
        with patch('importlib.import_module') as mock_import:
            mock_import.return_value = Mock(spec=[])
            tool = _make_tool(slug='query_problems')
            registry = ToolRegistry([tool])
            result = registry.execute('query_problems', {'keyword': 'dp'}, {})
            self.assertIn('未找到函数', result)

    def test_execute_python_function_invalid_config(self):
        tool = _make_tool(slug='bad', handler_config='not-json')
        registry = ToolRegistry([tool])
        result = registry.execute('bad', {}, {})
        self.assertIn('配置格式错误', result)

    def test_execute_python_function_missing_module(self):
        config = json.dumps({'function': 'foo'})
        tool = _make_tool(slug='bad', handler_config=config)
        registry = ToolRegistry([tool])
        result = registry.execute('bad', {}, {})
        self.assertIn('配置不完整', result)

    def test_execute_python_function_missing_function(self):
        config = json.dumps({'module': 'some.module'})
        tool = _make_tool(slug='bad', handler_config=config)
        registry = ToolRegistry([tool])
        result = registry.execute('bad', {}, {})
        self.assertIn('配置不完整', result)

    def test_execute_python_function_runtime_error(self):
        def failing(args, ctx):
            raise RuntimeError('boom')
        with patch('importlib.import_module') as mock_import:
            mock_module = Mock()
            mock_module.query_problems = failing
            mock_import.return_value = mock_module

            tool = _make_tool(slug='query_problems')
            registry = ToolRegistry([tool])
            result = registry.execute('query_problems', {}, {})
            self.assertIn('工具执行错误', result)
            self.assertIn('boom', result)

    def test_execute_sql_query_placeholder(self):
        tool = _make_tool(slug='db', handler_type='sql_query')
        registry = ToolRegistry([tool])
        result = registry.execute('db', {}, {})
        self.assertIn('开发中', result)

    def test_execute_api_call_placeholder(self):
        tool = _make_tool(slug='api', handler_type='api_call')
        registry = ToolRegistry([tool])
        result = registry.execute('api', {}, {})
        self.assertIn('开发中', result)

    def test_execute_unsupported_handler_type(self):
        tool = _make_tool(slug='bad', handler_type='unknown_type')
        registry = ToolRegistry([tool])
        result = registry.execute('bad', {}, {})
        self.assertIn('不支持', result)


if __name__ == '__main__':
    unittest.main()
