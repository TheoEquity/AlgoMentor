export type TrainingSummary = {
  total_runs: number
  ac_count: number
  wrong_count: number
  submit_count: number
  strongest_tag: string | null
  main_error_type: 'AC' | 'WA' | 'RE' | 'CE' | 'TLE' | 'PENDING' | null
}

export type TrainingRecentItem = {
  submission_id: number
  problem_id: number
  title: string
  company: string
  language: 'Python' | 'C++' | 'Java'
  run_type: 'run' | 'submit'
  verdict: 'AC' | 'WA' | 'RE' | 'CE' | 'TLE' | 'PENDING'
  created_at: string
}

export type TrainingErrorBucket = {
  verdict: 'AC' | 'WA' | 'RE' | 'CE' | 'TLE' | 'PENDING'
  count: number
}

export type TrainingRecommendation = {
  problem_id: number
  title: string
  company: string
  tags: string[]
  recommendation_reason: string
}

export type TrainingOverviewResponse = {
  summary: TrainingSummary
  recent_items: TrainingRecentItem[]
  error_buckets: TrainingErrorBucket[]
  recommendations: TrainingRecommendation[]
}
