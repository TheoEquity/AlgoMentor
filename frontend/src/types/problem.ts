export type ProblemListItem = {
  id: number
  slug: string
  title: string
  company: string
  department: string
  difficulty: string
  tags: string[]
  supported_languages: string[]
  status: string
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

export type ProblemCreatePayload = {
  slug: string
  title: string
  company: string
  department: string
  difficulty: 'Easy' | 'Medium' | 'Hard'
  statement_markdown: string
  constraints_text: string
  tags: string[]
  examples: ProblemExample[]
  supported_languages: ('Python' | 'C++' | 'Java')[]
  starter_templates: Record<string, string>
  source_type: string
  source_ref: string
  external_id: string
  status: 'draft' | 'published'
  test_cases: ProblemTestCase[]
}

export type ProblemDetail = ProblemListItem & {
  statement_markdown: string
  constraints_text: string
  starter_templates: Record<string, string>
  source_type?: string | null
  source_ref?: string | null
  external_id?: string | null
  examples: ProblemExample[]
  test_cases: ProblemTestCase[]
}
