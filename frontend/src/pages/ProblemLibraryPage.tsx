import { useEffect, useMemo, useState } from 'react'

import { createProblem, deleteProblem, listProblems } from '../lib/problemApi'
import { listCategories } from '../lib/categoryApi'
import { listCompanies } from '../lib/companyApi'
import type { ProblemCategory } from '../types/problemCategory'
import type { Company } from '../types/company'
import type { ProblemCreatePayload, ProblemListItem } from '../types/problem'

type ProblemLibraryPageProps = {
  onOpenProblem: (problemId: number) => void
}

export function ProblemLibraryPage({ onOpenProblem }: ProblemLibraryPageProps) {
  const [problems, setProblems] = useState<ProblemListItem[]>([])
  const [companies, setCompanies] = useState<Company[]>([])
  const [categories, setCategories] = useState<ProblemCategory[]>([])
  const [searchText, setSearchText] = useState('')
  const [company, setCompany] = useState('all')
  const [categorySlug, setCategorySlug] = useState('all')
  const [difficulty, setDifficulty] = useState('all')
  const [showCreatePanel, setShowCreatePanel] = useState(false)
  const [createError, setCreateError] = useState('')
  const [createSuccess, setCreateSuccess] = useState('')
  const [deleteError, setDeleteError] = useState('')
  const [isCreating, setIsCreating] = useState(false)
  const [form, setForm] = useState({
    slug: '',
    title: '',
    company: '',
    category_slug: '',
    difficulty: 'Medium' as 'Easy' | 'Medium' | 'Hard',
    statement_markdown: '',
    tags_text: '',
    source_type: 'manual',
    source: '手工',
    frequency: '中',
    year: '2026',
    source_ref: '',
    external_id: '',
    time_limit_ms: '2000',
    memory_limit_kb: '262144',
    hidden_input: '',
    hidden_output: '',
    python_template: 'def solve() -> None:\n    pass\n',
    cpp_template: '#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}\n',
    java_template: 'public class Main {\n    public static void main(String[] args) throws Exception {\n    }\n}\n',
  })

  useEffect(() => {
    void Promise.all([
      listProblems().then(setProblems),
      listCompanies().then(setCompanies).catch(() => {}),
      listCategories().then(setCategories).catch(() => {}),
    ])
  }, [])

  const handleCreateField = (field: keyof typeof form, value: string) => {
    setForm((current) => ({
      ...current,
      [field]: value,
    }))
  }

  const resetCreateForm = () => {
    setForm({
      slug: '',
      title: '',
      company: '',
      category_slug: '',
      difficulty: 'Medium',
      statement_markdown: '',
      tags_text: '',
      source_type: 'manual',
      source: '手工',
      frequency: '中',
      year: '2026',
      source_ref: '',
      external_id: '',
      time_limit_ms: '2000',
      memory_limit_kb: '262144',
      hidden_input: '',
      hidden_output: '',
      python_template: 'def solve() -> None:\n    pass\n',
      cpp_template: '#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}\n',
      java_template: 'public class Main {\n    public static void main(String[] args) throws Exception {\n    }\n}\n',
    })
  }

  const handleCreateProblem = async () => {
    setIsCreating(true)
    setCreateError('')
    setCreateSuccess('')

    const tags = form.tags_text
      .split(/[，,]/)
      .map((item) => item.trim())
      .filter(Boolean)

    const payload: ProblemCreatePayload = {
      slug: form.slug.trim(),
      title: form.title.trim(),
      company: form.company.trim(),
      category_slug: form.category_slug.trim(),
      difficulty: form.difficulty,
      statement_markdown: form.statement_markdown.trim(),
      constraints_text: '',
      tags,
      time_limit_ms: Number(form.time_limit_ms) || 2000,
      memory_limit_kb: Number(form.memory_limit_kb) || 262144,
      examples: [],
      supported_languages: ['Python', 'C++', 'Java'],
      starter_templates: {
        Python: form.python_template,
        'C++': form.cpp_template,
        Java: form.java_template,
      },
      source_type: form.source_type.trim() || 'manual',
      source: form.source.trim() || '手工',
      frequency: form.frequency.trim() || '中',
      year: form.year.trim() ? Number(form.year) : null,
      source_ref: form.source_ref.trim(),
      external_id: form.external_id.trim(),
      status: '未开始',
      test_cases: [
        {
          case_type: 'hidden',
          stdin_text: form.hidden_input || 'hidden\n1 2 3',
          expected_output_text: form.hidden_output || '0',
          sort_order: 1,
        },
      ],
    }

    try {
      const created = await createProblem(payload)
      setProblems((current) => [created, ...current])
      setCreateSuccess(`题目已创建：#${created.id} ${created.title}`)
      resetCreateForm()
      setShowCreatePanel(false)
    } catch (error) {
      setCreateError(error instanceof Error ? error.message : '录题失败')
    } finally {
      setIsCreating(false)
    }
  }

  const handleDeleteProblem = async (problem: ProblemListItem) => {
    setDeleteError('')
    const confirmed = window.confirm(`确认删除题目「${problem.title}」？`)
    if (!confirmed) {
      return
    }

    try {
      await deleteProblem(problem.id)
      setProblems((current) => current.filter((item) => item.id !== problem.id))
    } catch (error) {
      setDeleteError(error instanceof Error ? error.message : '删除失败')
    }
  }

  const filteredProblems = useMemo(() => {
    return problems.filter((problem) => {
      const matchesSearch =
        searchText.length === 0 ||
        problem.title.includes(searchText) ||
        problem.company.includes(searchText) ||
        problem.tags.some((tag) => tag.includes(searchText))

      const matchesCompany = company === 'all' || problem.company === company
      const matchesCategory = categorySlug === 'all' || problem.category_slug === categorySlug
      const matchesDifficulty = difficulty === 'all' || problem.difficulty === difficulty

      return matchesSearch && matchesCompany && matchesCategory && matchesDifficulty
    })
  }, [company, categorySlug, difficulty, problems, searchText])

  const companyNames = Array.from(new Set(problems.map((problem) => problem.company)))
  const categoryNames: { slug: string; name: string }[] = categories.map((c) => ({ slug: c.slug, name: c.name }))
  const categoryNameBySlug = new Map(categoryNames.map((category) => [category.slug, category.name]))

  return (
    <section>
      <div className="page-header">
        <div>
          <h1>题库</h1>
          <p>顶部筛选加传统表格布局，作为 ByteHunter 前端骨架的首个页面。</p>
        </div>

        <div className="summary-strip" aria-label="题库摘要">
          <span className="summary-pill">{companies.length} 家公司</span>
          <span className="summary-pill">{problems.length} 道首批题</span>
          <span className="summary-pill">{filteredProblems.length} 条当前结果</span>
        </div>
      </div>

      <div className="filter-card" aria-label="题库筛选">
        <div className="filter-row">
          <label className="filter-control">
            <input
              type="search"
              placeholder="搜索题目标题"
              value={searchText}
              onChange={(event) => setSearchText(event.target.value)}
            />
          </label>

          <label className="filter-control">
            <select value={company} onChange={(event) => setCompany(event.target.value)}>
              <option value="all">全部公司</option>
              {companyNames.map((item) => (
                <option key={item} value={item}>
                  {item}
                </option>
              ))}
            </select>
          </label>

          <label className="filter-control">
            <select value={categorySlug} onChange={(event) => setCategorySlug(event.target.value)}>
              <option value="all">全部题型</option>
              {categoryNames.map((item) => (
                <option key={item.slug} value={item.slug}>
                  {item.name}
                </option>
              ))}
            </select>
          </label>

          <label className="filter-control">
            <select value={difficulty} onChange={(event) => setDifficulty(event.target.value)}>
              <option value="all">全部难度</option>
              <option value="Easy">Easy</option>
              <option value="Medium">Medium</option>
              <option value="Hard">Hard</option>
            </select>
          </label>
        </div>

        <div className="toolbar-row">
          <label className="filter-control">
            <select defaultValue="frequency">
              <option value="frequency">按频率排序</option>
              <option value="recent">按最近训练</option>
              <option value="difficulty">按难度</option>
            </select>
          </label>

          <label className="filter-control">
              <select defaultValue="all">
                <option value="all">全部最新状态</option>
                <option value="pending">未开始</option>
                <option value="ac">已通过</option>
                <option value="review">待复盘</option>
                <option value="wa">待修正</option>
            </select>
          </label>

          <div className="button-row">
            <button
              type="button"
              className="button ghost"
              onClick={() => {
                setSearchText('')
                setCompany('all')
                setCategorySlug('all')
                setDifficulty('all')
              }}
            >
              重置
            </button>
            <button type="button" className="button">
              导出题单
            </button>
            <button
              type="button"
              className="button primary"
              onClick={() => {
                setShowCreatePanel((current) => !current)
                setCreateError('')
                setCreateSuccess('')
              }}
            >
              {showCreatePanel ? '收起录题' : '手工录题'}
            </button>
          </div>
        </div>
      </div>

      {showCreatePanel ? (
        <div className="table-card create-problem-panel">
          <div className="training-card-header">
            <div>
              <strong>手工录题</strong>
              <span>首版直接录入题面、样例、隐藏测试点与三种语言模板。</span>
            </div>
          </div>
          <div className="settings-form-grid create-problem-grid">
            <label className="settings-field">
              <span>Slug</span>
              <input value={form.slug} onChange={(event) => handleCreateField('slug', event.target.value)} />
            </label>
            <label className="settings-field">
              <span>标题</span>
              <input value={form.title} onChange={(event) => handleCreateField('title', event.target.value)} />
            </label>
            <label className="settings-field">
              <span>公司</span>
              <input value={form.company} onChange={(event) => handleCreateField('company', event.target.value)} />
            </label>
            <label className="settings-field">
              <span>题型 Slug</span>
              <input value={form.category_slug} onChange={(event) => handleCreateField('category_slug', event.target.value)} placeholder="two-pointers" />
            </label>
            <label className="settings-field">
              <span>难度</span>
              <select
                value={form.difficulty}
                onChange={(event) =>
                  setForm((current) => ({
                    ...current,
                    difficulty: event.target.value as 'Easy' | 'Medium' | 'Hard',
                  }))
                }
              >
                <option value="Easy">Easy</option>
                <option value="Medium">Medium</option>
                <option value="Hard">Hard</option>
              </select>
            </label>
            <label className="settings-field">
              <span>标签</span>
              <input
                value={form.tags_text}
                onChange={(event) => handleCreateField('tags_text', event.target.value)}
                placeholder="数组, 前缀和, 双指针"
              />
            </label>
            <label className="settings-field settings-field-full">
              <span>题目正文</span>
              <textarea
                className="settings-textarea"
                rows={12}
                value={form.statement_markdown}
                onChange={(event) => handleCreateField('statement_markdown', event.target.value)}
              />
            </label>
            <label className="settings-field">
              <span>时间限制 (ms)</span>
              <input value={form.time_limit_ms} onChange={(event) => handleCreateField('time_limit_ms', event.target.value)} />
            </label>
            <label className="settings-field">
              <span>空间限制 (KB)</span>
              <input value={form.memory_limit_kb} onChange={(event) => handleCreateField('memory_limit_kb', event.target.value)} />
            </label>
            <label className="settings-field settings-field-full">
              <span>隐藏测试输入</span>
              <textarea className="settings-textarea" value={form.hidden_input} onChange={(event) => handleCreateField('hidden_input', event.target.value)} />
            </label>
            <label className="settings-field settings-field-full">
              <span>隐藏测试输出</span>
              <textarea className="settings-textarea" value={form.hidden_output} onChange={(event) => handleCreateField('hidden_output', event.target.value)} />
            </label>
            <label className="settings-field">
              <span>来源类型</span>
              <input value={form.source_type} onChange={(event) => handleCreateField('source_type', event.target.value)} />
            </label>
            <label className="settings-field">
              <span>来源</span>
              <select value={form.source} onChange={(event) => handleCreateField('source', event.target.value)}>
                <option value="牛客">牛客</option>
                <option value="Leetcode">Leetcode</option>
                <option value="手工">手工</option>
                <option value="AI派生">AI派生</option>
              </select>
            </label>
            <label className="settings-field">
              <span>频率</span>
              <select value={form.frequency} onChange={(event) => handleCreateField('frequency', event.target.value)}>
                <option value="高">高</option>
                <option value="中">中</option>
                <option value="低">低</option>
              </select>
            </label>
            <label className="settings-field">
              <span>年度</span>
              <input value={form.year} onChange={(event) => handleCreateField('year', event.target.value)} />
            </label>
            <label className="settings-field">
              <span>来源引用</span>
              <input value={form.source_ref} onChange={(event) => handleCreateField('source_ref', event.target.value)} />
            </label>
            <label className="settings-field settings-field-full">
              <span>外部编号</span>
              <input value={form.external_id} onChange={(event) => handleCreateField('external_id', event.target.value)} />
            </label>
            <label className="settings-field settings-field-full">
              <span>Python 模板</span>
              <textarea className="settings-textarea settings-codearea" value={form.python_template} onChange={(event) => handleCreateField('python_template', event.target.value)} />
            </label>
            <label className="settings-field settings-field-full">
              <span>C++ 模板</span>
              <textarea className="settings-textarea settings-codearea" value={form.cpp_template} onChange={(event) => handleCreateField('cpp_template', event.target.value)} />
            </label>
            <label className="settings-field settings-field-full">
              <span>Java 模板</span>
              <textarea className="settings-textarea settings-codearea" value={form.java_template} onChange={(event) => handleCreateField('java_template', event.target.value)} />
            </label>
          </div>
          <div className="settings-actions button-row create-problem-actions">
            <button
              type="button"
              className="button ghost"
              onClick={() => {
                resetCreateForm()
                setCreateError('')
                setCreateSuccess('')
              }}
            >
              清空表单
            </button>
            <button type="button" className="button primary" disabled={isCreating} onClick={() => void handleCreateProblem()}>
              {isCreating ? '录入中...' : '提交题目'}
            </button>
          </div>
        </div>
      ) : null}

      {createError ? <div className="backend-note">录题失败：{createError}</div> : null}
      {deleteError ? <div className="backend-note">删除失败：{deleteError}</div> : null}
      {createSuccess ? <div className="backend-note success-note">{createSuccess}</div> : null}

      <div className="table-card">
        <div className="table-scroll">
          <table className="problem-table">
            <thead>
              <tr>
                <th>题目</th>
                <th>题型</th>
                <th className="problem-tags-column">标签</th>
                <th>公司</th>
                <th>难度</th>
                <th>频率</th>
                <th>年度</th>
                <th>来源</th>
                <th>最新状态</th>
                <th>操作</th>
              </tr>
            </thead>
            <tbody>
              {filteredProblems.map((problem) => (
                <tr key={problem.id}>
                  <td>
                    <div className="problem-title">
                      <div>
                        <strong>{problem.title}</strong>
                        <div>
                          <span>{problem.id}</span>
                        </div>
                      </div>
                    </div>
                  </td>
                  <td>{categoryNameBySlug.get(problem.category_slug) || problem.category_slug || '-'}</td>
                  <td className="problem-tags-column">
                    <div className="tag-list">
                      {problem.tags.map((tag) => (
                        <span key={tag} className="tag-badge">
                          {tag}
                        </span>
                      ))}
                    </div>
                  </td>
                  <td>{problem.company}</td>
                  <td>{problem.difficulty}</td>
                  <td>{problem.frequency}</td>
                  <td>{problem.year || '-'}</td>
                  <td>{problem.source}</td>
                  <td>
                    <span className={`status-badge ${problem.status === '已通过' ? 'ac' : problem.status === '待修正' ? 'wa' : 'review'}`}>
                      {problem.status}
                    </span>
                  </td>
                  <td>
                    <div className="table-actions">
                      <button type="button" className="link-button" onClick={() => onOpenProblem(problem.id)}>
                        编辑
                      </button>
                      <button type="button" className="icon-danger-button" aria-label={`删除 ${problem.title}`} onClick={() => void handleDeleteProblem(problem)}>
                        <svg viewBox="0 0 24 24" aria-hidden="true" focusable="false">
                          <path d="M9 3h6l1 2h4v2H4V5h4l1-2Zm1 6h2v9h-2V9Zm4 0h2v9h-2V9ZM7 9h2l1 11h4l1-11h2l-1.2 13H8.2L7 9Z" />
                        </svg>
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>

        <div className="table-footer">
          <span>显示 1 - {filteredProblems.length} / {problems.length} 道题</span>
          <div className="table-footer-actions">
            <button type="button" className="button ghost">
              上一页
            </button>
            <button type="button" className="button">
              下一页
            </button>
          </div>
        </div>
      </div>

      <div className="backend-note">当前页面优先请求 <code>/api/v1/problems</code>，接口不可用时回退到本地种子数据。</div>
    </section>
  )
}
