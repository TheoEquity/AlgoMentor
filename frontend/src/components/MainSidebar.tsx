export type NavigationKey = 'library' | 'training' | 'review' | 'system'

const navigationItems: Array<{ key: NavigationKey; label: string; hint: string }> = [
  { key: 'library', label: '题库', hint: '84 题' },
  { key: 'training', label: '训练', hint: '今日 3 次' },
  { key: 'review', label: '复盘', hint: '错题 12' },
  { key: 'system', label: '系统管理', hint: 'LLM' },
]

type MainSidebarProps = {
  activeKey: NavigationKey
  onNavigate: (key: NavigationKey) => void
}

export function MainSidebar({ activeKey, onNavigate }: MainSidebarProps) {
  return (
    <aside className="main-sidebar">
      <div className="brand-block">
        <div className="brand-mark">BH</div>
        <div>
          <div className="brand-title">ByteHunter</div>
          <div className="brand-subtitle">白底训练工作台骨架</div>
        </div>
      </div>

      <nav className="nav-list" aria-label="主导航">
        {navigationItems.map((item) => (
          <button
            key={item.label}
            type="button"
            className={`nav-item${item.key === activeKey ? ' active' : ''}`}
            onClick={() => onNavigate(item.key)}
          >
            <span>{item.label}</span>
            <span>{item.hint}</span>
          </button>
        ))}
      </nav>
    </aside>
  )
}
