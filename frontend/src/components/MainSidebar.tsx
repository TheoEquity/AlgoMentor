export type NavigationKey = 'dashboard' | 'library' | 'training' | 'review' | 'system' | 'chat'

const _defaultHints: Record<NavigationKey, string> = {
  dashboard: '',
  library: '-- 题',
  training: '-- 次',
  review: '--',
  system: 'LLM',
  chat: 'AI',
}

type MainSidebarProps = {
  activeKey: NavigationKey
  onNavigate: (key: NavigationKey) => void
  hints?: Partial<Record<NavigationKey, string>>
}

export function MainSidebar({ activeKey, onNavigate, hints = {} }: MainSidebarProps) {
  return (
    <aside className="main-sidebar">
      <div className="brand-block">
        <div className="brand-mark">AM</div>
        <div>
          <div className="brand-title">AlgoMentor</div>
          <div className="brand-subtitle">AI驱动的编程练习平台</div>
        </div>
      </div>

      <nav className="nav-list" aria-label="主导航">
        {(['dashboard', 'library', 'training', 'review', 'chat', 'system'] as NavigationKey[]).map((key) => {
          const label = { dashboard: '总览', library: '题库', training: '训练', review: '复盘', chat: 'AI 对话', system: '系统管理' }[key]
          const hint = hints[key] ?? _defaultHints[key]
          return (
            <button
              key={key}
              type="button"
              className={`nav-item${key === activeKey ? ' active' : ''}`}
              onClick={() => onNavigate(key)}
            >
              <span>{label}</span>
              <span>{hint}</span>
            </button>
          )
        })}
      </nav>
    </aside>
  )
}
