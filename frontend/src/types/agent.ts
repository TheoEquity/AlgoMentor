export type ToolConfig = {
  id: number
  slug: string
  name: string
  description: string
  parameters_schema: string
  handler_type: string
  handler_config: string
  is_enabled: boolean
  created_at: string
}

export type SkillConfig = {
  id: number
  slug: string
  name: string
  description: string
  prompt_text: string
  is_enabled: boolean
  created_at: string
}

export type AgentConfig = {
  id: number
  slug: string
  name: string
  description: string
  icon: string
  system_prompt: string
  user_prompt_template: string
  model: string
  temperature: number
  max_tokens: number
  max_iterations: number
  is_enabled: boolean
  sort_order: number
  created_at: string
  updated_at: string
  tools: ToolConfig[]
  skills: SkillConfig[]
}

export type AgentCreate = {
  slug: string
  name: string
  description?: string
  icon?: string
  system_prompt?: string
  user_prompt_template?: string
  model?: string
  temperature?: number
  max_tokens?: number
  max_iterations?: number
  is_enabled?: boolean
  sort_order?: number
  tool_ids?: number[]
  skill_ids?: number[]
}

export type AgentUpdate = Partial<AgentCreate>

export type ToolCallTrace = {
  name: string
  arguments: Record<string, unknown>
  result: string
  duration_ms: number
}

export type TokenUsage = {
  prompt_tokens: number
  completion_tokens: number
  total_tokens: number
}

export type AgentRunRequest = {
  context: Record<string, unknown>
  history?: Record<string, unknown>[]
}

export type AgentRunResult = {
  content: string
  tool_calls_trace: ToolCallTrace[]
  token_usage: TokenUsage
  iterations: number
  duration_ms: number
}

export type UsageSummary = {
  agent_slug: string
  model: string
  total_requests: number
  total_prompt_tokens: number
  total_completion_tokens: number
  total_tokens: number
  total_tool_calls: number
  avg_duration_ms: number
}

export type ChatSession = {
  id: number
  agent_id: number
  title: string
  created_at: string
  updated_at: string
}

export type ChatSessionCreate = {
  agent_id: number
  title?: string
}

export type ChatSessionUpdate = {
  title: string
}

export type ChatMessage = {
  id: number
  session_id: number
  role: string
  content: string
  tool_calls: string | null
  tool_results: string | null
  token_usage: string | null
  created_at: string
}

export type ChatRequest = {
  query: string
  context?: Record<string, unknown>
}

export type SSEEventType = 'meta' | 'thinking' | 'tool_call' | 'tool_result' | 'content' | 'status' | 'done' | 'error'

export type SSEEvent = {
  type: SSEEventType
  data: unknown
}
