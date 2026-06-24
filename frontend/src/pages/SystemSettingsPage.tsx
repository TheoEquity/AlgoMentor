import { useEffect, useState } from 'react'

import { getLLMSettings, updateLLMSettings } from '../lib/llmSettingsApi'
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
    <section className="settings-layout">
      <div className="page-header">
        <div>
          <h1>系统管理</h1>
          <p>集中配置 AI 解题分析、错误归因和复盘所使用的 LLM 模型。</p>
        </div>

        <div className="summary-strip">
          <span className="summary-pill">Provider: {form.provider}</span>
          <span className="summary-pill">更新于 {updatedAt || '未加载'}</span>
          <span className="summary-pill">API Key: {apiKeyStatus}</span>
          <span className={`summary-pill ${form.enabled ? 'summary-pill-active' : ''}`}>{form.enabled ? 'AI 已启用' : 'AI 已停用'}</span>
        </div>
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
    </section>
  )
}
