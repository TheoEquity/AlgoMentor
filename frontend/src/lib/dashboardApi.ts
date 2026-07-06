import type { DashboardData } from '../types/dashboard'
import { requestJSON } from './http'

export async function getDashboard(): Promise<DashboardData> {
  return requestJSON<DashboardData>('/system/dashboard')
}
