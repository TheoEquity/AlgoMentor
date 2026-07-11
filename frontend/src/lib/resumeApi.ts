import { requestJSON } from './http'
import type { ResumeListItem, ResumeDetail } from '../types/resume'

const BASE = '/resumes'

export function fetchResumes(): Promise<ResumeListItem[]> {
  return requestJSON<ResumeListItem[]>(BASE)
}

export function fetchResume(resumeId: number): Promise<ResumeDetail> {
  return requestJSON<ResumeDetail>(`${BASE}/${resumeId}`)
}

export function uploadResume(formData: FormData): Promise<ResumeDetail> {
  return requestJSON<ResumeDetail>(BASE, {
    method: 'POST',
    body: formData,
  })
}

export function updateResume(resumeId: number, formData: FormData): Promise<ResumeDetail> {
  return requestJSON<ResumeDetail>(`${BASE}/${resumeId}`, {
    method: 'PUT',
    body: formData,
  })
}

export function reparseResume(resumeId: number): Promise<{ ok: boolean; status: string; error?: string }> {
  return requestJSON(`${BASE}/${resumeId}/reparse`, { method: 'POST' })
}

export function getResumeTextStatus(resumeId: number): Promise<{ status: string; error: string | null; has_info: boolean }> {
  return requestJSON(`${BASE}/${resumeId}/text`)
}

export function deleteResume(resumeId: number): Promise<void> {
  return requestJSON(`${BASE}/${resumeId}`, { method: 'DELETE' })
}

export function getResumeFileUrl(resumeId: number): string {
  return `/api/v1${BASE}/${resumeId}/file`
}
