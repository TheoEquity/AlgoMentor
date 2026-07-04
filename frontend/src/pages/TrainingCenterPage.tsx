import { useEffect, useState } from 'react'

import { MarkdownRenderer } from '../components/MarkdownRenderer'
import { runAgent } from '../lib/agentApi'
import { getTrainingOverview } from '../lib/trainingApi'
import type { AgentRunResult } from '../types/agent'
import type { TrainingOverviewResponse } from '../types/training'

type TrainingCenterPageProps = {
  onOpenProblem: (problemId: number) => void
}

function verdictClassName(verdict: 'AC' | 'WA' | 'RE' | 'CE' | 'TLE' | 'PENDING'): string {
  switch (verdict) {
    case 'AC':
      return 'ac'
    case 'WA':
      return 'wa'
    case 'RE':
    case 'CE':
    case 'TLE':
    case 'PENDING':
    default:
      return 'review'
  }
}

export function TrainingCenterPage({ onOpenProblem }: TrainingCenterPageProps) {
  const [response, setResponse] = useState<TrainingOverviewResponse | null>(null)
  const [loading, setLoading] = useState(true)
  const [requestError, setRequestError] = useState('')
  const [reloadSeed, setReloadSeed] = useState(0)
  const [coachResult, setCoachResult] = useState<AgentRunResult | null>(null)
  const [isCoachLoading, setIsCoachLoading] = useState(false)
  const [coachError, setCoachError] = useState('')

  useEffect(() => {
    let cancelled = false
    setLoading(true)
    setRequestError('')

    void getTrainingOverview()
      .then((nextResponse) => {
        if (!cancelled) {
          setResponse(nextResponse)
        }
      })
      .catch((error: unknown) => {
        if (!cancelled) {
          setRequestError(error instanceof Error ? error.message : '加载失败')
          setResponse(null)
        }
      })
      .finally(() => {
        if (!cancelled) {
          setLoading(false)
        }
      })

    return () => {
      cancelled = true
    }
  }, [reloadSeed])

  const summary = response?.summary
  const recentItems = response?.recent_items ?? []
  const errorBuckets = response?.error_buckets ?? []
  const recommendations = response?.recommendations ?? []

  const handleCoachAnalysis = async () => {
    setIsCoachLoading(true)
    setCoachError('')
    try {
      const result = await runAgent('coach-agent', {
        context: {
          task: 'training_analysis',
          training_stats: summary || {},
          recent_items: recentItems.slice(0, 10).map((item) => ({
            title: item.title,
            problem_id: item.problem_id,
            verdict: item.verdict,
            language: item.language,
            run_type: item.run_type,
            created_at: item.created_at,
          })),
          error_buckets: errorBuckets,
        },
      })
      setCoachResult(result)
    } catch (error) {
      setCoachError(error instanceof Error ? error.message : '教练分析失败')
    } finally {
      setIsCoachLoading(false)
    }
  }

  return (
    <section className="training-layout">
      <div className="page-header">
        <div>
          <h1>训练中心</h1>
          <p>基于真实提交记录展示最近训练节奏、主要错误分布和下一步练习入口。</p>
        </div>

        <div className="summary-strip" aria-label="训练摘要">
          <span className="summary-pill">训练 {summary?.total_runs ?? 0} 次</span>
          <span className="summary-pill">通过 {summary?.ac_count ?? 0} 次</span>
          <span className="summary-pill">待修正 {summary?.wrong_count ?? 0} 次</span>
          <span className="summary-pill">正式提交 {summary?.submit_count ?? 0} 次</span>
        </div>
      </div>

      {requestError ? (
        <div className="backend-note action-note">
          <span>训练总览加载失败：{requestError}</span>
          <button type="button" className="button" onClick={() => setReloadSeed((current) => current + 1)}>
            重试加载
          </button>
        </div>
      ) : null}

      {loading ? (
        <div className="empty-panel">正在加载训练统计...</div>
      ) : (
        <>
          <article className="detail-card">
            <div className="ai-card-header">
              <div>
                <h2>AI 教练建议 <span className="agent-badge">coach-agent</span></h2>
                <p>综合训练数据，生成个性化训练计划、薄弱点分析和下一轮学习建议。</p>
              </div>
              <button type="button" className="button primary" disabled={isCoachLoading} onClick={() => void handleCoachAnalysis()}>
                {isCoachLoading ? '分析中...' : coachResult ? '重新生成' : '生成训练建议'}
              </button>
            </div>
            {coachError ? <div className="backend-note">教练分析失败：{coachError}</div> : null}
            {coachResult ? (
              <div className="ai-analysis-block">
                <MarkdownRenderer className="problem-markdown" markdown={coachResult.content} />
                <div className="analysis-meta-text" style={{ marginTop: 'var(--space-3)' }}>
                  Token: {coachResult.token_usage?.total_tokens ?? 0} | 迭代: {coachResult.iterations} | 工具调用: {coachResult.tool_calls_trace?.length ?? 0} | 耗时: {coachResult.duration_ms}ms
                </div>
              </div>
            ) : (
              <div className="empty-panel">点击上方按钮，让 AI 教练分析你的训练数据并给出建议。</div>
            )}
          </article>

          <div className="training-overview-grid">
            <section className="settings-card table-card training-card">
              <div className="training-card-header">
                <strong>训练状态</strong>
                <span>最近 20 次提交</span>
              </div>
              <div className="training-highlight-grid">
                <div className="training-highlight-item">
                  <span>主练标签</span>
                  <strong>{summary?.strongest_tag ?? '暂无'}</strong>
                </div>
                <div className="training-highlight-item">
                  <span>主要错误</span>
                  <strong>{summary?.main_error_type ?? '暂无'}</strong>
                </div>
              </div>
            </section>

            <section className="settings-card table-card training-card">
              <div className="training-card-header">
                <strong>错误分布</strong>
                <span>用于判断下一轮训练优先级</span>
              </div>
              <div className="training-bucket-list">
                {errorBuckets.length === 0 ? (
                  <div className="empty-panel">当前没有待修正错误，适合进入二刷阶段。</div>
                ) : (
                  errorBuckets.map((item) => (
                    <div key={item.verdict} className="training-bucket-item">
                      <span className={`status-badge ${verdictClassName(item.verdict)}`}>{item.verdict}</span>
                      <strong>{item.count} 次</strong>
                    </div>
                  ))
                )}
              </div>
            </section>
          </div>

          <div className="training-overview-grid training-overview-grid-wide">
            <section className="table-card training-card">
              <div className="training-card-header training-card-header-padded">
                <strong>最近训练</strong>
                <span>优先关注最近一次 WA / RE / CE 后的修正动作</span>
              </div>
              <div className="table-scroll">
                <table className="problem-table">
                  <thead>
                    <tr>
                      <th>题目</th>
                      <th>语言</th>
                      <th>动作</th>
                      <th>Verdict</th>
                      <th>最近训练</th>
                      <th>操作</th>
                    </tr>
                  </thead>
                  <tbody>
                    {recentItems.map((item) => (
                      <tr key={item.submission_id}>
                        <td>
                          <div className="problem-title">
                            <div>
                              <strong>{item.title}</strong>
                              <div>
                                <span>{item.company}</span>
                              </div>
                            </div>
                          </div>
                        </td>
                        <td>{item.language}</td>
                        <td>{item.run_type === 'submit' ? '正式提交' : '自测运行'}</td>
                        <td>
                          <span className={`status-badge ${verdictClassName(item.verdict)}`}>{item.verdict}</span>
                        </td>
                        <td>{item.created_at.replace('T', ' ').replace('Z', '')}</td>
                        <td>
                          <button type="button" className="link-button" onClick={() => onOpenProblem(item.problem_id)}>
                            打开工作台
                          </button>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </section>

            <section className="table-card training-card">
              <div className="training-card-header training-card-header-padded">
                <strong>继续训练推荐</strong>
                <span>按最近错误密度和训练节奏给出回炉建议</span>
              </div>
              <div className="training-recommendation-list">
                {recommendations.map((item) => (
                  <div key={item.problem_id} className="training-recommendation-item">
                    <div>
                      <strong>{item.title}</strong>
                      <div className="analysis-meta-text">{item.company}</div>
                      <div className="tag-list training-tag-list">
                        {item.tags.map((tag) => (
                          <span key={tag} className="tag-badge">
                            {tag}
                          </span>
                        ))}
                      </div>
                      <p>{item.recommendation_reason}</p>
                    </div>
                    <button type="button" className="button primary" onClick={() => onOpenProblem(item.problem_id)}>
                      继续训练
                    </button>
                  </div>
                ))}
              </div>
            </section>
          </div>
        </>
      )}
    </section>
  )
}
