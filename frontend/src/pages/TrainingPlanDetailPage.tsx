import { useEffect, useState } from 'react'
import { fetchTrainingPlan, updatePlanItemStatus } from '../lib/trainingPlanApi'
import type { TrainingPlanDetail, TrainingPlanItem } from '../types/trainingPlan'

type Props = {
  planId: number
  onBack: () => void
  onStartTraining: (problemId: number) => void
}

const DIFFICULTY_ORDER = ['Easy', 'Medium', 'Hard']
const STATUS_LABELS: Record<string, string> = { '未开始': '未开始', '已通过': '已通过', '待复盘': '待复盘' }

function difficultyBadge(d: string) {
  const idx = DIFFICULTY_ORDER.indexOf(d)
  if (idx === -1) return <span className="tag-badge">{d || '--'}</span>
  const colors = ['var(--success)', 'var(--warning)', 'var(--danger)']
  return <span className="tag-badge" style={{ background: colors[idx], color: '#fff' }}>{d}</span>
}

export function TrainingPlanDetailPage({ planId, onBack, onStartTraining }: Props) {
  const [plan, setPlan] = useState<TrainingPlanDetail | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')

  const load = () => {
    setLoading(true)
    setError('')
    void fetchTrainingPlan(planId)
      .then(setPlan)
      .catch((e: unknown) => setError(e instanceof Error ? e.message : '加载失败'))
      .finally(() => setLoading(false))
  }

  useEffect(() => { load() }, [planId])

  const handleStatusChange = (item: TrainingPlanItem, newStatus: string) => {
    void updatePlanItemStatus(item.id, newStatus).then(() => {
      load()
    }).catch(() => {})
  }

  const completedCount = plan?.items.filter((i) => i.status !== '未开始').length ?? 0
  const correctCount = plan?.items.filter((i) => i.status === '已通过').length ?? 0
  const total = plan?.total_problems ?? 0

  if (loading) return <div className="empty-panel">正在加载训练计划...</div>
  if (error) return <div className="backend-note action-note">{error}<button type="button" className="button" onClick={load} style={{ marginLeft: 12 }}>重试</button></div>
  if (!plan) return <div className="empty-panel">训练计划不存在</div>

  const planTypeLabel =
    plan.plan_type === 'comprehensive' ? '综合训练' :
      plan.plan_type === 'derived' ? '派生训练' :
        plan.plan_type === 'review' ? '回炉训练' : plan.plan_type

  return (
    <section className="training-layout">
      <div className="page-header">
        <div>
          <button type="button" className="link-button" onClick={onBack}>&larr; 返回计划列表</button>
          <h1 style={{ marginTop: 'var(--space-1)' }}>{plan.name}</h1>
          <p>
            <span className="tag-badge" style={{ marginRight: 8 }}>{planTypeLabel}</span>
            {plan.duration_days} 天 | {total} 题 |
            完成 {completedCount}/{total} ({total > 0 ? Math.round((completedCount / total) * 100) : 0}%) |
            正确 {correctCount}/{completedCount || 1} ({completedCount > 0 ? Math.round((correctCount / completedCount) * 100) : 0}%)
          </p>
        </div>
      </div>

      <article className="detail-card">
        <div className="ai-card-header">
          <div>
            <h2>训练题目列表</h2>
            <p>按顺序完成每道题。完成后可点击"开始训练"进入工作台作答。</p>
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
                <th>状态</th>
                <th>操作</th>
              </tr>
            </thead>
            <tbody>
              {plan.items.map((item, idx) => (
                <tr key={item.id}>
                  <td>{idx + 1}</td>
                  <td>
                    <div>
                      <strong>#{item.problem_id}</strong> {item.title}
                    </div>
                    <div className="tag-list" style={{ marginTop: 4 }}>
                      {item.tags.map((tag) => (
                        <span key={tag} className="tag-badge">{tag}</span>
                      ))}
                    </div>
                  </td>
                  <td>{item.company || '--'}</td>
                  <td>{difficultyBadge(item.difficulty)}</td>
                  <td>{item.category_slug}</td>
                  <td>
                    <select
                      value={item.status}
                      onChange={(e) => handleStatusChange(item, e.target.value)}
                      className="input"
                      style={{ width: 'auto', minWidth: 100 }}
                    >
                      {Object.entries(STATUS_LABELS).map(([val, label]) => (
                        <option key={val} value={val}>{label}</option>
                      ))}
                    </select>
                  </td>
                  <td>
                    <button type="button" className="link-button" onClick={() => onStartTraining(item.problem_id)}>
                      开始训练
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </article>
    </section>
  )
}
