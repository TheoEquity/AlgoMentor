import { useEffect, useState } from 'react'
import { fetchTrainingPlans, deleteTrainingPlan } from '../lib/trainingPlanApi'
import { getTrainingOverview } from '../lib/trainingApi'
import type { TrainingPlanListItem } from '../types/trainingPlan'
import type { TrainingOverviewResponse } from '../types/training'

type Props = {
  onCreatePlan: () => void
  onOpenPlan: (planId: number) => void
}

export function TrainingPlanListPage({ onCreatePlan, onOpenPlan }: Props) {
  const [plans, setPlans] = useState<TrainingPlanListItem[]>([])
  const [overview, setOverview] = useState<TrainingOverviewResponse | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')

  const loadData = () => {
    setLoading(true)
    setError('')
    void Promise.all([fetchTrainingPlans(), getTrainingOverview()])
      .then(([_plans, _overview]) => {
        setPlans(_plans)
        setOverview(_overview)
      })
      .catch((err: unknown) => setError(err instanceof Error ? err.message : '加载失败'))
      .finally(() => setLoading(false))
  }

  useEffect(() => {
    loadData()
  }, [])

  const handleDelete = async (plan: TrainingPlanListItem) => {
    setError('')
    if (!window.confirm(`确认删除计划「${plan.name}」？`)) return
    try {
      await deleteTrainingPlan(plan.id)
      setPlans((current) => current.filter((item) => item.id !== plan.id))
    } catch (err: unknown) {
      setError(err instanceof Error ? err.message : '删除失败')
    }
  }

  const completionRate = (item: TrainingPlanListItem) =>
    item.total_problems > 0 ? `${Math.round((item.completed_count / item.total_problems) * 100)}%` : '0%'

  const correctRate = (item: TrainingPlanListItem) =>
    item.completed_count > 0 ? `${Math.round((item.correct_count / item.completed_count) * 100)}%` : '--'

  const planTypeLabel = (type: string) => {
    switch (type) {
      case 'comprehensive': return '综合训练'
      case 'derived': return '派生训练'
      case 'review': return '回炉训练'
      default: return type
    }
  }

  if (loading) return <div className="empty-panel">正在加载训练数据...</div>

  return (
    <section className="training-layout">
      <div className="page-header">
        <div>
          <h1>训练中心</h1>
          <p>管理训练计划，按计划刷题，追踪完成率和正确率。</p>
        </div>
        <div className="summary-strip">
          <span className="summary-pill">训练 {overview?.summary.total_runs ?? 0} 次</span>
          <span className="summary-pill">通过 {overview?.summary.ac_count ?? 0} 次</span>
          <span className="summary-pill">待修正 {overview?.summary.wrong_count ?? 0} 次</span>
        </div>
      </div>

      {error ? <div className="backend-note action-note">{error}</div> : null}

      <article className="detail-card">
        <div className="ai-card-header">
          <div>
            <h2>训练计划</h2>
            <p>所有已创建的训练计划，点击操作列进入该计划的题目列表开始训练。</p>
          </div>
          <button type="button" className="button primary" onClick={onCreatePlan}>
            新建计划
          </button>
        </div>

        {plans.length === 0 ? (
          <div className="empty-panel">暂无训练计划，点击"新建计划"创建。</div>
        ) : (
          <div className="table-scroll">
            <table className="problem-table">
              <thead>
                <tr>
                  <th>#</th>
                  <th>创建时间</th>
                  <th>计划名称</th>
                  <th>类型</th>
                  <th>训练时长</th>
                  <th>训练题数</th>
                  <th>完成率</th>
                  <th>正确率</th>
                  <th>操作</th>
                </tr>
              </thead>
              <tbody>
                {plans.map((plan, idx) => (
                  <tr key={plan.id}>
                    <td>{idx + 1}</td>
                    <td>{plan.created_at.slice(0, 10)}</td>
                    <td><strong>{plan.name}</strong></td>
                    <td>{planTypeLabel(plan.plan_type)}</td>
                    <td>{plan.duration_days} 天</td>
                    <td>{plan.total_problems} 题</td>
                    <td>{completionRate(plan)}</td>
                    <td>{correctRate(plan)}</td>
                    <td>
                      <div className="table-actions">
                        <button type="button" className="link-button" onClick={() => onOpenPlan(plan.id)}>
                          开始训练
                        </button>
                        <button type="button" className="icon-danger-button" aria-label={`删除 ${plan.name}`} onClick={() => void handleDelete(plan)}>
                          <svg viewBox="0 0 24 24" aria-hidden="true" focusable="false">
                            <path d="M9 3h6l1 2h4v2H4V5h4l1-2Zm1 6h2v9h-2V9Zm4 0h2v9h-2V9ZM7 9h2l1 11h4l1-11h2l-1.2 13H8.2L7 9Z" />
                          </svg>
                        </button>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </article>
    </section>
  )
}
