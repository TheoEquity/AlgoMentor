import type {
  AgentConfig,
  AgentCreate,
  AgentUpdate,
  ToolConfig,
  SkillConfig,
  AgentRunRequest,
  AgentRunResult,
} from '../types/agent'
import { requestJSON } from './http'

export async function listAgents(enabledOnly = false): Promise<AgentConfig[]> {
  const qs = enabledOnly ? '?enabled_only=true' : ''
  return requestJSON<AgentConfig[]>(`/agents${qs}`)
}

export async function getAgent(id: number): Promise<AgentConfig> {
  return requestJSON<AgentConfig>(`/agents/${id}`)
}

export async function createAgent(payload: AgentCreate): Promise<AgentConfig> {
  return requestJSON<AgentConfig>('/agents', {
    method: 'POST',
    body: JSON.stringify(payload),
  })
}

export async function updateAgent(id: number, payload: AgentUpdate): Promise<AgentConfig> {
  return requestJSON<AgentConfig>(`/agents/${id}`, {
    method: 'PUT',
    body: JSON.stringify(payload),
  })
}

export async function deleteAgent(id: number): Promise<void> {
  await requestJSON<{ message: string }>(`/agents/${id}`, { method: 'DELETE' })
}

export async function listTools(): Promise<ToolConfig[]> {
  return requestJSON<ToolConfig[]>('/agents/tools/list')
}

export async function listSkills(): Promise<SkillConfig[]> {
  return requestJSON<SkillConfig[]>('/agents/skills/list')
}

export async function runAgent(agentSlug: string, payload: AgentRunRequest): Promise<AgentRunResult> {
  return requestJSON<AgentRunResult>(`/agents/${agentSlug}/run`, {
    method: 'POST',
    body: JSON.stringify(payload),
  })
}

export type AgentStreamCallbacks = {
  onMeta?: (data: unknown) => void
  onThinking?: (text: string) => void
  onToolCall?: (data: unknown) => void
  onToolResult?: (data: unknown) => void
  onContent?: (text: string) => void
  onStatus?: (data: unknown) => void
  onDone?: (data: unknown) => void
  onError?: (error: string) => void
}

function parseSSEBlock(block: string): { event: string; data: string } | null {
  const lines = block.split('\n')
  let event = 'message'
  const dataLines: string[] = []

  for (const line of lines) {
    if (line.startsWith('event:')) {
      event = line.slice(6).trim()
      continue
    }
    if (line.startsWith('data:')) {
      dataLines.push(line.slice(5).trim())
    }
  }

  if (dataLines.length === 0) return null
  return { event, data: dataLines.join('\n') }
}

export async function streamAgentRun(
  agentSlug: string,
  payload: AgentRunRequest,
  callbacks: AgentStreamCallbacks,
): Promise<void> {
  const contextJson = encodeURIComponent(JSON.stringify(payload.context))
  const response = await fetch(`/api/v1/agents/${agentSlug}/stream?context_json=${contextJson}`, {
    headers: { Accept: 'text/event-stream' },
  })

  if (!response.ok) {
    let detail = ''
    try {
      const err = await response.json() as { detail?: unknown }
      detail = typeof err.detail === 'string' ? err.detail : ''
    } catch { /* ignore */ }
    throw new Error(detail || `请求失败，状态码 ${response.status}`)
  }

  if (!response.body) throw new Error('浏览器不支持流式响应')

  const reader = response.body.getReader()
  const decoder = new TextDecoder()
  let buffer = ''

  while (true) {
    const { done, value } = await reader.read()
    buffer += decoder.decode(value ?? new Uint8Array(), { stream: !done })

    const blocks = buffer.split('\n\n')
    buffer = blocks.pop() ?? ''

    for (const block of blocks) {
      const parsed = parseSSEBlock(block.trim())
      if (!parsed) continue

      try {
        const data = JSON.parse(parsed.data)
        switch (parsed.event) {
          case 'meta':
            callbacks.onMeta?.(data)
            break
          case 'thinking':
            callbacks.onThinking?.(typeof data === 'string' ? data : '')
            break
          case 'tool_call':
            callbacks.onToolCall?.(data)
            break
          case 'tool_result':
            callbacks.onToolResult?.(data)
            break
          case 'content':
            callbacks.onContent?.(typeof data === 'string' ? data : '')
            break
          case 'status':
            callbacks.onStatus?.(data)
            break
          case 'done':
            callbacks.onDone?.(data)
            break
          case 'error':
            callbacks.onError?.(typeof data === 'string' ? data : '未知错误')
            break
        }
      } catch {
        if (parsed.event === 'content') {
          callbacks.onContent?.(parsed.data)
        } else if (parsed.event === 'done') {
          callbacks.onDone?.({})
        } else if (parsed.event === 'error') {
          callbacks.onError?.(parsed.data)
        }
      }
    }

    if (done) break
  }
}
