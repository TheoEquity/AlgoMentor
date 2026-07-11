import { useEffect, useState } from 'react'
import {
  createCandidate,
  deleteCandidate,
  fetchCandidates,
  recalcCandidateMatch,
  updateCandidate,
} from '../lib/positionApi'
import type { CandidatePosition } from '../types/position'

type EditState = {
  company_name: string
  title: string
  location: string
  apply_url: string
  degree_requirement: string
}

const emptyEdit: EditState = { company_name: '', title: '', location: '', apply_url: '', degree_requirement: '' }

const SOURCE_LABEL: Record<string, string> = { manual: '手动', site: '官网' }

export function PositionManagementPage() {
  const [positions, setPositions] = useState<CandidatePosition[]>([])
  const [editingId, setEditingId] = useState<number | null>(null)
  const [edit, setEdit] = useState<EditState>(emptyEdit)
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(false)
  const [recalcing, setRecalcing] = useState<number | null>(null)

  const load = () => { fetchCandidates().then(setPositions).catch(() => {}) }
  useEffect(() => { load() }, [])

  const startNew = () => {
    setEditingId(0)
    setEdit(emptyEdit)
    setError('')
  }

  const startEdit = (p: CandidatePosition) => {
    setEditingId(p.id)
    setEdit({
      company_name: p.company_name,
      title: p.title,
      location: p.location,
      apply_url: p.apply_url,
      degree_requirement: p.degree_requirement,
    })
    setError('')
  }

  const cancelEdit = () => {
    setEditingId(null)
    setEdit(emptyEdit)
    setError('')
  }

  const handleSave = async () => {
    const payload = {
      company_name: edit.company_name.trim(),
      title: edit.title.trim(),
      location: edit.location.trim(),
      apply_url: edit.apply_url.trim(),
      degree_requirement: edit.degree_requirement.trim(),
    }
    if (!payload.company_name || !payload.title) {
      setError('公司名称和岗位名称不能为空')
      return
    }

    setError('')
    setLoading(true)
    try {
      if (editingId === 0) {
        await createCandidate(payload)
      } else {
        await updateCandidate(editingId!, payload)
      }
      cancelEdit()
      load()
    } catch (err: unknown) {
      setError(err instanceof Error ? err.message : '操作失败')
    } finally {
      setLoading(false)
    }
  }

  const handleDelete = (id: number) => {
    if (!window.confirm('确认删除该候选岗位？')) return
    void deleteCandidate(id).then(load)
  }

  const handleRecalc = async (pos: CandidatePosition) => {
    if (!pos.resume_id) {
      alert('该岗位未关联简历，无法重算')
      return
    }
    setRecalcing(pos.id)
    try {
      await recalcCandidateMatch(pos.id, pos.resume_id)
      load()
    } catch {
      alert('重算失败')
    } finally {
      setRecalcing(null)
    }
  }

  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter') { e.preventDefault(); void handleSave() }
    if (e.key === 'Escape') cancelEdit()
  }

  const editing = editingId !== null
  const isNew = editingId === 0

  return (
    <section className="recruitment-page">
      <div className="page-header">
        <div>
          <h1>候选列表</h1>
          <p>管理已入库的候选岗位，支持手动添加。</p>
        </div>
        <div className="button-row">
          <button type="button" className="button primary" onClick={startNew} disabled={editing}>
            + 手动添加
          </button>
        </div>
      </div>

      {error && <div className="error-msg" style={{ marginTop: 12 }}>{error}</div>}

      <div className="detail-card" style={{ marginTop: 16 }}>
        <table className="data-table" style={{ tableLayout: 'fixed' }}>
          <thead>
            <tr>
              <th style={{ width: 130 }}>公司</th>
              <th style={{ width: 160 }}>岗位名称</th>
              <th style={{ width: 80 }}>地点</th>
              <th style={{ width: 80 }}>学历</th>
              <th style={{ width: 90 }}>匹配度</th>
              <th style={{ width: 60 }}>来源</th>
              <th style={{ width: 140 }}>操作</th>
            </tr>
          </thead>
          <tbody>
            {editing && isNew && (
              <tr>
                <td>
                  <input value={edit.company_name} onChange={(e) => setEdit((p) => ({ ...p, company_name: e.target.value }))} onKeyDown={handleKeyDown} placeholder="公司名称" style={{ width: '100%' }} />
                </td>
                <td>
                  <input value={edit.title} onChange={(e) => setEdit((p) => ({ ...p, title: e.target.value }))} onKeyDown={handleKeyDown} placeholder="岗位名称" style={{ width: '100%' }} />
                </td>
                <td>
                  <input value={edit.location} onChange={(e) => setEdit((p) => ({ ...p, location: e.target.value }))} onKeyDown={handleKeyDown} placeholder="地点" style={{ width: '100%' }} />
                </td>
                <td>
                  <input value={edit.degree_requirement} onChange={(e) => setEdit((p) => ({ ...p, degree_requirement: e.target.value }))} onKeyDown={handleKeyDown} placeholder="学历" style={{ width: '100%' }} />
                </td>
                <td>-</td>
                <td>-</td>
                <td>
                  <button type="button" className="button primary small" style={{ marginRight: 6 }} disabled={loading} onClick={() => { void handleSave() }}>
                    {loading ? '...' : '保存'}
                  </button>
                  <button type="button" className="button ghost small" onClick={cancelEdit}>取消</button>
                </td>
              </tr>
            )}
            {positions.length === 0 && !editing ? (
              <tr>
                <td colSpan={7} style={{ textAlign: 'center', padding: 32, color: '#6b7280' }}>
                  暂无候选岗位，请从「岗位提取」获取或点击右上角手动添加。
                </td>
              </tr>
            ) : (
              positions.map((p) =>
                editing && editingId === p.id ? (
                  <tr key={p.id}>
                    <td>
                      <input value={edit.company_name} onChange={(e) => setEdit((v) => ({ ...v, company_name: e.target.value }))} onKeyDown={handleKeyDown} style={{ width: '100%' }} />
                    </td>
                    <td>
                      <input value={edit.title} onChange={(e) => setEdit((v) => ({ ...v, title: e.target.value }))} onKeyDown={handleKeyDown} style={{ width: '100%' }} />
                    </td>
                    <td>
                      <input value={edit.location} onChange={(e) => setEdit((v) => ({ ...v, location: e.target.value }))} onKeyDown={handleKeyDown} style={{ width: '100%' }} />
                    </td>
                    <td>
                      <input value={edit.degree_requirement} onChange={(e) => setEdit((v) => ({ ...v, degree_requirement: e.target.value }))} onKeyDown={handleKeyDown} style={{ width: '100%' }} />
                    </td>
                    <td>-</td>
                    <td>-</td>
                    <td>
                      <button type="button" className="button primary small" style={{ marginRight: 6 }} disabled={loading} onClick={() => { void handleSave() }}>
                        {loading ? '...' : '保存'}
                      </button>
                      <button type="button" className="button ghost small" onClick={cancelEdit}>取消</button>
                    </td>
                  </tr>
                ) : (
                  <tr key={p.id}>
                    <td><strong>{p.company_name}</strong></td>
                    <td style={{ overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
                      {p.apply_url ? (
                        <a href={p.apply_url} target="_blank" rel="noreferrer" className="link">{p.title}</a>
                      ) : (
                        p.title
                      )}
                    </td>
                    <td>{p.location || '-'}</td>
                    <td>{p.degree_requirement || '-'}</td>
                    <td>
                      <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
                        <div style={{ flex: 1, height: 6, background: '#e5e7eb', borderRadius: 3, overflow: 'hidden' }}>
                          <div style={{ height: '100%', width: `${p.match_score}%`, background: p.match_score >= 70 ? '#22c55e' : p.match_score >= 40 ? '#f59e0b' : '#ef4444', borderRadius: 3, transition: 'width 0.3s' }} />
                        </div>
                        <span style={{ fontSize: 12, fontWeight: 600, minWidth: 28, textAlign: 'right' }}>{p.match_score}%</span>
                      </div>
                    </td>
                    <td><span className="chip">{SOURCE_LABEL[p.source_type] || p.source_type}</span></td>
                    <td style={{ whiteSpace: 'nowrap' }}>
                      <button type="button" className="button small ghost" onClick={() => startEdit(p)}>编辑</button>
                      <button type="button" className="button small ghost" onClick={() => { recalcing !== p.id && handleRecalc(p) }} disabled={recalcing === p.id}>
                        {recalcing === p.id ? '...' : '重算'}
                      </button>
                      <button type="button" className="button small ghost danger" onClick={() => handleDelete(p.id)}>删除</button>
                    </td>
                  </tr>
                ),
              )
            )}
          </tbody>
        </table>
      </div>
    </section>
  )
}
