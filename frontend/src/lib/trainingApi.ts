import type { TrainingOverviewResponse } from '../types/training'
import { requestJSON } from './http'

export async function getTrainingOverview(): Promise<TrainingOverviewResponse> {
  return requestJSON<TrainingOverviewResponse>('/training/overview')
}
