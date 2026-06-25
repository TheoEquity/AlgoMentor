import type { ProblemCreatePayload, ProblemDetail, ProblemListItem } from '../types/problem'
import { fallbackProblemDetails, fallbackProblemList } from './problemFallbacks'
import { requestJSON } from './http'

export async function listProblems(): Promise<ProblemListItem[]> {
  try {
    return await requestJSON<ProblemListItem[]>('/problems')
  } catch {
    return fallbackProblemList
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
