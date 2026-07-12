export interface JobPosition {
  id: number;
  resume_id: number | null;
  company_name: string;
  department: string;
  title: string;
  location: string;
  position_type: string;
  position_category: string;
  industry_category: string;
  deadline: string;
  status: string;
  status_date: string;
  notes: string;
  match_score: number;
  job_url: string;
  created_at: string;
  updated_at: string;
}

export interface JobPositionDetail {
  id: number;
  resume_id: number | null;
  company_name: string;
  department: string;
  title: string;
  location: string;
  position_type: string;
  position_category: string;
  industry_category: string;
  job_url: string;
  publish_date: string;
  deadline: string;
  job_description: string;
  job_requirements: string;
  job_preferences: string;
  status: string;
  status_date: string;
  notes: string;
  apply_channel: string;
  match_score: number;
  match_detail: string;
  match_advice: string;
  created_at: string;
  updated_at: string;
}

export interface JobPositionCreate {
  resume_id?: number | null;
  company_name: string;
  department?: string;
  title: string;
  location?: string;
  position_type?: string;
  position_category?: string;
  industry_category?: string;
  job_url?: string;
  publish_date?: string;
  deadline?: string;
  job_description?: string;
  job_requirements?: string;
  job_preferences?: string;
  status?: string;
  status_date?: string;
  notes?: string;
  apply_channel?: string;
  match_score?: number;
  match_detail?: string;
  match_advice?: string;
}

export interface JobPositionUpdate {
  company_name?: string;
  department?: string;
  title?: string;
  location?: string;
  position_type?: string;
  position_category?: string;
  industry_category?: string;
  job_url?: string;
  publish_date?: string;
  deadline?: string;
  job_description?: string;
  job_requirements?: string;
  job_preferences?: string;
  status?: string;
  status_date?: string;
  notes?: string;
  apply_channel?: string;
  match_score?: number;
  match_detail?: string;
  match_advice?: string;
}

export interface ExtractFromUrlResult {
  job_description: string;
  job_requirements: string;
  job_preferences: string;
  title: string;
  department: string;
  location: string;
  deadline: string;
}

export interface MatchAnalysisResult {
  match_score: number;
  match_detail: string;
  match_advice: string;
}

export const APPLICATION_STATUSES = [
  '待投递',
  '简历筛选',
  '测评',
  '笔试',
  '面试',
  '结束',
] as const;

export const POSITION_TYPES = ['校招', '实习'] as const;

export const POSITION_CATEGORIES = ['技术', '产品', '其他'] as const;
