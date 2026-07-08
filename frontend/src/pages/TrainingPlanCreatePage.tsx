import { useState, useCallback } from 'react'
import { previewAiPlan, previewDerivedPlan, previewReviewPlan, createTrainingPlan } from '../lib/trainingPlanApi'
import { listProblems, generateSimilarProblem } from '../lib/problemApi'
import { fetchDerivedProblems } from '../lib/problemApi'
import { runAgent } from '../lib/agentApi'
import { MarkdownRenderer } from '../components/MarkdownRenderer'
import type { AgentRunResult } from '../types/agent'
import type { ProblemListItem } from '../types/problem'
import type { PlanPreview, PlanPreviewProblem } from '../types/trainingPlan'

type Tab = 'ai' | 'derived' | 'review'

type Props = {
  onBack: () => void
  onPlanCreated: () => void
}

const DIFFICULTY_COLORS: Record<string, string> = {
  Easy: 'var(--success)',
  Medium: 'var(--warning)',
  Hard: 'var(--danger)',
}

export function TrainingPlanCreatePage({ onBack, onPlanCreated }: Props) {
  const [activeTab, setActiveTab] = useState<Tab>('ai')

  // Preview
  const [preview, setPreview] = useState<PlanPreview | null>(null)
  const [previewName, setPreviewName] = useState('')
  const [previewDays, setPreviewDays] = useState(7)
  const [previewProblems, setPreviewProblems] = useState<PlanPreviewProblem[]>([])
  const [publishLoading, setPublishLoading] = useState(false)
  const [publishError, setPublishError] = useState('')

  // AI tab
  const [aiResult, setAiResult] = useState<AgentRunResult | null>(null)
  const [aiLoading, setAiLoading] = useState(false)
  const [aiError, setAiError] = useState('')
  const [aiGenerating, setAiGenerating] = useState(false)
  const [aiGenError, setAiGenError] = useState('')

  // Derived tab
  const [derivedSearch, setDerivedSearch] = useState('')
  const [derivedPage, setDerivedPage] = useState(1)
  const [derivedProblems, setDerivedProblems] = useState<ProblemListItem[]>([])
  const [derivedTotal, setDerivedTotal] = useState(0)
  const [derivedLoading, setDerivedLoading] = useState(false)
  const [derivedSearchError, setDerivedSearchError] = useState('')
  const [selectedProblem, setSelectedProblem] = useState<ProblemListItem | null>(null)
  const [derivedList, setDerivedList] = useState<{ id: number; title: string }[]>([])
  const [derivedListLoading, setDerivedListLoading] = useState(false)
  const [derivedListError, setDerivedListError] = useState('')
  const [derivedGenerating, setDerivedGenerating] = useState(false)
  const [derivedGeneratePrompt, setDerivedGeneratePrompt] = useState(false)
  const [derivedGenError, setDerivedGenError] = useState('')

  // Review tab
  const [reviewLoading, setReviewLoading] = useState(false)
  const [reviewError, setReviewError] = useState('')

  const showPreview = (p: PlanPreview) => {
    setPreview(p)
    setPreviewName(p.name)
    setPreviewDays(p.duration_days)
    setPreviewProblems(p.problems)
    setPublishError('')
  }

  const handlePublish = async () => {
    if (previewProblems.length === 0) {
      setPublishError('请至少保留一道题目')
      return
    }
    if (!preview) return
    setPublishLoading(true)
    setPublishError('')
    try {
      const plan = await createTrainingPlan({
        name: previewName.trim() || preview.name,
        plan_type: preview.plan_type,
        duration_days: previewDays,
        problem_ids: previewProblems.map((p) => p.problem_id),
      })
      onPlanCreated()
    } catch (e) {
      setPublishError(e instanceof Error ? e.message : '创建计划失败')
    } finally {
      setPublishLoading(false)
    }
  }

  const handleCoachAnalysis = useCallback(async () => {
    setAiLoading(true)
    setAiError('')
    try {
      const result = await runAgent('coach-agent', {
        context: {
          task: 'training_analysis',
          training_stats: {},
          recent_items: [],
          error_buckets: [],
        },
      })
      setAiResult(result)
    } catch (e) {
      setAiError(e instanceof Error ? e.message : '分析失败')
    } finally {
      setAiLoading(false)
    }
  }, [])

  const handleAiPreview = useCallback(async (analysisText?: string) => {
    setAiGenerating(true)
    setAiGenError('')
    try {
      const p = await previewAiPlan(analysisText)
      showPreview(p)
    } catch (e) {
      setAiGenError(e instanceof Error ? e.message : '生成预览失败')
    } finally {
      setAiGenerating(false)
    }
  }, [])

  const handleDerivedSearch = useCallback(async (page: number = 1) => {
    setDerivedLoading(true)
    setDerivedSearchError('')
    try {
      const result = await listProblems({
        search: derivedSearch || undefined,
        page,
        pageSize: 10,
      })
      setDerivedProblems(result.items)
      setDerivedTotal(result.total)
      setDerivedPage(page)
    } catch (e) {
      setDerivedSearchError(e instanceof Error ? e.message : '搜索失败')
    } finally {
      setDerivedLoading(false)
    }
  }, [derivedSearch])

  const handleSelectProblem = useCallback(async (problem: ProblemListItem) => {
    setSelectedProblem(problem)
    setDerivedList([])
    setDerivedListLoading(true)
    setDerivedListError('')
    setDerivedGeneratePrompt(false)
    try {
      const items = await fetchDerivedProblems(problem.id)
      setDerivedList(items)
      if (items.length === 0) {
        setDerivedGeneratePrompt(true)
      }
    } catch (e) {
      setDerivedListError(e instanceof Error ? e.message : '加载派生题目失败')
    } finally {
      setDerivedListLoading(false)
    }
  }, [])

  const handleGenerateDerived = useCallback(async (problemId: number) => {
    setDerivedGeneratePrompt(false)
    setDerivedListLoading(true)
    setDerivedListError('')
    try {
      await generateSimilarProblem(problemId)
      const items = await fetchDerivedProblems(problemId)
      setDerivedList(items)
      if (items.length === 0) {
        setDerivedGeneratePrompt(true)
      }
    } catch (e) {
      setDerivedListError(e instanceof Error ? e.message : '生成派生题目失败')
    } finally {
      setDerivedListLoading(false)
    }
  }, [])

  const handleDerivedPreview = useCallback(async () => {
    if (!selectedProblem) return
    setDerivedGenerating(true)
    setDerivedGenError('')
    try {
      const p = await previewDerivedPlan(selectedProblem.id)
      showPreview(p)
    } catch (e) {
      setDerivedGenError(e instanceof Error ? e.message : '生成预览失败')
    } finally {
      setDerivedGenerating(false)
    }
  }, [selectedProblem])

  const handleReviewPreview = useCallback(async () => {
    setReviewLoading(true)
    setReviewError('')
    try {
      const p = await previewReviewPlan()
      showPreview(p)
    } catch (e) {
      setReviewError(e instanceof Error ? e.message : '生成预览失败')
    } finally {
      setReviewLoading(false)
    }
  }, [])

  const tabs: { key: Tab; label: string; desc: string }[] = [
    { key: 'ai', label: 'AI 生成', desc: '由 AI 教练分析训练数据，自动编排综合训练题目' },
    { key: 'derived', label: '派生训练', desc: '选择一道题，找出其所有派生题目组建训练计划' },
    { key: 'review', label: '回炉训练', desc: '按错误密度和训练节奏，推荐 10 道待回炉题目' },
  ]

  const planTypeLabel =
    preview?.plan_type === 'comprehensive' ? '综合训练' :
      preview?.plan_type === 'derived' ? '派生训练' :
        preview?.plan_type === 'review' ? '回炉训练' : ''
  const planTypeSlug =
    preview?.plan_type === 'comprehensive' ? 'comprehensive' :
      preview?.plan_type === 'derived' ? 'derived' :
        preview?.plan_type === 'review' ? 'review' : ''

  return (
    <section className="training-layout">
      <div className="page-header">
        <div>
          <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
            <button type="button" className="link-button" onClick={onBack}>
              &larr; 返回
            </button>
            <h1>新建训练计划</h1>
          </div>
        </div>
      </div>

      <div className="tab-bar">
        {tabs.map((tab) => (
          <button
            key={tab.key}
            type="button"
            className={`tab-button ${activeTab === tab.key ? 'active' : ''}`}
            onClick={() => setActiveTab(tab.key)}
          >
            {tab.label}
          </button>
        ))}
      </div>

      {/* Tab 1: AI */}
      {activeTab === 'ai' && (
        <article className="detail-card" style={{ marginTop: 'var(--space-4)' }}>
          <div className="ai-card-header">
            <div>
              <h2>AI 综合训练 <span className="agent-badge">coach-agent</span></h2>
              <p>AI 教练分析你的训练弱项，自动编排题目生成"综合训练"计划。</p>
            </div>
          </div>

          {aiResult ? (
            <div className="ai-analysis-block">
              <MarkdownRenderer className="problem-markdown" markdown={aiResult.content} />
              <div className="analysis-meta-text" style={{ marginTop: 'var(--space-3)' }}>
                Token: {aiResult.token_usage?.total_tokens ?? 0} | 迭代: {aiResult.iterations} | 耗时: {aiResult.duration_ms}ms
              </div>
              <div style={{ marginTop: 'var(--space-4)' }}>
                <button
                  type="button"
                  className="button primary"
                  disabled={aiGenerating}
                  onClick={() => void handleAiPreview(aiResult.content)}
                >
                  {aiGenerating ? '生成中...' : '按 AI 建议生成训练计划预览'}
                </button>
              </div>
              {aiGenError ? <div className="backend-note" style={{ marginTop: 'var(--space-2)' }}>{aiGenError}</div> : null}
            </div>
          ) : (
            <div style={{ padding: 'var(--space-4)' }}>
              <button
                type="button"
                className="button primary"
                disabled={aiLoading}
                onClick={() => void handleCoachAnalysis()}
              >
                {aiLoading ? '分析中...' : '生成 AI 训练建议'}
              </button>
              {aiError ? <div className="backend-note" style={{ marginTop: 'var(--space-2)' }}>{aiError}</div> : null}
              <div style={{ marginTop: 'var(--space-4)' }}>
                <button
                  type="button"
                  className="button secondary"
                  disabled={aiGenerating}
                  onClick={() => void handleAiPreview()}
                >
                  {aiGenerating ? '生成中...' : '跳过分析，随机编排题目预览'}
                </button>
              </div>
              {aiGenError ? <div className="backend-note" style={{ marginTop: 'var(--space-2)' }}>{aiGenError}</div> : null}
            </div>
          )}
        </article>
      )}

      {/* Tab 2: Derived */}
      {activeTab === 'derived' && (
        <article className="detail-card" style={{ marginTop: 'var(--space-4)' }}>
          <div className="ai-card-header">
            <div>
              <h2>派生训练</h2>
              <p>选择一道原题，系统自动找出其所有 AI 派生题目，组建"派生训练"计划。</p>
            </div>
          </div>

          <div style={{ padding: 'var(--space-4)' }}>
            <div style={{ display: 'flex', gap: '8px', marginBottom: 'var(--space-3)' }}>
              <input
                type="text"
                className="input"
                placeholder="搜索题目..."
                style={{ flex: 1 }}
                value={derivedSearch}
                onChange={(e) => setDerivedSearch(e.target.value)}
                onKeyDown={(e) => { if (e.key === 'Enter') { void handleDerivedSearch() } }}
              />
              <button type="button" className="button" onClick={() => void handleDerivedSearch()}>
                搜索
              </button>
            </div>

            {derivedSearchError ? <div className="backend-note">{derivedSearchError}</div> : null}

            {derivedLoading ? (
              <div className="empty-panel">搜索题目中...</div>
            ) : derivedProblems.length > 0 ? (
              <div className="table-scroll">
                <table className="problem-table">
                  <thead>
                    <tr>
                      <th>ID</th>
                      <th>题目</th>
                      <th>公司</th>
                      <th>难度</th>
                      <th>操作</th>
                    </tr>
                  </thead>
                  <tbody>
                    {derivedProblems.map((p) => (
                      <tr key={p.id}>
                        <td>{p.id}</td>
                        <td><strong>{p.title}</strong></td>
                        <td>{p.company}</td>
                        <td>{p.difficulty}</td>
                        <td>
                          <button
                            type="button"
                            className={`link-button ${selectedProblem?.id === p.id ? 'active' : ''}`}
                            onClick={() => void handleSelectProblem(p)}
                          >
                            {selectedProblem?.id === p.id ? '已选择' : '选择'}
                          </button>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
                {derivedTotal > 10 && (
                  <div className="pagination-bar">
                    <button type="button" className="link-button" disabled={derivedPage <= 1} onClick={() => void handleDerivedSearch(derivedPage - 1)}>
                      上一页
                    </button>
                    <span>第 {derivedPage} / {Math.ceil(derivedTotal / 10)} 页</span>
                    <button type="button" className="link-button" disabled={derivedPage * 10 >= derivedTotal} onClick={() => void handleDerivedSearch(derivedPage + 1)}>
                      下一页
                    </button>
                  </div>
                )}
              </div>
            ) : null}

            {selectedProblem && (
              <div style={{ marginTop: 'var(--space-4)' }}>
                <h3 style={{ marginBottom: 'var(--space-2)' }}>
                  已选原题：#{selectedProblem.id} {selectedProblem.title}
                </h3>
                {derivedListLoading ? (
                  <div className="empty-panel">加载派生题目...</div>
                ) : derivedListError ? (
                  <div className="backend-note">{derivedListError}</div>
                ) : derivedList.length > 0 ? (
                  <>
                    <div className="table-scroll">
                      <table className="problem-table">
                        <thead>
                          <tr>
                            <th>#</th>
                            <th>派生题目</th>
                          </tr>
                        </thead>
                        <tbody>
                          <tr>
                            <td>0</td>
                            <td><strong>{selectedProblem.title}</strong> (原题)</td>
                          </tr>
                          {derivedList.map((d, i) => (
                            <tr key={d.id}>
                              <td>{i + 1}</td>
                              <td><strong>#{d.id}</strong> {d.title}</td>
                            </tr>
                          ))}
                        </tbody>
                      </table>
                    </div>
                    <div style={{ marginTop: 'var(--space-3)' }}>
                      <button
                        type="button"
                        className="button primary"
                        disabled={derivedGenerating}
                        onClick={() => void handleDerivedPreview()}
                      >
                        {derivedGenerating ? '生成预览...' : `使用这 ${derivedList.length + 1} 道题生成训练计划预览`}
                      </button>
                    </div>
                  </>
                ) : derivedGeneratePrompt ? (
                  <div style={{ marginTop: 'var(--space-3)' }}>
                    <div className="empty-panel">该题目暂无派生题目。</div>
                    <button
                      type="button"
                      className="button primary"
                      style={{ marginTop: 'var(--space-2)' }}
                      disabled={derivedListLoading}
                      onClick={() => void handleGenerateDerived(selectedProblem.id)}
                    >
                      {derivedListLoading ? '生成中...' : '自动生成派生题目'}
                    </button>
                  </div>
                ) : null}
                {derivedGenError ? <div className="backend-note" style={{ marginTop: 'var(--space-2)' }}>{derivedGenError}</div> : null}
              </div>
            )}
          </div>
        </article>
      )}

      {/* Tab 3: Review */}
      {activeTab === 'review' && (
        <article className="detail-card" style={{ marginTop: 'var(--space-4)' }}>
          <div className="ai-card-header">
            <div>
              <h2>回炉训练</h2>
              <p>系统根据最近错误密度和训练节奏，自动选出 10 道最需要回炉的题目，组建"回炉训练"计划。</p>
            </div>
          </div>

          <div style={{ padding: 'var(--space-4)' }}>
            <p>回炉训练会根据以下规则从你的提交历史中筛选题目：</p>
            <ul style={{ marginTop: 'var(--space-2)', marginLeft: 'var(--space-4)', lineHeight: 1.8 }}>
              <li>优先选择错误次数最多的题目</li>
              <li>同等错误数下优先最近提交的题目</li>
              <li>每次生成恰好 10 道题</li>
            </ul>

            <div style={{ marginTop: 'var(--space-4)' }}>
              <button
                type="button"
                className="button primary"
                disabled={reviewLoading}
                onClick={() => void handleReviewPreview()}
              >
                {reviewLoading ? '生成中...' : '生成回炉训练计划预览'}
              </button>
            </div>
            {reviewError ? <div className="backend-note" style={{ marginTop: 'var(--space-2)' }}>{reviewError}</div> : null}
          </div>
        </article>
      )}

      {/* Preview section - shown below tabs after generation */}
      {preview && (
        <article className="detail-card" style={{ marginTop: 'var(--space-4)' }}>
          <div className="ai-card-header">
            <div>
              <h2>计划预览 <span className="summary-pill" style={{ marginLeft: 8 }}>{planTypeLabel}</span></h2>
              <p>确认计划名称、训练时长和题目列表后发布。</p>
            </div>
            <div style={{ display: 'flex', gap: '8px' }}>
              <button type="button" className="button" onClick={() => setPreview(null)}>
                放弃
              </button>
              <button
                type="button"
                className="button primary"
                disabled={publishLoading}
                onClick={() => void handlePublish()}
              >
                {publishLoading ? '发布中...' : `发布计划（${previewProblems.length} 题）`}
              </button>
            </div>
          </div>

          {publishError ? <div className="backend-note action-note" style={{ margin: '0 var(--space-4)' }}>{publishError}</div> : null}

          <div style={{ padding: 'var(--space-4)', display: 'flex', gap: 'var(--space-4)', flexWrap: 'wrap' }}>
            <div style={{ flex: 1, minWidth: 200 }}>
              <span className="form-label">计划名称</span>
              <input
                type="text"
                className="input"
                value={previewName}
                onChange={(e) => setPreviewName(e.target.value)}
                style={{ width: '100%' }}
              />
            </div>
            <div style={{ flex: 1, minWidth: 150 }}>
              <span className="form-label">训练时长（天）</span>
              <input
                type="number"
                className="input"
                min={1}
                max={90}
                value={previewDays}
                onChange={(e) => setPreviewDays(Math.max(1, Math.min(90, Number(e.target.value))))}
                style={{ width: '100%' }}
              />
            </div>
          </div>

          <div className="table-scroll">
            <table className="problem-table">
              <thead>
                <tr>
                  <th>#</th>
                  <th>题目</th>
                  <th>公司</th>
                  <th>难度</th>
                  <th>分类</th>
                  <th>操作</th>
                </tr>
              </thead>
              <tbody>
                {previewProblems.map((p, idx) => (
                  <tr key={p.problem_id}>
                    <td>{idx + 1}</td>
                    <td>
                      <div>
                        <strong>#{p.problem_id}</strong> {p.title}
                      </div>
                      <div className="tag-list" style={{ marginTop: 4 }}>
                        {p.tags.map((tag) => (
                          <span key={tag} className="tag-badge">{tag}</span>
                        ))}
                      </div>
                    </td>
                    <td>{p.company || '--'}</td>
                    <td>
                      <span
                        className="tag-badge"
                        style={{
                          background: DIFFICULTY_COLORS[p.difficulty] || 'var(--text-muted)',
                          color: '#fff',
                        }}
                      >
                        {p.difficulty}
                      </span>
                    </td>
                    <td>{p.category_slug}</td>
                    <td>
                      <button
                        type="button"
                        className="icon-danger-button"
                        aria-label={`移除 ${p.title}`}
                        onClick={() => setPreviewProblems((prev) => prev.filter((x) => x.problem_id !== p.problem_id))}
                      >
                        <svg viewBox="0 0 24 24" aria-hidden="true" focusable="false">
                          <path d="M9 3h6l1 2h4v2H4V5h4l1-2Zm1 6h2v9h-2V9Zm4 0h2v9h-2V9ZM7 9h2l1 11h4l1-11h2l-1.2 13H8.2L7 9Z" />
                        </svg>
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </article>
      )}

      <style>{`
        .tab-bar {
          display: flex;
          gap: 0;
          border-bottom: 2px solid var(--border, #e2e8f0);
          margin-top: var(--space-2);
        }
        .tab-button {
          padding: 10px 24px;
          background: none;
          border: none;
          border-bottom: 2px solid transparent;
          margin-bottom: -2px;
          cursor: pointer;
          font-size: 15px;
          color: var(--text-muted, #64748b);
          transition: color 0.2s, border-color 0.2s;
        }
        .tab-button:hover {
          color: var(--text, #1e293b);
        }
        .tab-button.active {
          color: var(--primary, #3b82f6);
          border-bottom-color: var(--primary, #3b82f6);
          font-weight: 600;
        }
        .form-label {
          display: block;
          font-size: 13px;
          color: var(--text-muted, #64748b);
          margin-bottom: 4px;
        }
      `}</style>
    </section>
  )
}
