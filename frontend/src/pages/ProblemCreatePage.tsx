import { useEffect, useState, type ChangeEvent } from 'react'

import { parseProblemText } from '../lib/analysisApi'
import { createProblem, extractOfflineProblems, batchImportProblems } from '../lib/problemApi'
import { listCompanies } from '../lib/companyApi'
import { listCategories } from '../lib/categoryApi'
import type { Company } from '../types/company'
import type { ProblemCategory } from '../types/problemCategory'
import type { ParseProblemPayload, ParsedProblemResult } from '../types/analysis'
import type { OfflineProblemCandidate, ProblemCreatePayload, ProblemImportPayload, ProblemBatchImportPayload, ProblemLatestStatus } from '../types/problem'
import { MarkdownRenderer } from '../components/MarkdownRenderer'

type CreateTab = 'paste' | 'image' | 'niuke'

type OfflineCandidateWithFile = OfflineProblemCandidate & { _fileName: string }

type Props = {
  onBack: () => void
  onProblemCreated: (problemId: number) => void
}

type EditableForm = {
  title: string
  company: string
  position: string
  difficulty: string
  category_slug: string
  statement_markdown: string
  time_limit_ms: string
  memory_limit_kb: string
  source: string
  source_type: string
  frequency: string
  year: string
  source_ref: string
  external_id: string
}


function buildForm(parsed: ParsedProblemResult, rawText: string): EditableForm {
  return {
    title: parsed.title || '',
    company: parsed.company || '',
    position: '',
    difficulty: parsed.difficulty || 'Medium',
    category_slug: parsed.category_slug || '',
    statement_markdown: parsed.statement_markdown || rawText.trim(),
    time_limit_ms: String(parsed.time_limit_ms || 2000),
    memory_limit_kb: String(parsed.memory_limit_kb || 262144),
    source: parsed.source || '手工',
    source_type: parsed.source_type || 'manual',
    frequency: parsed.frequency || '中',
    year: parsed.year ? String(parsed.year) : '',
    source_ref: parsed.source_ref || '',
    external_id: parsed.external_id || '',
  }
}

function readFileAsDataUrl(file: File): Promise<string> {
  return new Promise((resolve, reject) => {
    const reader = new FileReader()
    reader.onload = () => {
      if (typeof reader.result === 'string') {
        resolve(reader.result)
        return
      }
      reject(new Error('图片读取失败'))
    }
    reader.onerror = () => reject(new Error('图片读取失败'))
    reader.readAsDataURL(file)
  })
}

function readFileAsText(file: File): Promise<string> {
  return new Promise((resolve, reject) => {
    const reader = new FileReader()
    reader.onload = () => {
      if (typeof reader.result === 'string') {
        resolve(reader.result)
        return
      }
      reject(new Error('文件读取失败'))
    }
    reader.onerror = () => reject(new Error('文件读取失败'))
    reader.readAsText(file)
  })
}

export function ProblemCreatePage({ onBack, onProblemCreated }: Props) {
  const [activeTab, setActiveTab] = useState<CreateTab>('paste')
  const [rawText, setRawText] = useState('')
  const [parseImageDataUrl, setParseImageDataUrl] = useState('')
  const [parseImageName, setParseImageName] = useState('')
  const [imageError, setImageError] = useState('')
  const [isParsing, setIsParsing] = useState(false)
  const [parseError, setParseError] = useState('')
  const [parsed, setParsed] = useState<ParsedProblemResult | null>(null)
  const [form, setForm] = useState<EditableForm | null>(null)

  const [isCreating, setIsCreating] = useState(false)
  const [createError, setCreateError] = useState('')
  const [companies, setCompanies] = useState<Company[]>([])
  const [categories, setCategories] = useState<ProblemCategory[]>([])
  const [niukeFileName, setNiukeFileName] = useState('')
  const [offlineCandidates, setOfflineCandidates] = useState<OfflineCandidateWithFile[]>([])
  const [offlineError, setOfflineError] = useState('')
  const [offlineSuccess, setOfflineSuccess] = useState('')
  const [isOfflineExtracting, setIsOfflineExtracting] = useState(false)
  const [selectedIndices, setSelectedIndices] = useState<Set<number>>(new Set())
  const [isBulkImporting, setIsBulkImporting] = useState(false)
  const [importedIndices, setImportedIndices] = useState<Set<number>>(new Set())
  const [importErrorMap, setImportErrorMap] = useState<Map<number, string>>(new Map())

  useEffect(() => {
    void listCompanies().then(setCompanies).catch(() => {})
    void listCategories().then(setCategories).catch(() => {})
  }, [])

  const buildParsePayload = (): ParseProblemPayload | null => {
    const text = rawText.trim()
    const hasImage = Boolean(parseImageDataUrl)

    if (activeTab === 'image') {
      if (!hasImage) {
        return null
      }
      return {
        mode: 'image_only',
        image_data_url: parseImageDataUrl,
        image_name: parseImageName,
      }
    }

    if (text && hasImage) {
      return {
        mode: 'text_plus_image',
        raw_text: text,
        image_data_url: parseImageDataUrl,
        image_name: parseImageName,
      }
    }

    if (text) {
      return {
        mode: 'text_only',
        raw_text: text,
      }
    }

    if (hasImage) {
      return {
        mode: 'image_only',
        image_data_url: parseImageDataUrl,
        image_name: parseImageName,
      }
    }

    return null
  }

  const handleParse = async () => {
    const payload = buildParsePayload()
    if (!payload) {
      return
    }
    setIsParsing(true)
    setParseError('')
    try {
      const result = await parseProblemText(payload)
      setParsed(result)
      setForm(buildForm(result, payload.raw_text ?? ''))
    } catch (error) {
      setParseError(error instanceof Error ? error.message : '解析失败')
    } finally {
      setIsParsing(false)
    }
  }

  const handleUseRaw = async () => {
    const text = rawText.trim()
    if (!text) {
      return
    }
    setIsParsing(true)
    setParseError('')
    try {
      const result = await parseProblemText({ mode: 'text_only', raw_text: text })
      setParsed(result)
      setForm(buildForm(result, text))
    } catch (error) {
      setParseError(error instanceof Error ? error.message : '解析失败')
    } finally {
      setIsParsing(false)
    }
  }

  const handleImageChange = async (event: ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0]
    if (!file) {
      return
    }
    setImageError('')
    if (!file.type.startsWith('image/')) {
      setImageError('请选择 PNG、JPG、WEBP 等图片文件。')
      return
    }
    try {
      const dataUrl = await readFileAsDataUrl(file)
      setParseImageDataUrl(dataUrl)
      setParseImageName(file.name)
    } catch (error) {
      setImageError(error instanceof Error ? error.message : '图片读取失败')
    }
  }

  const clearImage = () => {
    setParseImageDataUrl('')
    setParseImageName('')
    setImageError('')
  }

  const updateForm = (field: keyof EditableForm, value: string) => {
    setForm((current) => (current ? { ...current, [field]: value } : current))
  }

  const handleCreate = async () => {
    if (!form) {
      return
    }
    setIsCreating(true)
    setCreateError('')
    try {
      const tags: string[] = ['未分类']

      const examples = parsed?.examples ?? []
      const testCases = examples.length > 0
        ? examples.map((example, index) => ({
            case_type: index === 0 ? ('sample' as const) : ('hidden' as const),
            stdin_text: example.input,
            expected_output_text: example.output,
            sort_order: index + 1,
          }))
        : [{
            case_type: 'hidden' as const,
            stdin_text: 'hidden\n1',
            expected_output_text: '0',
            sort_order: 1,
          }]

      const payload: ProblemCreatePayload = {
        slug: (parsed?.slug && parsed.slug.length >= 3 ? parsed.slug : form.title.replace(/\W+/g, '-').replace(/^-|-$/g, '')) || 'untitled-problem',
        title: form.title || '未命名题目',
        company: form.company || '未知',
        position: form.position || '',
        difficulty: (['Easy', 'Medium', 'Hard'] as const).includes(form.difficulty as 'Easy' | 'Medium' | 'Hard') ? form.difficulty as 'Easy' | 'Medium' | 'Hard' : 'Medium',
        category_slug: form.category_slug || 'simulation',
        statement_markdown: form.statement_markdown.length >= 10 ? form.statement_markdown : form.statement_markdown.padEnd(10, ' '),
        constraints_text: '',
        time_limit_ms: Number(form.time_limit_ms) || 2000,
        memory_limit_kb: Number(form.memory_limit_kb) || 262144,
        tags: tags.length > 0 ? tags : ['未分类'],
        examples,
        supported_languages: ['Python', 'C++', 'Java'],
        starter_templates: {
          Python: 'def solve() -> None:\n    pass\n',
          'C++': '#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}\n',
          Java: 'public class Main {\n    public static void main(String[] args) {\n    }\n}\n',
        },
        source_type: form.source_type || 'manual',
        source: form.source || '手工',
        frequency: form.frequency || '中',
        year: form.year.trim() ? Number(form.year) : null,
        source_ref: form.source_ref,
        external_id: form.external_id,
        status: '未开始' as ProblemLatestStatus,
        test_cases: testCases,
      }
      const newProblem = await createProblem(payload)
      onProblemCreated(newProblem.id)
    } catch (error) {
      setCreateError(error instanceof Error ? error.message : '创建失败')
    } finally {
      setIsCreating(false)
    }
  }

  const handleOfflineFileChange = async (event: ChangeEvent<HTMLInputElement>) => {
    const files = Array.from(event.target.files ?? [])
    if (files.length === 0) {
      return
    }

    setIsOfflineExtracting(true)
    setOfflineError('')
    setOfflineSuccess('')
    setOfflineCandidates([])
    setSelectedIndices(new Set())
    setImportedIndices(new Set())
    setImportErrorMap(new Map())
    setNiukeFileName(files.map((f) => f.name).join(', '))

    const allCandidates: OfflineCandidateWithFile[] = []
    const errors: string[] = []

    for (const file of files) {
      try {
        const fileContent = await readFileAsText(file)
        const candidates = await extractOfflineProblems({
          file_name: file.name,
          file_content: fileContent,
        })
        for (const c of candidates) {
          allCandidates.push({ ...c, _fileName: file.name })
        }
      } catch (error) {
        errors.push(`${file.name}: ${error instanceof Error ? error.message : '解析失败'}`)
      }
    }

    setOfflineCandidates(allCandidates)
    if (errors.length > 0) {
      setOfflineError(errors.join('\n'))
    }
    setOfflineSuccess(files.length > 1
      ? `共 ${files.length} 个文件，识别 ${allCandidates.length} 道编程题`
      : `已识别 ${allCandidates.length} 道编程题`)
    setIsOfflineExtracting(false)
    event.target.value = ''
  }

  const handleToggleCandidate = (index: number) => {
    setSelectedIndices((prev) => {
      const next = new Set(prev)
      if (next.has(index)) {
        next.delete(index)
      } else {
        next.add(index)
      }
      return next
    })
  }

  const handleSelectAll = () => {
    if (selectedIndices.size === offlineCandidates.length) {
      setSelectedIndices(new Set())
    } else {
      setSelectedIndices(new Set(offlineCandidates.map((_, i) => i)))
    }
  }

  const handleBatchImport = async () => {
    if (selectedIndices.size === 0) {
      return
    }
    setIsBulkImporting(true)
    setOfflineError('')
    setOfflineSuccess('')

    const problems: ProblemImportPayload[] = []
    const indices: number[] = []
    for (const idx of selectedIndices) {
      const c = offlineCandidates[idx]
      if (c) {
        problems.push({
          source: 'niuke_offline',
          title: c.title,
          description_html: c.description_html,
          description_text: c.description_text,
          source_url: c.source_url,
          samples: c.samples,
        })
        indices.push(idx)
      }
    }

    const newErrorMap = new Map<number, string>()
    const newImported = new Set(importedIndices)

    try {
      const payload: ProblemBatchImportPayload = { problems }
      const results = await batchImportProblems(payload)
      for (let i = 0; i < results.length; i++) {
        const idx = indices[i]
        if (idx !== undefined && results[i]) {
          newImported.add(idx)
        }
      }
      setImportedIndices(new Set(newImported))
      setOfflineSuccess(`成功导入 ${results.length} 道题`)
      setSelectedIndices(new Set())
    } catch (error) {
      const msg = error instanceof Error ? error.message : '批量导入失败'
      setOfflineError(msg)
      for (const idx of indices) {
        newErrorMap.set(idx, msg)
      }
    } finally {
      setImportErrorMap(new Map(newErrorMap))
      setIsBulkImporting(false)
    }
  }

  const canAiParse = activeTab === 'paste'
    ? Boolean(rawText.trim() || parseImageDataUrl)
    : activeTab === 'image'
      ? Boolean(parseImageDataUrl)
      : false

  return (
    <section className="detail-layout">
      <div className="page-header">
        <div>
          <h1>新增题目</h1>
          <p>文本优先导入，图片用于公式和复杂排版校对；只有图片时也支持直接解析。</p>
        </div>
        <button type="button" className="button ghost" onClick={onBack}>
          返回题库
        </button>
      </div>

      <div className="workspace-tabs" style={{ marginBottom: 'var(--space-4)' }}>
        <button
          type="button"
          className={`workspace-tab${activeTab === 'paste' ? ' active' : ''}`}
          onClick={() => setActiveTab('paste')}
        >
           手工粘贴
        </button>
        <button
          type="button"
          className={`workspace-tab${activeTab === 'image' ? ' active' : ''}`}
          onClick={() => setActiveTab('image')}
        >
          图像识别
        </button>
        <button
          type="button"
          className={`workspace-tab${activeTab === 'niuke' ? ' active' : ''}`}
          onClick={() => setActiveTab('niuke')}
        >
          牛客导入
        </button>
      </div>

      {activeTab === 'paste' ? (
        <div className="detail-card">
          <label className="settings-field settings-field-full" style={{ marginBottom: 'var(--space-3)' }}>
            <span>题面文本</span>
            <textarea
              className="settings-textarea parse-textarea"
              placeholder="将题目原文粘贴到此处。推荐同时上传题面截图，用于修正数学公式、分式、上下标和复杂排版。"
              style={{ minHeight: '480px', height: '480px' }}
              value={rawText}
              onChange={(event) => setRawText(event.target.value)}
            />
          </label>

          <label className="settings-field settings-field-full" style={{ marginBottom: 'var(--space-3)' }}>
            <span>辅助截图（可选）</span>
            <input type="file" accept="image/*" onChange={(event) => void handleImageChange(event)} />
          </label>

          {parseImageDataUrl ? (
            <div style={{ marginBottom: 'var(--space-3)' }}>
              <div style={{ display: 'flex', gap: 'var(--space-3)', alignItems: 'center', marginBottom: 'var(--space-2)' }}>
                <strong>{parseImageName}</strong>
                <button type="button" className="button ghost" onClick={clearImage}>移除图片</button>
              </div>
              <img src={parseImageDataUrl} alt={parseImageName || '题面截图'} style={{ maxWidth: '100%', maxHeight: 280, borderRadius: 12, border: '1px solid var(--border-subtle)' }} />
            </div>
          ) : null}

          <div className="backend-note" style={{ marginBottom: 'var(--space-3)' }}>
            文本负责主内容结构，截图负责校对公式和复杂排版。只粘贴文本时仍可使用规则解析快速生成草稿。
          </div>

          <div style={{ display: 'flex', gap: 'var(--space-3)', alignItems: 'center', flexWrap: 'wrap' }}>
            <button type="button" className="button primary" disabled={isParsing || !canAiParse} onClick={() => void handleParse()}>
              {isParsing ? '智能解析中...' : '智能解析'}
            </button>
            <button type="button" className="button" disabled={isParsing || !rawText.trim()} onClick={() => void handleUseRaw()}>
              规则解析
            </button>
            {imageError ? <span className="save-error-text">{imageError}</span> : null}
            {parseError ? <span className="save-error-text">{parseError}</span> : null}
          </div>
        </div>
      ) : activeTab === 'image' ? (
        <div className="detail-card">
          <label className="settings-field settings-field-full" style={{ marginBottom: 'var(--space-3)' }}>
            <span>题面图片</span>
            <input type="file" accept="image/*" onChange={(event) => void handleImageChange(event)} />
          </label>

          {parseImageDataUrl ? (
            <div style={{ marginBottom: 'var(--space-3)' }}>
              <div style={{ display: 'flex', gap: 'var(--space-3)', alignItems: 'center', marginBottom: 'var(--space-2)' }}>
                <strong>{parseImageName}</strong>
                <button type="button" className="button ghost" onClick={clearImage}>移除图片</button>
              </div>
              <img src={parseImageDataUrl} alt={parseImageName || '题面截图'} style={{ maxWidth: '100%', maxHeight: 360, borderRadius: 12, border: '1px solid var(--border-subtle)' }} />
            </div>
          ) : null}

          <div className="backend-note" style={{ marginBottom: 'var(--space-3)' }}>
            仅图片模式会直接依赖 AI 恢复正文、样例和数学公式。截图越清晰，识别效果越稳定。
          </div>

          <div style={{ display: 'flex', gap: 'var(--space-3)', alignItems: 'center', flexWrap: 'wrap' }}>
            <button type="button" className="button primary" disabled={isParsing || !canAiParse} onClick={() => void handleParse()}>
              {isParsing ? '图像解析中...' : '图像解析'}
            </button>
            {imageError ? <span className="save-error-text">{imageError}</span> : null}
            {parseError ? <span className="save-error-text">{parseError}</span> : null}
          </div>
        </div>
      ) : (
        <div className="detail-card">
          <div className="detail-card" style={{ marginTop: 'var(--space-4)' }}>
            <h2>离线 html / mhtml 导入</h2>
            <p className="backend-note" style={{ marginBottom: 'var(--space-3)' }}>
              支持直接读取牛客导出的一个或多个 <code>.html</code> / <code>.mhtml</code> 文件，优先抽取整卷中的编程题，再按题逐个导入。
            </p>
            <label className="settings-field settings-field-full" style={{ marginBottom: 'var(--space-3)' }}>
              <span>离线文件</span>
              <input type="file" multiple accept=".html,.mhtml,text/html,message/rfc822,multipart/related" onChange={(event) => void handleOfflineFileChange(event)} />
            </label>
            <div style={{ display: 'flex', gap: 'var(--space-3)', flexWrap: 'wrap', alignItems: 'center', marginBottom: 'var(--space-3)' }}>
              {niukeFileName ? <span>{niukeFileName}</span> : null}
              {isOfflineExtracting ? <span className="save-success-text">离线题面解析中...</span> : null}
              {offlineSuccess ? <span className="save-success-text">{offlineSuccess}</span> : null}
              {offlineError ? <span className="save-error-text">{offlineError}</span> : null}
            </div>

            {offlineCandidates.length > 0 ? (
              <div style={{ display: 'grid', gap: 'var(--space-3)' }}>
                <div style={{ display: 'flex', gap: 'var(--space-3)', alignItems: 'center', flexWrap: 'wrap' }}>
                  <label className="backend-note" style={{ cursor: 'pointer', display: 'flex', alignItems: 'center', gap: 'var(--space-1)' }}>
                    <input
                      type="checkbox"
                      checked={selectedIndices.size === offlineCandidates.length && offlineCandidates.length > 0}
                      onChange={handleSelectAll}
                      disabled={isBulkImporting}
                    />
                    全选
                  </label>
                  <button
                    type="button"
                    className="button primary"
                    disabled={selectedIndices.size === 0 || isBulkImporting}
                    onClick={() => void handleBatchImport()}
                  >
                    {isBulkImporting ? '批量导入中...' : `批量导入 ${selectedIndices.size} 题`}
                  </button>
                </div>
                {offlineCandidates.map((candidate, index) => {
                  const isImported = importedIndices.has(index)
                  const errorMsg = importErrorMap.get(index)
                  const isSelected = selectedIndices.has(index)
                  return (
                    <article key={`${candidate.title}-${candidate.source_url}`} className="detail-card">
                      <div style={{ display: 'flex', gap: 'var(--space-3)', alignItems: 'flex-start' }}>
                        <input
                          type="checkbox"
                          style={{ marginTop: 'var(--space-1)' }}
                          checked={isSelected || isImported}
                          disabled={isImported || isBulkImporting}
                          onChange={() => handleToggleCandidate(index)}
                        />
                        <div>
                          <h3 style={{ marginBottom: 'var(--space-2)' }}>
                            {candidate.title}
                            {isImported ? <span className="save-success-text" style={{ marginLeft: 'var(--space-2)' }}>已导入</span> : null}
                            {errorMsg ? <span className="save-error-text" style={{ marginLeft: 'var(--space-2)' }}>{errorMsg}</span> : null}
                          </h3>
                          <div className="backend-note">样例数：{candidate.samples.length}{candidate._fileName ? `   文件：${candidate._fileName}` : ''}</div>
                          {candidate.source_url ? <div className="backend-note">来源：{candidate.source_url}</div> : null}
                        </div>
                      </div>
                      {candidate.description_text ? (
                        <pre className="backend-note" style={{ whiteSpace: 'pre-wrap', marginTop: 'var(--space-3)', maxHeight: 220, overflow: 'auto' }}>
                          {candidate.description_text.slice(0, 1200)}
                        </pre>
                      ) : null}
                    </article>
                  )
                })}
              </div>
            ) : null}
          </div>
        </div>
      )}

      {form ? (
        <div style={{ marginTop: 'var(--space-5)' }}>
          <div className="problem-edit-actions">
            <button type="button" className="button primary" disabled={isCreating} onClick={() => void handleCreate()}>
              {isCreating ? '创建中...' : '创建题目'}
            </button>
            {parsed?.analysis ? <span className="save-success-text">{parsed.analysis}</span> : null}
            {createError ? <span className="save-error-text">创建失败：{createError}</span> : null}
          </div>

          <div className="problem-overview-grid" style={{ marginTop: 'var(--space-4)' }}>
            <article className="detail-card problem-statement-card">
              <label className="settings-field settings-field-full" style={{ marginBottom: 'var(--space-3)' }}>
                <span>标题</span>
                <input value={form.title} onChange={(event) => updateForm('title', event.target.value)} />
              </label>
              <label className="settings-field settings-field-full" style={{ marginBottom: 'var(--space-3)' }}>
                <span>题目正文 (Markdown)</span>
                <textarea
                  className="settings-textarea"
                  rows={16}
                  value={form.statement_markdown}
                  onChange={(event) => updateForm('statement_markdown', event.target.value)}
                />
              </label>
              {form.statement_markdown ? (
                <>
                  <h3 style={{ marginTop: 'var(--space-3)' }}>预览</h3>
                  <MarkdownRenderer className="problem-markdown" markdown={form.statement_markdown} />
                </>
              ) : null}
            </article>

            <aside className="detail-card">
              <h2>题目属性</h2>
              <div className="settings-form-grid problem-edit-grid">
                <label className="settings-field">
                  <span>题型</span>
                  <select value={form.category_slug} onChange={(event) => updateForm('category_slug', event.target.value)}>
                    {form.category_slug && categories.every((item) => item.slug !== form.category_slug) ? (
                      <option value={form.category_slug}>{form.category_slug}</option>
                    ) : null}
                    {categories.map((item) => (
                      <option key={item.slug} value={item.slug}>{item.name}</option>
                    ))}
                  </select>
                </label>
                <label className="settings-field">
                  <span>年度</span>
                  <input value={form.year} onChange={(event) => updateForm('year', event.target.value)} />
                </label>
                <label className="settings-field">
                  <span>公司</span>
                  <select value={form.company} onChange={(event) => updateForm('company', event.target.value)}>
                    {form.company && companies.every((item) => item.abbreviation !== form.company) ? (
                      <option value={form.company}>{form.company}</option>
                    ) : null}
                    {companies.map((item) => (
                      <option key={item.id} value={item.abbreviation}>{item.abbreviation}</option>
                    ))}
                  </select>
                </label>
                <label className="settings-field">
                  <span>岗位</span>
                  <input value={form.position} onChange={(event) => updateForm('position', event.target.value)} placeholder="后端/前端/算法..." />
                </label>
                <label className="settings-field">
                  <span>难度</span>
                  <select value={form.difficulty} onChange={(event) => updateForm('difficulty', event.target.value)}>
                    <option value="Easy">Easy</option>
                    <option value="Medium">Medium</option>
                    <option value="Hard">Hard</option>
                  </select>
                </label>
                <label className="settings-field">
                  <span>频率</span>
                  <select value={form.frequency} onChange={(event) => updateForm('frequency', event.target.value)}>
                    <option value="高">高</option>
                    <option value="中">中</option>
                    <option value="低">低</option>
                  </select>
                </label>
                <label className="settings-field">
                  <span>最新状态</span>
                  <select value="未开始" disabled>
                    <option value="未开始">未开始</option>
                  </select>
                </label>
                <label className="settings-field">
                  <span>来源</span>
                  <select value={form.source} onChange={(event) => updateForm('source', event.target.value)}>
                    <option value="牛客">牛客</option>
                    <option value="Leetcode">Leetcode</option>
                    <option value="手工">手工</option>
                    <option value="AI派生">AI派生</option>
                  </select>
                </label>
                <label className="settings-field">
                  <span>时间限制 (ms)</span>
                  <input value={form.time_limit_ms} onChange={(event) => updateForm('time_limit_ms', event.target.value)} />
                </label>
                <label className="settings-field">
                  <span>空间限制 (KB)</span>
                  <input value={form.memory_limit_kb} onChange={(event) => updateForm('memory_limit_kb', event.target.value)} />
                </label>
              </div>
            </aside>
          </div>
        </div>
      ) : null}
    </section>
  )
}
