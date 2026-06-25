import { useEffect, useState } from 'react'

import { AppFrame } from './components/AppFrame'
import type { NavigationKey } from './components/MainSidebar'
import { getProblem } from './lib/problemApi'
import { listCategories } from './lib/categoryApi'
import { ProblemDetailPage } from './pages/ProblemDetailPage'
import { ProblemLibraryPage } from './pages/ProblemLibraryPage'
import { ProblemOverviewPage } from './pages/ProblemOverviewPage'
import { ReviewCenterPage } from './pages/ReviewCenterPage'
import { SystemSettingsPage } from './pages/SystemSettingsPage'
import { TrainingCenterPage } from './pages/TrainingCenterPage'
import type { ProblemDetail } from './types/problem'
import type { ProblemCategory } from './types/problemCategory'

type ProblemMode = 'overview' | 'training'

type AppRouteState = {
  activeNav: NavigationKey
  selectedProblemId: number | null
  problemMode: ProblemMode
}

function readRouteFromLocation(): AppRouteState {
  const pathname = window.location.pathname
  const problemMatch = pathname.match(/^\/problems\/(\d+)(?:\/(training))?$/)

  if (problemMatch) {
    return {
      activeNav: 'library',
      selectedProblemId: Number(problemMatch[1]),
      problemMode: problemMatch[2] === 'training' ? 'training' : 'overview',
    }
  }

  if (pathname === '/training') {
    return { activeNav: 'training', selectedProblemId: null, problemMode: 'overview' }
  }

  if (pathname === '/review') {
    return { activeNav: 'review', selectedProblemId: null, problemMode: 'overview' }
  }

  if (pathname === '/system') {
    return { activeNav: 'system', selectedProblemId: null, problemMode: 'overview' }
  }

  return { activeNav: 'library', selectedProblemId: null, problemMode: 'overview' }
}

function buildRoutePath(route: AppRouteState): string {
  if (route.selectedProblemId !== null) {
    return route.problemMode === 'training'
      ? `/problems/${route.selectedProblemId}/training`
      : `/problems/${route.selectedProblemId}`
  }

  return route.activeNav === 'library' ? '/library' : `/${route.activeNav}`
}

function App() {
  const initialRoute = readRouteFromLocation()
  const [activeNav, setActiveNav] = useState<NavigationKey>(initialRoute.activeNav)
  const [selectedProblemId, setSelectedProblemId] = useState<number | null>(initialRoute.selectedProblemId)
  const [selectedProblem, setSelectedProblem] = useState<ProblemDetail | null>(null)
  const [problemMode, setProblemMode] = useState<ProblemMode>(initialRoute.problemMode)
  const [categories, setCategories] = useState<ProblemCategory[]>([])
  const [problemError, setProblemError] = useState('')
  const [problemReloadSeed, setProblemReloadSeed] = useState(0)

  useEffect(() => {
    if (selectedProblemId === null) {
      setSelectedProblem(null)
      setProblemError('')
      return
    }

    let cancelled = false
    setProblemError('')

    void getProblem(selectedProblemId)
      .then((problem) => {
        if (!cancelled) {
          setSelectedProblem(problem)
        }
      })
      .catch((error: unknown) => {
        if (!cancelled) {
          setSelectedProblem(null)
          setProblemError(error instanceof Error ? error.message : '题目加载失败')
        }
      })

    return () => {
      cancelled = true
    }
  }, [selectedProblemId, problemReloadSeed])

  useEffect(() => {
    void listCategories().then(setCategories).catch(() => {})
  }, [])

  useEffect(() => {
    const currentRoute = readRouteFromLocation()
    window.history.replaceState(currentRoute, '', buildRoutePath(currentRoute))

    const handlePopState = () => {
      const route = readRouteFromLocation()
      setActiveNav(route.activeNav)
      setSelectedProblemId(route.selectedProblemId)
      setProblemMode(route.problemMode)
      setProblemReloadSeed(0)
    }

    window.addEventListener('popstate', handlePopState)
    return () => window.removeEventListener('popstate', handlePopState)
  }, [])

  const isWorkspace = activeNav === 'library' && selectedProblemId !== null
  const isLibrary = activeNav === 'library' && selectedProblemId === null
  const categoryNameBySlug = new Map(categories.map((category) => [category.slug, category.name]))

  const applyRoute = (route: AppRouteState) => {
    setActiveNav(route.activeNav)
    setSelectedProblemId(route.selectedProblemId)
    setProblemMode(route.problemMode)
    setProblemReloadSeed(0)
  }

  const navigateTo = (route: AppRouteState) => {
    applyRoute(route)
    window.history.pushState(route, '', buildRoutePath(route))
  }

  const handleNavigate = (next: NavigationKey) => {
    navigateTo({ activeNav: next, selectedProblemId: null, problemMode: 'overview' })
  }

  return (
    <AppFrame
      activeNav={activeNav}
      onNavigate={handleNavigate}
    >
      {isLibrary ? (
        <ProblemLibraryPage
          onOpenProblem={(problemId) => {
            navigateTo({ activeNav: 'library', selectedProblemId: problemId, problemMode: 'overview' })
          }}
        />
      ) : isWorkspace && selectedProblem && problemMode === 'overview' ? (
        <ProblemOverviewPage
          problem={selectedProblem}
          categoryName={categoryNameBySlug.get(selectedProblem.category_slug) || ''}
          onBack={() => navigateTo({ activeNav: 'library', selectedProblemId: null, problemMode: 'overview' })}
          onStartTraining={() => navigateTo({ activeNav: 'library', selectedProblemId: selectedProblem.id, problemMode: 'training' })}
          onProblemSaved={setSelectedProblem}
        />
      ) : isWorkspace && selectedProblem ? (
        <ProblemDetailPage problem={selectedProblem} onBack={() => navigateTo({ activeNav: 'library', selectedProblemId: null, problemMode: 'overview' })} />
      ) : isWorkspace && problemError ? (
        <div className="backend-note action-note">
          <span>题目详情加载失败：{problemError}</span>
          <button type="button" className="button" onClick={() => setProblemReloadSeed((current) => current + 1)}>
            重试加载
          </button>
        </div>
      ) : activeNav === 'system' ? (
        <SystemSettingsPage />
      ) : activeNav === 'training' ? (
        <TrainingCenterPage
          onOpenProblem={(problemId) => {
            navigateTo({ activeNav: 'library', selectedProblemId: problemId, problemMode: 'training' })
          }}
        />
      ) : activeNav === 'review' ? (
        <ReviewCenterPage
          onOpenProblem={(problemId) => {
            navigateTo({ activeNav: 'library', selectedProblemId: problemId, problemMode: 'training' })
          }}
        />
      ) : (
        <div className="backend-note">正在加载题目详情...</div>
      )}
    </AppFrame>
  )
}

export default App
