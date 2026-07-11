export interface CareerSite {
  id: number
  company_name: string
  url: string
  notes: string | null
  industry_category: string
  referral_code: string
  last_scraped_at: string | null
  scrape_status: string
  scrape_error: string | null
  position_count: number
  created_at: string
  updated_at: string
}

export interface IndustryCategory {
  id: number
  name: string
  sort_order: number
  created_at: string
}
