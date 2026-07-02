import type { ReactNode } from 'react'

import { MainSidebar, type NavigationKey } from './MainSidebar'

type AppFrameProps = {
  children: ReactNode
  activeNav: NavigationKey
  onNavigate: (key: NavigationKey) => void
  hints?: Partial<Record<NavigationKey, string>>
}

export function AppFrame({ children, activeNav, onNavigate, hints }: AppFrameProps) {
  return (
    <div className="app-shell">
      <MainSidebar activeKey={activeNav} onNavigate={onNavigate} hints={hints} />
      <div className="shell-content">
        <main className="page-content">{children}</main>
      </div>
    </div>
  )
}
