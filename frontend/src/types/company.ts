export type Company = {
  id: number
  name: string
  name_en: string
  abbreviation: string
  created_at: string
}

export type CompanyCreatePayload = {
  name: string
  name_en: string
  abbreviation: string
}
