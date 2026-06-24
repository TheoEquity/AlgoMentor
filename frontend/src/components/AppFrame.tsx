import type { ReactNode } from 'react'

import { MainSidebar, type NavigationKey } from './MainSidebar'
import { TopHeader } from './TopHeader'

type AppFrameProps = {
  children: ReactNode
  title: string
  subtitle: string
  activeNav: NavigationKey
  onNavigate: (key: NavigationKey) => void
}

export function AppFrame({ children, title, subtitle, activeNav, onNavigate }: AppFrameProps) {
  return (
    <div className="app-shell">
      <MainSidebar activeKey={activeNav} onNavigate={onNavigate} />
      <div className="shell-content">
        <TopHeader title={title} subtitle={subtitle} />
        <main className="page-content">{children}</main>
      </div>
    </div>
  )
}
