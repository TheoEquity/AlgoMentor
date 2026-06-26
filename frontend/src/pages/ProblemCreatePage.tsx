import { useState } from 'react'

import { parseProblemText } from '../lib/analysisApi'
import { createProblem } from '../lib/problemApi'
import type { ParsedProblemResult } from '../types/analysis'
import type { ProblemCreatePayload, ProblemLatestStatus } from '../types/problem'
import { MarkdownRenderer } from '../components/MarkdownRenderer'

type CreateTab = 'paste' | 'pdf' | 'image'

type Props = {
  onBack: () => void
  onProblemCreated: (problemId: number) => void
}

export function ProblemCreatePage({ onBack, onProblemCreated }: Props) {
  const [activeTab, setActiveTab] = useState<CreateTab>('paste')
  const [rawText, setRawText] = useState('')
  const [isParsing, setIsParsing] = useState(false)
  const [parseError, setParseError] = useState('')
  const [parsed, setParsed] = useState<ParsedProblemResult | null>(null)

  const [isCreating, setIsCreating] = useState(false)
  const [createError, setCreateError] = useState('')

  const handleParse = async () => {
    if (!rawText.trim()) {
      return
    }
    setIsParsing(true)
    setParseError('')
    try {
      const result = await parseProblemText(rawText)
      setParsed(result)
    } catch (error) {
      setParseError(error instanceof Error ? error.message : '解析失败')
    } finally {
      setIsParsing(false)
    }
  }

  const handleCreate = async () => {
    if (!parsed) {
      return
    }
    setIsCreating(true)
    setCreateError('')
    try {
      const payload: ProblemCreatePayload = {
        slug: parsed.slug || parsed.title.toLowerCase().replace(/\s+/g, '-'),
        title: parsed.title,
        company: parsed.company,
        difficulty: parsed.difficulty as 'Easy' | 'Medium' | 'Hard',
        category_slug: parsed.category_slug || 'simulation',
        statement_markdown: parsed.statement_markdown,
        constraints_text: '',
        time_limit_ms: parsed.time_limit_ms || 2000,
        memory_limit_kb: parsed.memory_limit_kb || 262144,
        tags: parsed.tags,
        examples: parsed.examples,
        supported_languages: ['Python', 'C++', 'Java'],
        starter_templates: {
          Python: 'def solve() -> None:\n    pass\n',
          'C++': '#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}\n',
          Java: 'public class Main {\n    public static void main(String[] args) {\n    }\n}\n',
        },
        source_type: parsed.source_type || 'manual',
        source: parsed.source || '手工',
        frequency: parsed.frequency || '中',
        year: parsed.year,
        source_ref: parsed.source_ref,
        external_id: parsed.external_id,
        status: '未开始' as ProblemLatestStatus,
        test_cases: parsed.examples.map((example, index) => ({
          case_type: index === 0 ? 'sample' : 'hidden',
          stdin_text: example.input,
          expected_output_text: example.output,
          sort_order: index + 1,
        })),
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
            className="settings-textarea"
            rows={14}
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

          {parsed ? (
            <div style={{ marginTop: 'var(--space-5)' }}>
              <article className="detail-card">
                <div className="ai-card-header">
                  <div>
                    <h2>解析预览</h2>
                    <p>{parsed.analysis || 'AI 已从原文中提取题目结构，请确认后创建。'}</p>
                  </div>
                  <button type="button" className="button primary" disabled={isCreating} onClick={() => void handleCreate()}>
                    {isCreating ? '创建中...' : '创建题目'}
                  </button>
                </div>
                {createError ? <div className="backend-note save-error-text" style={{ marginBottom: 0 }}>创建失败：{createError}</div> : null}

                <div className="settings-form-grid problem-edit-grid" style={{ marginTop: 'var(--space-4)' }}>
                  <label className="settings-field">
                    <span>标题</span>
                    <input value={parsed.title} readOnly className="readonly-input" />
                  </label>
                  <label className="settings-field">
                    <span>公司</span>
                    <input value={parsed.company || '(未识别)'} readOnly className="readonly-input" />
                  </label>
                  <label className="settings-field">
                    <span>难度</span>
                    <input value={parsed.difficulty} readOnly className="readonly-input" />
                  </label>
                  <label className="settings-field">
                    <span>题型</span>
                    <input value={parsed.category_slug} readOnly className="readonly-input" />
                  </label>
                  <label className="settings-field">
                    <span>时间限制 (ms)</span>
                    <input value={parsed.time_limit_ms} readOnly className="readonly-input" />
                  </label>
                  <label className="settings-field">
                    <span>空间限制 (KB)</span>
                    <input value={parsed.memory_limit_kb} readOnly className="readonly-input" />
                  </label>
                  <label className="settings-field settings-field-full">
                    <span>标签</span>
                    <input value={parsed.tags.join(', ')} readOnly className="readonly-input" />
                  </label>
                  <label className="settings-field">
                    <span>来源</span>
                    <input value={parsed.source} readOnly className="readonly-input" />
                  </label>
                  <label className="settings-field">
                    <span>年份</span>
                    <input value={parsed.year ?? ''} readOnly className="readonly-input" />
                  </label>
                  <label className="settings-field settings-field-full">
                    <span>来源引用</span>
                    <input value={parsed.source_ref} readOnly className="readonly-input" />
                  </label>
                </div>
              </article>

              <article className="detail-card" style={{ marginTop: 'var(--space-4)' }}>
                <h2>题目正文预览</h2>
                <MarkdownRenderer markdown={parsed.statement_markdown} />
              </article>
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
