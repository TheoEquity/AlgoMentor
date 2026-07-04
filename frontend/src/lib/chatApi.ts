import type {
  ChatSession,
  ChatSessionCreate,
  ChatSessionUpdate,
  ChatMessage,
  ChatRequest,
} from '../types/agent'
import { requestJSON } from './http'

export async function listSessions(agentId?: number): Promise<ChatSession[]> {
  const qs = agentId != null ? `?agent_id=${agentId}` : ''
  return requestJSON<ChatSession[]>(`/chat/sessions${qs}`)
}

export async function getSession(id: number): Promise<ChatSession> {
  return requestJSON<ChatSession>(`/chat/sessions/${id}`)
}

export async function createSession(payload: ChatSessionCreate): Promise<ChatSession> {
  return requestJSON<ChatSession>('/chat/sessions', {
    method: 'POST',
    body: JSON.stringify(payload),
  })
}

export async function updateSession(id: number, payload: ChatSessionUpdate): Promise<ChatSession> {
  return requestJSON<ChatSession>(`/chat/sessions/${id}`, {
    method: 'PUT',
    body: JSON.stringify(payload),
  })
}

export async function deleteSession(id: number): Promise<void> {
  await requestJSON<{ message: string }>(`/chat/sessions/${id}`, { method: 'DELETE' })
}

export async function listMessages(sessionId: number): Promise<ChatMessage[]> {
  return requestJSON<ChatMessage[]>(`/chat/sessions/${sessionId}/messages`)
}

export async function sendMessage(sessionId: number, payload: ChatRequest) {
  return requestJSON<{
    content: string
    tool_calls_trace: unknown[]
    token_usage: { prompt_tokens: number; completion_tokens: number; total_tokens: number }
    iterations: number
    duration_ms: number
  }>(`/chat/sessions/${sessionId}/messages`, {
    method: 'POST',
    body: JSON.stringify(payload),
  })
}

export async function findOrCreateProblemSession(
  problemId: number,
  title?: string,
): Promise<ChatSession> {
  return requestJSON<ChatSession>('/chat/sessions/by-problem', {
    method: 'POST',
    body: JSON.stringify({ problem_id: problemId, title, agent_slug: 'chat-agent' }),
  })
}

export type ChatStreamCallbacks = {
  onChunk?: (text: string) => void
  onContent?: (text: string) => void
  onDone?: (data: { iterations: number; duration_ms: number }) => void
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

export async function streamSendMessage(
  sessionId: number,
  payload: ChatRequest,
  callbacks: ChatStreamCallbacks,
): Promise<void> {
  const response = await fetch(`/api/v1/chat/sessions/${sessionId}/stream`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      Accept: 'text/event-stream',
    },
    body: JSON.stringify(payload),
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
        if (parsed.event === 'chunk') {
          callbacks.onChunk?.(typeof data === 'string' ? data : '')
        } else if (parsed.event === 'content') {
          callbacks.onContent?.(typeof data === 'string' ? data : '')
        } else if (parsed.event === 'done') {
          callbacks.onDone?.(data)
        } else if (parsed.event === 'error') {
          callbacks.onError?.(typeof data === 'string' ? data : '未知错误')
        }
      } catch {
        if (parsed.event === 'chunk') {
          callbacks.onChunk?.(parsed.data)
        } else if (parsed.event === 'content') {
          callbacks.onContent?.(parsed.data)
        } else if (parsed.event === 'done') {
          callbacks.onDone?.({ iterations: 0, duration_ms: 0 })
        }
      }
    }

    if (done) break
  }
}
