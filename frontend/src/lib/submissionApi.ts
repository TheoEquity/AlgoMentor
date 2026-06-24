import type { SubmissionCreatePayload, SubmissionResult } from '../types/submission'
import { requestJSON } from './http'

export async function createSubmission(payload: SubmissionCreatePayload): Promise<SubmissionResult> {
  return requestJSON<SubmissionResult>('/submissions', {
    method: 'POST',
    body: JSON.stringify(payload),
  })
}

export async function getSubmission(submissionId: number): Promise<SubmissionResult> {
  return requestJSON<SubmissionResult>(`/submissions/${submissionId}`)
}

export async function listSubmissions(problemId: number, limit = 20): Promise<SubmissionResult[]> {
  return requestJSON<SubmissionResult[]>(`/submissions?problem_id=${problemId}&limit=${limit}`)
}
