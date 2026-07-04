from __future__ import annotations

import json
import time
from collections.abc import Iterator

from config import Settings
from schemas.agent import AgentConfig
from schemas.agent_run import AgentRunRequest, AgentRunResult
from schemas.llm_settings import LLMSettings

from services.agent.agent_registry import AgentRegistry
from services.agent.prompt_builder import PromptBuilder
from services.agent.tool_registry import ToolRegistry
from services.agent.agent_loop import AgentLoop
from services.agent.session_manager import SessionManager
from services.llm_client import LLMClient
from repositories.chat_repository import ChatRepository
from repositories.usage_repository import UsageRepository


class AgentRunner:
    def __init__(self, settings: Settings) -> None:
        self._settings = settings
        self._llm = LLMClient()
        self._prompt_builder = PromptBuilder()
        self._chat_repo = ChatRepository(settings.database_url)
        self._usage_repo = UsageRepository(settings.database_url)
        from repositories.agent_repository import AgentRepository
        self._registry = AgentRegistry(AgentRepository(settings.database_url))
        self._session_manager = SessionManager(self._chat_repo, self._llm)

    def reload_agents(self) -> None:
        self._registry.reload()

    def run(self, agent_slug: str, request: AgentRunRequest) -> AgentRunResult:
        agent = self._registry.get_agent(agent_slug)
        if not agent:
            return AgentRunResult(content=f'Agent "{agent_slug}" 不存在。')
        if not agent.is_enabled:
            return AgentRunResult(content=f'Agent "{agent_slug}" 已禁用。')

        context = self._enrich_context(agent_slug, request.context)
        tool_registry = ToolRegistry(agent.tools)
        agent_loop = AgentLoop(self._llm, tool_registry)

        settings, api_key = self._load_llm_settings()

        messages = self._prompt_builder.build_messages(agent, context, request.history)

        return agent_loop.run(
            messages=messages,
            max_iterations=agent.max_iterations,
            settings=settings,
            api_key=api_key,
            model=agent.model,
            temperature=agent.temperature,
            context=context,
        )

    def run_stream(self, agent_slug: str, request: AgentRunRequest) -> Iterator[dict]:
        agent = self._registry.get_agent(agent_slug)
        if not agent:
            yield {'type': 'error', 'data': f'Agent "{agent_slug}" 不存在。'}
            return
        if not agent.is_enabled:
            yield {'type': 'error', 'data': f'Agent "{agent_slug}" 已禁用。'}
            return

        context = self._enrich_context(agent_slug, request.context)
        tool_registry = ToolRegistry(agent.tools)
        agent_loop = AgentLoop(self._llm, tool_registry)

        settings, api_key = self._load_llm_settings()

        messages = self._prompt_builder.build_messages(agent, context, request.history)
        yield from agent_loop.run_stream(
            messages=messages,
            max_iterations=agent.max_iterations,
            settings=settings,
            api_key=api_key,
            model=agent.model,
            temperature=agent.temperature,
            context=context,
        )

    def run_chat_stream(self, session_id: int, query: str) -> Iterator[dict]:
        session = self._chat_repo.get_session(session_id)
        if not session:
            yield {'type': 'error', 'data': f'会话 {session_id} 不存在。'}
            return

        agent = self._registry._repo.get_agent(session.agent_id)
        if not agent:
            yield {'type': 'error', 'data': '会话关联的 Agent 不存在。'}
            return
        if not agent.is_enabled:
            yield {'type': 'error', 'data': f'Agent "{agent.slug}" 已禁用。'}
            return

        messages = self._chat_repo.list_messages(session_id)
        history, summary = self._session_manager.build_context(messages)

        self._session_manager.save_message(session_id, 'user', query)

        context = self._enrich_context(agent.slug, {'query': query})
        self._enrich_problem_context(session, context)
        tool_registry = ToolRegistry(agent.tools)
        agent_loop = AgentLoop(self._llm, tool_registry)

        settings, api_key = self._load_llm_settings()

        agent_messages = self._prompt_builder.build_messages(
            agent, context, history, summary,
        )

        start = time.monotonic()
        full_content = ''
        for event in agent_loop.run_stream(
            messages=agent_messages,
            max_iterations=agent.max_iterations,
            settings=settings,
            api_key=api_key,
            model=agent.model,
            temperature=agent.temperature,
            context=context,
        ):
            if event['type'] == 'chunk':
                full_content += event['data']
            elif event['type'] == 'error':
                yield event
                return
            yield event

        duration_ms = int((time.monotonic() - start) * 1000)

        self._session_manager.save_message(
            session_id, 'assistant', full_content,
            tool_calls=None,
            token_usage=None,
        )

        self._usage_repo.log_usage(
            agent_slug=agent.slug,
            model=agent.model,
            prompt_tokens=0,
            completion_tokens=0,
            total_tokens=0,
            tool_calls_count=0,
            duration_ms=duration_ms,
        )

    def run_chat(self, session_id: int, query: str) -> AgentRunResult:
        """Run agent with session context. Resolves agent from session's agent_id."""
        session = self._chat_repo.get_session(session_id)
        if not session:
            return AgentRunResult(content=f'会话 {session_id} 不存在。')

        agent = self._registry._repo.get_agent(session.agent_id)
        if not agent:
            return AgentRunResult(content=f'会话关联的 Agent 不存在。')
        if not agent.is_enabled:
            return AgentRunResult(content=f'会话关联的 Agent "{agent.slug}" 已禁用。')

        messages = self._chat_repo.list_messages(session_id)
        history, summary = self._session_manager.build_context(messages)

        self._session_manager.save_message(session_id, 'user', query)

        context = self._enrich_context(agent.slug, {'query': query})
        self._enrich_problem_context(session, context)
        tool_registry = ToolRegistry(agent.tools)
        agent_loop = AgentLoop(self._llm, tool_registry)

        settings, api_key = self._load_llm_settings()

        agent_messages = self._prompt_builder.build_messages(
            agent, context, history, summary,
        )

        start = time.monotonic()
        result = agent_loop.run(
            messages=agent_messages,
            max_iterations=agent.max_iterations,
            settings=settings,
            api_key=api_key,
            model=agent.model,
            temperature=agent.temperature,
            context=context,
        )

        tool_calls_json = json.dumps(
            [tc.model_dump() for tc in result.tool_calls_trace],
            ensure_ascii=False,
        ) if result.tool_calls_trace else None
        usage_json = json.dumps(result.token_usage.model_dump()) if result.token_usage else None

        self._session_manager.save_message(
            session_id, 'assistant', result.content,
            tool_calls=tool_calls_json,
            token_usage=usage_json,
        )

        self._usage_repo.log_usage(
            agent_slug=agent.slug,
            model=agent.model,
            prompt_tokens=result.token_usage.prompt_tokens,
            completion_tokens=result.token_usage.completion_tokens,
            total_tokens=result.token_usage.total_tokens,
            tool_calls_count=len(result.tool_calls_trace),
            duration_ms=result.duration_ms,
        )

        return result

    def _enrich_context(self, agent_slug: str, context: dict) -> dict:
        context['database_url'] = self._settings.database_url
        return context

    def _enrich_problem_context(self, session, context: dict) -> None:
        if not hasattr(session, 'problem_id') or not session.problem_id:
            return
        try:
            from repositories.problem_repository import ProblemRepository
            repo = ProblemRepository(self._settings.database_url)
            problem = repo.get_problem(session.problem_id)
            if problem:
                context['problem'] = {
                    'id': problem.id,
                    'title': problem.title,
                    'statement_markdown': problem.statement_markdown,
                    'tags': problem.tags,
                    'constraints_text': problem.constraints_text,
                    'difficulty': problem.difficulty,
                    'category_slug': problem.category_slug,
                }
        except Exception:
            pass

    def _load_llm_settings(self) -> tuple[LLMSettings, str]:
        from repositories.llm_settings_repository import LLMSettingsRepository
        repo = LLMSettingsRepository(self._settings.database_url)
        settings = repo.get_settings()
        api_key = repo.get_api_key()
        return settings, api_key
