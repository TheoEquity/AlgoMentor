import type { AnalysisResult, AnalysisStreamMeta, AttributionAnalysisPayload, SolutionAnalysisPayload } from '../types/analysis'
import { requestJSON } from './http'

const API_BASE = '/api/v1'

type ErrorPayload = {
  detail?: unknown
}

type StreamCallbacks = {
  onMeta?: (meta: AnalysisStreamMeta) => void
  onStatus?: (status: Pick<AnalysisStreamMeta, 'execution_status' | 'status_reason'>) => void
  onChunk?: (text: string) => void
  onTitle?: (title: string) => void
  onSummary?: (summary: string) => void
  onBullet?: (bullet: string) => void
  onLineRef?: (lineRef: AnalysisResult['line_refs'][number]) => void
  onDone: (result: AnalysisResult) => void
}

function normalizeDetail(detail: unknown): string {
  if (typeof detail === 'string' && detail.trim()) {
    return detail
  }

  if (Array.isArray(detail) && detail.length > 0) {
    return detail.map((item) => String(item)).join('；')
  }

  return ''
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

  if (dataLines.length === 0) {
    return null
  }

  return { event, data: dataLines.join('\n') }
}

async function streamAnalysis<TPayload>(path: string, payload: TPayload, callbacks: StreamCallbacks): Promise<void> {
  const response = await fetch(`${API_BASE}${path}`, {
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
      const errorPayload = (await response.json()) as ErrorPayload
      detail = normalizeDetail(errorPayload.detail)
    } catch {
      detail = ''
    }

    throw new Error(detail || `请求失败，状态码 ${response.status}`)
  }

  if (!response.body) {
    throw new Error('浏览器当前无法读取流式响应。')
  }

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
      if (!parsed) {
        continue
      }

      const eventPayload = JSON.parse(parsed.data) as AnalysisStreamMeta | AnalysisResult | {
        text?: string
        title?: string
        summary?: string
        bullet?: string
        line?: number
        message?: string
        severity?: 'warning' | 'error'
        execution_status?: AnalysisStreamMeta['execution_status']
        status_reason?: string
      }
      if (parsed.event === 'meta') {
        callbacks.onMeta?.(eventPayload as AnalysisStreamMeta)
        continue
      }

      if (parsed.event === 'status') {
        const payload = eventPayload as { execution_status?: AnalysisStreamMeta['execution_status']; status_reason?: string }
        callbacks.onStatus?.({
          execution_status: payload.execution_status ?? 'streaming',
          status_reason: payload.status_reason ?? '',
        })
        continue
      }

      if (parsed.event === 'chunk') {
        callbacks.onChunk?.((eventPayload as { text?: string }).text ?? '')
        continue
      }

      if (parsed.event === 'title') {
        callbacks.onTitle?.((eventPayload as { title?: string }).title ?? '')
        continue
      }

      if (parsed.event === 'summary') {
        callbacks.onSummary?.((eventPayload as { summary?: string }).summary ?? '')
        continue
      }

      if (parsed.event === 'bullet') {
        callbacks.onBullet?.((eventPayload as { bullet?: string }).bullet ?? '')
        continue
      }

      if (parsed.event === 'line_ref') {
        const payload = eventPayload as { line?: number; message?: string; severity?: 'warning' | 'error' }
        if (typeof payload.line === 'number' && typeof payload.message === 'string') {
          callbacks.onLineRef?.({
            line: payload.line,
            message: payload.message,
            severity: payload.severity === 'error' ? 'error' : 'warning',
          })
        }
        continue
      }

      if (parsed.event === 'done') {
        callbacks.onDone(eventPayload as AnalysisResult)
      }
    }

    if (done) {
      break
    }
  }

  const lastBlock = parseSSEBlock(buffer.trim())
  if (lastBlock && lastBlock.event === 'done') {
    callbacks.onDone(JSON.parse(lastBlock.data) as AnalysisResult)
  }
}

export async function analyzeSolution(payload: SolutionAnalysisPayload): Promise<AnalysisResult> {
  return requestJSON<AnalysisResult>('/analysis/solution', {
    method: 'POST',
    body: JSON.stringify(payload),
  })
}

export async function analyzeAttribution(payload: AttributionAnalysisPayload): Promise<AnalysisResult> {
  return requestJSON<AnalysisResult>('/analysis/attribution', {
    method: 'POST',
    body: JSON.stringify(payload),
  })
}

export async function analyzeReview(payload: AttributionAnalysisPayload): Promise<AnalysisResult> {
  return requestJSON<AnalysisResult>('/analysis/review', {
    method: 'POST',
    body: JSON.stringify(payload),
  })
}

export async function streamSolutionAnalysis(payload: SolutionAnalysisPayload, callbacks: StreamCallbacks): Promise<void> {
  return streamAnalysis('/analysis/solution/stream', payload, callbacks)
}

export async function streamAttributionAnalysis(payload: AttributionAnalysisPayload, callbacks: StreamCallbacks): Promise<void> {
  return streamAnalysis('/analysis/attribution/stream', payload, callbacks)
}

export async function streamReviewAnalysis(payload: AttributionAnalysisPayload, callbacks: StreamCallbacks): Promise<void> {
  return streamAnalysis('/analysis/review/stream', payload, callbacks)
}
