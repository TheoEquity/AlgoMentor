const API_BASE = '/api/v1'

type ErrorPayload = {
  detail?: unknown
  error_code?: unknown
}

function normalizeDetail(detail: unknown): string {
  if (typeof detail === 'string' && detail.trim()) {
    return detail
  }

  if (Array.isArray(detail) && detail.length > 0) {
    return detail
      .map((item) => {
        if (typeof item === 'string') {
          return item
        }

        if (item && typeof item === 'object') {
          const itemRecord = item as Record<string, unknown>
          const message = typeof itemRecord.msg === 'string' ? itemRecord.msg : ''
          const location = Array.isArray(itemRecord.loc) ? itemRecord.loc.join('.') : ''
          return [location, message].filter(Boolean).join(': ')
        }

        return String(item)
      })
      .filter(Boolean)
      .join('；')
  }

  return ''
}

export async function requestJSON<T>(path: string, init?: RequestInit): Promise<T> {
  const response = await fetch(`${API_BASE}${path}`, {
    headers: {
      'Content-Type': 'application/json',
      ...(init?.headers ?? {}),
    },
    ...init,
  })

  if (!response.ok) {
    let detail = ''
    try {
      const payload = (await response.json()) as ErrorPayload
      detail = normalizeDetail(payload.detail)
    } catch {
      detail = ''
    }

    throw new Error(detail || `请求失败，状态码 ${response.status}`)
  }

  return (await response.json()) as T
}
