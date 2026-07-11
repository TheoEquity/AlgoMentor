import { requestJSON } from './http'
import type { JobApplication, ApplicationStats } from '../types/application'

const BASE = '/applications'

export function fetchApplications(params?: { status?: string; company?: string; start_date?: string; end_date?: string }): Promise<JobApplication[]> {
  const search = new URLSearchParams()
  if (params?.status) search.set('status', params.status)
  if (params?.company) search.set('company', params.company)
  if (params?.start_date) search.set('start_date', params.start_date)
  if (params?.end_date) search.set('end_date', params.end_date)
  const qs = search.toString()
  return requestJSON<JobApplication[]>(qs ? `${BASE}?${qs}` : BASE)
}

export function fetchApplicationStats(): Promise<ApplicationStats> {
  return requestJSON<ApplicationStats>(`${BASE}/stats`)
}

export function fetchApplication(applicationId: number): Promise<JobApplication> {
  return requestJSON<JobApplication>(`${BASE}/${applicationId}`)
}

export function updateApplication(applicationId: number, payload: { status?: string; notes?: string }): Promise<JobApplication> {
  return requestJSON<JobApplication>(`${BASE}/${applicationId}`, {
    method: 'PUT',
    body: JSON.stringify(payload),
  })
}

export function deleteApplication(applicationId: number): Promise<void> {
  return requestJSON(`${BASE}/${applicationId}`, { method: 'DELETE' })
}
