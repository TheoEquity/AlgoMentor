import { useEffect, useMemo, useRef, useState } from 'react'

import { createProblem, deleteProblem, fetchDistinctCompanies, fetchDistinctPositions, listProblems } from '../lib/problemApi'
import { listCategories } from '../lib/categoryApi'
import { listCompanies } from '../lib/companyApi'
import type { ProblemCategory } from '../types/problemCategory'
import type { Company } from '../types/company'
import type { ProblemCreatePayload, ProblemListItem } from '../types/problem'

type ProblemLibraryPageProps = {
  onOpenProblem: (problemId: number) => void
  onCreateProblem: () => void
}

export function ProblemLibraryPage({ onOpenProblem, onCreateProblem }: ProblemLibraryPageProps) {
  const [problems, setProblems] = useState<ProblemListItem[]>([])
  const [totalCount, setTotalCount] = useState(0)
  const [currentPage, setCurrentPage] = useState(1)
  const [isLoading, setIsLoading] = useState(false)
  const pageSize = 15
  const [jumpValue, setJumpValue] = useState('')
  const totalPages = Math.max(1, Math.ceil(totalCount / pageSize))

  const buildPageNumbers = (): (number | 'ellipsis')[] => {
    const pages: (number | 'ellipsis')[] = []
    const tp = totalPages
    if (tp <= 7) {
      for (let i = 1; i <= tp; i++) pages.push(i)
      return pages
    }
    if (currentPage <= 3) {
      for (let i = 1; i <= 5; i++) pages.push(i)
      pages.push('ellipsis')
      pages.push(tp)
    } else if (currentPage >= tp - 2) {
      pages.push(1)
      pages.push('ellipsis')
      for (let i = tp - 4; i <= tp; i++) pages.push(i)
    } else {
      pages.push(1)
      pages.push('ellipsis')
      for (let i = currentPage - 1; i <= currentPage + 1; i++) pages.push(i)
      pages.push('ellipsis')
      pages.push(tp)
    }
    return pages
  }

  const handleJump = () => {
    const n = parseInt(jumpValue, 10)
    if (n >= 1 && n <= totalPages) {
      setCurrentPage(n)
    }
    setJumpValue('')
  }
  const [companies, setCompanies] = useState<Company[]>([])
  const [categories, setCategories] = useState<ProblemCategory[]>([])
  const [distinctCompanies, setDistinctCompanies] = useState<string[]>([])
  const [distinctPositions, setDistinctPositions] = useState<string[]>([])
  const [searchText, setSearchText] = useState('')
  const [company, setCompany] = useState('all')
  const [categorySlug, setCategorySlug] = useState('all')
  const [difficulty, setDifficulty] = useState('all')
  const [positionFilter, setPositionFilter] = useState('all')
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

  const prevFiltersRef = useRef({ searchText, company, categorySlug, difficulty, positionFilter })

  useEffect(() => {
    void Promise.all([
      listCompanies().then(setCompanies).catch(() => {}),
      listCategories().then(setCategories).catch(() => {}),
      fetchDistinctCompanies().then(setDistinctCompanies).catch(() => {}),
      fetchDistinctPositions().then(setDistinctPositions).catch(() => {}),
    ])
  }, [])

  useEffect(() => {
    const prev = prevFiltersRef.current

    if (
      prev.searchText !== searchText ||
      prev.company !== company ||
      prev.categorySlug !== categorySlug ||
      prev.difficulty !== difficulty ||
      prev.positionFilter !== positionFilter
    ) {
      setCurrentPage(1)
      prevFiltersRef.current = { searchText, company, categorySlug, difficulty, positionFilter }
    }
  }, [searchText, company, categorySlug, difficulty, positionFilter])

  useEffect(() => {
    let cancelled = false
    setIsLoading(true)
    listProblems({
      page: currentPage,
      pageSize,
      search: searchText || undefined,
      company: company !== 'all' ? company : undefined,
      categorySlug: categorySlug !== 'all' ? categorySlug : undefined,
      difficulty: difficulty !== 'all' ? difficulty : undefined,
      position: positionFilter !== 'all' ? positionFilter : undefined,
    })
      .then((result) => {
        if (!cancelled) {
          setProblems(result.items)
          setTotalCount(result.total)
        }
      })
      .catch(() => {})
      .finally(() => {
        if (!cancelled) setIsLoading(false)
      })
    return () => { cancelled = true }
  }, [currentPage, searchText, company, categorySlug, difficulty, positionFilter])

  const positionNames = useMemo(() => distinctPositions, [distinctPositions])

  const companyNames = useMemo(() => distinctCompanies, [distinctCompanies])

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

    const payload: ProblemCreatePayload = {
      slug: form.slug.trim(),
      title: form.title.trim(),
      company: form.company.trim(),
      category_slug: form.category_slug.trim(),
      difficulty: form.difficulty,
      statement_markdown: form.statement_markdown.trim(),
      constraints_text: '',
      tags: ['未分类'],
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

  const categoryNames: { slug: string; name: string }[] = categories.map((c) => ({ slug: c.slug, name: c.name }))
  const categoryNameBySlug = new Map(categoryNames.map((category) => [category.slug, category.name]))

  return (
    <section>
      <div className="page-header">
        <div>
          <h1>题库</h1>
        </div>

        <div className="summary-strip" aria-label="题库摘要">
          <span className="summary-pill">{totalCount} 道题</span>
          <span className="summary-pill">{currentPage} / {Math.ceil(totalCount / pageSize)} 页</span>
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

          {positionNames.length > 0 ? (
            <label className="filter-control">
              <select value={positionFilter} onChange={(event) => setPositionFilter(event.target.value)}>
                <option value="all">全部岗位</option>
                {positionNames.map((item) => (
                  <option key={item} value={item}>
                    {item}
                  </option>
                ))}
              </select>
            </label>
          ) : null}
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
                setPositionFilter('all')
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
              onClick={onCreateProblem}
            >
              新增题目
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
                <option value="SSPoffer">SSPoffer</option>
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
                <th>年度</th>
                <th>公司</th>
                <th>岗位</th>
                <th>难度</th>
                <th>频率</th>
                <th>最新状态</th>
                <th>来源</th>
                <th>操作</th>
              </tr>
            </thead>
            <tbody>
              {problems.map((problem) => (
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
                  <td>{problem.year || '-'}</td>
                  <td>{problem.company}</td>
                  <td>{problem.position || '-'}</td>
                  <td>{problem.difficulty}</td>
                  <td>{problem.frequency}</td>
                  <td>
                    <span className={`status-badge ${problem.status === '已通过' ? 'ac' : problem.status === '待修正' ? 'wa' : 'review'}`}>
                      {problem.status}
                    </span>
                  </td>
                  <td>{problem.source}</td>
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
          <span>
            {totalCount > 0
              ? `显示 ${(currentPage - 1) * pageSize + 1} - ${Math.min(currentPage * pageSize, totalCount)} / ${totalCount} 道题`
              : '暂无题目'}
            {isLoading ? ' (加载中...)' : ''}
          </span>
          <div className="table-footer-actions">
            <button
              type="button"
              className="button ghost"
              disabled={currentPage <= 1}
              onClick={() => setCurrentPage((p) => Math.max(1, p - 1))}
            >
              上一页
            </button>
            {buildPageNumbers().map((item, idx) =>
              item === 'ellipsis' ? (
                <span key={`e${idx}`} className="pagination-ellipsis">...</span>
              ) : (
                <button
                  key={item}
                  type="button"
                  className={`pagination-page${item === currentPage ? ' active' : ''}`}
                  onClick={() => setCurrentPage(item)}
                >
                  {item}
                </button>
              )
            )}
            <button
              type="button"
              className="button"
              disabled={currentPage >= totalPages}
              onClick={() => setCurrentPage((p) => p + 1)}
            >
              下一页
            </button>
            <span className="pagination-jump">
              跳至
              <input
                type="text"
                className="jump-input"
                value={jumpValue}
                onChange={(e) => setJumpValue(e.target.value.replace(/\D/g, ''))}
                onKeyDown={(e) => { if (e.key === 'Enter') handleJump() }}
                placeholder="页"
              />
              页
              <button type="button" className="button ghost" onClick={handleJump}>GO</button>
            </span>
          </div>
        </div>
      </div>
    </section>
  )
}
