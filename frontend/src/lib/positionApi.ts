import { requestJSON } from './http'
import type { CandidatePosition, ExtractedPosition, RecruitmentPosition, RecruitmentPositionDetail } from '../types/position'

const BASE = '/recruitment-positions'
const CANDIDATE_BASE = '/candidate-positions'

export function fetchPositions(params?: { resume_id?: number; status?: string; site_id?: number }): Promise<RecruitmentPosition[]> {
  const search = new URLSearchParams()
  if (params?.resume_id) search.set('resume_id', String(params.resume_id))
  if (params?.status) search.set('status', params.status)
  if (params?.site_id) search.set('site_id', String(params.site_id))
  const qs = search.toString()
  return requestJSON<RecruitmentPosition[]>(qs ? `${BASE}?${qs}` : BASE)
}

export function fetchPosition(positionId: number, resumeId?: number): Promise<RecruitmentPositionDetail> {
  const qs = resumeId ? `?resume_id=${resumeId}` : ''
  return requestJSON<RecruitmentPositionDetail>(`${BASE}/${positionId}${qs}`)
}

export function confirmPosition(positionId: number, resumeId: number): Promise<{ ok: boolean }> {
  return requestJSON(`${BASE}/${positionId}/confirm?resume_id=${resumeId}`, { method: 'PUT' })
}

export function ignorePosition(positionId: number): Promise<{ ok: boolean }> {
  return requestJSON(`${BASE}/${positionId}/ignore`, { method: 'PUT' })
}

export function classifyAllPositions(): Promise<{ ok: boolean; classified: number; total: number }> {
  return requestJSON(`${BASE}/classify-all`, { method: 'POST' })
}

export function matchPositions(resumeId: number, limit: number = 50): Promise<{ ok: boolean; matched: number; total: number }> {
  return requestJSON(`${BASE}/match/${resumeId}?limit=${limit}`, { method: 'POST' })
}

export function matchSinglePosition(positionId: number, resumeId: number): Promise<{ score: number; reason: string }> {
  return requestJSON(`${BASE}/match-single/${positionId}/${resumeId}`, { method: 'POST' })
}

export function deletePosition(positionId: number): Promise<void> {
  return requestJSON(`${BASE}/${positionId}`, { method: 'DELETE' })
}

export function fetchCandidates(resumeId?: number): Promise<CandidatePosition[]> {
  const qs = resumeId ? `?resume_id=${resumeId}` : ''
  return requestJSON<CandidatePosition[]>(`${CANDIDATE_BASE}${qs}`)
}

export function createCandidate(payload: {
  resume_id?: number
  company_name: string
  title: string
  location?: string
  description?: string
  apply_url?: string
  degree_requirement?: string
  match_score?: number
  match_reason?: string
  site_id?: number
  source_position_id?: number
}): Promise<CandidatePosition> {
  return requestJSON<CandidatePosition>(CANDIDATE_BASE, {
    method: 'POST',
    body: JSON.stringify(payload),
  })
}

export function updateCandidate(
  id: number,
  payload: {
    company_name?: string
    title?: string
    location?: string
    description?: string
    apply_url?: string
    degree_requirement?: string
    match_score?: number
    match_reason?: string
    status?: string
  },
): Promise<CandidatePosition> {
  return requestJSON<CandidatePosition>(`${CANDIDATE_BASE}/${id}`, {
    method: 'PUT',
    body: JSON.stringify(payload),
  })
}

export function deleteCandidate(id: number): Promise<void> {
  return requestJSON(`${CANDIDATE_BASE}/${id}`, { method: 'DELETE' })
}

export function extractFromSite(siteId: number, resumeId: number): Promise<{ ok: boolean; results: ExtractedPosition[] }> {
  return requestJSON(`${CANDIDATE_BASE}/extract-from-site`, {
    method: 'POST',
    body: JSON.stringify({ site_id: siteId, resume_id: resumeId }),
  })
}

export function fetchPositionDetail(
  siteId: number,
  title: string,
  company: string,
  sourcePositionId: number,
): Promise<{
  title: string; company: string; location: string; description: string
  requirements: string; priority: string; other: string; deadline: string
  degree_requirement: string; apply_url: string
}> {
  return requestJSON(`/career-sites/${siteId}/fetch-detail`, {
    method: 'POST',
    body: JSON.stringify({ title, company, source_position_id: sourcePositionId }),
  })
}

export function recalcCandidateMatch(positionId: number, resumeId: number): Promise<{ score: number; reason: string }> {
  return requestJSON(`${CANDIDATE_BASE}/${positionId}/recalc-match?resume_id=${resumeId}`, {
    method: 'POST',
  })
}
