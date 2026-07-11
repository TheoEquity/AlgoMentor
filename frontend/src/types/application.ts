export interface JobApplication {
  id: number
  position_id: number
  resume_id: number
  company_name: string
  position_title: string
  resume_name: string
  status: string
  applied_at: string | null
  feedback_at: string | null
  notes: string | null
  created_at: string
  updated_at: string
}

export interface ApplicationStats {
  total: number
  pending_apply: number
  applied: number
  screening_pass: number
  written_test: number
  interviewing: number
  offered: number
  rejected: number
}
