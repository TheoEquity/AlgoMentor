import { useCallback, useEffect, useMemo, useState } from 'react'
import { deletePosition, fetchPositions } from '../lib/applicationApi'
import type { JobPosition } from '../types/application'
import { APPLICATION_STATUSES } from '../types/application'

const PAGE_SIZE = 15

interface Props {
  onNavigate: (key: string, params?: Record<string, string>) => void
  resumeId?: number
}

function buildPageNumbers(current: number, total: number): (number | '...')[] {
  if (total <= 7) return Array.from({ length: total }, (_, i) => i + 1)
  if (current <= 3) return [1, 2, 3, 4, 5, '...', total]
  if (current >= total - 2) return [1, '...', total - 4, total - 3, total - 2, total - 1, total]
  return [1, '...', current - 1, current, current + 1, '...', total]
}

const STATUS_BADGE_CLASS: Record<string, string> = {
  '待投递': 'review',
  '简历筛选': 'review',
  '测评': 'wa',
  '笔试': 'wa',
  '面试': 'ac',
  '结束': 'review',
}

export function ApplicationManagementPage({ onNavigate, resumeId }: Props) {
  const [positions, setPositions] = useState<JobPosition[]>([])
  const [loading, setLoading] = useState(true)
  const [search, setSearch] = useState('')
  const [filterStatus, setFilterStatus] = useState('')
  const [page, setPage] = useState(1)

  const loadData = useCallback(() => {
    setLoading(true)
    fetchPositions(resumeId)
      .then(setPositions)
      .catch(() => {})
      .finally(() => setLoading(false))
  }, [resumeId])

  useEffect(() => {
    loadData()
  }, [loadData])

  useEffect(() => { setPage(1) }, [search, filterStatus])

  const filtered = useMemo(() => {
    let list = positions
    if (search) {
      const q = search.toLowerCase()
      list = list.filter((p) =>
        p.company_name.toLowerCase().includes(q) || p.title.toLowerCase().includes(q)
      )
    }
    if (filterStatus) {
      list = list.filter((p) => p.status === filterStatus)
    }
    return list
  }, [positions, search, filterStatus])

  const totalPages = Math.max(1, Math.ceil(filtered.length / PAGE_SIZE))
  const safePage = Math.min(page, totalPages)
  const pageItems = filtered.slice((safePage - 1) * PAGE_SIZE, safePage * PAGE_SIZE)

  const matchColor = (score: number) => {
    if (score >= 80) return 'var(--verdict-ac)'
    if (score >= 60) return 'var(--verdict-wa)'
    if (score > 0) return 'var(--verdict-re)'
    return 'var(--text-muted)'
  }

  const handleDelete = async (id: number, title: string) => {
    if (!window.confirm(`确定删除岗位「${title}」吗？`)) return
    try {
      await deletePosition(id)
      loadData()
    } catch {
      window.alert('删除失败')
    }
  }

  return (
    <section>
      <div className="page-header">
        <h1>投递管理</h1>
        <div className="summary-strip">
          <span className="summary-pill">{filtered.length} 个岗位</span>
          <span className="summary-pill">{safePage} / {totalPages} 页</span>
        </div>
      </div>

      <div className="filter-card" aria-label="岗位筛选">
        <div className="filter-row">
          <label className="filter-control">
            <input
              type="search"
              placeholder="搜索公司或岗位名称"
              value={search}
              onChange={(e) => setSearch(e.target.value)}
            />
          </label>
          <label className="filter-control">
            <select value={filterStatus} onChange={(e) => setFilterStatus(e.target.value)}>
              <option value="">全部状态</option>
              {APPLICATION_STATUSES.map((s) => (
                <option key={s} value={s}>{s}</option>
              ))}
            </select>
          </label>
        </div>
        <div className="toolbar-row">
          <span style={{ flex: 1 }} />
          <div className="button-row">
            <button className="button primary" onClick={() => onNavigate('jobPositionDetail', { mode: 'create' })}>
              新建岗位
            </button>
          </div>
        </div>
      </div>

      <div className="table-card">
        <div className="table-scroll">
          <table className="problem-table">
            <thead>
              <tr>
                <th>行业类别</th>
                <th>公司</th>
                <th>部门</th>
                <th>岗位名称</th>
                <th>截止时间</th>
                <th>匹配度</th>
                <th>当前状态</th>
                <th>状态日期</th>
                <th>备注</th>
                <th>操作</th>
              </tr>
            </thead>
            <tbody>
              {loading ? (
                <tr><td colSpan={10} style={{ textAlign: 'center', color: 'var(--text-muted)', padding: 32 }}>加载中...</td></tr>
              ) : pageItems.length === 0 ? (
                <tr><td colSpan={10} style={{ textAlign: 'center', color: 'var(--text-muted)', padding: 32 }}>暂无岗位，点击右上角「新建岗位」开始</td></tr>
              ) : (
                pageItems.map((pos) => (
                  <tr key={pos.id}>
                    <td>{pos.industry_category || '-'}</td>
                    <td>{pos.company_name}</td>
                    <td>{pos.department || '-'}</td>
                    <td>
                      {pos.job_url ? (
                        <a
                          className="link-button"
                          href={pos.job_url}
                          target="_blank"
                          rel="noopener noreferrer"
                        >
                          {pos.title}
                        </a>
                      ) : (
                        <span>{pos.title}</span>
                      )}
                    </td>
                    <td>{pos.deadline || '-'}</td>
                    <td>
                      {pos.match_score > 0 ? (
                        <span style={{ color: matchColor(pos.match_score), fontWeight: 600 }}>
                          {pos.match_score}%
                        </span>
                      ) : (
                        <span style={{ color: 'var(--text-muted)' }}>-</span>
                      )}
                    </td>
                    <td>
                      <span className={`status-badge ${STATUS_BADGE_CLASS[pos.status] || 'review'}`}>
                        {pos.status}
                      </span>
                    </td>
                    <td>{pos.status_date || '-'}</td>
                    <td style={{ maxWidth: 150, overflow: 'hidden', textOverflow: 'ellipsis' }} title={pos.notes || ''}>
                      {pos.notes || '-'}
                    </td>
                    <td>
                      <div className="table-actions">
                        <button
                          type="button"
                          className="link-button"
                          onClick={() => onNavigate('jobPositionDetail', { mode: 'edit', id: String(pos.id) })}
                        >
                          编辑
                        </button>
                        <button
                          type="button"
                          className="icon-danger-button"
                          aria-label={`删除 ${pos.title}`}
                          onClick={() => handleDelete(pos.id, pos.title)}
                        >
                          <svg viewBox="0 0 24 24" aria-hidden="true" focusable="false">
                            <path d="M9 3h6l1 2h4v2H4V5h4l1-2Zm-3 6h12l-1 12H7L6 9Zm4 2v7h2v-7h-2Zm4 0v7h2v-7h-2Z" />
                          </svg>
                        </button>
                      </div>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>

        <div className="table-footer">
          <span>
            {filtered.length === 0
              ? '暂无岗位'
              : `显示 ${(safePage - 1) * PAGE_SIZE + 1} - ${Math.min(safePage * PAGE_SIZE, filtered.length)} / ${filtered.length} 个岗位`}
          </span>
          <div className="table-footer-actions">
            <button
              className="button ghost"
              disabled={safePage <= 1}
              onClick={() => setPage((p) => Math.max(1, p - 1))}
            >
              上一页
            </button>
            {buildPageNumbers(safePage, totalPages).map((item, i) =>
              item === '...' ? (
                <span key={`ellipsis-${i}`} className="pagination-ellipsis">...</span>
              ) : (
                <button
                  key={item}
                  className={`pagination-page${item === safePage ? ' active' : ''}`}
                  onClick={() => setPage(item)}
                >
                  {item}
                </button>
              )
            )}
            <button
              className="button"
              disabled={safePage >= totalPages}
              onClick={() => setPage((p) => Math.min(totalPages, p + 1))}
            >
              下一页
            </button>
            <span className="pagination-jump">
              跳至
              <input
                className="jump-input"
                defaultValue=""
                onKeyDown={(e) => {
                  if (e.key === 'Enter') {
                    const val = parseInt((e.target as HTMLInputElement).value, 10)
                    if (val >= 1 && val <= totalPages) setPage(val)
                  }
                }}
                onChange={(e) => {
                  e.target.value = e.target.value.replace(/\D/g, '')
                }}
              />
              页
              <button
                className="button ghost"
                onClick={(e) => {
                  const input = (e.target as HTMLElement).previousElementSibling?.previousElementSibling as HTMLInputElement
                  if (input) {
                    const val = parseInt(input.value, 10)
                    if (val >= 1 && val <= totalPages) setPage(val)
                  }
                }}
              >
                GO
              </button>
            </span>
          </div>
        </div>
      </div>
    </section>
  )
}
