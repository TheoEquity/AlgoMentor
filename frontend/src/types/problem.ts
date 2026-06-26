export type ProblemListItem = {
  id: number
  slug: string
  title: string
  company: string
  difficulty: string
  category_slug: string
  tags: string[]
  frequency: string
  year?: number | null
  source: string
  supported_languages: string[]
  status: string
  time_limit_ms: number
  memory_limit_kb: number
  updated_at: string
}

export type ProblemExample = {
  input: string
  output: string
  explanation: string
}

export type ProblemTestCase = {
  case_type: 'sample' | 'hidden'
  stdin_text: string
  expected_output_text: string
  sort_order: number
}

export type ProblemLatestStatus = '未开始' | '已通过' | '待复盘' | '待修正'

export type ProblemCreatePayload = {
  slug: string
  title: string
  company: string
  difficulty: 'Easy' | 'Medium' | 'Hard'
  category_slug: string
  statement_markdown: string
  constraints_text: string
  time_limit_ms: number
  memory_limit_kb: number
  tags: string[]
  examples: ProblemExample[]
  supported_languages: ('Python' | 'C++' | 'Java')[]
  starter_templates: Record<string, string>
  source_type: string
  source: string
  frequency: string
  year?: number | null
  source_ref: string
  external_id: string
  status: ProblemLatestStatus
  test_cases: ProblemTestCase[]
}

export type ProblemDetail = ProblemListItem & {
  statement_markdown: string
  constraints_text: string
  time_limit_ms: number
  memory_limit_kb: number
  starter_templates: Record<string, string>
  source_type?: string | null
  source_ref?: string | null
  external_id?: string | null
  examples: ProblemExample[]
  test_cases: ProblemTestCase[]
}
