import { requestJSON } from './http'
import type { TrainingPlanListItem, TrainingPlanDetail, PlanPreview } from '../types/trainingPlan'

const BASE = '/training-plans'

export function fetchTrainingPlans(): Promise<TrainingPlanListItem[]> {
  return requestJSON<TrainingPlanListItem[]>(BASE)
}

export function fetchTrainingPlan(planId: number): Promise<TrainingPlanDetail> {
  return requestJSON<TrainingPlanDetail>(`${BASE}/${planId}`)
}

export function createTrainingPlan(payload: {
  name: string
  plan_type: string
  duration_days: number
  problem_ids: number[]
}): Promise<TrainingPlanDetail> {
  return requestJSON<TrainingPlanDetail>(BASE, {
    method: 'POST',
    body: JSON.stringify(payload),
  })
}

export function previewAiPlan(analysisText?: string): Promise<PlanPreview> {
  return requestJSON<PlanPreview>(
    `${BASE}/ai-generate?preview=true`,
    {
      method: 'POST',
      body: JSON.stringify({ analysis_text: analysisText || '' }),
    },
  )
}

export function previewDerivedPlan(problemId: number): Promise<PlanPreview> {
  return requestJSON<PlanPreview>(
    `${BASE}/derived-generate?problem_id=${problemId}&preview=true`,
    { method: 'POST' },
  )
}

export function previewReviewPlan(): Promise<PlanPreview> {
  return requestJSON<PlanPreview>(
    `${BASE}/review-generate?preview=true`,
    { method: 'POST' },
  )
}

export function aiGeneratePlan(analysisText?: string): Promise<TrainingPlanDetail> {
  return requestJSON<TrainingPlanDetail>(`${BASE}/ai-generate`, {
    method: 'POST',
    body: JSON.stringify({ analysis_text: analysisText || '' }),
  })
}

export function derivedGeneratePlan(problemId: number): Promise<TrainingPlanDetail> {
  return requestJSON<TrainingPlanDetail>(`${BASE}/derived-generate?problem_id=${problemId}`, { method: 'POST' })
}

export function reviewGeneratePlan(): Promise<TrainingPlanDetail> {
  return requestJSON<TrainingPlanDetail>(`${BASE}/review-generate`, { method: 'POST' })
}

export function deleteTrainingPlan(planId: number): Promise<void> {
  return requestJSON<void>(`${BASE}/${planId}`, { method: 'DELETE' })
}

export function updatePlanItemStatus(itemId: number, status: string): Promise<{ ok: boolean }> {
  return requestJSON<{ ok: boolean }>(`${BASE}/items/${itemId}/status?status=${encodeURIComponent(status)}`, { method: 'PATCH' })
}
