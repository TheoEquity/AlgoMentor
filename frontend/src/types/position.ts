export interface RecruitmentPosition {
  id: number
  site_id: number
  company_name: string
  title: string
  location: string | null
  degree_requirement: string | null
  position_type: string
  status: string
  match_score: number | null
  match_reason: string | null
  extracted_at: string
  created_at: string
}

export interface RecruitmentPositionDetail extends RecruitmentPosition {
  description: string | null
  apply_url: string | null
  source_hash: string
}

export interface CandidatePosition {
  id: number
  resume_id: number | null
  company_name: string
  title: string
  location: string
  description: string
  apply_url: string
  degree_requirement: string
  match_score: number
  match_reason: string
  source_type: string
  site_id: number | null
  source_position_id: number | null
  status: string
  created_at: string
  updated_at: string
}

export interface ExtractedPosition {
  source_position_id: number
  company_name: string
  title: string
  location: string
  description: string
  apply_url: string
  degree_requirement: string
  score: number
  reason: string
}
