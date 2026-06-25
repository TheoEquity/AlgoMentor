import type { ReactNode } from 'react'

import { MainSidebar, type NavigationKey } from './MainSidebar'

type AppFrameProps = {
  children: ReactNode
  activeNav: NavigationKey
  onNavigate: (key: NavigationKey) => void
}

export function AppFrame({ children, activeNav, onNavigate }: AppFrameProps) {
  return (
    <div className="app-shell">
      <MainSidebar activeKey={activeNav} onNavigate={onNavigate} />
      <div className="shell-content">
        <main className="page-content">{children}</main>
      </div>
    </div>
  )
}
