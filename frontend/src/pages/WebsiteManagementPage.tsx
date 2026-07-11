import { useEffect, useState } from 'react'
import { createSite, deleteSite, fetchSites, listIndustryCategories, updateSite } from '../lib/websiteApi'
import type { CareerSite, IndustryCategory } from '../types/website'

type EditState = {
  company_name: string
  url: string
  industry_category: string
  referral_code: string
  account: string
  password: string
}

const emptyEdit: EditState = { company_name: '', url: '', industry_category: '', referral_code: '', account: '', password: '' }

export function WebsiteManagementPage() {
  const [sites, setSites] = useState<CareerSite[]>([])
  const [categories, setCategories] = useState<IndustryCategory[]>([])
  const [editingId, setEditingId] = useState<number | null>(null)
  const [edit, setEdit] = useState<EditState>(emptyEdit)
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(false)

  const loadSites = () => { fetchSites().then(setSites).catch(() => {}) }
  useEffect(() => {
    loadSites()
    listIndustryCategories().then(setCategories).catch(() => {})
  }, [])

  const startNew = () => {
    setEditingId(0)
    setEdit(emptyEdit)
    setError('')
  }

  const startEdit = (site: CareerSite) => {
    setEditingId(site.id)
    setEdit({
      company_name: site.company_name,
      url: site.url,
      industry_category: site.industry_category,
      referral_code: site.referral_code,
      account: site.account,
      password: site.password,
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
      url: edit.url.trim(),
      industry_category: edit.industry_category,
      referral_code: edit.referral_code.trim(),
      account: edit.account.trim(),
      password: edit.password.trim(),
    }
    if (!payload.company_name || !payload.url) {
      setError('公司名称和 URL 不能为空')
      return
    }

    setError('')
    setLoading(true)
    try {
      if (editingId === 0) {
        await createSite({ ...payload, notes: '' })
      } else {
        await updateSite(editingId!, payload)
      }
      cancelEdit()
      loadSites()
    } catch (err: unknown) {
      setError(err instanceof Error ? err.message : '操作失败')
    } finally {
      setLoading(false)
    }
  }

  const handleDelete = (siteId: number) => {
    if (!window.confirm('确认删除该官网？关联的岗位也将被删除。')) return
    void deleteSite(siteId).then(loadSites)
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
          <h1>官网管理</h1>
          <p>管理目标公司校招官网链接。</p>
        </div>
      </div>

      {error && <div className="error-msg" style={{ marginTop: 12 }}>{error}</div>}

      <div className="detail-card" style={{ marginTop: 16 }}>
        <div className="card-header" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <h3>官网列表</h3>
          <button type="button" className="button primary" onClick={startNew} disabled={editing}>
            + 新增
          </button>
        </div>

        <table className="data-table" style={{ tableLayout: 'fixed', width: '100%' }}>
          <thead>
            <tr>
              <th style={{ width: 110 }}>行业类别</th>
              <th style={{ width: 140 }}>公司名称</th>
              <th>校招官网</th>
              <th style={{ width: 130 }}>内推码</th>
              <th style={{ width: 100 }}>账号</th>
              <th style={{ width: 100 }}>密码</th>
              <th style={{ width: 140 }}>操作</th>
            </tr>
          </thead>
          <tbody>
            {editing && isNew && (
              <tr>
                <td>
                  <select
                    value={edit.industry_category}
                    onChange={(e) => setEdit((p) => ({ ...p, industry_category: e.target.value }))}
                    onKeyDown={handleKeyDown}
                    style={{ width: '100%' }}
                  >
                    <option value="">请选择</option>
                    {categories.map((c) => (
                      <option key={c.id} value={c.name}>{c.name}</option>
                    ))}
                  </select>
                </td>
                <td>
                  <input
                    value={edit.company_name}
                    onChange={(e) => setEdit((p) => ({ ...p, company_name: e.target.value }))}
                    onKeyDown={handleKeyDown}
                    placeholder="公司名称"
                    style={{ width: '100%' }}
                  />
                </td>
                <td>
                  <input
                    value={edit.url}
                    onChange={(e) => setEdit((p) => ({ ...p, url: e.target.value }))}
                    onKeyDown={handleKeyDown}
                    placeholder="https://"
                    style={{ width: '100%' }}
                  />
                </td>
                <td>
                  <input
                    value={edit.referral_code}
                    onChange={(e) => setEdit((p) => ({ ...p, referral_code: e.target.value }))}
                    onKeyDown={handleKeyDown}
                    placeholder="内推码"
                    style={{ width: '100%' }}
                  />
                </td>
                <td>
                  <input
                    value={edit.account}
                    onChange={(e) => setEdit((p) => ({ ...p, account: e.target.value }))}
                    onKeyDown={handleKeyDown}
                    placeholder="账号"
                    style={{ width: '100%' }}
                  />
                </td>
                <td>
                  <input
                    value={edit.password}
                    onChange={(e) => setEdit((p) => ({ ...p, password: e.target.value }))}
                    onKeyDown={handleKeyDown}
                    placeholder="密码"
                    style={{ width: '100%' }}
                  />
                </td>
                <td>
                  <button type="button" className="button primary small" style={{ marginRight: 6 }} disabled={loading} onClick={() => { void handleSave() }}>
                    {loading ? '...' : '保存'}
                  </button>
                  <button type="button" className="button ghost small" onClick={cancelEdit}>取消</button>
                </td>
              </tr>
            )}
            {sites.length === 0 && !editing ? (
              <tr>
                <td colSpan={7} style={{ textAlign: 'center', padding: 24, color: '#6b7280' }}>
                  暂无官网数据，请点击右上角「新增」添加。
                </td>
              </tr>
            ) : (
              sites.map((site) =>
                editing && editingId === site.id ? (
                  <tr key={site.id}>
                    <td>
                      <select
                        value={edit.industry_category}
                        onChange={(e) => setEdit((p) => ({ ...p, industry_category: e.target.value }))}
                        onKeyDown={handleKeyDown}
                        style={{ width: '100%' }}
                      >
                        <option value="">请选择</option>
                        {categories.map((c) => (
                          <option key={c.id} value={c.name}>{c.name}</option>
                        ))}
                      </select>
                    </td>
                    <td>
                      <input
                        value={edit.company_name}
                        onChange={(e) => setEdit((p) => ({ ...p, company_name: e.target.value }))}
                        onKeyDown={handleKeyDown}
                        style={{ width: '100%' }}
                      />
                    </td>
                    <td>
                      <input
                        value={edit.url}
                        onChange={(e) => setEdit((p) => ({ ...p, url: e.target.value }))}
                        onKeyDown={handleKeyDown}
                        style={{ width: '100%' }}
                      />
                    </td>
                    <td>
                      <input
                        value={edit.referral_code}
                        onChange={(e) => setEdit((p) => ({ ...p, referral_code: e.target.value }))}
                        onKeyDown={handleKeyDown}
                        style={{ width: '100%' }}
                      />
                    </td>
                    <td>
                      <input
                        value={edit.account}
                        onChange={(e) => setEdit((p) => ({ ...p, account: e.target.value }))}
                        onKeyDown={handleKeyDown}
                        style={{ width: '100%' }}
                      />
                    </td>
                    <td>
                      <input
                        value={edit.password}
                        onChange={(e) => setEdit((p) => ({ ...p, password: e.target.value }))}
                        onKeyDown={handleKeyDown}
                        style={{ width: '100%' }}
                      />
                    </td>
                    <td>
                      <button type="button" className="button primary small" style={{ marginRight: 6 }} disabled={loading} onClick={() => { void handleSave() }}>
                        {loading ? '...' : '保存'}
                      </button>
                      <button type="button" className="button ghost small" onClick={cancelEdit}>取消</button>
                    </td>
                  </tr>
                ) : (
                  <tr key={site.id}>
                    <td>
                      <span className="chip">{site.industry_category || '-'}</span>
                    </td>
                    <td><strong>{site.company_name}</strong></td>
                    <td style={{ overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
                      <a href={site.url} target="_blank" rel="noreferrer" className="link">{site.url}</a>
                    </td>
                    <td>{site.referral_code || '-'}</td>
                    <td>{site.account || '-'}</td>
                    <td>{site.password || '-'}</td>
                    <td>
                      <button className="button small ghost" onClick={() => startEdit(site)}>编辑</button>
                      <button className="button small ghost danger" onClick={() => handleDelete(site.id)}>删除</button>
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
