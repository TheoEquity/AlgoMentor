import { useEffect, useMemo, useState } from 'react'

import { listReviews } from '../lib/reviewApi'
import { getSubmission } from '../lib/submissionApi'
import type { ReviewItem, ReviewListResponse, ReviewSummary } from '../types/review'
import type { SubmissionResult } from '../types/submission'

type ReviewCenterPageProps = {
  onOpenProblem: (problemId: number) => void
}

const emptySummary: ReviewSummary = {
  total_submissions: 0,
  wrong_submissions: 0,
  ac_submissions: 0,
  top_error_type: null,
}

const emptyItems: ReviewItem[] = []

function verdictClassName(verdict: ReviewItem['verdict']): string {
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

function getAnalysisStatusLabel(status: string): string {
  if (status === 'degraded') {
    return '降级结果'
  }

  if (status === 'streaming') {
    return '流式生成中'
  }

  return '正常结果'
}

function getAnalysisStatusClassName(status: string): string {
  if (status === 'degraded') {
    return 'analysis-status-badge degraded'
  }

  if (status === 'streaming') {
    return 'analysis-status-badge streaming'
  }

  return 'analysis-status-badge completed'
}

export function ReviewCenterPage({ onOpenProblem }: ReviewCenterPageProps) {
  const [response, setResponse] = useState<ReviewListResponse | null>(null)
  const [loading, setLoading] = useState(true)
  const [requestError, setRequestError] = useState('')
  const [wrongOnly, setWrongOnly] = useState(true)
  const [company, setCompany] = useState('all')
  const [tag, setTag] = useState('all')
  const [errorType, setErrorType] = useState<'all' | 'AC' | 'WA' | 'RE' | 'CE' | 'TLE'>('all')
  const [reloadSeed, setReloadSeed] = useState(0)
  const [selectedItem, setSelectedItem] = useState<ReviewItem | null>(null)
  const [selectedSubmission, setSelectedSubmission] = useState<SubmissionResult | null>(null)
  const [detailLoading, setDetailLoading] = useState(false)
  const [detailError, setDetailError] = useState('')

  useEffect(() => {
    let cancelled = false
    setLoading(true)
    setRequestError('')

    void listReviews({
      wrong_only: wrongOnly,
      company,
      tag,
      error_type: errorType,
    })
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
  }, [company, errorType, tag, wrongOnly, reloadSeed])

  const items = response?.items ?? emptyItems
  const summary = response?.summary ?? emptySummary
  const companies = useMemo(() => Array.from(new Set(items.map((item) => item.company))), [items])
  const tags = useMemo(() => Array.from(new Set(items.flatMap((item) => item.tags))), [items])

  useEffect(() => {
    if (!selectedItem) {
      return
    }

    const nextSelected = items.find((item) => item.submission_id === selectedItem.submission_id) ?? null
    setSelectedItem(nextSelected)
    if (!nextSelected) {
      setSelectedSubmission(null)
    }
  }, [items, selectedItem])

  const loadSubmissionDetail = async (item: ReviewItem) => {
    setSelectedItem(item)
    setSelectedSubmission(null)
    setDetailLoading(true)
    setDetailError('')

    try {
      const submission = await getSubmission(item.submission_id)
      setSelectedSubmission(submission)
    } catch (error) {
      setDetailError(error instanceof Error ? error.message : '记录详情加载失败')
    } finally {
      setDetailLoading(false)
    }
  }

  return (
    <section>
      <div className="page-header">
        <div>
          <h1>复盘中心</h1>
          <p>聚合最近提交、错误类型和继续训练入口，形成真实训练闭环。</p>
        </div>

        <div className="summary-strip" aria-label="复盘摘要">
          <span className="summary-pill">提交 {summary.total_submissions} 次</span>
          <span className="summary-pill">错题 {summary.wrong_submissions} 次</span>
          <span className="summary-pill">最近 AC {summary.ac_submissions} 次</span>
          <span className="summary-pill">主要错误 {summary.top_error_type ?? '暂无'}</span>
        </div>
      </div>

      <div className="filter-card" aria-label="复盘筛选">
        <div className="filter-row">
          <label className="filter-control checkbox-control">
            <input type="checkbox" checked={wrongOnly} onChange={(event) => setWrongOnly(event.target.checked)} />
            <span>仅看错题</span>
          </label>

          <label className="filter-control">
            <select value={company} onChange={(event) => setCompany(event.target.value)}>
              <option value="all">全部公司</option>
              {companies.map((item) => (
                <option key={item} value={item}>
                  {item}
                </option>
              ))}
            </select>
          </label>

          <label className="filter-control">
            <select value={tag} onChange={(event) => setTag(event.target.value)}>
              <option value="all">全部标签</option>
              {tags.map((item) => (
                <option key={item} value={item}>
                  {item}
                </option>
              ))}
            </select>
          </label>

          <label className="filter-control">
            <select value={errorType} onChange={(event) => setErrorType(event.target.value as typeof errorType)}>
              <option value="all">全部错误类型</option>
              <option value="WA">WA</option>
              <option value="RE">RE</option>
              <option value="CE">CE</option>
              <option value="TLE">TLE</option>
              <option value="AC">AC</option>
            </select>
          </label>
        </div>
      </div>

      {requestError ? (
        <div className="backend-note action-note">
          <span>复盘列表加载失败：{requestError}</span>
          <button type="button" className="button" onClick={() => setReloadSeed((current) => current + 1)}>
            重试加载
          </button>
        </div>
      ) : null}

      <div className="table-card">
        {loading ? (
          <div className="empty-panel">正在加载最近提交记录...</div>
        ) : items.length === 0 ? (
          <div className="empty-panel">当前筛选条件下还没有可复盘的提交记录。</div>
        ) : (
          <>
            <div className="table-scroll">
              <table className="problem-table review-table">
                <thead>
                  <tr>
                    <th>题目</th>
                    <th>语言</th>
                    <th>动作</th>
                    <th>Verdict</th>
                    <th>错误类型</th>
                    <th>失败摘要</th>
                    <th>最近训练</th>
                    <th>操作</th>
                  </tr>
                </thead>
                <tbody>
                  {items.map((item) => (
                    <tr key={item.submission_id}>
                      <td>
                        <div className="problem-title">
                          <div>
                            <strong>{item.title}</strong>
                            <div className="review-problem-meta">
                              <span>{item.company}</span>
                              <span>{item.category_slug}</span>
                              <span>{item.difficulty}</span>
                            </div>
                          </div>
                        </div>
                      </td>
                      <td>{item.language}</td>
                      <td>{item.run_type === 'submit' ? '正式提交' : '自测运行'}</td>
                      <td>
                        <span className={`status-badge ${verdictClassName(item.verdict)}`}>{item.verdict}</span>
                      </td>
                      <td>
                        <span className={`status-badge ${verdictClassName(item.error_type)}`}>{item.error_type}</span>
                      </td>
                      <td>
                        <div className="review-summary-cell">{item.failed_case_summary}</div>
                      </td>
                      <td>{item.created_at.replace('T', ' ').replace('Z', '')}</td>
                       <td>
                          <button type="button" className="link-button" onClick={() => onOpenProblem(item.problem_id)}>
                            继续训练
                          </button>
                          <button type="button" className="link-button review-detail-button" onClick={() => void loadSubmissionDetail(item)}>
                            查看详情
                          </button>
                        </td>
                      </tr>
                    ))}
                </tbody>
              </table>
            </div>

            <div className="table-footer">
              <span>当前显示 {items.length} 条复盘记录</span>
            </div>
          </>
        )}
      </div>

      {selectedItem ? (
        <div className="table-card review-detail-panel">
          <div className="training-card-header">
            <div>
              <strong>复盘详情</strong>
              <span>
                #{selectedItem.submission_id} / {selectedItem.title} / {selectedItem.created_at.replace('T', ' ').replace('Z', '')}
              </span>
            </div>
            <div className="button-row">
              <button type="button" className="button ghost" onClick={() => setSelectedItem(null)}>
                收起详情
              </button>
              <button type="button" className="button" onClick={() => onOpenProblem(selectedItem.problem_id)}>
                回到题目页
              </button>
            </div>
          </div>

          {detailError ? <div className="backend-note">详情加载失败：{detailError}</div> : null}

          {detailLoading ? (
            <div className="empty-panel">正在加载提交详情...</div>
          ) : selectedSubmission ? (
            <div className="review-detail-grid">
              <div className="review-detail-card">
                <div className="review-detail-metrics">
                  <span className={`status-badge ${verdictClassName(selectedSubmission.verdict)}`}>{selectedSubmission.verdict}</span>
                  <span>{selectedSubmission.language}</span>
                  <span>{selectedSubmission.run_type === 'submit' ? '正式提交' : '自测运行'}</span>
                  <span>{selectedSubmission.runtime_ms} ms</span>
                  <span>{selectedSubmission.memory_kb} KB</span>
                </div>
                <p className="review-detail-summary">{selectedItem.failed_case_summary}</p>
                {selectedSubmission.stderr_output ? <pre className="stderr-card">{selectedSubmission.stderr_output}</pre> : null}
                {selectedSubmission.compiler_output ? <pre className="stderr-card">{selectedSubmission.compiler_output}</pre> : null}
              </div>

              <div className="review-detail-card">
                <strong>错误归因</strong>
                {selectedSubmission.attribution_analysis ? (
                  <div className={getAnalysisStatusClassName(selectedSubmission.attribution_analysis.execution_status)}>
                    {getAnalysisStatusLabel(selectedSubmission.attribution_analysis.execution_status)}
                  </div>
                ) : null}
                <p className="review-detail-summary">
                  {selectedSubmission.attribution_analysis?.summary ?? '当前还没有保存的错误归因，可以回到题目页继续触发。'}
                </p>
                {selectedSubmission.attribution_analysis?.status_reason ? (
                  <div className="backend-note">状态说明：{selectedSubmission.attribution_analysis.status_reason}</div>
                ) : null}
                <div className="diagnostic-list">
                  {(selectedSubmission.attribution_analysis?.bullets ?? []).map((item) => (
                    <div key={item} className="diagnostic-item">
                      <span>{item}</span>
                    </div>
                  ))}
                </div>
              </div>

              <div className="review-detail-card">
                <strong>训练复盘</strong>
                {selectedSubmission.review_analysis ? (
                  <div className={getAnalysisStatusClassName(selectedSubmission.review_analysis.execution_status)}>
                    {getAnalysisStatusLabel(selectedSubmission.review_analysis.execution_status)}
                  </div>
                ) : null}
                <p className="review-detail-summary">
                  {selectedSubmission.review_analysis?.summary ?? '当前还没有保存的训练复盘，可以回到题目页继续触发。'}
                </p>
                {selectedSubmission.review_analysis?.status_reason ? (
                  <div className="backend-note">状态说明：{selectedSubmission.review_analysis.status_reason}</div>
                ) : null}
                <ul className="review-bullet-list">
                  {(selectedSubmission.review_analysis?.bullets ?? []).map((item) => (
                    <li key={item}>{item}</li>
                  ))}
                </ul>
              </div>

              <div className="review-detail-card review-detail-card-full">
                <strong>失败用例与输出</strong>
                <div className="review-detail-case-grid">
                  <div>
                    <span className="analysis-meta-text">失败输入</span>
                    <pre className="output-block">{selectedSubmission.failed_input || '暂无'}</pre>
                  </div>
                  <div>
                    <span className="analysis-meta-text">预期输出</span>
                    <pre className="output-block">{selectedSubmission.failed_expected_output || '暂无'}</pre>
                  </div>
                  <div>
                    <span className="analysis-meta-text">实际输出</span>
                    <pre className="output-block">{selectedSubmission.failed_actual_output || '暂无'}</pre>
                  </div>
                </div>
              </div>
            </div>
          ) : null}
        </div>
      ) : null}

      <div className="backend-note">当前页面使用 <code>/api/v1/review</code> 聚合真实提交记录，并支持错题、公司、标签和错误类型筛选。</div>
    </section>
  )
}
