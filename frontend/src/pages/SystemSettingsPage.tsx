import { useEffect, useState } from 'react'

import { getLLMSettings, updateLLMSettings } from '../lib/llmSettingsApi'
import { createCompany, deleteCompany, listCompanies } from '../lib/companyApi'
import { createCategory, deleteCategory, listCategories, updateCategory } from '../lib/categoryApi'
import type { LLMProvider, LLMSettingsPayload } from '../types/llmSettings'

const defaultForm: LLMSettingsPayload = {
  provider: 'OpenAI Compatible',
  endpoint_url: 'https://api.openai.com/v1',
  solution_model: 'gpt-4.1-mini',
  attribution_model: 'gpt-4.1-mini',
  review_model: 'gpt-4.1-mini',
  solution_temperature: 0.2,
  attribution_temperature: 0.1,
  review_temperature: 0.3,
  enabled: true,
  api_key: '',
  clear_api_key: false,
}

export function SystemSettingsPage() {
  const [activeTab, setActiveTab] = useState<'llm' | 'company' | 'category'>('llm')

  return (
    <section className="settings-layout">
      <div className="page-header">
        <div>
          <h1>系统管理</h1>
          <p>集中配置 AI 模型、题库公司与题型分类。</p>
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
      </nav>

      {activeTab === 'llm' && <LLMConfigTab />}
      {activeTab === 'company' && <CompanyConfigTab />}
      {activeTab === 'category' && <CategoryConfigTab />}
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
        attribution_model: settings.attribution_model,
        review_model: settings.review_model,
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

            <label className="settings-field settings-field-full">
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
          </div>
        </section>

        <section className="detail-card settings-card settings-card-full">
          <h2>温度参数</h2>

          <div className="settings-form-grid">
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
          <table className="data-table">
            <thead>
              <tr>
                <th>#</th>
                <th>公司名称</th>
                <th>英文名</th>
                <th>简称</th>
                <th>操作</th>
              </tr>
            </thead>
            <tbody>
              {companies.length === 0 ? (
                <tr>
                  <td colSpan={5} style={{ textAlign: 'center', padding: 24, color: '#6b7280' }}>
                    暂无公司记录，请在上方添加。
                  </td>
                </tr>
              ) : (
                companies.map((company) => (
                  <tr key={company.id}>
                    <td>{company.id}</td>
                    <td>{company.name}</td>
                    <td>{company.name_en || '-'}</td>
                    <td>{company.abbreviation || '-'}</td>
                    <td>
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
