export type AnalysisLineRef = {
  line: number
  message: string
  severity: 'warning' | 'error'
}

export type AnalysisResult = {
  analysis_type: 'solution' | 'attribution' | 'review'
  provider: string
  model: string
  endpoint_url: string
  execution_status: 'completed' | 'degraded'
  status_reason: string
  title: string
  summary: string
  bullets: string[]
  line_refs: AnalysisLineRef[]
  verdict: 'AC' | 'WA' | 'RE' | 'CE' | 'TLE' | 'PENDING' | null
}

export type AnalysisStreamMeta = {
  analysis_type: AnalysisResult['analysis_type']
  provider: string
  model: string
  endpoint_url: string
  verdict: AnalysisResult['verdict']
  execution_status: 'streaming' | AnalysisResult['execution_status']
  status_reason: string
}

export type SolutionAnalysisPayload = {
  problem_id: number
  language: 'Python' | 'C++' | 'Java'
  code_text: string
}

export type AttributionAnalysisPayload = {
  submission_id: number
}
