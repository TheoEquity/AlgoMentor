import { useEffect, useState } from 'react'

import { MarkdownRenderer } from '../components/MarkdownRenderer'
import { analyzeProblem, chatProblem } from '../lib/analysisApi'
import { listCategories } from '../lib/categoryApi'
import { listCompanies } from '../lib/companyApi'
import { updateProblem } from '../lib/problemApi'
import type { AnalysisResult, ProblemChatMessage } from '../types/analysis'
import type { Company } from '../types/company'
import type { ProblemCreatePayload, ProblemDetail, ProblemLatestStatus } from '../types/problem'
import type { ProblemCategory } from '../types/problemCategory'

type ProblemOverviewPageProps = {
  problem: ProblemDetail
  categoryName: string
  onBack: () => void
  onStartTraining: () => void
  onProblemSaved: (problem: ProblemDetail) => void
}

type ProblemEditForm = {
  slug: string
  title: string
  company: string
  difficulty: 'Easy' | 'Medium' | 'Hard'
  category_slug: string
  statement_markdown: string
  source_type: string
  source: string
  frequency: string
  year: string
  source_ref: string
  external_id: string
  status: ProblemLatestStatus
  time_limit_ms: string
  memory_limit_kb: string
  hidden_input: string
  hidden_output: string
  python_template: string
  cpp_template: string
  java_template: string
}

function buildEditForm(problem: ProblemDetail): ProblemEditForm {
  const hiddenCase = problem.test_cases.find((item) => item.case_type === 'hidden')

  return {
    slug: problem.slug,
    title: problem.title,
    company: problem.company,
    difficulty: problem.difficulty as 'Easy' | 'Medium' | 'Hard',
    category_slug: problem.category_slug,
    statement_markdown: problem.statement_markdown,
    source_type: problem.source_type || 'manual',
    source: problem.source || '手工',
    frequency: problem.frequency || '中',
    year: problem.year ? String(problem.year) : '',
    source_ref: problem.source_ref || '',
    external_id: problem.external_id || '',
    status: normalizeLatestStatus(problem.status),
    time_limit_ms: String(problem.time_limit_ms ?? 2000),
    memory_limit_kb: String(problem.memory_limit_kb ?? 262144),
    hidden_input: hiddenCase?.stdin_text || '',
    hidden_output: hiddenCase?.expected_output_text || '',
    python_template: problem.starter_templates.Python || '',
    cpp_template: problem.starter_templates['C++'] || '',
    java_template: problem.starter_templates.Java || '',
  }
}

function buildThinkingSummary(problem: ProblemDetail, categoryName: string): string {
  const tags = problem.tags.length > 0 ? problem.tags.join('、') : '基础算法'
  return `建议先识别题型为 ${categoryName || categoryNameOrFallback(problem, tags)}，再围绕输入规模和边界条件选择可证明复杂度的解法。实现时优先覆盖样例、最小规模、重复值和极端规模。`
}

function categoryNameOrFallback(problem: ProblemDetail, fallback: string): string {
  return problem.category_slug || fallback
}

function normalizeLatestStatus(status: string): ProblemLatestStatus {
  if (status === '已通过' || status === '待复盘' || status === '待修正') {
    return status
  }

  return '未开始'
}

export function ProblemOverviewPage({ problem, categoryName, onBack, onStartTraining, onProblemSaved }: ProblemOverviewPageProps) {
  const [form, setForm] = useState<ProblemEditForm>(() => buildEditForm(problem))
  const [saveError, setSaveError] = useState('')
  const [saveSuccess, setSaveSuccess] = useState('')
  const [isSaving, setIsSaving] = useState(false)
  const [companies, setCompanies] = useState<Company[]>([])
  const [categories, setCategories] = useState<ProblemCategory[]>([])
  const [problemAnalysis, setProblemAnalysis] = useState<AnalysisResult | null>(null)
  const [analysisError, setAnalysisError] = useState('')
  const [isAnalyzingProblem, setIsAnalyzingProblem] = useState(false)
  const [chatMessages, setChatMessages] = useState<ProblemChatMessage[]>([])
  const [chatQuestion, setChatQuestion] = useState('')
  const [chatError, setChatError] = useState('')
  const [isChatting, setIsChatting] = useState(false)
  const [showAdvanced, setShowAdvanced] = useState(false)

  useEffect(() => {
    setForm(buildEditForm(problem))
    setSaveError('')
    setSaveSuccess('')
    setProblemAnalysis(null)
    setAnalysisError('')
    setChatMessages([])
    setChatQuestion('')
    setChatError('')
  }, [problem])

  useEffect(() => {
    void Promise.all([
      listCompanies().then(setCompanies).catch(() => {}),
      listCategories().then(setCategories).catch(() => {}),
    ])
  }, [])

  const handleFieldChange = (field: keyof ProblemEditForm, value: string) => {
    setForm((current) => ({ ...current, [field]: value }))
  }

  const buildPayload = (): ProblemCreatePayload => {
    return {
      slug: form.slug.trim(),
      title: form.title.trim(),
      company: form.company.trim(),
      difficulty: form.difficulty,
      category_slug: form.category_slug.trim(),
      statement_markdown: form.statement_markdown.trim(),
      constraints_text: '',
      time_limit_ms: Number(form.time_limit_ms) || 2000,
      memory_limit_kb: Number(form.memory_limit_kb) || 262144,
      tags: problem.tags,
      examples: [],
      supported_languages: ['Python', 'C++', 'Java'],
      starter_templates: {
        Python: form.python_template,
        'C++': form.cpp_template,
        Java: form.java_template,
      },
      source_type: form.source_type.trim() || 'manual',
      source: form.source.trim() || '手工',
      frequency: form.frequency.trim() || '中',
      year: form.year.trim() ? Number(form.year) : null,
      source_ref: form.source_ref.trim(),
      external_id: form.external_id.trim(),
      status: form.status,
      test_cases: [
        {
          case_type: 'hidden',
          stdin_text: form.hidden_input || 'hidden\n1 2 3',
          expected_output_text: form.hidden_output || '0',
          sort_order: 1,
        },
      ],
    }
  }

  const handleSave = async () => {
    setIsSaving(true)
    setSaveError('')
    setSaveSuccess('')

    try {
      const updated = await updateProblem(problem.id, buildPayload())
      onProblemSaved(updated)
      setSaveSuccess('更改已保存')
    } catch (error) {
      setSaveError(error instanceof Error ? error.message : '保存失败')
    } finally {
      setIsSaving(false)
    }
  }

  const handleAnalyzeProblem = async () => {
    setIsAnalyzingProblem(true)
    setAnalysisError('')

    try {
      const result = await analyzeProblem({ problem_id: problem.id })
      setProblemAnalysis(result)
    } catch (error) {
      setAnalysisError(error instanceof Error ? error.message : '分析失败')
    } finally {
      setIsAnalyzingProblem(false)
    }
  }

  const handleAskProblem = async () => {
    const question = chatQuestion.trim()
    if (!question) {
      return
    }

    setIsChatting(true)
    setChatError('')
    setChatQuestion('')
    const nextMessages: ProblemChatMessage[] = [...chatMessages, { role: 'user', content: question }]
    setChatMessages(nextMessages)

    try {
      const result = await chatProblem({ problem_id: problem.id, messages: chatMessages, question })
      setChatMessages([...nextMessages, { role: 'assistant', content: [result.summary, ...result.bullets].filter(Boolean).join('\n') }])
    } catch (error) {
      setChatError(error instanceof Error ? error.message : '问答失败')
    } finally {
      setIsChatting(false)
    }
  }

  return (
    <section className="detail-layout">
      <div className="page-header">
        <div>
          <h1>{problem.title}</h1>
          <p>题目详情、属性信息与 AI 做题思路。</p>
        </div>
        <div className="button-row">
          <button type="button" className="button ghost" onClick={onBack}>
            返回题库
          </button>
          <button type="button" className="button primary" onClick={onStartTraining}>
            进入训练
          </button>
        </div>
      </div>

      <div className="problem-edit-actions">
        <button type="button" className="button primary" disabled={isSaving} onClick={() => void handleSave()}>
          {isSaving ? '保存中...' : '保存更改'}
        </button>
        {saveSuccess ? <span className="save-success-text">{saveSuccess}</span> : null}
        {saveError ? <span className="save-error-text">保存失败：{saveError}</span> : null}
      </div>

      <div className="problem-overview-grid">
        <article className="detail-card problem-statement-card">
          <h2>题面</h2>
          <MarkdownRenderer className="problem-markdown" markdown={problem.statement_markdown} />
        </article>

        <aside className="detail-card">
          <h2>题目属性</h2>
          <div className="settings-form-grid problem-edit-grid">
            <label className="settings-field">
              <span>题型</span>
              <select value={form.category_slug} onChange={(event) => handleFieldChange('category_slug', event.target.value)}>
                {form.category_slug && categories.every((item) => item.slug !== form.category_slug) ? (
                  <option value={form.category_slug}>{categoryName || form.category_slug}</option>
                ) : null}
                {categories.map((item) => (
                  <option key={item.slug} value={item.slug}>
                    {item.name}
                  </option>
                ))}
              </select>
            </label>
            <label className="settings-field">
              <span>公司</span>
              <select value={form.company} onChange={(event) => handleFieldChange('company', event.target.value)}>
                {form.company && companies.every((item) => item.abbreviation !== form.company) ? <option value={form.company}>{form.company}</option> : null}
                {companies.map((item) => (
                  <option key={item.id} value={item.abbreviation}>
                    {item.abbreviation}
                  </option>
                ))}
              </select>
            </label>
            <label className="settings-field">
              <span>难度</span>
              <select value={form.difficulty} onChange={(event) => handleFieldChange('difficulty', event.target.value)}>
                <option value="Easy">Easy</option>
                <option value="Medium">Medium</option>
                <option value="Hard">Hard</option>
              </select>
            </label>
            <label className="settings-field">
              <span>频率</span>
              <select value={form.frequency} onChange={(event) => handleFieldChange('frequency', event.target.value)}>
                <option value="高">高</option>
                <option value="中">中</option>
                <option value="低">低</option>
              </select>
            </label>
            <label className="settings-field">
              <span>年度</span>
              <input value={form.year} onChange={(event) => handleFieldChange('year', event.target.value)} />
            </label>
            <label className="settings-field">
              <span>来源</span>
              <select value={form.source} onChange={(event) => handleFieldChange('source', event.target.value)}>
                <option value="牛客">牛客</option>
                <option value="Leetcode">Leetcode</option>
                <option value="手工">手工</option>
                <option value="AI派生">AI派生</option>
              </select>
            </label>
            <label className="settings-field">
              <span>最新状态</span>
              <select value={form.status} onChange={(event) => handleFieldChange('status', event.target.value)}>
                <option value="未开始">未开始</option>
                <option value="已通过">已通过</option>
                <option value="待复盘">待复盘</option>
                <option value="待修正">待修正</option>
              </select>
            </label>
            <label className="settings-field">
              <span>时间限制 (ms)</span>
              <input value={form.time_limit_ms} onChange={(event) => handleFieldChange('time_limit_ms', event.target.value)} />
            </label>
            <label className="settings-field">
              <span>空间限制 (KB)</span>
              <input value={form.memory_limit_kb} onChange={(event) => handleFieldChange('memory_limit_kb', event.target.value)} />
            </label>
          </div>
        </aside>
      </div>

      <article className="detail-card">
        <div className="ai-card-header">
          <div>
            <h2>高级设置</h2>
            <p>隐藏测试用例与各语言代码模板。</p>
          </div>
          <button type="button" className="button ghost" onClick={() => setShowAdvanced((prev) => !prev)}>
            {showAdvanced ? '收起' : '展开'}
          </button>
        </div>
        {showAdvanced ? (
          <div className="settings-form-grid create-problem-grid">
            <label className="settings-field settings-field-full">
              <span>隐藏测试输入</span>
              <textarea className="settings-textarea" value={form.hidden_input} onChange={(event) => handleFieldChange('hidden_input', event.target.value)} />
            </label>
            <label className="settings-field settings-field-full">
              <span>隐藏测试输出</span>
              <textarea className="settings-textarea" value={form.hidden_output} onChange={(event) => handleFieldChange('hidden_output', event.target.value)} />
            </label>
            <label className="settings-field settings-field-full">
              <span>Python 模板</span>
              <textarea className="settings-textarea settings-codearea" value={form.python_template} onChange={(event) => handleFieldChange('python_template', event.target.value)} />
            </label>
            <label className="settings-field settings-field-full">
              <span>C++ 模板</span>
              <textarea className="settings-textarea settings-codearea" value={form.cpp_template} onChange={(event) => handleFieldChange('cpp_template', event.target.value)} />
            </label>
            <label className="settings-field settings-field-full">
              <span>Java 模板</span>
              <textarea className="settings-textarea settings-codearea" value={form.java_template} onChange={(event) => handleFieldChange('java_template', event.target.value)} />
            </label>
          </div>
        ) : null}
      </article>

      <article className="detail-card">
        <div className="ai-card-header">
          <div>
            <h2>AI 解题思路分析</h2>
            <p>{buildThinkingSummary(problem, categoryName)}</p>
          </div>
          <button type="button" className="button primary" disabled={isAnalyzingProblem} onClick={() => void handleAnalyzeProblem()}>
            {isAnalyzingProblem ? '分析中...' : problemAnalysis ? '重新分析' : '生成分析'}
          </button>
        </div>
        {analysisError ? <div className="backend-note">题目分析失败：{analysisError}</div> : null}
        {problemAnalysis ? (
          <div className="diagnostic-list ai-analysis-block">
            <div className="diagnostic-item">
              <strong>{problemAnalysis.title}</strong>
              <span>{problemAnalysis.summary}</span>
            </div>
            {problemAnalysis.bullets.map((item) => (
              <div key={item} className="diagnostic-item">
                <span>{item}</span>
              </div>
            ))}
          </div>
        ) : null}

        <div className="problem-chat-panel">
          <div className="ai-card-header">
            <div>
              <h3>解题思路问答</h3>
              <p>围绕题意、算法选择、复杂度证明和边界条件继续追问。</p>
            </div>
          </div>
          <div className="problem-chat-thread">
            {chatMessages.length === 0 ? (
              <div className="empty-panel">可以提问：为什么用 DP？能否贪心？复杂度怎么证明？</div>
            ) : (
              chatMessages.map((message, index) => (
                <div key={`${message.role}-${index}`} className={`chat-message ${message.role}`}>
                  <strong>{message.role === 'user' ? '我' : 'AI 助教'}</strong>
                  <p>{message.content}</p>
                </div>
              ))
            )}
          </div>
          {chatError ? <div className="backend-note">问答失败：{chatError}</div> : null}
          <div className="problem-chat-input-row">
            <input
              value={chatQuestion}
              onChange={(event) => setChatQuestion(event.target.value)}
              placeholder="继续追问这道题的解题思路"
              onKeyDown={(event) => {
                if (event.key === 'Enter') {
                  void handleAskProblem()
                }
              }}
            />
            <button type="button" className="button" disabled={isChatting || !chatQuestion.trim()} onClick={() => void handleAskProblem()}>
              {isChatting ? '回答中...' : '发送'}
            </button>
          </div>
        </div>
      </article>
    </section>
  )
}
