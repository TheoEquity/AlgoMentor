import { useEffect, useRef, useState } from 'react'
import { createCandidate, extractFromSite, fetchPositionDetail } from '../lib/positionApi'
import { requestJSON } from '../lib/http'
import { fetchSites } from '../lib/websiteApi'
import { fetchResume, fetchResumes } from '../lib/resumeApi'
import type { ExtractedPosition } from '../types/position'
import type { CareerSite } from '../types/website'
import type { ResumeDetail, ResumeListItem } from '../types/resume'

const PLACEHOLDER: ExtractedPosition = {
  source_position_id: 0,
  company_name: '-',
  title: '-',
  department: '',
  location: '-',
  apply_url: '',
  degree_requirement: '-',
  deadline: '',
  description: '',
  score: 0,
  reason: '',
}

export function PositionExtractPage() {
  const [sites, setSites] = useState<CareerSite[]>([])
  const [resumeList, setResumeList] = useState<ResumeListItem[]>([])
  const [siteId, setSiteId] = useState<number | null>(null)
  const [resumeId, setResumeId] = useState<number | null>(null)
  const [resumeDetail, setResumeDetail] = useState<ResumeDetail | null>(null)
  const [results, setResults] = useState<ExtractedPosition[]>([])
  const [selected, setSelected] = useState<Set<number>>(new Set())
  const [extracting, setExtracting] = useState(false)
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')
  const [detailLoading, setDetailLoading] = useState(false)
  const [detailData, setDetailData] = useState<Record<string, string> | null>(null)
  const [detailError, setDetailError] = useState('')
  const [showDetail, setShowDetail] = useState(false)
  const detailCache = useRef<Map<number, Record<string, string>>>(new Map())

  useEffect(() => {
    fetchSites().then(setSites).catch(() => {})
    fetchResumes().then(setResumeList).catch(() => {})
  }, [])

  useEffect(() => {
    if (!resumeId) { setResumeDetail(null); return }
    fetchResume(resumeId).then(setResumeDetail).catch(() => setResumeDetail(null))
  }, [resumeId])

  const handleExtract = async () => {
    if (!siteId || !resumeId) { setError('请选择官网和简历'); return }
    setError('')
    setExtracting(true)
    setResults([])
    setSelected(new Set())
    const site = sites.find(s => s.id === siteId)
    if (site && site.position_count === 0) {
      setError('正在抓取岗位数据，请稍候...')
      try {
        await requestJSON(`/career-sites/${siteId}/scrape`, { method: 'POST' })
        setError('')
      } catch {
        setError('抓取失败，请重试')
        setExtracting(false)
        return
      }
    }
    try {
      const data = await extractFromSite(siteId, resumeId)
      setResults(data?.results || [])
    } catch (err: unknown) {
      setError(err instanceof Error ? err.message : '提取失败')
    } finally {
      setExtracting(false)
    }
  }

  const handleSelect = (idx: number) => {
    setSelected((prev) => {
      const next = new Set(prev)
      if (next.has(idx)) {
        next.delete(idx)
      } else {
        next.add(idx)
      }
      return next
    })
  }

  const handleBatchConfirm = async () => {
    if (selected.size === 0) return
    setLoading(true)
    let added = 0
    for (const idx of selected) {
      try {
        const r = results[idx]
        if (!r) continue
        await createCandidate({
          resume_id: resumeId!,
          company_name: r.company_name,
          title: r.title,
          location: r.location,
          description: r.description,
          apply_url: r.apply_url,
          degree_requirement: r.degree_requirement,
          match_score: r.score,
          match_reason: r.reason,
          site_id: siteId!,
          source_position_id: r.source_position_id,
        })
        added++
      } catch { /* skip duplicates */ }
    }
    setLoading(false)
    setResults((prev) => prev.filter((_, i) => !selected.has(i)))
    setSelected(new Set())
    alert(`已入库 ${added} 个岗位`)
  }

  const handleShowDetail = async (row: ExtractedPosition) => {
    if (!siteId) return
    setShowDetail(true)
    setDetailError('')
    const cached = detailCache.current.get(row.source_position_id)
    if (cached) {
      setDetailLoading(false)
      setDetailData(cached)
      return
    }
    setDetailLoading(true)
    setDetailData(null)
    try {
      const data = await fetchPositionDetail(siteId, row.title, row.company_name, row.source_position_id)
      const dataObj = data as unknown as Record<string, string>
      detailCache.current.set(row.source_position_id, dataObj)
      setDetailData(dataObj)
      setDetailLoading(false)
    } catch (err: unknown) {
      setDetailLoading(false)
      setDetailError(err instanceof Error ? err.message : '获取详情失败')
    }
  }

  const positionType = resumeDetail?.position_type || ''
  const positionCategory = resumeDetail?.position_category || ''
  const positionKeywords = resumeDetail?.position_keywords || []

  const cityName = (loc: string) => {
    if (!loc) return ''
    const m = loc.match(/([\u4e00-\u9fff]+?)(市|省|区|县|州)/)
    return m ? m[1] + m[2] : loc.slice(0, 4)
  }

  const hasResults = results.length > 0

  const rows: (ExtractedPosition | null)[] = []
  for (let i = 0; i < 5; i++) {
    rows.push(hasResults ? (results[i] || null) : PLACEHOLDER)
  }

  return (
    <section className="recruitment-page">
      <div className="page-header">
        <div>
          <h1>岗位提取</h1>
          <p>从官网 AI 提取并匹配岗位，选中后批量入库。</p>
        </div>
      </div>

      {error && <div className="error-msg" style={{ marginTop: 12 }}>{error}</div>}

      <div className="detail-card" style={{ marginTop: 16 }}>
        <div style={{ display: 'flex', gap: 16, alignItems: 'flex-end', flexWrap: 'wrap' }}>
          <label className="field" style={{ flex: '1 1 160px' }}>
            <span>选择官网</span>
            <select value={siteId ?? ''} onChange={(e) => setSiteId(e.target.value ? Number(e.target.value) : null)}>
              <option value="">请选择</option>
              {sites.map((s) => (
                <option key={s.id} value={s.id}>{s.company_name}</option>
              ))}
            </select>
          </label>
          <label className="field" style={{ flex: '1 1 150px' }}>
            <span>选择简历</span>
            <select value={resumeId ?? ''} onChange={(e) => setResumeId(e.target.value ? Number(e.target.value) : null)}>
              <option value="">请选择</option>
              {resumeList.map((r) => (
                  <option key={r.id} value={r.id}>{r.name || `简历 #${r.id}`}</option>
                ))}
            </select>
          </label>
          <label className="field" style={{ flex: '1 1 130px' }}>
            <span>岗位性质</span>
            <input value={positionType} readOnly placeholder="自动带出" />
          </label>
          <label className="field" style={{ flex: '1 1 130px' }}>
            <span>岗位类别</span>
            <input value={positionCategory} readOnly placeholder="自动带出" />
          </label>
          <label className="field" style={{ flex: '1 1 180px' }}>
            <span>岗位关键词</span>
            <input value={positionKeywords.join('、')} readOnly placeholder="自动带出" />
          </label>
          <div style={{ paddingBottom: 4 }}>
            <button
              type="button"
              className="button primary"
              disabled={extracting || !siteId || !resumeId}
              onClick={() => { void handleExtract() }}
            >
              {extracting ? '提取中...' : '开始提取'}
            </button>
          </div>
        </div>

        <div style={{ marginTop: 16 }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 8 }}>
            <strong>
              提取结果 {hasResults && <span style={{ fontWeight: 400, fontSize: 14, color: '#6b7280' }}>({results.length} 个岗位)</span>}
              {extracting && <span style={{ fontWeight: 400, fontSize: 14, color: '#6b7280', marginLeft: 8 }}>AI 匹配中...</span>}
            </strong>
            {hasResults && (
              <button
                type="button"
                className="button primary"
                disabled={loading || selected.size === 0}
                onClick={() => { void handleBatchConfirm() }}
              >
                {loading ? '入库中...' : `批量入库 (${selected.size})`}
              </button>
            )}
          </div>
          <table className="data-table" style={{ tableLayout: 'fixed' }}>
            <thead>
              <tr>
                <th style={{ width: 42 }} />
                <th style={{ width: 100 }}>公司</th>
                <th style={{ width: 90 }}>部门</th>
                <th style={{ width: 80 }}>地点</th>
                <th style={{ width: 200 }}>岗位名称</th>
                <th style={{ width: 75 }}>学历要求</th>
                <th style={{ width: 80 }}>截止时间</th>
                <th style={{ width: 85 }}>匹配度</th>
                <th style={{ width: 55 }}>详情</th>
              </tr>
            </thead>
            <tbody>
              {rows.map((r, idx) => {
                if (!r) return <tr key={idx}><td colSpan={9} style={{ color: '#9ca3af', textAlign: 'center' }}>-</td></tr>
                return (
                  <tr key={idx} style={{ background: selected.has(idx) ? '#eff6ff' : undefined }}>
                    <td>
                      <input type="checkbox" checked={selected.has(idx)} onChange={() => handleSelect(idx)} />
                    </td>
                    <td>{r.company_name}</td>
                    <td>{r.department}</td>
                    <td>{cityName(r.location)}</td>
                    <td style={{ overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
                      {r.apply_url ? (
                        <a href={r.apply_url} target="_blank" rel="noreferrer" className="link">{r.title}</a>
                      ) : r.title}
                    </td>
                    <td>{r.degree_requirement}</td>
                    <td>{r.deadline}</td>
                    <td>
                      <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
                        <div style={{ flex: 1, height: 6, background: '#e5e7eb', borderRadius: 3, overflow: 'hidden' }}>
                          <div style={{ height: '100%', width: `${r.score}%`, background: r.score >= 70 ? '#22c55e' : r.score >= 40 ? '#f59e0b' : '#ef4444', borderRadius: 3 }} />
                        </div>
                        <span style={{ fontSize: 12, fontWeight: 600, minWidth: 28, textAlign: 'right' }}>{r.score}%</span>
                      </div>
                    </td>
                    <td style={{ whiteSpace: 'nowrap' }}>
                      <button
                        type="button"
                        className="link"
                        style={{ border: 'none', background: 'none', cursor: 'pointer', padding: 0 }}
                        onClick={() => { void handleShowDetail(r) }}
                      >
                        详情
                      </button>
                    </td>
                  </tr>
                )
              })}
            </tbody>
          </table>
        </div>
      </div>

      {showDetail && (
        <div className="modal-overlay" onClick={() => setShowDetail(false)}>
          <div className="modal-content" style={{ maxWidth: 680, maxHeight: '80vh', overflow: 'auto', padding: 'var(--space-4)' }} onClick={e => e.stopPropagation()}>
            <div className="modal-header" style={{ paddingLeft: 0, paddingRight: 0, paddingTop: 0 }}>
              <h2>岗位详情</h2>
              <button type="button" className="button secondary" onClick={() => setShowDetail(false)}>关闭</button>
            </div>
            {detailLoading ? (
              <p style={{ color: '#6b7280' }}>加载中...</p>
            ) : detailData ? (
              <div style={{ display: 'flex', flexDirection: 'column', gap: 14 }}>
                <div><strong>岗位名称：</strong>{detailData.title}</div>
                <div><strong>公司：</strong>{detailData.company}</div>
                <div><strong>地点：</strong>{detailData.location}</div>
                <div><strong>学历要求：</strong>{detailData.degree_requirement}</div>
                <div>
                  <strong>岗位职责：</strong>
                  <pre style={{ margin: '4px 0 0', whiteSpace: 'pre-wrap', fontFamily: 'inherit', fontSize: 14, lineHeight: 1.6 }}>{detailData.description}</pre>
                </div>
                <div>
                  <strong>任职资格：</strong>
                  <pre style={{ margin: '4px 0 0', whiteSpace: 'pre-wrap', fontFamily: 'inherit', fontSize: 14, lineHeight: 1.6 }}>{detailData.requirements}</pre>
                </div>
                {detailData.priority && (
                  <div>
                    <strong>优先条件：</strong>
                    <pre style={{ margin: '4px 0 0', whiteSpace: 'pre-wrap', fontFamily: 'inherit', fontSize: 14, lineHeight: 1.6 }}>{detailData.priority}</pre>
                  </div>
                )}
                {detailData.deadline && <div><strong>截止时间：</strong>{detailData.deadline}</div>}
                {detailData.apply_url && (
                  <div><strong>链接：</strong><a href={detailData.apply_url} target="_blank" rel="noreferrer" className="link">{detailData.apply_url}</a></div>
                )}
              </div>
            ) : (
              <p style={{ color: '#ef4444' }}>{detailError || '加载失败'}</p>
            )}
          </div>
        </div>
      )}
    </section>
  )
}
