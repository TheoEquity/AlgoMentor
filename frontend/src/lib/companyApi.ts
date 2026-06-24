import type { Company, CompanyCreatePayload } from '../types/company'
import { requestJSON } from './http'

export async function listCompanies(): Promise<Company[]> {
  return requestJSON<Company[]>('/system/companies')
}

export async function createCompany(payload: CompanyCreatePayload): Promise<Company> {
  return requestJSON<Company>('/system/companies', {
    method: 'POST',
    body: JSON.stringify(payload),
  })
}

export async function deleteCompany(companyId: number): Promise<void> {
  await requestJSON<unknown>(`/system/companies/${companyId}`, {
    method: 'DELETE',
  })
}
