export type SubmissionRunType = 'run' | 'submit'
export type SubmissionVerdict = 'AC' | 'WA' | 'RE' | 'CE' | 'TLE' | 'PENDING'

export type SubmissionCaseResult = {
  case_index: number
  case_type: 'sample' | 'hidden'
  stdin_text: string
  expected_output_text: string
  actual_output_text: string
  verdict: SubmissionVerdict
  runtime_ms: number
  memory_kb: number
  stderr_output: string
}

export type SubmissionAnalysisLineRef = {
  line: number
  message: string
  severity: 'warning' | 'error'
}

export type SubmissionAnalysisSnapshot = {
  analysis_type: 'solution' | 'attribution' | 'review'
  provider: string
  model: string
  endpoint_url: string
  execution_status: 'completed' | 'degraded'
  status_reason: string
  title: string
  summary: string
  bullets: string[]
  line_refs: SubmissionAnalysisLineRef[]
  verdict: SubmissionVerdict | null
}

export type SubmissionCreatePayload = {
  problem_id: number
  language: 'Python' | 'C++' | 'Java'
  run_type: SubmissionRunType
  code_text: string
  custom_input: string
}

export type SubmissionResult = {
  id: number
  user_id: number
  problem_id: number
  language: 'Python' | 'C++' | 'Java'
  run_type: SubmissionRunType
  code_text: string
  verdict: SubmissionVerdict
  runtime_ms: number
  memory_kb: number
  compiler_output: string
  stderr_output: string
  failed_case_index: number | null
  failed_input: string | null
  failed_expected_output: string | null
  failed_actual_output: string | null
  case_results: SubmissionCaseResult[]
  judge_token: string | null
  attribution_analysis: SubmissionAnalysisSnapshot | null
  review_analysis: SubmissionAnalysisSnapshot | null
  created_at: string
}
