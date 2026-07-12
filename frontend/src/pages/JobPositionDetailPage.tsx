import { useCallback, useEffect, useState } from 'react'
import {
  createPosition,
  extractFromUrl,
  fetchPosition,
  runMatchAnalysis,
  updatePosition,
} from '../lib/applicationApi'
import { fetchResumes } from '../lib/resumeApi'
import { fetchSites, listIndustryCategories } from '../lib/websiteApi'
import type { JobPositionCreate } from '../types/application'
import type { ResumeListItem } from '../types/resume'
import type { CareerSite, IndustryCategory } from '../types/website'
import {
  APPLICATION_STATUSES,
  POSITION_CATEGORIES,
  POSITION_TYPES,
} from '../types/application'

interface Props {
  mode: 'create' | 'edit'
  positionId?: number
  onBack: () => void
  resumeId?: number
}

export function JobPositionDetailPage({ mode, positionId, onBack, resumeId: initialResumeId }: Props) {
  const [loading, setLoading] = useState(false)
  const [saving, setSaving] = useState(false)
  const [extracting, setExtracting] = useState(false)
  const [analyzing, setAnalyzing] = useState(false)

  const [resumes, setResumes] = useState<ResumeListItem[]>([])
  const [sites, setSites] = useState<CareerSite[]>([])
  const [industryCategories, setIndustryCategories] = useState<IndustryCategory[]>([])

  const [resumeId, setResumeId] = useState(initialResumeId || 0)
  const [companyName, setCompanyName] = useState('')
  const [department, setDepartment] = useState('')
  const [title, setTitle] = useState('')
  const [location, setLocation] = useState('')
  const [positionType, setPositionType] = useState('')
  const [positionCategory, setPositionCategory] = useState('')
  const [industryCategory, setIndustryCategory] = useState('')
  const [jobUrl, setJobUrl] = useState('')
  const [publishDate, setPublishDate] = useState('')
  const [deadline, setDeadline] = useState('')

  const [jobDescription, setJobDescription] = useState('')
  const [jobRequirements, setJobRequirements] = useState('')
  const [jobPreferences, setJobPreferences] = useState('')

  const [status, setStatus] = useState('待投递')
  const [statusDate, setStatusDate] = useState('')
  const [notes, setNotes] = useState('')
  const [applyChannel, setApplyChannel] = useState('')

  const [matchScore, setMatchScore] = useState(0)
  const [matchDetail, setMatchDetail] = useState('')
  const [matchAdvice, setMatchAdvice] = useState('')

  const [matchDetailParsed, setMatchDetailParsed] = useState<Record<string, { score: number; comment: string }>>({})

  useEffect(() => {
    fetchResumes().then(setResumes).catch(() => {})
    fetchSites().then(setSites).catch(() => {})
    listIndustryCategories().then(setIndustryCategories).catch(() => {})
    if (mode === 'edit' && positionId) {
      setLoading(true)
      fetchPosition(positionId)
        .then((pos) => {
          setResumeId(pos.resume_id)
          setCompanyName(pos.company_name)
          setDepartment(pos.department)
          setTitle(pos.title)
          setLocation(pos.location)
          setPositionType(pos.position_type)
          setPositionCategory(pos.position_category)
          setIndustryCategory(pos.industry_category)
          setJobUrl(pos.job_url)
          setPublishDate(pos.publish_date)
          setDeadline(pos.deadline)
          setJobDescription(pos.job_description)
          setJobRequirements(pos.job_requirements)
          setJobPreferences(pos.job_preferences)
          setStatus(pos.status)
          setStatusDate(pos.status_date)
          setNotes(pos.notes)
          setApplyChannel(pos.apply_channel)
          setMatchScore(pos.match_score)
          setMatchDetail(pos.match_detail)
          setMatchAdvice(pos.match_advice)
          if (pos.match_detail) {
            try {
              setMatchDetailParsed(JSON.parse(pos.match_detail))
            } catch {}
          }
        })
        .catch(() => window.alert('加载岗位详情失败'))
        .finally(() => setLoading(false))
    }
  }, [mode, positionId])

  const handleExtract = useCallback(async () => {
    if (!jobUrl) {
      window.alert('请先填写岗位描述 URL 地址')
      return
    }
    setExtracting(true)
    try {
      const result = await extractFromUrl(jobUrl)
      if (result.title) setTitle((prev) => prev || result.title)
      if (result.department) setDepartment((prev) => prev || result.department)
      if (result.location) setLocation((prev) => prev || result.location)
      if (result.deadline) setDeadline((prev) => prev || result.deadline)
      if (result.job_description) setJobDescription(result.job_description)
      if (result.job_requirements) setJobRequirements(result.job_requirements)
      if (result.job_preferences) setJobPreferences(result.job_preferences)
      window.alert('提取完成')
    } catch (e: any) {
      window.alert(`提取失败: ${e?.message || e}`)
    } finally {
      setExtracting(false)
    }
  }, [jobUrl])

  const handleMatch = useCallback(async () => {
    if (mode !== 'edit' || !positionId) {
      window.alert('请先保存岗位后再运行匹配分析')
      return
    }
    if (!resumeId) {
      window.alert('请选择简历')
      return
    }
    setAnalyzing(true)
    try {
      const result = await runMatchAnalysis(positionId, resumeId)
      setMatchScore(result.match_score)
      setMatchDetail(result.match_detail)
      setMatchAdvice(result.match_advice)
      try {
        setMatchDetailParsed(JSON.parse(result.match_detail))
      } catch {
        setMatchDetailParsed({})
      }
    } catch (e: any) {
      window.alert(`分析失败: ${e?.message || e}`)
    } finally {
      setAnalyzing(false)
    }
  }, [mode, positionId, resumeId])

  const handleSave = useCallback(async () => {
    if (!companyName.trim() || !title.trim()) {
      window.alert('公司名称和岗位名称不能为空')
      return
    }
    setSaving(true)
    try {
      if (mode === 'create') {
        const payload: JobPositionCreate = {
          resume_id: resumeId || 0,
          company_name: companyName.trim(),
          department,
          title: title.trim(),
          location,
          position_type: positionType,
          position_category: positionCategory,
          industry_category: industryCategory,
          job_url: jobUrl,
          publish_date: publishDate,
          deadline,
          job_description: jobDescription,
          job_requirements: jobRequirements,
          job_preferences: jobPreferences,
          status,
          status_date: statusDate,
          notes,
          apply_channel: applyChannel,
          match_score: matchScore,
          match_detail: matchDetail,
          match_advice: matchAdvice,
        }
        await createPosition(payload)
      } else if (positionId) {
        await updatePosition(positionId, {
          company_name: companyName.trim(),
          department,
          title: title.trim(),
          location,
          position_type: positionType,
          position_category: positionCategory,
          industry_category: industryCategory,
          job_url: jobUrl,
          publish_date: publishDate,
          deadline,
          job_description: jobDescription,
          job_requirements: jobRequirements,
          job_preferences: jobPreferences,
          status,
          status_date: statusDate,
          notes,
          apply_channel: applyChannel,
          match_score: matchScore,
          match_detail: matchDetail,
          match_advice: matchAdvice,
        })
      }
      onBack()
    } catch (e: any) {
      window.alert(`保存失败: ${e?.message || e}`)
    } finally {
      setSaving(false)
    }
  }, [
    mode, positionId, resumeId, companyName, department, title, location,
    positionType, positionCategory, industryCategory, jobUrl, publishDate, deadline,
    jobDescription, jobRequirements, jobPreferences,
    status, statusDate, notes, applyChannel, matchScore, matchDetail, matchAdvice, onBack,
  ])

  if (loading) return <div className="page-container"><div className="loading-text">加载中...</div></div>

  return (
    <div className="page-container">
      <div className="page-header">
        <h2>{mode === 'create' ? '新建岗位' : '编辑岗位'}</h2>
        <div style={{ display: 'flex', gap: 10 }}>
          <button className="btn btn-primary" onClick={handleSave} disabled={saving}>
            {saving ? '保存中...' : '保存'}
          </button>
          <button className="btn" onClick={onBack}>返回</button>
        </div>
      </div>

      <div style={{ display: 'flex', flexDirection: 'column', gap: 20, maxWidth: 900, overflow: 'hidden' }}>
        {mode === 'create' && (
          <div style={{ marginBottom: 4 }}>
            <label style={{ fontWeight: 600, marginRight: 8 }}>关联简历：</label>
            <select value={resumeId || ''} onChange={(e) => setResumeId(Number(e.target.value) || 0)}>
              <option value="">请选择简历</option>
              {resumes.map((r) => (
                <option key={r.id} value={r.id}>{r.name}</option>
              ))}
            </select>
          </div>
        )}

        {/* Section 1: Basic Info */}
        <fieldset className="form-section">
          <legend>岗位基本信息</legend>
          <div className="form-grid">
            <div className="form-group">
              <label>公司</label>
              <input
                list="company-list"
                value={companyName}
                onChange={(e) => setCompanyName(e.target.value)}
                placeholder="选择或输入公司名称"
              />
              <datalist id="company-list">
                {sites.map((s) => (
                  <option key={s.id} value={s.company_name} />
                ))}
              </datalist>
            </div>
            <div className="form-group">
              <label>部门</label>
              <input value={department} onChange={(e) => setDepartment(e.target.value)} placeholder="所属部门" />
            </div>
            <div className="form-group">
              <label>岗位名称</label>
              <input value={title} onChange={(e) => setTitle(e.target.value)} placeholder="岗位名称" />
            </div>
            <div className="form-group">
              <label>工作地点</label>
              <input value={location} onChange={(e) => setLocation(e.target.value)} placeholder="如：北京" />
            </div>
            <div className="form-group">
              <label>岗位性质</label>
              <select value={positionType} onChange={(e) => setPositionType(e.target.value)}>
                <option value="">请选择</option>
                {POSITION_TYPES.map((t) => (
                  <option key={t} value={t}>{t}</option>
                ))}
              </select>
            </div>
            <div className="form-group">
              <label>岗位类别</label>
              <select value={positionCategory} onChange={(e) => setPositionCategory(e.target.value)}>
                <option value="">请选择</option>
                {POSITION_CATEGORIES.map((c) => (
                  <option key={c} value={c}>{c}</option>
                ))}
              </select>
            </div>
            <div className="form-group">
              <label>行业类别</label>
              <select value={industryCategory} onChange={(e) => setIndustryCategory(e.target.value)}>
                <option value="">请选择</option>
                {industryCategories.map((ic) => (
                  <option key={ic.id} value={ic.name}>{ic.name}</option>
                ))}
              </select>
            </div>
            <div className="form-group">
              <label>岗位描述 URL</label>
              <input value={jobUrl} onChange={(e) => setJobUrl(e.target.value)} placeholder="https://..." />
            </div>
            <div className="form-group">
              <label>发布时间</label>
              <input type="date" value={publishDate} onChange={(e) => setPublishDate(e.target.value)} />
            </div>
            <div className="form-group">
              <label>截止时间</label>
              <input type="date" value={deadline} onChange={(e) => setDeadline(e.target.value)} />
            </div>
          </div>
        </fieldset>

        {/* Section 2: Job Requirements */}
        <fieldset className="form-section">
          <legend>岗位要求</legend>
          <div style={{ marginBottom: 10 }}>
            <button
              className="btn btn-small"
              onClick={handleExtract}
              disabled={extracting || !jobUrl}
            >
              {extracting ? '提取中...' : '从 URL 提取'}
            </button>
            <span style={{ marginLeft: 8, color: '#6b7280', fontSize: 13 }}>
              或手动粘贴下方内容
            </span>
          </div>
          <div className="form-group">
            <label>岗位描述</label>
            <textarea
              rows={4}
              value={jobDescription}
              onChange={(e) => setJobDescription(e.target.value)}
              placeholder="岗位描述..."
            />
          </div>
          <div className="form-group">
            <label>岗位要求</label>
            <textarea
              rows={4}
              value={jobRequirements}
              onChange={(e) => setJobRequirements(e.target.value)}
              placeholder="岗位要求..."
            />
          </div>
          <div className="form-group">
            <label>优先项</label>
            <textarea
              rows={4}
              value={jobPreferences}
              onChange={(e) => setJobPreferences(e.target.value)}
              placeholder="优先项 / 加分项..."
            />
          </div>
        </fieldset>

        {/* Section 3: Process Info */}
        <fieldset className="form-section">
          <legend>流程信息</legend>
          <div className="form-grid">
            <div className="form-group">
              <label>当前状态</label>
              <select value={status} onChange={(e) => setStatus(e.target.value)}>
                {APPLICATION_STATUSES.map((s) => (
                  <option key={s} value={s}>{s}</option>
                ))}
              </select>
            </div>
            <div className="form-group">
              <label>状态日期</label>
              <input type="date" value={statusDate} onChange={(e) => setStatusDate(e.target.value)} />
            </div>
            <div className="form-group">
              <label>投递渠道</label>
              <input value={applyChannel} onChange={(e) => setApplyChannel(e.target.value)} placeholder="如：官网、BOSS直聘" />
            </div>
            <div className="form-group" style={{ gridColumn: 'span 2' }}>
              <label>备注</label>
              <textarea
                rows={2}
                value={notes}
                onChange={(e) => setNotes(e.target.value)}
                placeholder="笔试时间、面试安排等备注..."
              />
            </div>
          </div>
        </fieldset>

        {/* Section 4: Matching Analysis */}
        <fieldset className="form-section">
          <legend>岗位匹配度分析</legend>
          {mode === 'create' ? (
            <p style={{ color: '#6b7280' }}>保存岗位后，在编辑页面运行匹配分析</p>
          ) : (
            <>
              <div style={{ marginBottom: 12 }}>
                <button
                  className="btn btn-primary"
                  onClick={handleMatch}
                  disabled={analyzing || !resumeId}
                >
                  {analyzing ? '分析中...' : '运行 AI 分析'}
                </button>
              </div>

              {matchScore > 0 && (
                <div style={{ marginTop: 12 }}>
                  <div style={{ fontSize: 20, fontWeight: 700, marginBottom: 8 }}>
                    综合匹配度：{' '}
                    <span style={{
                      color: matchScore >= 80 ? '#22c55e' : matchScore >= 60 ? '#eab308' : '#ef4444',
                    }}>
                      {matchScore}%
                    </span>
                  </div>
                  <div style={{ fontSize: 12, color: '#6b7280', marginBottom: 16 }}>
                    计算公式：学历(15%) + 技能(35%) + 经验(25%) + 地点(10%) + 加分(15%)
                  </div>

                  {Object.keys(matchDetailParsed).length > 0 && (
                    <div style={{ marginBottom: 16, overflowX: 'auto' }}>
                      <h4 style={{ marginBottom: 8 }}>评分详情</h4>
                      <table className="problem-table" style={{ width: '100%', tableLayout: 'fixed' }}>
                        <thead>
                          <tr>
                            <th style={{ width: '12%' }}>维度</th>
                            <th style={{ width: '8%' }}>权重</th>
                            <th style={{ width: '8%' }}>得分</th>
                            <th style={{ width: '72%' }}>说明</th>
                          </tr>
                        </thead>
                        <tbody>
                          {Object.entries(matchDetailParsed).map(([key, val]) => {
                            const weights: Record<string, string> = {
                              '学历匹配': '15%', '技能匹配': '35%', '经验匹配': '25%',
                              '地点匹配': '10%', '加分项': '15%',
                            }
                            return (
                            <tr key={key}>
                              <td style={{ wordBreak: 'break-word' }}>{key}</td>
                              <td>{weights[key] || '-'}</td>
                              <td>
                                <span style={{
                                  fontWeight: 600,
                                  color: val.score >= 80 ? '#22c55e' : val.score >= 60 ? '#eab308' : '#ef4444',
                                }}>
                                  {val.score}
                                </span>
                              </td>
                              <td style={{ wordBreak: 'break-word', whiteSpace: 'pre-wrap', fontSize: 13 }}>{val.comment}</td>
                            </tr>
                          )})}
                        </tbody>
                      </table>
                    </div>
                  )}

                  {matchAdvice && (
                    <div style={{
                      background: '#f0fdf4',
                      border: '1px solid #bbf7d0',
                      borderRadius: 8,
                      padding: 16,
                      whiteSpace: 'pre-wrap',
                      wordBreak: 'break-word',
                      overflowWrap: 'break-word',
                      fontSize: 14,
                      lineHeight: 1.7,
                      maxWidth: '100%',
                    }}>
                      <h4 style={{ margin: '0 0 8px 0' }}>投递建议</h4>
                      {matchAdvice}
                    </div>
                  )}
                </div>
              )}
            </>
          )}
        </fieldset>
      </div>

      <style>{`
        .form-section {
          border: 1px solid #e5e7eb;
          border-radius: 8px;
          padding: 20px;
        }
        .form-section legend {
          font-weight: 700;
          font-size: 15px;
          padding: 0 8px;
        }
        .form-grid {
          display: grid;
          grid-template-columns: 1fr 1fr;
          gap: 12px;
        }
        .form-group {
          display: flex;
          flex-direction: column;
          gap: 4px;
        }
        .form-group label {
          font-weight: 600;
          font-size: 13px;
          color: #374151;
        }
        .form-group input,
        .form-group select,
        .form-group textarea {
          padding: 8px 10px;
          border: 1px solid #d1d5db;
          border-radius: 6px;
          font-size: 14px;
        }
        .form-group textarea {
          resize: vertical;
          font-family: inherit;
        }
      `}</style>
    </div>
  )
}
