type TopHeaderProps = {
  title: string
  subtitle: string
}

export function TopHeader({ title, subtitle }: TopHeaderProps) {
  return (
    <header className="top-header">
      <div className="top-header-title">
        <strong>{title}</strong>
        <span>{subtitle}</span>
      </div>

      <div className="top-header-search">
        <input type="search" placeholder="搜索题目、公司、标签" aria-label="全局搜索" />
      </div>

      <div className="top-header-user">
        <div className="user-chip">
          <span className="user-avatar">MC</span>
          <span>Monica</span>
        </div>
      </div>
    </header>
  )
}
