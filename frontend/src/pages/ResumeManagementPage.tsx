import { useCallback, useEffect, useRef, useState } from 'react'
import { fetchResumes, fetchResume, uploadResume, deleteResume, reparseResume, updateResume } from '../lib/resumeApi'
import type {
  ResumeDetail,
  ResumeExtractedInfo,
  EducationRecord,
  ExperienceRecord,
  ProjectRecord,
  LanguageRecord,
} from '../types/resume'

const POSITION_TYPES = ['校招', '实习']
const POSITION_CATEGORIES = ['技术', '产品', '其他']

const emptyInfo = (): ResumeExtractedInfo => ({
  name: '',
  email: '',
  phone: '',
  target_city: '',
  education: [],
  skills: [],
  experiences: [],
  projects: [],
  certifications: [],
  languages: [],
  self_evaluation: '',
})

const _emptyEdu = (): EducationRecord => ({ school: '', degree: '', major: '', start_date: '', end_date: '', gpa: '', courses: [], honors: [] })
const _emptyExp = (): ExperienceRecord => ({ company: '', title: '', start_date: '', end_date: '', description: '' })
const _emptyProj = (): ProjectRecord => ({ name: '', role: '', tech_stack: [], start_date: '', end_date: '', description: '' })
const _emptyLang = (): LanguageRecord => ({ name: '', level: '良好' })

export function ResumeManagementPage() {
  const [resume, setResume] = useState<ResumeDetail | null>(null)
  const [info, setInfo] = useState<ResumeExtractedInfo>(emptyInfo())
  const [positionType, setPositionType] = useState('日常实习')
  const [positionCategory, setPositionCategory] = useState('')
  const [keywordInput, setKeywordInput] = useState('')
  const [loading, setLoading] = useState(false)
  const [saving, setSaving] = useState(false)
  const [message, setMessage] = useState('')
  const [dragOver, setDragOver] = useState(false)
  const [uploadFileName, setUploadFileName] = useState('')
  const fileRef = useRef<HTMLInputElement>(null)

  const loadPrimary = useCallback(() => {
    fetchResumes().then((list) => {
      if (list.length > 0) {
        fetchResume(list[0].id).then((d) => {
          setResume(d)
          setInfo(d.extracted_info || emptyInfo())
          setPositionType(d.position_type)
          setPositionCategory(d.position_category)
        })
      } else {
        setResume(null)
        setInfo(emptyInfo())
        setPositionType('日常实习')
        setPositionCategory('')
      }
    }).catch(() => {})
  }, [])

  useEffect(() => { loadPrimary() }, [loadPrimary])

  useEffect(() => {
    if (!resume || resume.extract_status !== 'parsing') return
    const timer = setInterval(() => {
      fetchResume(resume.id).then((d) => {
        setResume(d)
        if (d.extract_status !== 'parsing' && d.extracted_info) {
          setInfo(d.extracted_info)
        }
      }).catch(() => {})
    }, 3000)
    return () => clearInterval(timer)
  }, [resume?.extract_status])

  const handleFile = async (file: File) => {
    setUploadFileName(file.name)
    setLoading(true)
    setMessage('')
    try {
      if (resume) await deleteResume(resume.id)
      const fd = new FormData()
      fd.append('file', file)
      fd.append('name', file.name.replace(/\.[^.]+$/, ''))
      fd.append('position_keywords', JSON.stringify(resume?.position_keywords || []))
      fd.append('position_type', positionType)
      fd.append('position_category', positionCategory)
      const created = await uploadResume(fd)
      setResume(created)
      if (created.extracted_info) {
        setInfo(created.extracted_info)
      }
      setPositionType(created.position_type)
      setPositionCategory(created.position_category)
      setMessage(created.extracted_info ? '解析成功' : '上传成功')
    } catch (err: unknown) {
      setMessage(err instanceof Error ? err.message : '上传失败')
    } finally {
      setLoading(false)
      setUploadFileName('')
    }
  }

  const handleReparse = async () => {
    if (!resume) return
    setLoading(true)
    setMessage('')
    try {
      await reparseResume(resume.id)
      const d = await fetchResume(resume.id)
      setResume(d)
      if (d.extracted_info) setInfo(d.extracted_info)
      setMessage('重新解析完成')
    } catch (err: unknown) {
      setMessage(err instanceof Error ? err.message : '解析失败')
    } finally {
      setLoading(false)
    }
  }

  const handleSave = async () => {
    if (!resume) return
    setSaving(true)
    setMessage('')
    try {
      const fd = new FormData()
      fd.append('name', resume.name)
      fd.append('position_keywords', JSON.stringify(resume.position_keywords || []))
      fd.append('position_type', positionType)
      fd.append('position_category', positionCategory)
      const updated = await updateResume(resume.id, fd)
      setResume(updated)
      setPositionCategory(updated.position_category)
      setMessage('保存成功')
    } catch (err: unknown) {
      setMessage(err instanceof Error ? err.message : '保存失败')
    } finally {
      setSaving(false)
    }
  }

  const onDrop = (e: React.DragEvent) => {
    e.preventDefault()
    setDragOver(false)
    const file = e.dataTransfer.files?.[0]
    if (file) void handleFile(file)
  }

  const onFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0]
    if (file) void handleFile(file)
  }

  const updateField = <K extends keyof ResumeExtractedInfo>(key: K, value: ResumeExtractedInfo[K]) => {
    setInfo((prev) => ({ ...prev, [key]: value }))
  }

  const addKeyword = () => {
    const kw = keywordInput.trim()
    if (kw) setResume((prev) => prev ? { ...prev, position_keywords: prev.position_keywords?.includes(kw) ? prev.position_keywords : [...(prev.position_keywords || []), kw] } : prev)
    setKeywordInput('')
  }

  const removeKeyword = (kw: string) => setResume((prev) => prev ? { ...prev, position_keywords: prev.position_keywords?.filter((k) => k !== kw) } : prev)

  const statusLabel: Record<string, string> = {
    pending: '待解析', parsing: '解析中', success: '已解析', failed: '失败',
  }

  return (
    <section className="recruitment-page resume-editor" style={{ maxWidth: 800 }}>
      {/* --- Header & Drop Zone --- */}
      <div className="resume-header">
        <div className="resume-header-left">
          <h1>简历管理</h1>
          <p>拖拽简历文件自动解析填充，维护一份完整个人简历</p>
        </div>
        <div className="resume-header-right">
          {resume && (
            <>
              <button className="button" onClick={handleReparse} disabled={loading}>重新解析</button>
              <button className="button primary" onClick={() => void handleSave()} disabled={saving}>
                {saving ? '保存中...' : '保存简历'}
              </button>
            </>
          )}
        </div>
      </div>

      <div
        className={`resume-drop-zone${dragOver ? ' drag-over' : ''}${resume ? ' has-file' : ''}`}
        onDragOver={(e) => { e.preventDefault(); setDragOver(true) }}
        onDragLeave={() => setDragOver(false)}
        onDrop={onDrop}
        onClick={() => fileRef.current?.click()}
      >
        <input ref={fileRef} type="file" accept=".pdf,.docx,.txt" style={{ display: 'none' }} onChange={onFileChange} />
        {loading ? (
          <span>
            <strong>正在上传: {uploadFileName}</strong>
            <span className="resume-drop-hint">解析中，请稍候...</span>
          </span>
        ) : resume ? (
          <span>
            <strong>{resume.name}</strong>
            <span className={`status-badge status-${resume.extract_status}`} style={{ marginLeft: 10 }}>
              {statusLabel[resume.extract_status]}
            </span>
            <span className="resume-drop-hint">点击或拖拽新简历替换</span>
          </span>
        ) : (
          <span>
            <strong>拖拽简历文件到此处开始</strong>
            <span className="resume-drop-hint">支持 PDF / DOCX / TXT 格式</span>
          </span>
        )}
      </div>

      {resume?.extract_status === 'failed' && (
        <div className="error-msg" style={{ marginTop: 12 }}>解析失败: {resume.extract_error || '未知错误'}</div>
      )}
      {message && <div className="backend-note success" style={{ marginTop: 8 }}>{message}</div>}

      {/* --- Target Position --- */}
      <div className="resume-section">
        <h3 className="resume-section-title">目标岗位</h3>
        <table className="resume-table">
          <tbody>
            <tr>
              <td className="resume-table-label">岗位性质</td>
              <td>
                <select className="input" value={positionType} onChange={(e) => setPositionType(e.target.value)}>
                  {POSITION_TYPES.map((t) => <option key={t} value={t}>{t}</option>)}
                </select>
              </td>
              <td className="resume-table-label">岗位类别</td>
              <td>
                <select className="input" value={positionCategory} onChange={(e) => setPositionCategory(e.target.value)}>
                  <option value="">请选择</option>
                  {POSITION_CATEGORIES.map((c) => <option key={c} value={c}>{c}</option>)}
                </select>
              </td>
            </tr>
            <tr>
              <td className="resume-table-label">岗位关键词</td>
              <td>
                <div className="tag-list">
                  {(resume?.position_keywords || []).map((kw) => (
                    <span key={kw} className="tag clickable" onClick={() => removeKeyword(kw)} title="点击移除">
                      {kw} &times;
                    </span>
                  ))}
                </div>
                <div className="tag-input-row">
                  <input
                    className="input"
                    value={keywordInput}
                    onChange={(e) => setKeywordInput(e.target.value)}
                    onKeyDown={(e) => { if (e.key === 'Enter') { e.preventDefault(); addKeyword() } }}
                    placeholder="输入后回车添加"
                  />
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      {/* --- Basic Info --- */}
      <div className="resume-section">
        <h3 className="resume-section-title">基本信息</h3>
        <table className="resume-table">
          <tbody>
            <tr>
              <td className="resume-table-label">姓名</td>
              <td><input className="input" value={info.name} onChange={(e) => updateField('name', e.target.value)} /></td>
              <td className="resume-table-label">邮箱</td>
              <td><input className="input" value={info.email} onChange={(e) => updateField('email', e.target.value)} /></td>
            </tr>
            <tr>
              <td className="resume-table-label">电话</td>
              <td><input className="input" value={info.phone} onChange={(e) => updateField('phone', e.target.value)} /></td>
              <td className="resume-table-label">期望城市</td>
              <td><input className="input" value={info.target_city} onChange={(e) => updateField('target_city', e.target.value)} placeholder="如: 北京、上海" /></td>
            </tr>
          </tbody>
        </table>
      </div>

      {/* --- Education --- */}
      <div className="resume-section">
        <div className="resume-section-header">
          <h3 className="resume-section-title">教育经历</h3>
          <button className="button small" onClick={() => updateField('education', [...info.education, _emptyEdu()])}>+ 添加</button>
        </div>
        {info.education.length === 0 && <div className="resume-empty">暂无教育经历</div>}
        {info.education.map((edu, i) => (
          <div key={i} className="resume-card">
            <div className="resume-card-header">
              <span>教育经历 {i + 1}</span>
              <button className="button small danger" onClick={() => updateField('education', info.education.filter((_, j) => j !== i))}>删除</button>
            </div>
            <table className="resume-table">
              <tbody>
                <tr>
                  <td className="resume-table-label">学校</td>
                  <td><input className="input" value={edu.school} onChange={(e) => { const list = [...info.education]; list[i] = { ...list[i], school: e.target.value }; updateField('education', list) }} /></td>
                  <td className="resume-table-label">学历</td>
                  <td><input className="input" value={edu.degree} onChange={(e) => { const list = [...info.education]; list[i] = { ...list[i], degree: e.target.value }; updateField('education', list) }} placeholder="本科/硕士/博士" /></td>
                </tr>
                <tr>
                  <td className="resume-table-label">专业</td>
                  <td><input className="input" value={edu.major} onChange={(e) => { const list = [...info.education]; list[i] = { ...list[i], major: e.target.value }; updateField('education', list) }} /></td>
                  <td className="resume-table-label">GPA</td>
                  <td><input className="input" value={edu.gpa} onChange={(e) => { const list = [...info.education]; list[i] = { ...list[i], gpa: e.target.value }; updateField('education', list) }} /></td>
                </tr>
                <tr>
                  <td className="resume-table-label">时间</td>
                  <td colSpan={3}>
                    <div style={{ display: 'flex', gap: 8 }}>
                      <input className="input" style={{ flex: 1 }} value={edu.start_date} onChange={(e) => { const list = [...info.education]; list[i] = { ...list[i], start_date: e.target.value }; updateField('education', list) }} placeholder="开始 (YYYY.MM)" />
                      <span className="input-separator">--</span>
                      <input className="input" style={{ flex: 1 }} value={edu.end_date} onChange={(e) => { const list = [...info.education]; list[i] = { ...list[i], end_date: e.target.value }; updateField('education', list) }} placeholder="结束 (YYYY.MM)" />
                    </div>
                  </td>
                </tr>
                <tr>
                  <td className="resume-table-label">课程</td>
                  <td colSpan={3}>
                    <InlineTags tags={edu.courses} onAdd={(t) => { const list = [...info.education]; list[i] = { ...list[i], courses: [...list[i].courses, t] }; updateField('education', list) }} onRemove={(t) => { const list = [...info.education]; list[i] = { ...list[i], courses: list[i].courses.filter((c) => c !== t) }; updateField('education', list) }} />
                  </td>
                </tr>
                <tr>
                  <td className="resume-table-label">荣誉</td>
                  <td colSpan={3}>
                    <InlineTags tags={edu.honors || []} onAdd={(t) => { const list = [...info.education]; list[i] = { ...list[i], honors: [...(list[i].honors || []), t] }; updateField('education', list) }} onRemove={(t) => { const list = [...info.education]; const honors = (list[i].honors || []).filter((h: string) => h !== t); list[i] = { ...list[i], honors }; updateField('education', list) }} />
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        ))}
      </div>

      {/* --- Skills --- */}
      <div className="resume-section">
        <h3 className="resume-section-title">技能</h3>
        <InlineTags tags={info.skills} onAdd={(t) => updateField('skills', [...info.skills, t])} onRemove={(t) => updateField('skills', info.skills.filter((s) => s !== t))} />
      </div>

      {/* --- Work/Internship Experience --- */}
      <div className="resume-section">
        <div className="resume-section-header">
          <h3 className="resume-section-title">工作 / 实习经历</h3>
          <button className="button small" onClick={() => updateField('experiences', [...info.experiences, _emptyExp()])}>+ 添加</button>
        </div>
        {info.experiences.length === 0 && <div className="resume-empty">暂无经历</div>}
        {info.experiences.map((exp, i) => (
          <div key={i} className="resume-card">
            <div className="resume-card-header">
              <span>经历 {i + 1}</span>
              <button className="button small danger" onClick={() => updateField('experiences', info.experiences.filter((_, j) => j !== i))}>删除</button>
            </div>
            <table className="resume-table">
              <tbody>
                <tr>
                  <td className="resume-table-label">公司</td>
                  <td><input className="input" value={exp.company} onChange={(e) => { const list = [...info.experiences]; list[i] = { ...list[i], company: e.target.value }; updateField('experiences', list) }} /></td>
                  <td className="resume-table-label">职位</td>
                  <td><input className="input" value={exp.title} onChange={(e) => { const list = [...info.experiences]; list[i] = { ...list[i], title: e.target.value }; updateField('experiences', list) }} /></td>
                </tr>
                <tr>
                  <td className="resume-table-label">时间</td>
                  <td colSpan={3}>
                    <div style={{ display: 'flex', gap: 8 }}>
                      <input className="input" style={{ flex: 1 }} value={exp.start_date} onChange={(e) => { const list = [...info.experiences]; list[i] = { ...list[i], start_date: e.target.value }; updateField('experiences', list) }} placeholder="开始 (YYYY.MM)" />
                      <span className="input-separator">--</span>
                      <input className="input" style={{ flex: 1 }} value={exp.end_date} onChange={(e) => { const list = [...info.experiences]; list[i] = { ...list[i], end_date: e.target.value }; updateField('experiences', list) }} placeholder="结束 (YYYY.MM)" />
                    </div>
                  </td>
                </tr>
                <tr>
                  <td className="resume-table-label">描述</td>
                  <td colSpan={3}>
                    <textarea className="input textarea" rows={6} value={exp.description} onChange={(e) => { const list = [...info.experiences]; list[i] = { ...list[i], description: e.target.value }; updateField('experiences', list) }} />
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        ))}
      </div>

      {/* --- Projects --- */}
      <div className="resume-section">
        <div className="resume-section-header">
          <h3 className="resume-section-title">项目经历</h3>
          <button className="button small" onClick={() => updateField('projects', [...info.projects, _emptyProj()])}>+ 添加</button>
        </div>
        {info.projects.length === 0 && <div className="resume-empty">暂无项目</div>}
        {info.projects.map((proj, i) => (
          <div key={i} className="resume-card">
            <div className="resume-card-header">
              <span>项目 {i + 1}</span>
              <button className="button small danger" onClick={() => updateField('projects', info.projects.filter((_, j) => j !== i))}>删除</button>
            </div>
            <table className="resume-table">
              <tbody>
                <tr>
                  <td className="resume-table-label">项目名称</td>
                  <td><input className="input" value={proj.name} onChange={(e) => { const list = [...info.projects]; list[i] = { ...list[i], name: e.target.value }; updateField('projects', list) }} /></td>
                  <td className="resume-table-label">角色</td>
                  <td><input className="input" value={proj.role} onChange={(e) => { const list = [...info.projects]; list[i] = { ...list[i], role: e.target.value }; updateField('projects', list) }} /></td>
                </tr>
                <tr>
                  <td className="resume-table-label">时间</td>
                  <td colSpan={3}>
                    <div style={{ display: 'flex', gap: 8 }}>
                      <input className="input" style={{ flex: 1 }} value={proj.start_date} onChange={(e) => { const list = [...info.projects]; list[i] = { ...list[i], start_date: e.target.value }; updateField('projects', list) }} placeholder="开始 (YYYY.MM)" />
                      <span className="input-separator">--</span>
                      <input className="input" style={{ flex: 1 }} value={proj.end_date} onChange={(e) => { const list = [...info.projects]; list[i] = { ...list[i], end_date: e.target.value }; updateField('projects', list) }} placeholder="结束 (YYYY.MM)" />
                    </div>
                  </td>
                </tr>
                <tr>
                  <td className="resume-table-label">技术栈</td>
                  <td colSpan={3}>
                    <InlineTags tags={proj.tech_stack} onAdd={(t) => { const list = [...info.projects]; list[i] = { ...list[i], tech_stack: [...list[i].tech_stack, t] }; updateField('projects', list) }} onRemove={(t) => { const list = [...info.projects]; list[i] = { ...list[i], tech_stack: list[i].tech_stack.filter((s) => s !== t) }; updateField('projects', list) }} />
                  </td>
                </tr>
                <tr>
                  <td className="resume-table-label">描述</td>
                  <td colSpan={3}>
                    <textarea className="input textarea" rows={6} value={proj.description} onChange={(e) => { const list = [...info.projects]; list[i] = { ...list[i], description: e.target.value }; updateField('projects', list) }} />
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        ))}
      </div>

      {/* --- Certifications --- */}
      <div className="resume-section">
        <h3 className="resume-section-title">证书</h3>
        <InlineTags tags={info.certifications} onAdd={(t) => updateField('certifications', [...info.certifications, t])} onRemove={(t) => updateField('certifications', info.certifications.filter((c) => c !== t))} />
      </div>

      {/* --- Languages --- */}
      <div className="resume-section">
        <div className="resume-section-header">
          <h3 className="resume-section-title">语言能力</h3>
          <button className="button small" onClick={() => updateField('languages', [...info.languages, _emptyLang()])}>+ 添加</button>
        </div>
        {info.languages.length === 0 && <div className="resume-empty">暂无语言记录</div>}
        {info.languages.map((lang, i) => (
          <div key={i} className="resume-card">
            <div className="resume-card-header">
              <span>语言 {i + 1}</span>
              <button className="button small danger" onClick={() => updateField('languages', info.languages.filter((_, j) => j !== i))}>删除</button>
            </div>
            <table className="resume-table">
              <tbody>
                <tr>
                  <td className="resume-table-label">语言</td>
                  <td><input className="input" value={lang.name} onChange={(e) => { const list = [...info.languages]; list[i] = { ...list[i], name: e.target.value }; updateField('languages', list) }} placeholder="语言名称" /></td>
                  <td className="resume-table-label">水平</td>
                  <td>
                    <select className="input" value={lang.level} onChange={(e) => { const list = [...info.languages]; list[i] = { ...list[i], level: e.target.value }; updateField('languages', list) }}>
                      {['母语', '流利', '良好', '基础'].map((l) => <option key={l} value={l}>{l}</option>)}
                    </select>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        ))}
      </div>

      <div className="resume-section">
        <h3 className="resume-section-title">自我评价</h3>
        <textarea
          className="input textarea"
          rows={6}
          value={info.self_evaluation}
          onChange={(e) => updateField('self_evaluation', e.target.value)}
          placeholder="可选，填写自我评价、个人优势、职业规划等"
        />
      </div>
    </section>
  )
}

function InlineTags({ tags, onAdd, onRemove }: { tags: string[]; onAdd: (t: string) => void; onRemove: (t: string) => void }) {
  const [input, setInput] = useState('')
  const handleAdd = () => {
    const val = input.trim()
    if (val && !tags.includes(val)) { onAdd(val); setInput('') }
  }
  return (
    <div>
      <div className="tag-list">
        {tags.map((t) => (
          <span key={t} className="tag clickable" onClick={() => onRemove(t)} title="点击移除">{t} &times;</span>
        ))}
        {tags.length === 0 && <span className="tag-empty">暂无</span>}
      </div>
      <div className="tag-input-row">
        <input className="input" value={input} onChange={(e) => setInput(e.target.value)} onKeyDown={(e) => { if (e.key === 'Enter') { e.preventDefault(); handleAdd() } }} placeholder="输入后回车添加" />
      </div>
    </div>
  )
}
