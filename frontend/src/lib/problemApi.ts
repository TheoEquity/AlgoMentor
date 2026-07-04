import type { OfflineProblemCandidate, OfflineProblemExtractPayload, PaginatedProblemsResponse, ProblemBatchImportPayload, ProblemCreatePayload, ProblemDetail, ProblemImportPayload, ProblemListItem } from '../types/problem'
import { fallbackProblemDetails, fallbackProblemList } from './problemFallbacks'
import { requestJSON } from './http'

export interface ProblemListFilters {
  page?: number
  pageSize?: number
  company?: string
  difficulty?: string
  categorySlug?: string
  search?: string
  position?: string
}

export async function listProblems(filters: ProblemListFilters = {}): Promise<PaginatedProblemsResponse> {
  const params = new URLSearchParams()
  if (filters.page != null) params.set('page', String(filters.page))
  if (filters.pageSize != null) params.set('page_size', String(filters.pageSize))
  if (filters.company) params.set('company', filters.company)
  if (filters.difficulty) params.set('difficulty', filters.difficulty)
  if (filters.categorySlug) params.set('category_slug', filters.categorySlug)
  if (filters.search) params.set('search', filters.search)
  if (filters.position) params.set('position', filters.position)
  const queryString = params.toString()
  try {
    return await requestJSON<PaginatedProblemsResponse>(`/problems${queryString ? `?${queryString}` : ''}`)
  } catch {
    return { items: fallbackProblemList, total: fallbackProblemList.length, page: 1, page_size: 50 }
  }
}

export async function getProblem(problemId: number): Promise<ProblemDetail> {
  try {
    return await requestJSON<ProblemDetail>(`/problems/${problemId}`)
  } catch {
    const problem = fallbackProblemDetails[problemId]
    if (!problem) {
      throw new Error('Problem not found')
    }

    return problem
  }
}

export async function createProblem(payload: ProblemCreatePayload): Promise<ProblemDetail> {
  return requestJSON<ProblemDetail>('/problems', {
    method: 'POST',
    body: JSON.stringify(payload),
  })
}

export async function importProblem(payload: ProblemImportPayload): Promise<ProblemDetail> {
  return requestJSON<ProblemDetail>('/problems/import', {
    method: 'POST',
    body: JSON.stringify(payload),
  })
}

export async function extractOfflineProblems(payload: OfflineProblemExtractPayload): Promise<OfflineProblemCandidate[]> {
  return requestJSON<OfflineProblemCandidate[]>('/problems/import-offline/extract', {
    method: 'POST',
    body: JSON.stringify(payload),
  })
}

export async function batchImportProblems(payload: ProblemBatchImportPayload): Promise<ProblemDetail[]> {
  return requestJSON<ProblemDetail[]>('/problems/import/batch', {
    method: 'POST',
    body: JSON.stringify(payload),
  })
}

export async function updateProblem(problemId: number, payload: ProblemCreatePayload): Promise<ProblemDetail> {
  return requestJSON<ProblemDetail>(`/problems/${problemId}`, {
    method: 'PUT',
    body: JSON.stringify(payload),
  })
}

export async function deleteProblem(problemId: number): Promise<void> {
  const response = await fetch(`/api/v1/problems/${problemId}`, {
    method: 'DELETE',
  })

  if (!response.ok) {
    throw new Error(`删除失败，状态码 ${response.status}`)
  }
}

export async function fetchDistinctCompanies(): Promise<string[]> {
  try {
    return await requestJSON<string[]>('/problems/distinct-companies')
  } catch {
    return []
  }
}

export async function fetchDistinctPositions(): Promise<string[]> {
  try {
    return await requestJSON<string[]>('/problems/distinct-positions')
  } catch {
    return []
  }
}
