import { useState, useEffect } from 'react'

import { parseProblemText } from '../lib/analysisApi'
import { createProblem } from '../lib/problemApi'
import { listCompanies } from '../lib/companyApi'
import { listCategories } from '../lib/categoryApi'
import type { Company } from '../types/company'
import type { ProblemCategory } from '../types/problemCategory'
import type { ParsedProblemResult } from '../types/analysis'
import type { ProblemCreatePayload, ProblemLatestStatus } from '../types/problem'
import { MarkdownRenderer } from '../components/MarkdownRenderer'

type CreateTab = 'paste' | 'pdf' | 'image'

type Props = {
  onBack: () => void
  onProblemCreated: (problemId: number) => void
}

type EditableForm = {
  title: string
  company: string
  difficulty: string
  category_slug: string
  statement_markdown: string
  tags_text: string
  time_limit_ms: string
  memory_limit_kb: string
  source: string
  source_type: string
  frequency: string
  year: string
  source_ref: string
  external_id: string
}

function buildForm(parsed: ParsedProblemResult, rawText: string): EditableForm {
  return {
    title: parsed.title || '',
    company: parsed.company || '',
    difficulty: parsed.difficulty || 'Medium',
    category_slug: parsed.category_slug || '',
    statement_markdown: parsed.statement_markdown || rawText.trim(),
    tags_text: parsed.tags.join(', '),
    time_limit_ms: String(parsed.time_limit_ms || 2000),
    memory_limit_kb: String(parsed.memory_limit_kb || 262144),
    source: parsed.source || '手工',
    source_type: parsed.source_type || 'manual',
    frequency: parsed.frequency || '中',
    year: parsed.year ? String(parsed.year) : '',
    source_ref: parsed.source_ref || '',
    external_id: parsed.external_id || '',
  }
}

export function ProblemCreatePage({ onBack, onProblemCreated }: Props) {
  const [activeTab, setActiveTab] = useState<CreateTab>('paste')
  const [rawText, setRawText] = useState('')
  const [isParsing, setIsParsing] = useState(false)
  const [parseError, setParseError] = useState('')
  const [parsed, setParsed] = useState<ParsedProblemResult | null>(null)
  const [form, setForm] = useState<EditableForm | null>(null)

  const [isCreating, setIsCreating] = useState(false)
  const [createError, setCreateError] = useState('')
  const [companies, setCompanies] = useState<Company[]>([])
  const [categories, setCategories] = useState<ProblemCategory[]>([])

  useEffect(() => {
    void listCompanies().then(setCompanies).catch(() => {})
    void listCategories().then(setCategories).catch(() => {})
  }, [])

  const handleParse = async () => {
    if (!rawText.trim()) {
      return
    }
    setIsParsing(true)
    setParseError('')
    try {
      const result = await parseProblemText(rawText)
      setParsed(result)
      setForm(buildForm(result, rawText))
    } catch (error) {
      setParseError(error instanceof Error ? error.message : '解析失败')
    } finally {
      setIsParsing(false)
    }
  }

  const updateForm = (field: keyof EditableForm, value: string) => {
    setForm((current) => (current ? { ...current, [field]: value } : current))
  }

  const handleCreate = async () => {
    if (!form) {
      return
    }
    setIsCreating(true)
    setCreateError('')
    try {
      const tags = form.tags_text
        .split(/[，,]/)
        .map((item) => item.trim())
        .filter(Boolean)

      const examples = parsed?.examples ?? []
      const testCases = examples.length > 0
        ? examples.map((example, index) => ({
            case_type: index === 0 ? ('sample' as const) : ('hidden' as const),
            stdin_text: example.input,
            expected_output_text: example.output,
            sort_order: index + 1,
          }))
        : [{
            case_type: 'hidden' as const,
            stdin_text: 'hidden\n1',
            expected_output_text: '0',
            sort_order: 1,
          }]

      const payload: ProblemCreatePayload = {
        slug: (parsed?.slug && parsed.slug.length >= 3 ? parsed.slug : form.title.replace(/\W+/g, '-').replace(/^-|-$/g, '')) || 'untitled-problem',
        title: form.title || '未命名题目',
        company: form.company || '未知',
        difficulty: (['Easy', 'Medium', 'Hard'] as const).includes(form.difficulty as 'Easy' | 'Medium' | 'Hard') ? form.difficulty as 'Easy' | 'Medium' | 'Hard' : 'Medium',
        category_slug: form.category_slug || 'simulation',
        statement_markdown: form.statement_markdown.length >= 10 ? form.statement_markdown : form.statement_markdown.padEnd(10, ' '),
        constraints_text: '',
        time_limit_ms: Number(form.time_limit_ms) || 2000,
        memory_limit_kb: Number(form.memory_limit_kb) || 262144,
        tags: tags.length > 0 ? tags : ['未分类'],
        examples,
        supported_languages: ['Python', 'C++', 'Java'],
        starter_templates: {
          Python: 'def solve() -> None:\n    pass\n',
          'C++': '#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}\n',
          Java: 'public class Main {\n    public static void main(String[] args) {\n    }\n}\n',
        },
        source_type: form.source_type || 'manual',
        source: form.source || '手工',
        frequency: form.frequency || '中',
        year: form.year.trim() ? Number(form.year) : null,
        source_ref: form.source_ref,
        external_id: form.external_id,
        status: '未开始' as ProblemLatestStatus,
        test_cases: testCases,
      }
      const newProblem = await createProblem(payload)
      onProblemCreated(newProblem.id)
    } catch (error) {
      setCreateError(error instanceof Error ? error.message : '创建失败')
    } finally {
      setIsCreating(false)
    }
  }

  return (
    <section className="detail-layout">
      <div className="page-header">
        <div>
          <h1>新增题目</h1>
          <p>手工粘贴原始题面让 AI 解析为结构化数据，或通过 PDF / 图像导入。</p>
        </div>
        <button type="button" className="button ghost" onClick={onBack}>
          返回题库
        </button>
      </div>

      <div className="workspace-tabs" style={{ marginBottom: 'var(--space-4)' }}>
        <button
          type="button"
          className={`workspace-tab${activeTab === 'paste' ? ' active' : ''}`}
          onClick={() => setActiveTab('paste')}
        >
          手工粘贴
        </button>
        <button
          type="button"
          className={`workspace-tab${activeTab === 'pdf' ? ' active' : ''}`}
          onClick={() => setActiveTab('pdf')}
        >
          PDF 导入
        </button>
        <button
          type="button"
          className={`workspace-tab${activeTab === 'image' ? ' active' : ''}`}
          onClick={() => setActiveTab('image')}
        >
          图像识别
        </button>
      </div>

      {activeTab === 'paste' ? (
        <div>
          <textarea
            className="settings-textarea parse-textarea"
            placeholder="将题目原文（如牛客、Leetcode 页面内容）粘贴到此处，包括标题、描述、输入输出格式、约束条件、样例等..."
            value={rawText}
            onChange={(event) => setRawText(event.target.value)}
          />

          <div style={{ marginTop: 'var(--space-3)', display: 'flex', gap: 'var(--space-3)', alignItems: 'center' }}>
            <button type="button" className="button primary" disabled={isParsing || !rawText.trim()} onClick={() => void handleParse()}>
              {isParsing ? 'AI 解析中...' : 'AI 解析'}
            </button>
            {parseError ? <span className="save-error-text">{parseError}</span> : null}
          </div>

          {form ? (
            <div style={{ marginTop: 'var(--space-5)' }}>
              <div className="problem-edit-actions">
                <button type="button" className="button primary" disabled={isCreating} onClick={() => void handleCreate()}>
                  {isCreating ? '创建中...' : '创建题目'}
                </button>
                {parsed?.analysis ? <span className="save-success-text">{parsed.analysis}</span> : null}
                {createError ? <span className="save-error-text">创建失败：{createError}</span> : null}
              </div>

              <div className="problem-overview-grid" style={{ marginTop: 'var(--space-4)' }}>
                <article className="detail-card problem-statement-card">
                  <label className="settings-field settings-field-full" style={{ marginBottom: 'var(--space-3)' }}>
                    <span>标题</span>
                    <input value={form.title} onChange={(event) => updateForm('title', event.target.value)} />
                  </label>
                  <label className="settings-field settings-field-full" style={{ marginBottom: 'var(--space-3)' }}>
                    <span>题目正文 (Markdown)</span>
                    <textarea
                      className="settings-textarea"
                      rows={16}
                      value={form.statement_markdown}
                      onChange={(event) => updateForm('statement_markdown', event.target.value)}
                    />
                  </label>
                  {form.statement_markdown ? (
                    <>
                      <h3 style={{ marginTop: 'var(--space-3)' }}>预览</h3>
                      <MarkdownRenderer markdown={form.statement_markdown} />
                    </>
                  ) : null}
                </article>

                <aside className="detail-card">
                  <h2>题目属性</h2>
                  <div className="settings-form-grid problem-edit-grid">
                    <label className="settings-field">
                      <span>题型</span>
                      <select value={form.category_slug} onChange={(event) => updateForm('category_slug', event.target.value)}>
                        {form.category_slug && categories.every((item) => item.slug !== form.category_slug) ? (
                          <option value={form.category_slug}>{form.category_slug}</option>
                        ) : null}
                        {categories.map((item) => (
                          <option key={item.slug} value={item.slug}>{item.name}</option>
                        ))}
                      </select>
                    </label>
                    <label className="settings-field settings-field-full">
                      <span>算法标签 (逗号分隔)</span>
                      <input value={form.tags_text} onChange={(event) => updateForm('tags_text', event.target.value)} />
                    </label>
                    <label className="settings-field">
                      <span>公司</span>
                      <select value={form.company} onChange={(event) => updateForm('company', event.target.value)}>
                        {form.company && companies.every((item) => item.name !== form.company) ? (
                          <option value={form.company}>{form.company}</option>
                        ) : null}
                        {companies.map((item) => (
                          <option key={item.id} value={item.name}>{item.name}</option>
                        ))}
                      </select>
                    </label>
                    <label className="settings-field">
                      <span>难度</span>
                      <select value={form.difficulty} onChange={(event) => updateForm('difficulty', event.target.value)}>
                        <option value="Easy">Easy</option>
                        <option value="Medium">Medium</option>
                        <option value="Hard">Hard</option>
                      </select>
                    </label>
                    <label className="settings-field">
                      <span>频率</span>
                      <select value={form.frequency} onChange={(event) => updateForm('frequency', event.target.value)}>
                        <option value="高">高</option>
                        <option value="中">中</option>
                        <option value="低">低</option>
                      </select>
                    </label>
                    <label className="settings-field">
                      <span>年度</span>
                      <input value={form.year} onChange={(event) => updateForm('year', event.target.value)} />
                    </label>
                    <label className="settings-field">
                      <span>来源</span>
                      <select value={form.source} onChange={(event) => updateForm('source', event.target.value)}>
                        <option value="牛客">牛客</option>
                        <option value="Leetcode">Leetcode</option>
                        <option value="手工">手工</option>
                        <option value="AI派生">AI派生</option>
                      </select>
                    </label>
                    <label className="settings-field">
                      <span>最新状态</span>
                      <select value="未开始" disabled>
                        <option value="未开始">未开始</option>
                      </select>
                    </label>
                    <label className="settings-field">
                      <span>时间限制 (ms)</span>
                      <input value={form.time_limit_ms} onChange={(event) => updateForm('time_limit_ms', event.target.value)} />
                    </label>
                    <label className="settings-field">
                      <span>空间限制 (KB)</span>
                      <input value={form.memory_limit_kb} onChange={(event) => updateForm('memory_limit_kb', event.target.value)} />
                    </label>
                  </div>
                </aside>
              </div>
            </div>
          ) : null}
        </div>
      ) : activeTab === 'pdf' ? (
        <div className="detail-card">
          <div className="empty-panel">
            PDF 导入功能即将上线。将支持上传 PDF 文件，自动提取文档中的题目内容并结构化为题目数据。
          </div>
        </div>
      ) : (
        <div className="detail-card">
          <div className="empty-panel">
            图像识别功能即将上线。将支持上传题目截图，通过 OCR 和多模态模型自动提取并结构化题目内容。
          </div>
        </div>
      )}
    </section>
  )
}
