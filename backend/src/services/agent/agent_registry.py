from __future__ import annotations

from schemas.agent import AgentConfig
from repositories.agent_repository import AgentRepository


class AgentRegistry:
    def __init__(self, repository: AgentRepository) -> None:
        self._repo = repository
        self._agents: dict[str, AgentConfig] = {}
        self.reload()

    def get_agent(self, slug: str) -> AgentConfig | None:
        return self._agents.get(slug)

    def list_agents(self, enabled_only: bool = True) -> list[AgentConfig]:
        agents = list(self._agents.values())
        if enabled_only:
            agents = [a for a in agents if a.is_enabled]
        agents.sort(key=lambda a: a.sort_order)
        return agents

    def reload(self) -> None:
        agents = self._repo.list_agents()
        self._agents = {a.slug: a for a in agents}
