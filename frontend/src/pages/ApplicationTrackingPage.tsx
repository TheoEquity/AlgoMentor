import { useEffect, useState } from 'react'
import { deleteApplication, fetchApplicationStats, fetchApplications, updateApplication } from '../lib/applicationApi'
import type { ApplicationStats, JobApplication } from '../types/application'

const STATUS_OPTIONS = [
  { value: 'pending_apply', label: '待投递' },
  { value: 'applied', label: '已投递' },
  { value: 'screening_pass', label: '筛选通过' },
  { value: 'written_test', label: '笔试' },
  { value: 'interviewing', label: '面试中' },
  { value: 'offered', label: '已 Offer' },
  { value: 'rejected', label: '已拒绝' },
]

const STATUS_LABELS: Record<string, string> = Object.fromEntries(STATUS_OPTIONS.map((s) => [s.value, s.label]))

export function ApplicationTrackingPage() {
  const [applications, setApplications] = useState<JobApplication[]>([])
  const [stats, setStats] = useState<ApplicationStats | null>(null)
  const [filterStatus, setFilterStatus] = useState('')
  const [filterCompany, setFilterCompany] = useState('')
  const [editId, setEditId] = useState<number | null>(null)
  const [editStatus, setEditStatus] = useState('')
  const [editNotes, setEditNotes] = useState('')

  const loadData = () => {
    fetchApplications({ status: filterStatus || undefined, company: filterCompany || undefined })
      .then(setApplications).catch(() => {})
    fetchApplicationStats().then(setStats).catch(() => {})
  }

  useEffect(() => { loadData() }, [filterStatus, filterCompany])

  const handleEdit = (app: JobApplication) => {
    setEditId(app.id)
    setEditStatus(app.status)
    setEditNotes(app.notes || '')
  }

  const handleSave = async () => {
    if (editId === null) return
    try {
      await updateApplication(editId, { status: editStatus, notes: editNotes })
      setEditId(null)
      loadData()
    } catch {
      alert('更新失败')
    }
  }

  const handleDelete = (appId: number) => {
    if (!window.confirm('确认删除该投递记录？')) return
    void deleteApplication(appId).then(loadData)
  }

  const statCards = stats ? [
    { key: 'total', label: '总计', value: stats.total },
    { key: 'pending_apply', label: '待投递', value: stats.pending_apply },
    { key: 'applied', label: '已投递', value: stats.applied },
    { key: 'screening_pass', label: '筛选通过', value: stats.screening_pass },
    { key: 'written_test', label: '笔试', value: stats.written_test },
    { key: 'interviewing', label: '面试中', value: stats.interviewing },
    { key: 'offered', label: '已 Offer', value: stats.offered },
    { key: 'rejected', label: '已拒绝', value: stats.rejected },
  ] : []

  return (
    <section className="recruitment-page">
      <div className="page-header">
        <div>
          <h1>投递管理</h1>
          <p>追踪所有投递进度，从投递到 Offer 全流程管理。</p>
        </div>
      </div>

      {stats && (
        <div className="stats-row">
          {statCards.map((card) => (
            <div key={card.key} className="stat-card">
              <div className="stat-value">{card.value}</div>
              <div className="stat-label">{card.label}</div>
            </div>
          ))}
        </div>
      )}

      <div className="filter-bar">
        <label>
          状态:
          <select value={filterStatus} onChange={(e) => setFilterStatus(e.target.value)}>
            <option value="">全部</option>
            {STATUS_OPTIONS.map((s) => <option key={s.value} value={s.value}>{s.label}</option>)}
          </select>
        </label>
        <label>
          公司:
          <input value={filterCompany} onChange={(e) => setFilterCompany(e.target.value)} placeholder="搜索公司名" />
        </label>
      </div>

      <table className="data-table">
        <thead>
          <tr>
            <th>公司</th>
            <th>岗位</th>
            <th>简历</th>
            <th>状态</th>
            <th>投递时间</th>
            <th>反馈时间</th>
            <th>操作</th>
          </tr>
        </thead>
        <tbody>
          {applications.length === 0 && (
            <tr><td colSpan={7} className="empty-cell">暂无投递记录</td></tr>
          )}
          {applications.map((app) => (
            <tr key={app.id}>
              <td>{app.company_name}</td>
              <td><strong>{app.position_title}</strong></td>
              <td>{app.resume_name}</td>
              <td>
                <span className={`status-badge status-${app.status}`}>
                  {STATUS_LABELS[app.status] || app.status}
                </span>
              </td>
              <td>{app.applied_at?.slice(0, 10) || '-'}</td>
              <td>{app.feedback_at?.slice(0, 10) || '-'}</td>
              <td>
                <div className="button-row compact">
                  <button className="button small" onClick={() => handleEdit(app)}>编辑</button>
                  <button className="button small danger" onClick={() => handleDelete(app.id)}>删除</button>
                </div>
              </td>
            </tr>
          ))}
        </tbody>
      </table>

      {editId !== null && (
        <div className="modal-overlay" onClick={() => setEditId(null)}>
          <div className="modal-content" onClick={(e) => e.stopPropagation()}>
            <h3>编辑投递状态</h3>
            <label className="field">
              <span>状态</span>
              <select value={editStatus} onChange={(e) => setEditStatus(e.target.value)}>
                {STATUS_OPTIONS.map((s) => <option key={s.value} value={s.value}>{s.label}</option>)}
              </select>
            </label>
            <label className="field">
              <span>备注</span>
              <textarea value={editNotes} onChange={(e) => setEditNotes(e.target.value)} rows={3} placeholder="备注信息" />
            </label>
            <div className="button-row">
              <button className="button" onClick={() => setEditId(null)}>取消</button>
              <button className="button primary" onClick={() => { void handleSave() }}>保存</button>
            </div>
          </div>
        </div>
      )}
    </section>
  )
}
