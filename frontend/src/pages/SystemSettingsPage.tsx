import { useEffect, useState } from 'react'

import { getLLMSettings, updateLLMSettings, getBrowserSettings, updateBrowserSettings } from '../lib/llmSettingsApi'
import { createCompany, deleteCompany, listCompanies } from '../lib/companyApi'
import { createCategory, deleteCategory, listCategories, updateCategory } from '../lib/categoryApi'
import { listAgents, updateAgent, listTools, listSkills } from '../lib/agentApi'
import { createIndustryCategory, deleteIndustryCategory, listIndustryCategories, updateIndustryCategory } from '../lib/websiteApi'
import type { LLMProvider, LLMSettingsPayload, BrowserSettingsPayload } from '../types/llmSettings'
import type { AgentConfig, ToolConfig, SkillConfig } from '../types/agent'
import type { IndustryCategory } from '../types/website'

const defaultForm: LLMSettingsPayload = {
  provider: 'OpenAI Compatible',
  endpoint_url: 'https://api.openai.com/v1',
  solution_model: 'gpt-4.1-mini',
  vision_model: 'gpt-4.1-mini',
  attribution_model: 'gpt-4.1-mini',
  review_model: 'gpt-4.1-mini',
  resume_model: 'gpt-4.1-mini',
  scraping_model: 'gpt-4.1-mini',
  solution_temperature: 0.2,
  attribution_temperature: 0.1,
  review_temperature: 0.3,
  enabled: true,
  api_key: '',
  clear_api_key: false,
}

export function SystemSettingsPage() {
  const [activeTab, setActiveTab] = useState<'llm' | 'agent' | 'company' | 'category' | 'browser' | 'industry'>('llm')

  return (
    <section className="settings-layout">
      <div className="page-header">
        <div>
          <h1>系统管理</h1>
          <p>集中配置 AI 模型、AI Agent、题库公司与题型分类。</p>
        </div>
      </div>

      <nav className="tabs-bar" aria-label="系统管理页签">
        <button
          type="button"
          className={`tab-item${activeTab === 'llm' ? ' tab-active' : ''}`}
          onClick={() => setActiveTab('llm')}
        >
          LLM 配置
        </button>
        <button
          type="button"
          className={`tab-item${activeTab === 'agent' ? ' tab-active' : ''}`}
          onClick={() => setActiveTab('agent')}
        >
          AI Agent
        </button>
        <button
          type="button"
          className={`tab-item${activeTab === 'company' ? ' tab-active' : ''}`}
          onClick={() => setActiveTab('company')}
        >
          公司配置
        </button>
        <button
          type="button"
          className={`tab-item${activeTab === 'category' ? ' tab-active' : ''}`}
          onClick={() => setActiveTab('category')}
        >
          题型配置
        </button>
        <button
          type="button"
          className={`tab-item${activeTab === 'browser' ? ' tab-active' : ''}`}
          onClick={() => setActiveTab('browser')}
        >
          浏览器配置
        </button>
        <button
          type="button"
          className={`tab-item${activeTab === 'industry' ? ' tab-active' : ''}`}
          onClick={() => setActiveTab('industry')}
        >
          行业类别
        </button>
      </nav>

      {activeTab === 'llm' && <LLMConfigTab />}
      {activeTab === 'agent' && <AgentConfigTab />}
      {activeTab === 'company' && <CompanyConfigTab />}
      {activeTab === 'category' && <CategoryConfigTab />}
      {activeTab === 'browser' && <BrowserConfigTab />}
      {activeTab === 'industry' && <IndustryCategoryTab />}
    </section>
  )
}

function LLMConfigTab() {
  const [form, setForm] = useState<LLMSettingsPayload>(defaultForm)
  const [apiKeyStatus, setApiKeyStatus] = useState('未配置')
  const [isLoading, setIsLoading] = useState(true)
  const [isSaving, setIsSaving] = useState(false)
  const [updatedAt, setUpdatedAt] = useState('')
  const [message, setMessage] = useState('')
  const [error, setError] = useState('')
  const [reloadSeed, setReloadSeed] = useState(0)

  const loadSettings = async (cancelled: { value: boolean }) => {
    try {
      const settings = await getLLMSettings()
      if (cancelled.value) {
        return
      }

      setForm({
        provider: settings.provider,
        endpoint_url: settings.endpoint_url,
        solution_model: settings.solution_model,
        vision_model: settings.vision_model,
        attribution_model: settings.attribution_model,
        review_model: settings.review_model,
        resume_model: settings.resume_model,
        scraping_model: settings.scraping_model,
        solution_temperature: settings.solution_temperature,
        attribution_temperature: settings.attribution_temperature,
        review_temperature: settings.review_temperature,
        enabled: settings.enabled,
        api_key: '',
        clear_api_key: false,
      })
      setApiKeyStatus(settings.api_key_configured ? `已配置 ${settings.api_key_masked}` : '未配置')
      setUpdatedAt(settings.updated_at)
    } catch (loadError) {
      if (!cancelled.value) {
        setError(loadError instanceof Error ? loadError.message : '加载配置失败')
      }
    } finally {
      if (!cancelled.value) {
        setIsLoading(false)
      }
    }
  }

  useEffect(() => {
    const cancelled = { value: false }
    setIsLoading(true)
    setError('')
    void loadSettings(cancelled)

    return () => {
      cancelled.value = true
    }
  }, [reloadSeed])

  const handleSave = async () => {
    setIsSaving(true)
    setMessage('')
    setError('')

    try {
      const saved = await updateLLMSettings(form)
      setUpdatedAt(saved.updated_at)
      setApiKeyStatus(saved.api_key_configured ? `已配置 ${saved.api_key_masked}` : '未配置')
      setForm((current) => ({ ...current, api_key: '', clear_api_key: false }))
      setMessage('LLM 模型配置已保存到系统设置。')
    } catch (saveError) {
      setError(saveError instanceof Error ? saveError.message : '保存失败')
    } finally {
      setIsSaving(false)
    }
  }

  return (
    <>
      <div className="summary-strip">
        <span className="summary-pill">Provider: {form.provider}</span>
        <span className="summary-pill">更新于 {updatedAt || '未加载'}</span>
        <span className="summary-pill">API Key: {apiKeyStatus}</span>
        <span className={`summary-pill ${form.enabled ? 'summary-pill-active' : ''}`}>{form.enabled ? 'AI 已启用' : 'AI 已停用'}</span>
      </div>

      {error ? (
        <div className="backend-note action-note">
          <span>系统管理接口异常：{error}</span>
          <button type="button" className="button" onClick={() => setReloadSeed((current) => current + 1)}>
            重新加载
          </button>
        </div>
      ) : null}
      {message ? <div className="backend-note success-note">{message}</div> : null}

      <div className="settings-grid">
        <section className="detail-card settings-card">
          <h2>LLM 连接配置</h2>

          {isLoading ? (
            <div className="empty-panel">正在加载模型配置...</div>
          ) : (
            <div className="settings-form-grid">
              <label className="settings-field">
                <span>Provider</span>
                <select
                  value={form.provider}
                  onChange={(event) =>
                    setForm((current) => ({
                      ...current,
                      provider: event.target.value as LLMProvider,
                    }))
                  }
                >
                  <option value="OpenAI Compatible">OpenAI Compatible</option>
                  <option value="Anthropic Compatible">Anthropic Compatible</option>
                  <option value="Custom">Custom</option>
                </select>
              </label>

              <label className="settings-field settings-field-full">
                <span>Endpoint URL</span>
                <input
                  type="url"
                  value={form.endpoint_url}
                  onChange={(event) =>
                    setForm((current) => ({
                      ...current,
                      endpoint_url: event.target.value,
                    }))
                  }
                />
              </label>

              <label className="settings-switch">
                <input
                  type="checkbox"
                  checked={form.enabled}
                  onChange={(event) =>
                    setForm((current) => ({
                      ...current,
                      enabled: event.target.checked,
                    }))
                  }
                />
                <span>启用 AI 分析与归因能力</span>
              </label>

              <label className="settings-field settings-field-full">
                <span>API Key</span>
                <input
                  type="password"
                  value={form.api_key ?? ''}
                  placeholder="留空表示保持当前 Key，不会回显已保存内容"
                  onChange={(event) =>
                    setForm((current) => ({
                      ...current,
                      api_key: event.target.value,
                      clear_api_key: false,
                    }))
                  }
                />
              </label>

              <label className="settings-switch">
                <input
                  type="checkbox"
                  checked={Boolean(form.clear_api_key)}
                  onChange={(event) =>
                    setForm((current) => ({
                      ...current,
                      clear_api_key: event.target.checked,
                      api_key: event.target.checked ? '' : current.api_key,
                    }))
                  }
                />
                <span>清空当前已保存的 API Key</span>
              </label>
            </div>
          )}
        </section>

        <section className="detail-card settings-card">
          <h2>模型路由</h2>

          <div className="settings-form-grid">
            <label className="settings-field">
              <span>解题分析模型</span>
              <input
                type="text"
                value={form.solution_model}
                onChange={(event) =>
                  setForm((current) => ({
                    ...current,
                    solution_model: event.target.value,
                  }))
                }
              />
            </label>

            <label className="settings-field">
              <span>图片识别模型</span>
              <input
                type="text"
                value={form.vision_model}
                onChange={(event) =>
                  setForm((current) => ({
                    ...current,
                    vision_model: event.target.value,
                  }))
                }
              />
            </label>

            <label className="settings-field">
              <span>错误归因模型</span>
              <input
                type="text"
                value={form.attribution_model}
                onChange={(event) =>
                  setForm((current) => ({
                    ...current,
                    attribution_model: event.target.value,
                  }))
                }
              />
            </label>

            <label className="settings-field">
              <span>复盘推荐模型</span>
              <input
                type="text"
                value={form.review_model}
                onChange={(event) =>
                  setForm((current) => ({
                    ...current,
                    review_model: event.target.value,
                  }))
                }
              />
            </label>

            <label className="settings-field">
              <span>简历解析模型</span>
              <input
                type="text"
                value={form.resume_model}
                onChange={(event) =>
                  setForm((current) => ({
                    ...current,
                    resume_model: event.target.value,
                  }))
                }
              />
            </label>

            <label className="settings-field">
              <span>抓取分类模型</span>
              <input
                type="text"
                value={form.scraping_model}
                onChange={(event) =>
                  setForm((current) => ({
                    ...current,
                    scraping_model: event.target.value,
                  }))
                }
              />
            </label>

            <label className="settings-field">
              <span>解题分析 Temperature</span>
              <input
                type="number"
                min="0"
                max="2"
                step="0.1"
                value={form.solution_temperature}
                onChange={(event) =>
                  setForm((current) => ({
                    ...current,
                    solution_temperature: Number(event.target.value),
                  }))
                }
              />
            </label>

            <label className="settings-field">
              <span>错误归因 Temperature</span>
              <input
                type="number"
                min="0"
                max="2"
                step="0.1"
                value={form.attribution_temperature}
                onChange={(event) =>
                  setForm((current) => ({
                    ...current,
                    attribution_temperature: Number(event.target.value),
                  }))
                }
              />
            </label>

            <label className="settings-field">
              <span>复盘推荐 Temperature</span>
              <input
                type="number"
                min="0"
                max="2"
                step="0.1"
                value={form.review_temperature}
                onChange={(event) =>
                  setForm((current) => ({
                    ...current,
                    review_temperature: Number(event.target.value),
                  }))
                }
              />
            </label>
          </div>

          <div className="button-row settings-actions">
            <button type="button" className="button ghost" onClick={() => setForm(defaultForm)}>
              恢复默认值
            </button>
            <button type="button" className="button primary" disabled={isSaving || isLoading} onClick={() => void handleSave()}>
              {isSaving ? '保存中...' : '保存配置'}
            </button>
          </div>
        </section>
      </div>
    </>
  )
}

function CompanyConfigTab() {
  const [companies, setCompanies] = useState<Array<{ id: number; name: string; name_en: string; abbreviation: string; created_at: string }>>([])
  const [isLoading, setIsLoading] = useState(true)
  const [error, setError] = useState('')
  const [newName, setNewName] = useState('')
  const [newNameEn, setNewNameEn] = useState('')
  const [newAbbr, setNewAbbr] = useState('')
  const [isAdding, setIsAdding] = useState(false)

  const loadCompanies = async () => {
    try {
      const data = await listCompanies()
      setCompanies(data)
    } catch (err) {
      setError(err instanceof Error ? err.message : '加载公司列表失败')
    } finally {
      setIsLoading(false)
    }
  }

  useEffect(() => {
    void loadCompanies()
  }, [])

  const handleAdd = async () => {
    if (!newName.trim()) {
      return
    }

    setIsAdding(true)
    setError('')
    try {
      const created = await createCompany({
        name: newName.trim(),
        name_en: newNameEn.trim(),
        abbreviation: newAbbr.trim(),
      })
      setCompanies((current) => [...current, created])
      setNewName('')
      setNewNameEn('')
      setNewAbbr('')
    } catch (err) {
      setError(err instanceof Error ? err.message : '添加公司失败')
    } finally {
      setIsAdding(false)
    }
  }

  const handleDelete = async (companyId: number) => {
    setError('')
    try {
      await deleteCompany(companyId)
      setCompanies((current) => current.filter((c) => c.id !== companyId))
    } catch (err) {
      setError(err instanceof Error ? err.message : '删除公司失败')
    }
  }

  return (
    <>
      {error ? <div className="backend-note action-note">{error}</div> : null}

      <div className="detail-card" style={{ marginTop: 16 }}>
        <div className="filter-row" style={{ padding: '12px 16px', gap: 12 }}>
          <input
            type="text"
            placeholder="公司名称"
            value={newName}
            onChange={(e) => setNewName(e.target.value)}
            style={{ flex: 1 }}
          />
          <input
            type="text"
            placeholder="英文名"
            value={newNameEn}
            onChange={(e) => setNewNameEn(e.target.value)}
            style={{ flex: 1 }}
          />
          <input
            type="text"
            placeholder="简称"
            value={newAbbr}
            onChange={(e) => setNewAbbr(e.target.value)}
            style={{ maxWidth: 160 }}
          />
          <button type="button" className="button primary" disabled={isAdding || !newName.trim()} onClick={() => void handleAdd()}>
            {isAdding ? '添加中...' : '新增公司'}
          </button>
        </div>
      </div>

      {isLoading ? (
        <div className="empty-panel" style={{ marginTop: 16 }}>正在加载公司配置...</div>
      ) : (
        <div className="detail-card" style={{ marginTop: 16 }}>
          <table className="data-table" style={{ width: '100%', tableLayout: 'fixed', borderCollapse: 'collapse' }}>
            <thead>
              <tr>
                <th style={{ width: '8%', border: '1px solid var(--border-subtle)', padding: '8px 12px', textAlign: 'left' }}>#</th>
                <th style={{ width: '28%', border: '1px solid var(--border-subtle)', padding: '8px 12px', textAlign: 'left' }}>公司名称</th>
                <th style={{ width: '28%', border: '1px solid var(--border-subtle)', padding: '8px 12px', textAlign: 'left' }}>英文名</th>
                <th style={{ width: '16%', border: '1px solid var(--border-subtle)', padding: '8px 12px', textAlign: 'left' }}>简称</th>
                <th style={{ width: '20%', border: '1px solid var(--border-subtle)', padding: '8px 12px', textAlign: 'left' }}>操作</th>
              </tr>
            </thead>
            <tbody>
              {companies.length === 0 ? (
                  <tr>
                    <td colSpan={5} style={{ textAlign: 'center', padding: 24, color: '#6b7280', border: '1px solid var(--border-subtle)' }}>
                      暂无公司记录，请在上方添加。
                    </td>
                  </tr>
              ) : (
                companies.map((company) => (
                  <tr key={company.id}>
                    <td style={{ border: '1px solid var(--border-subtle)', padding: '8px 12px' }}>{company.id}</td>
                    <td style={{ border: '1px solid var(--border-subtle)', padding: '8px 12px' }}>{company.name}</td>
                    <td style={{ border: '1px solid var(--border-subtle)', padding: '8px 12px' }}>{company.name_en || '-'}</td>
                    <td style={{ border: '1px solid var(--border-subtle)', padding: '8px 12px' }}>{company.abbreviation || '-'}</td>
                    <td style={{ border: '1px solid var(--border-subtle)', padding: '8px 12px' }}>
                      <button
                        type="button"
                        className="button ghost"
                        onClick={() => {
                          if (window.confirm(`确定删除「${company.name}」吗？`)) {
                            void handleDelete(company.id)
                          }
                        }}
                      >
                        删除
                      </button>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      )}
    </>
  )
}

function CategoryConfigTab() {
  const [categories, setCategories] = useState<Array<{ id: number; name: string; slug: string; sort_order: number }>>([])
  const [isLoading, setIsLoading] = useState(true)
  const [error, setError] = useState('')
  const [newName, setNewName] = useState('')
  const [newSlug, setNewSlug] = useState('')
  const [newSort, setNewSort] = useState(0)
  const [isAdding, setIsAdding] = useState(false)
  const [editingId, setEditingId] = useState<number | null>(null)
  const [editName, setEditName] = useState('')
  const [editSlug, setEditSlug] = useState('')
  const [editSort, setEditSort] = useState(0)
  const [isSaving, setIsSaving] = useState(false)

  const load = async () => {
    try {
      const data = await listCategories()
      setCategories(data)
    } catch (err) {
      setError(err instanceof Error ? err.message : '加载题型分类失败')
    } finally {
      setIsLoading(false)
    }
  }

  useEffect(() => {
    void load()
  }, [])

  const handleAdd = async () => {
    if (!newName.trim() || !newSlug.trim()) return
    setIsAdding(true)
    setError('')
    try {
      const created = await createCategory({ name: newName.trim(), slug: newSlug.trim(), sort_order: newSort })
      setCategories((current) => [...current, created])
      setNewName('')
      setNewSlug('')
      setNewSort(0)
    } catch (err) {
      setError(err instanceof Error ? err.message : '添加失败')
    } finally {
      setIsAdding(false)
    }
  }

  const startEdit = (cat: { id: number; name: string; slug: string; sort_order: number }) => {
    setEditingId(cat.id)
    setEditName(cat.name)
    setEditSlug(cat.slug)
    setEditSort(cat.sort_order)
  }

  const cancelEdit = () => {
    setEditingId(null)
  }

  const handleSaveEdit = async (id: number) => {
    setIsSaving(true)
    setError('')
    try {
      const updated = await updateCategory(id, { name: editName, slug: editSlug, sort_order: editSort })
      setCategories((current) => current.map((c) => (c.id === id ? updated : c)))
      setEditingId(null)
    } catch (err) {
      setError(err instanceof Error ? err.message : '保存失败')
    } finally {
      setIsSaving(false)
    }
  }

  const handleDelete = async (id: number) => {
    setError('')
    try {
      await deleteCategory(id)
      setCategories((current) => current.filter((c) => c.id !== id))
    } catch (err) {
      setError(err instanceof Error ? err.message : '删除失败')
    }
  }

  return (
    <>
      {error ? <div className="backend-note action-note">{error}</div> : null}

      <div className="detail-card" style={{ marginTop: 16 }}>
        <div className="filter-row" style={{ padding: '12px 16px', gap: 12 }}>
          <input
            type="text"
            placeholder="题型名称"
            value={newName}
            onChange={(e) => setNewName(e.target.value)}
            style={{ flex: 1 }}
          />
          <input
            type="text"
            placeholder="Slug"
            value={newSlug}
            onChange={(e) => setNewSlug(e.target.value)}
            style={{ flex: 1 }}
          />
          <input
            type="number"
            placeholder="排序"
            value={newSort}
            onChange={(e) => setNewSort(Number(e.target.value))}
            style={{ maxWidth: 80 }}
          />
          <button type="button" className="button primary" disabled={isAdding || !newName.trim() || !newSlug.trim()} onClick={() => void handleAdd()}>
            {isAdding ? '添加中...' : '新增'}
          </button>
        </div>
      </div>

      {isLoading ? (
        <div className="empty-panel" style={{ marginTop: 16 }}>正在加载题型分类...</div>
      ) : (
        <div className="detail-card" style={{ marginTop: 16 }}>
          <table className="data-table">
            <thead>
              <tr>
                <th style={{ width: 60 }}>#</th>
                <th>题型</th>
                <th>Slug</th>
                <th style={{ width: 80 }}>排序</th>
                <th style={{ width: 140 }}>操作</th>
              </tr>
            </thead>
            <tbody>
              {categories.length === 0 ? (
                <tr>
                  <td colSpan={5} style={{ textAlign: 'center', padding: 24, color: '#6b7280' }}>
                    暂无题型分类，请在上方添加。
                  </td>
                </tr>
              ) : (
                categories.map((cat) =>
                  editingId === cat.id ? (
                    <tr key={cat.id}>
                      <td>{cat.id}</td>
                      <td>
                        <input type="text" value={editName} onChange={(e) => setEditName(e.target.value)} style={{ width: '100%' }} />
                      </td>
                      <td>
                        <input type="text" value={editSlug} onChange={(e) => setEditSlug(e.target.value)} style={{ width: '100%' }} />
                      </td>
                      <td>
                        <input type="number" value={editSort} onChange={(e) => setEditSort(Number(e.target.value))} style={{ width: 60 }} />
                      </td>
                      <td>
                        <button type="button" className="button primary" style={{ marginRight: 6 }} disabled={isSaving} onClick={() => void handleSaveEdit(cat.id)}>
                          保存
                        </button>
                        <button type="button" className="button ghost" onClick={cancelEdit}>
                          取消
                        </button>
                      </td>
                    </tr>
                  ) : (
                    <tr key={cat.id}>
                      <td>{cat.sort_order}</td>
                      <td>{cat.name}</td>
                      <td><code>{cat.slug}</code></td>
                      <td>{cat.sort_order}</td>
                      <td>
                        <button type="button" className="button ghost" onClick={() => startEdit(cat)}>
                          编辑
                        </button>
                        <button
                          type="button"
                          className="button ghost"
                          onClick={() => {
                            if (window.confirm(`确定删除「${cat.name}」吗？`)) {
                              void handleDelete(cat.id)
                            }
                          }}
                        >
                          删除
                        </button>
                      </td>
                    </tr>
                  ),
                )
              )}
            </tbody>
          </table>
        </div>
      )}
    </>
  )
}

function AgentConfigTab() {
  const [agents, setAgents] = useState<AgentConfig[]>([])
  const [tools, setTools] = useState<ToolConfig[]>([])
  const [skills, setSkills] = useState<SkillConfig[]>([])
  const [isLoading, setIsLoading] = useState(true)
  const [error, setError] = useState('')
  const [editingAgent, setEditingAgent] = useState<AgentConfig | null>(null)
  const [isSaving, setIsSaving] = useState(false)
  const [message, setMessage] = useState('')

  useEffect(() => {
    void loadData()
  }, [])

  async function loadData() {
    setIsLoading(true)
    try {
      const [agentList, toolList, skillList] = await Promise.all([
        listAgents(),
        listTools(),
        listSkills(),
      ])
      setAgents(agentList)
      setTools(toolList)
      setSkills(skillList)
    } catch (e) {
      setError(e instanceof Error ? e.message : '加载 Agent 配置失败')
    } finally {
      setIsLoading(false)
    }
  }

  async function handleToggle(agent: AgentConfig) {
    setError('')
    try {
      const updated = await updateAgent(agent.id, { is_enabled: !agent.is_enabled })
      setAgents((prev) => prev.map((a) => (a.id === agent.id ? updated : a)))
    } catch (e) {
      setError(e instanceof Error ? e.message : '切换失败')
    }
  }

  function openEdit(agent: AgentConfig) {
    setEditingAgent({ ...agent })
    setMessage('')
  }

  function updateEditField<K extends keyof AgentConfig>(field: K, value: AgentConfig[K]) {
    if (!editingAgent) return
    setEditingAgent({ ...editingAgent, [field]: value })
  }

  function toggleToolId(toolId: number) {
    if (!editingAgent) return
    const current = editingAgent.tools.map((t) => t.id)
    const next = current.includes(toolId) ? current.filter((id) => id !== toolId) : [...current, toolId]
    updateEditField('tool_ids' as keyof AgentConfig, next as unknown as AgentConfig[keyof AgentConfig])
  }

  function toggleSkillId(skillId: number) {
    if (!editingAgent) return
    const current = editingAgent.skills.map((s) => s.id)
    const next = current.includes(skillId) ? current.filter((id) => id !== skillId) : [...current, skillId]
    updateEditField('skill_ids' as keyof AgentConfig, next as unknown as AgentConfig[keyof AgentConfig])
  }

  async function handleSave() {
    if (!editingAgent) return
    setIsSaving(true)
    setError('')
    try {
      const payload: Record<string, unknown> = {
        name: editingAgent.name,
        description: editingAgent.description,
        system_prompt: editingAgent.system_prompt,
        user_prompt_template: editingAgent.user_prompt_template,
        model: editingAgent.model,
        temperature: editingAgent.temperature,
        max_iterations: editingAgent.max_iterations,
        sort_order: editingAgent.sort_order,
        tool_ids: editingAgent.tools.map((t) => t.id),
        skill_ids: editingAgent.skills.map((s) => s.id),
      }
      const updated = await updateAgent(editingAgent.id, payload)
      setAgents((prev) => prev.map((a) => (a.id === editingAgent.id ? updated : a)))
      setEditingAgent(null)
      setMessage(`Agent "${updated.name}" 已更新`)
    } catch (e) {
      setError(e instanceof Error ? e.message : '保存失败')
    } finally {
      setIsSaving(false)
    }
  }

  return (
    <>
      {error ? <div className="backend-note action-note">{error}</div> : null}
      {message ? <div className="backend-note success-note">{message}</div> : null}

      {isLoading ? (
        <div className="empty-panel" style={{ marginTop: 16 }}>正在加载 Agent 配置...</div>
      ) : (
        <div className="detail-card" style={{ marginTop: 16 }}>
          <table style={{ width: '100%', borderCollapse: 'collapse' }}>
            <thead>
              <tr style={{ background: 'var(--bg-subtle)', textAlign: 'left' }}>
                <th style={{ width: 40, padding: '0 12px', height: 44, fontWeight: 600, fontSize: 13, textAlign: 'left' }}>#</th>
                <th style={{ width: 100, padding: '0 12px', height: 44, fontWeight: 600, fontSize: 13, textAlign: 'left' }}>名称</th>
                <th style={{ width: 140, padding: '0 12px', height: 44, fontWeight: 600, fontSize: 13, textAlign: 'left' }}>描述</th>
                <th style={{ width: 240, padding: '0 12px', height: 44, fontWeight: 600, fontSize: 13, textAlign: 'left' }}>模型</th>
                <th style={{ width: 50, padding: '0 12px', height: 44, fontWeight: 600, fontSize: 13, textAlign: 'left' }}>温度</th>
                <th style={{ width: 120, padding: '0 12px', height: 44, fontWeight: 600, fontSize: 13, textAlign: 'left' }}>状态</th>
                <th style={{ width: 130, padding: '0 12px', height: 44, fontWeight: 600, fontSize: 13, textAlign: 'left' }}>操作</th>
              </tr>
            </thead>
            <tbody>
              {agents.map((agent) => (
                <tr key={agent.id} style={{ borderBottom: '1px solid var(--border-default)', fontSize: 13 }}>
                  <td style={{ padding: '0 12px', height: 44, textAlign: 'left' }}>{agent.sort_order}</td>
                  <td style={{ padding: '0 12px', height: 44, textAlign: 'left', overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}><strong title={agent.slug}>{agent.name}</strong></td>
                  <td style={{ padding: '0 12px', height: 44, textAlign: 'left', overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }} title={agent.description}>
                    {agent.description}
                  </td>
                  <td style={{ padding: '0 12px', height: 44, textAlign: 'left' }}><code style={{ fontSize: '0.85rem' }}>{agent.model}</code></td>
                  <td style={{ padding: '0 12px', height: 44, textAlign: 'left' }}>{agent.temperature}</td>
                  <td style={{ padding: '0 12px', height: 44, textAlign: 'left' }}>
                    <span className={`status-badge ${agent.is_enabled ? 'status-ac' : ''}`}>
                      {agent.is_enabled ? '启用' : '禁用'}
                    </span>
                  </td>
                  <td style={{ padding: '0 12px', height: 44, textAlign: 'left', whiteSpace: 'nowrap' }}>
                    <button type="button" className="button ghost" onClick={() => openEdit(agent)}>编辑</button>
                    <button type="button" className="button ghost" onClick={() => void handleToggle(agent)}>
                      {agent.is_enabled ? '禁用' : '启用'}
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      {editingAgent && (
        <div className="modal-overlay" onClick={() => setEditingAgent(null)}>
          <div className="modal-content wide" onClick={(e) => e.stopPropagation()}>
            <h3>编辑 Agent: {editingAgent.name}</h3>

            <div className="settings-form-grid">
              <label className="settings-field">
                <span>启用</span>
                <select
                  value={editingAgent.is_enabled ? '1' : '0'}
                  onChange={(e) => setEditingAgent((prev) => prev ? { ...prev, is_enabled: e.target.value === '1' } : null)}
                >
                  <option value="1">是</option>
                  <option value="0">否</option>
                </select>
              </label>

              <label className="settings-field">
                <span>模型</span>
                <input
                  type="text"
                  value={editingAgent.model}
                  onChange={(e) => setEditingAgent((prev) => prev ? { ...prev, model: e.target.value } : null)}
                />
              </label>

              <label className="settings-field">
                <span>Temperature</span>
                <input
                  type="number"
                  step="0.1"
                  min={0}
                  max={2}
                  value={editingAgent.temperature}
                  onChange={(e) => setEditingAgent((prev) => prev ? { ...prev, temperature: Number(e.target.value) } : null)}
                />
              </label>

              <label className="settings-field">
                <span>最大 Tokens</span>
                <input
                  type="number"
                  min={1}
                  value={editingAgent.max_tokens}
                  onChange={(e) => setEditingAgent((prev) => prev ? { ...prev, max_tokens: Number(e.target.value) } : null)}
                />
              </label>
            </div>

            <div className="modal-footer">
              <button type="button" className="button ghost" onClick={() => setEditingAgent(null)}>取消</button>
              <button type="button" className="button primary" disabled={isSaving} onClick={() => void handleSave()}>
                {isSaving ? '保存中...' : '保存'}
              </button>
            </div>
          </div>
        </div>
      )}
    </>
  )
}

function BrowserConfigTab() {
  const [form, setForm] = useState<BrowserSettingsPayload>({
    headless: true,
    executable_path: '',
    viewport_width: 1280,
    viewport_height: 720,
    timeout_seconds: 30,
    user_data_dir: '',
    proxy_url: '',
  })
  const [isLoading, setIsLoading] = useState(true)
  const [isSaving, setIsSaving] = useState(false)
  const [message, setMessage] = useState('')

  useEffect(() => {
    const cancelled = { value: false }
    setIsLoading(true)
    getBrowserSettings()
      .then((settings) => {
        if (!cancelled.value) {
          setForm({
            headless: settings.headless,
            executable_path: settings.executable_path,
            viewport_width: settings.viewport_width,
            viewport_height: settings.viewport_height,
            timeout_seconds: settings.timeout_seconds,
            user_data_dir: settings.user_data_dir,
            proxy_url: settings.proxy_url,
          })
        }
      })
      .catch(() => {})
      .finally(() => { if (!cancelled.value) setIsLoading(false) })
    return () => { cancelled.value = true }
  }, [])

  const handleSave = async () => {
    setIsSaving(true)
    setMessage('')
    try {
      await updateBrowserSettings(form)
      setMessage('浏览器配置已保存')
    } catch {
      setMessage('保存失败')
    } finally {
      setIsSaving(false)
    }
  }

  if (isLoading) {
    return <div className="backend-note">加载中...</div>
  }

  return (
    <div className="settings-card">
      <h2>浏览器自动化配置</h2>
      <p style={{ color: 'var(--text-secondary)', marginBottom: 16 }}>
        配置 Playwright / Browserbase 浏览器自动化抓取参数。
      </p>

      <div className="settings-form-grid">
        <label className="settings-field">
          <span>无头模式</span>
          <select
            value={form.headless ? '1' : '0'}
            onChange={(e) => setForm((c) => ({ ...c, headless: e.target.value === '1' }))}
          >
            <option value="1">是</option>
            <option value="0">否</option>
          </select>
        </label>
        <label className="settings-field">
          <span>浏览器可执行路径</span>
          <input
            type="text"
            value={form.executable_path}
            placeholder="留空自动检测"
            onChange={(e) => setForm((c) => ({ ...c, executable_path: e.target.value }))}
          />
        </label>
        <label className="settings-field">
          <span>视口宽度</span>
          <input
            type="number"
            value={form.viewport_width}
            min={800}
            max={3840}
            onChange={(e) => setForm((c) => ({ ...c, viewport_width: Number(e.target.value) }))}
          />
        </label>
        <label className="settings-field">
          <span>视口高度</span>
          <input
            type="number"
            value={form.viewport_height}
            min={600}
            max={2160}
            onChange={(e) => setForm((c) => ({ ...c, viewport_height: Number(e.target.value) }))}
          />
        </label>
        <label className="settings-field">
          <span>超时秒数</span>
          <input
            type="number"
            value={form.timeout_seconds}
            min={5}
            max={300}
            onChange={(e) => setForm((c) => ({ ...c, timeout_seconds: Number(e.target.value) }))}
          />
        </label>
        <label className="settings-field">
          <span>用户数据目录</span>
          <input
            type="text"
            value={form.user_data_dir}
            placeholder="留空使用临时目录"
            onChange={(e) => setForm((c) => ({ ...c, user_data_dir: e.target.value }))}
          />
        </label>
        <label className="settings-field">
          <span>代理 URL</span>
          <input
            type="text"
            value={form.proxy_url}
            placeholder="可选"
            onChange={(e) => setForm((c) => ({ ...c, proxy_url: e.target.value }))}
          />
        </label>
      </div>

      <div className="settings-actions">
        <button className="button primary" disabled={isSaving} onClick={() => { void handleSave() }}>
          {isSaving ? '保存中...' : '保存配置'}
        </button>
      </div>

      {message && (
        <div className="backend-note success" style={{ marginTop: 12 }}>{message}</div>
      )}
    </div>
  )
}

function IndustryCategoryTab() {
  const [categories, setCategories] = useState<IndustryCategory[]>([])
  const [newName, setNewName] = useState('')
  const [editingId, setEditingId] = useState<number | null>(null)
  const [editName, setEditName] = useState('')
  const [isSaving, setIsSaving] = useState(false)
  const [error, setError] = useState('')

  const load = () => { listIndustryCategories().then(setCategories).catch(() => {}) }
  useEffect(() => { load() }, [])

  const handleAdd = async () => {
    const name = newName.trim()
    if (!name) { setError('类别名称不能为空'); return }
    setError('')
    setIsSaving(true)
    try {
      await createIndustryCategory({ name })
      setNewName('')
      load()
    } catch (err: unknown) {
      setError(err instanceof Error ? err.message : '添加失败')
    } finally {
      setIsSaving(false)
    }
  }

  const handleSaveEdit = async (id: number) => {
    const name = editName.trim()
    if (!name) { setError('类别名称不能为空'); return }
    setError('')
    setIsSaving(true)
    try {
      await updateIndustryCategory(id, { name })
      setEditingId(null)
      load()
    } catch (err: unknown) {
      setError(err instanceof Error ? err.message : '保存失败')
    } finally {
      setIsSaving(false)
    }
  }

  const handleDelete = async (id: number) => {
    if (!window.confirm('确定删除该行业类别吗？')) return
    try {
      await deleteIndustryCategory(id)
      load()
    } catch (err: unknown) {
      setError(err instanceof Error ? err.message : '删除失败')
    }
  }

  const startEdit = (cat: IndustryCategory) => {
    setEditingId(cat.id)
    setEditName(cat.name)
    setError('')
  }

  return (
    <div className="detail-card">
      <h3>行业类别</h3>
      <p className="hint" style={{ marginBottom: 12 }}>定义官网管理中使用的行业类别选项。</p>

      <div style={{ display: 'flex', gap: 8, marginBottom: 16 }}>
        <input
          type="text"
          value={newName}
          onChange={(e) => setNewName(e.target.value)}
          placeholder="输入新类别名称"
          style={{ flex: 1 }}
          onKeyDown={(e) => { if (e.key === 'Enter') { e.preventDefault(); void handleAdd() } }}
        />
        <button type="button" className="button primary" disabled={isSaving} onClick={() => { void handleAdd() }}>
          添加
        </button>
      </div>

      {error && <div className="error-msg" style={{ marginBottom: 8 }}>{error}</div>}

      <table className="data-table">
        <thead>
          <tr>
            <th style={{ width: 60 }}>#</th>
            <th>类别名称</th>
            <th style={{ width: 140 }}>操作</th>
          </tr>
        </thead>
        <tbody>
          {categories.length === 0 ? (
            <tr>
              <td colSpan={3} style={{ textAlign: 'center', padding: 24, color: '#6b7280' }}>
                暂无行业类别，请在上方添加。
              </td>
            </tr>
          ) : (
            categories.map((cat) =>
              editingId === cat.id ? (
                <tr key={cat.id}>
                  <td>{cat.id}</td>
                  <td>
                    <input
                      type="text"
                      value={editName}
                      onChange={(e) => setEditName(e.target.value)}
                      style={{ width: '100%' }}
                      onKeyDown={(e) => { if (e.key === 'Enter') { e.preventDefault(); void handleSaveEdit(cat.id) } }}
                    />
                  </td>
                  <td>
                    <button type="button" className="button primary" style={{ marginRight: 6 }} disabled={isSaving} onClick={() => { void handleSaveEdit(cat.id) }}>
                      保存
                    </button>
                    <button type="button" className="button ghost" onClick={() => setEditingId(null)}>
                      取消
                    </button>
                  </td>
                </tr>
              ) : (
                <tr key={cat.id}>
                  <td>{cat.id}</td>
                  <td>{cat.name}</td>
                  <td>
                    <button type="button" className="button ghost" onClick={() => startEdit(cat)}>
                      编辑
                    </button>
                    <button type="button" className="button ghost" onClick={() => { void handleDelete(cat.id) }}>
                      删除
                    </button>
                  </td>
                </tr>
              ),
            )
          )}
        </tbody>
      </table>
    </div>
  )
}
