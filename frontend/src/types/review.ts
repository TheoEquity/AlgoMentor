export type ReviewErrorType = 'AC' | 'WA' | 'RE' | 'CE' | 'TLE'

export type ReviewSummary = {
  total_submissions: number
  wrong_submissions: number
  ac_submissions: number
  top_error_type: string | null
}

export type ReviewItem = {
  submission_id: number
  problem_id: number
  title: string
  company: string
  difficulty: string
  category_slug: string
  tags: string[]
  language: 'Python' | 'C++' | 'Java'
  run_type: 'run' | 'submit'
  verdict: 'AC' | 'WA' | 'RE' | 'CE' | 'TLE' | 'PENDING'
  error_type: string
  runtime_ms: number
  memory_kb: number
  failed_case_summary: string
  created_at: string
}

export type ReviewListResponse = {
  summary: ReviewSummary
  items: ReviewItem[]
}

export type ReviewListQuery = {
  wrong_only?: boolean
  company?: string
  tag?: string
  error_type?: ReviewErrorType | 'all'
}
