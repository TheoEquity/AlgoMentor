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
