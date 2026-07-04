from __future__ import annotations

import importlib
import json
import time

from schemas.tool import ToolConfig


class ToolRegistry:
    def __init__(self, tools: list[ToolConfig] | None = None) -> None:
        self._tools: dict[str, ToolConfig] = {}
        if tools:
            for tool in tools:
                if tool.is_enabled:
                    self._tools[tool.slug] = tool

    def register(self, tool: ToolConfig) -> None:
        if tool.is_enabled:
            self._tools[tool.slug] = tool

    def get_openai_tools(self) -> list[dict]:
        result: list[dict] = []
        for tool in self._tools.values():
            try:
                params = json.loads(tool.parameters_schema) if isinstance(tool.parameters_schema, str) else tool.parameters_schema
                result.append({
                    'type': 'function',
                    'function': {
                        'name': tool.slug,
                        'description': tool.description,
                        'parameters': params,
                    },
                })
            except (json.JSONDecodeError, TypeError):
                pass
        return result

    def execute(self, name: str, arguments: dict, context: dict) -> str:
        tool = self._tools.get(name)
        if not tool:
            return f'工具 "{name}" 不存在。可用工具: {", ".join(self._tools.keys())}'

        start = time.monotonic()
        try:
            if tool.handler_type == 'python_function':
                result = self._execute_python_function(tool, arguments, context)
            elif tool.handler_type == 'sql_query':
                result = self._execute_sql_query(tool, arguments, context)
            elif tool.handler_type == 'api_call':
                result = self._execute_api_call(tool, arguments, context)
            else:
                result = f'不支持的工具类型: {tool.handler_type}'
        except Exception as exc:
            result = f'工具执行错误: {exc}'

        elapsed_ms = int((time.monotonic() - start) * 1000)
        if elapsed_ms > 30000:
            return '工具执行超时（超过 30 秒限制），请尝试其他方式获取信息。'

        return result

    def _execute_python_function(self, tool: ToolConfig, arguments: dict, context: dict) -> str:
        try:
            config = json.loads(tool.handler_config) if isinstance(tool.handler_config, str) else tool.handler_config
        except (json.JSONDecodeError, TypeError):
            return '工具配置格式错误。'

        module_path = config.get('module', '')
        function_name = config.get('function', '')

        if not module_path or not function_name:
            return '工具配置不完整，缺少 module 或 function。'

        try:
            module = importlib.import_module(module_path)
            func = getattr(module, function_name)
            return func(arguments, context)
        except ImportError:
            return f'模块 {module_path} 加载失败。'
        except AttributeError:
            return f'模块 {module_path} 中未找到函数 {function_name}。'

    def _execute_sql_query(self, tool: ToolConfig, arguments: dict, context: dict) -> str:
        return '[SQL 查询功能开发中]'

    def _execute_api_call(self, tool: ToolConfig, arguments: dict, context: dict) -> str:
        return '[API 调用功能开发中]'
