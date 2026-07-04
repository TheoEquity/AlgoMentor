from __future__ import annotations

from jinja2 import BaseLoader, Environment

from schemas.agent import AgentConfig
from schemas.chat import ChatMessage


_jinja_env = Environment(loader=BaseLoader(), autoescape=False)


class PromptBuilder:
    def build_messages(
        self,
        agent: AgentConfig,
        context: dict,
        history: list[dict] | None = None,
        history_summary: str | None = None,
    ) -> list[dict]:
        system_content = agent.system_prompt

        for skill in agent.skills:
            if skill.is_enabled:
                system_content += f'\n\n[技能: {skill.name}]\n{skill.prompt_text}'

        if history_summary:
            system_content += f'\n\n[历史摘要]\n{history_summary}'

        messages: list[dict] = [{'role': 'system', 'content': system_content}]

        user_content = self._render_template(agent.user_prompt_template, context)
        messages.append({'role': 'user', 'content': user_content})

        if history:
            for msg in history:
                role = msg.get('role', 'assistant')
                content = msg.get('content', '')
                tool_calls = msg.get('tool_calls')
                if role == 'tool':
                    messages.append({
                        'role': 'tool',
                        'tool_call_id': msg.get('tool_call_id', ''),
                        'content': content,
                    })
                elif role == 'assistant' and tool_calls:
                    messages.append({'role': 'assistant', 'content': content, 'tool_calls': tool_calls})
                else:
                    messages.append({'role': role, 'content': content})

        return messages

    def build_chat_history(self, db_messages: list[ChatMessage]) -> list[dict]:
        history: list[dict] = []
        for msg in db_messages:
            entry: dict = {'role': msg.role, 'content': msg.content}
            if msg.tool_calls:
                import json
                try:
                    entry['tool_calls'] = json.loads(msg.tool_calls)
                except (json.JSONDecodeError, TypeError):
                    pass
            history.append(entry)
        return history

    def _render_template(self, template: str, context: dict) -> str:
        if not template:
            return ''
        try:
            tmpl = _jinja_env.from_string(template)
            return tmpl.render(**context)
        except Exception:
            return template
