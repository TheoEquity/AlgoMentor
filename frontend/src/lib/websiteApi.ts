import { requestJSON } from './http'
import type { CareerSite, IndustryCategory } from '../types/website'

const BASE = '/career-sites'
const INDUSTRY_BASE = '/system/industry-categories'

export function fetchSites(): Promise<CareerSite[]> {
  return requestJSON<CareerSite[]>(BASE)
}

export function fetchSite(siteId: number): Promise<CareerSite> {
  return requestJSON<CareerSite>(`${BASE}/${siteId}`)
}

export function createSite(payload: {
  company_name: string
  url: string
  notes: string
  industry_category: string
  referral_code: string
}): Promise<CareerSite> {
  return requestJSON<CareerSite>(BASE, {
    method: 'POST',
    body: JSON.stringify(payload),
  })
}

export function updateSite(
  siteId: number,
  payload: {
    company_name?: string
    url?: string
    notes?: string
    industry_category?: string
    referral_code?: string
  },
): Promise<CareerSite> {
  return requestJSON<CareerSite>(`${BASE}/${siteId}`, {
    method: 'PUT',
    body: JSON.stringify(payload),
  })
}

export function deleteSite(siteId: number): Promise<void> {
  return requestJSON(`${BASE}/${siteId}`, { method: 'DELETE' })
}

export function listIndustryCategories(): Promise<IndustryCategory[]> {
  return requestJSON<IndustryCategory[]>(INDUSTRY_BASE)
}

export function createIndustryCategory(payload: { name: string }): Promise<IndustryCategory> {
  return requestJSON<IndustryCategory>(INDUSTRY_BASE, {
    method: 'POST',
    body: JSON.stringify(payload),
  })
}

export function updateIndustryCategory(
  id: number,
  payload: { name?: string; sort_order?: number },
): Promise<IndustryCategory> {
  return requestJSON<IndustryCategory>(`${INDUSTRY_BASE}/${id}`, {
    method: 'PUT',
    body: JSON.stringify(payload),
  })
}

export function deleteIndustryCategory(id: number): Promise<void> {
  return requestJSON(`${INDUSTRY_BASE}/${id}`, { method: 'DELETE' })
}
