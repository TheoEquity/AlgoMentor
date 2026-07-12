import { requestJSON } from './http'
import type {
  JobPosition,
  JobPositionDetail,
  JobPositionCreate,
  JobPositionUpdate,
  ExtractFromUrlResult,
  MatchAnalysisResult,
} from '../types/application'

const BASE = '/job-positions'

export function fetchPositions(resumeId?: number): Promise<JobPosition[]> {
  const qs = resumeId ? `?resume_id=${resumeId}` : ''
  return requestJSON<JobPosition[]>(`${BASE}${qs}`)
}

export function fetchPosition(positionId: number): Promise<JobPositionDetail> {
  return requestJSON<JobPositionDetail>(`${BASE}/${positionId}`)
}

export function createPosition(payload: JobPositionCreate): Promise<JobPosition> {
  return requestJSON<JobPosition>(BASE, {
    method: 'POST',
    body: JSON.stringify(payload),
  })
}

export function updatePosition(positionId: number, payload: JobPositionUpdate): Promise<JobPositionDetail> {
  return requestJSON<JobPositionDetail>(`${BASE}/${positionId}`, {
    method: 'PUT',
    body: JSON.stringify(payload),
  })
}

export function deletePosition(positionId: number): Promise<void> {
  return requestJSON(`${BASE}/${positionId}`, { method: 'DELETE' })
}

export function extractFromUrl(url: string): Promise<ExtractFromUrlResult> {
  return requestJSON<ExtractFromUrlResult>(`${BASE}/extract-from-url`, {
    method: 'POST',
    body: JSON.stringify({ url }),
  })
}

export function runMatchAnalysis(positionId: number, resumeId: number): Promise<MatchAnalysisResult> {
  return requestJSON<MatchAnalysisResult>(`${BASE}/${positionId}/match-analysis`, {
    method: 'POST',
    body: JSON.stringify({ resume_id: resumeId }),
  })
}

export function getMatchResult(positionId: number): Promise<MatchAnalysisResult> {
  return requestJSON<MatchAnalysisResult>(`${BASE}/${positionId}/match-result`)
}
