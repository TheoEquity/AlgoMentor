export interface EducationRecord {
  school: string
  degree: string
  major: string
  start_date: string
  end_date: string
  gpa: string
  courses: string[]
  honors: string[]
}

export interface ExperienceRecord {
  company: string
  title: string
  start_date: string
  end_date: string
  description: string
}

export interface ProjectRecord {
  name: string
  role: string
  tech_stack: string[]
  start_date: string
  end_date: string
  description: string
}

export interface LanguageRecord {
  name: string
  level: string
}

export interface ResumeExtractedInfo {
  name: string
  email: string
  phone: string
  target_city: string
  education: EducationRecord[]
  skills: string[]
  experiences: ExperienceRecord[]
  projects: ProjectRecord[]
  certifications: string[]
  languages: LanguageRecord[]
  self_evaluation: string
}

export interface ResumeListItem {
  id: number
  name: string
  file_type: string
  position_keywords: string[]
  position_type: string
  position_category: string
  extract_status: string
  created_at: string
}

export interface ResumeDetail extends ResumeListItem {
  file_path: string
  extracted_info: ResumeExtractedInfo | null
  extract_error: string | null
  updated_at: string
}
