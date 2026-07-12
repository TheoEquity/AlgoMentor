import { useEffect, useState } from 'react'

import { AppFrame } from './components/AppFrame'
import type { NavigationKey } from './components/MainSidebar'
import { getProblem, listProblems } from './lib/problemApi'
import { listCategories } from './lib/categoryApi'
import { getTrainingOverview } from './lib/trainingApi'
import { listReviews } from './lib/reviewApi'
import { DashboardPage } from './pages/DashboardPage'
import { ProblemDetailPage } from './pages/ProblemDetailPage'
import { ProblemCreatePage } from './pages/ProblemCreatePage'
import { ProblemLibraryPage } from './pages/ProblemLibraryPage'
import { ProblemOverviewPage } from './pages/ProblemOverviewPage'
import { ReviewCenterPage } from './pages/ReviewCenterPage'
import { SystemSettingsPage } from './pages/SystemSettingsPage'
import { TrainingPlanListPage } from './pages/TrainingPlanListPage'
import { TrainingPlanCreatePage } from './pages/TrainingPlanCreatePage'
import { TrainingPlanDetailPage } from './pages/TrainingPlanDetailPage'
import { ChatPage } from './pages/ChatPage'
import { ResumeManagementPage } from './pages/ResumeManagementPage'
import { WebsiteManagementPage } from './pages/WebsiteManagementPage'
import { ApplicationManagementPage } from './pages/ApplicationManagementPage'
import { JobPositionDetailPage } from './pages/JobPositionDetailPage'
import type { ProblemDetail } from './types/problem'
import type { ProblemCategory } from './types/problemCategory'

type ProblemMode = 'overview' | 'training'
type TrainingView = 'list' | 'create' | 'plan-detail'
type ApplicationView = 'list' | 'create' | 'edit'

type AppRouteState = {
  activeNav: NavigationKey
  selectedProblemId: number | null
  problemMode: ProblemMode
  chatProblemId: number | null
  trainingView: TrainingView
  selectedPlanId: number | null
  applicationView: ApplicationView
  selectedJobPositionId: number | null
}

function readRouteFromLocation(): AppRouteState {
  const pathname = window.location.pathname
  const searchParams = new URLSearchParams(window.location.search)
  const problemMatch = pathname.match(/^\/problems\/(\d+)(?:\/(training))?$/)

  if (problemMatch) {
    return {
      activeNav: 'library',
      selectedProblemId: Number(problemMatch[1]),
      problemMode: problemMatch[2] === 'training' ? 'training' : 'overview',
      chatProblemId: null,
      trainingView: 'list',
      selectedPlanId: null,
      applicationView: 'list',
      selectedJobPositionId: null,
    }
  }

  if (pathname === '/' || pathname === '/dashboard') {
    return { activeNav: 'dashboard', selectedProblemId: null, problemMode: 'overview', chatProblemId: null, trainingView: 'list', selectedPlanId: null, applicationView: 'list', selectedJobPositionId: null }
  }

  const chatProblemId = searchParams.get('problem_id')
  if (pathname === '/chat') {
    return {
      activeNav: 'chat',
      selectedProblemId: null,
      problemMode: 'overview',
      chatProblemId: chatProblemId ? Number(chatProblemId) : null,
      trainingView: 'list',
      selectedPlanId: null,
      applicationView: 'list',
      selectedJobPositionId: null,
    }
  }

  if (pathname === '/training') {
    return { activeNav: 'training', selectedProblemId: null, problemMode: 'overview', chatProblemId: null, trainingView: 'list', selectedPlanId: null, applicationView: 'list', selectedJobPositionId: null }
  }

  if (pathname === '/training/create') {
    return { activeNav: 'training', selectedProblemId: null, problemMode: 'overview', chatProblemId: null, trainingView: 'create', selectedPlanId: null, applicationView: 'list', selectedJobPositionId: null }
  }

  const planMatch = pathname.match(/^\/training\/plans\/(\d+)$/)
  if (planMatch) {
    return { activeNav: 'training', selectedProblemId: null, problemMode: 'overview', chatProblemId: null, trainingView: 'plan-detail', selectedPlanId: Number(planMatch[1]), applicationView: 'list', selectedJobPositionId: null }
  }

  if (pathname === '/review') {
    return { activeNav: 'review', selectedProblemId: null, problemMode: 'overview', chatProblemId: null, trainingView: 'list', selectedPlanId: null, applicationView: 'list', selectedJobPositionId: null }
  }

  if (pathname === '/system') {
    return { activeNav: 'system', selectedProblemId: null, problemMode: 'overview', chatProblemId: null, trainingView: 'list', selectedPlanId: null, applicationView: 'list', selectedJobPositionId: null }
  }

  if (pathname === '/resume') {
    return { activeNav: 'resume', selectedProblemId: null, problemMode: 'overview', chatProblemId: null, trainingView: 'list', selectedPlanId: null, applicationView: 'list', selectedJobPositionId: null }
  }

  if (pathname === '/website') {
    return { activeNav: 'website', selectedProblemId: null, problemMode: 'overview', chatProblemId: null, trainingView: 'list', selectedPlanId: null, applicationView: 'list', selectedJobPositionId: null }
  }

  if (pathname === '/application') {
    return { activeNav: 'application', selectedProblemId: null, problemMode: 'overview', chatProblemId: null, trainingView: 'list', selectedPlanId: null, applicationView: 'list', selectedJobPositionId: null }
  }

  const jobPositionMatch = pathname.match(/^\/job-position\/(\d+)$/)
  if (jobPositionMatch) {
    return { activeNav: 'application', selectedProblemId: null, problemMode: 'overview', chatProblemId: null, trainingView: 'list', selectedPlanId: null, applicationView: 'edit', selectedJobPositionId: Number(jobPositionMatch[1]) }
  }

  if (pathname === '/job-position') {
    return { activeNav: 'application', selectedProblemId: null, problemMode: 'overview', chatProblemId: null, trainingView: 'list', selectedPlanId: null, applicationView: 'create', selectedJobPositionId: null }
  }

  return { activeNav: 'dashboard', selectedProblemId: null, problemMode: 'overview', chatProblemId: null, trainingView: 'list', selectedPlanId: null, applicationView: 'list', selectedJobPositionId: null }
}

function buildRoutePath(route: AppRouteState): string {
  if (route.selectedProblemId !== null) {
    return route.problemMode === 'training'
      ? `/problems/${route.selectedProblemId}/training`
      : `/problems/${route.selectedProblemId}`
  }

  if (route.activeNav === 'chat' && route.chatProblemId !== null) {
    return `/chat?problem_id=${route.chatProblemId}`
  }

  if (route.activeNav === 'training') {
    if (route.trainingView === 'create') return '/training/create'
    if (route.trainingView === 'plan-detail' && route.selectedPlanId !== null) return `/training/plans/${route.selectedPlanId}`
    return '/training'
  }

  if (route.activeNav === 'application') {
    if (route.applicationView === 'create') return '/job-position'
    if (route.applicationView === 'edit' && route.selectedJobPositionId !== null) return `/job-position/${route.selectedJobPositionId}`
    return '/application'
  }

  return route.activeNav === 'dashboard' ? '/dashboard' : route.activeNav === 'library' ? '/library' : `/${route.activeNav}`
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
  const [createPageOpen, setCreatePageOpen] = useState(false)
  const [hintsRefreshSeed, setHintsRefreshSeed] = useState(0)
  const [sidebarHints, setSidebarHints] = useState<Partial<Record<NavigationKey, string>>>({})
  const [chatProblemId, setChatProblemId] = useState<number | null>(initialRoute.chatProblemId)
  const [trainingView, setTrainingView] = useState<TrainingView>(initialRoute.trainingView)
  const [selectedPlanId, setSelectedPlanId] = useState<number | null>(initialRoute.selectedPlanId)
  const [applicationView, setApplicationView] = useState<ApplicationView>(initialRoute.applicationView)
  const [selectedJobPositionId, setSelectedJobPositionId] = useState<number | null>(initialRoute.selectedJobPositionId)

  useEffect(() => {
    if (createPageOpen) {
      document.title = '新增题目 - AlgoMentor'
      return
    }
    const titles: Record<NavigationKey, string> = {
      dashboard: '总览 - AlgoMentor',
      library: '题库 - AlgoMentor',
      training: '训练 - AlgoMentor',
      review: '复盘 - AlgoMentor',
      system: '系统管理 - AlgoMentor',
      chat: 'AI 对话 - AlgoMentor',
      resume: '简历管理 - AlgoMentor',
      website: '官网管理 - AlgoMentor',
      application: '投递管理 - AlgoMentor',
    }
    document.title = titles[activeNav]
  }, [activeNav, createPageOpen])

  useEffect(() => {
    void listProblems({ pageSize: 1 })
      .then((result) => setSidebarHints((prev) => ({ ...prev, library: `${result.total} 题` })))
      .catch(() => {})
    void getTrainingOverview()
      .then((data) => setSidebarHints((prev) => ({ ...prev, training: `今日 ${data.summary.total_runs} 次` })))
      .catch(() => {})
    void listReviews({ wrong_only: true })
      .then((data) => setSidebarHints((prev) => ({ ...prev, review: `错题 ${data.summary.wrong_submissions}` })))
      .catch(() => {})
  }, [hintsRefreshSeed])

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
      setTrainingView(route.trainingView)
      setSelectedPlanId(route.selectedPlanId)
      setApplicationView(route.applicationView)
      setSelectedJobPositionId(route.selectedJobPositionId)
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
    setChatProblemId(route.chatProblemId)
    setTrainingView(route.trainingView)
    setSelectedPlanId(route.selectedPlanId)
    setApplicationView(route.applicationView)
    setSelectedJobPositionId(route.selectedJobPositionId)
    setProblemReloadSeed(0)
  }

  const navigateTo = (route: AppRouteState) => {
    applyRoute(route)
    window.history.pushState(route, '', buildRoutePath(route))
  }

  const handleNavigate = (next: NavigationKey) => {
    navigateTo({ activeNav: next, selectedProblemId: null, problemMode: 'overview', chatProblemId: null, trainingView: 'list', selectedPlanId: null, applicationView: 'list', selectedJobPositionId: null })
  }

  return (
    <AppFrame
      activeNav={activeNav}
      onNavigate={handleNavigate}
      hints={sidebarHints}
    >
      {createPageOpen ? (
        <ProblemCreatePage
          onBack={() => {
            setCreatePageOpen(false)
            setHintsRefreshSeed((s) => s + 1)
          }}
          onProblemCreated={(problemId) => {
            setCreatePageOpen(false)
            setHintsRefreshSeed((s) => s + 1)
            navigateTo({ activeNav: 'library', selectedProblemId: problemId, problemMode: 'overview', applicationView: 'list', selectedJobPositionId: null })
          }}
        />
      ) : isLibrary ? (
        <ProblemLibraryPage
          onOpenProblem={(problemId) => {
            navigateTo({ activeNav: 'library', selectedProblemId: problemId, problemMode: 'overview', applicationView: 'list', selectedJobPositionId: null })
          }}
          onCreateProblem={() => setCreatePageOpen(true)}
        />
      ) : isWorkspace && selectedProblem && problemMode === 'overview' ? (
        <ProblemOverviewPage
          problem={selectedProblem}
          categoryName={categoryNameBySlug.get(selectedProblem.category_slug) || ''}
          onBack={() => navigateTo({ activeNav: 'library', selectedProblemId: null, problemMode: 'overview', chatProblemId: null, trainingView: 'list', selectedPlanId: null, applicationView: 'list', selectedJobPositionId: null })}

          onStartTraining={() => navigateTo({ activeNav: 'library', selectedProblemId: selectedProblem.id, problemMode: 'training', chatProblemId: null, trainingView: 'list', selectedPlanId: null, applicationView: 'list', selectedJobPositionId: null })}

          onProblemSaved={setSelectedProblem}
          onGoToChat={(problemId) => {
            navigateTo({ activeNav: 'chat', selectedProblemId: null, problemMode: 'overview', chatProblemId: problemId, trainingView: 'list', selectedPlanId: null, applicationView: 'list', selectedJobPositionId: null })
          }}
          onProblemGenerated={(problemId) => {
            navigateTo({ activeNav: 'library', selectedProblemId: problemId, problemMode: 'overview', applicationView: 'list', selectedJobPositionId: null })
          }}
        />
      ) : isWorkspace && selectedProblem ? (
        <ProblemDetailPage problem={selectedProblem} onBack={() => navigateTo({ activeNav: 'library', selectedProblemId: null, problemMode: 'overview', chatProblemId: null, trainingView: 'list', selectedPlanId: null, applicationView: 'list', selectedJobPositionId: null })} />
      ) : isWorkspace && problemError ? (
        <div className="backend-note action-note">
          <span>题目详情加载失败：{problemError}</span>
          <button type="button" className="button" onClick={() => setProblemReloadSeed((current) => current + 1)}>
            重试加载
          </button>
        </div>
      ) : activeNav === 'system' ? (
        <SystemSettingsPage />
      ) : activeNav === 'dashboard' ? (
        <DashboardPage />
      ) : activeNav === 'chat' ? (
        <ChatPage problemId={chatProblemId} />
      ) : activeNav === 'training' && trainingView === 'create' ? (
        <TrainingPlanCreatePage
          onBack={() => navigateTo({ activeNav: 'training', selectedProblemId: null, problemMode: 'overview', chatProblemId: null, trainingView: 'list', selectedPlanId: null, applicationView: 'list', selectedJobPositionId: null })}
          onPlanCreated={() => navigateTo({ activeNav: 'training', selectedProblemId: null, problemMode: 'overview', chatProblemId: null, trainingView: 'list', selectedPlanId: null, applicationView: 'list', selectedJobPositionId: null })}
        />
      ) : activeNav === 'training' && trainingView === 'plan-detail' && selectedPlanId !== null ? (
        <TrainingPlanDetailPage
          planId={selectedPlanId}
          onBack={() => navigateTo({ activeNav: 'training', selectedProblemId: null, problemMode: 'overview', chatProblemId: null, trainingView: 'list', selectedPlanId: null, applicationView: 'list', selectedJobPositionId: null })}
          onStartTraining={(problemId) => navigateTo({ activeNav: 'library', selectedProblemId: problemId, problemMode: 'training', chatProblemId: null, trainingView: 'list', selectedPlanId: null, applicationView: 'list', selectedJobPositionId: null })}
        />
      ) : activeNav === 'training' ? (
        <TrainingPlanListPage
          onCreatePlan={() => navigateTo({ activeNav: 'training', selectedProblemId: null, problemMode: 'overview', chatProblemId: null, trainingView: 'create', selectedPlanId: null, applicationView: 'list', selectedJobPositionId: null })}
          onOpenPlan={(planId) => navigateTo({ activeNav: 'training', selectedProblemId: null, problemMode: 'overview', chatProblemId: null, trainingView: 'plan-detail', selectedPlanId: planId, applicationView: 'list', selectedJobPositionId: null })}
        />
      ) : activeNav === 'review' ? (
        <ReviewCenterPage
          onOpenProblem={(problemId) => {
            navigateTo({ activeNav: 'library', selectedProblemId: problemId, problemMode: 'training', chatProblemId: null, trainingView: 'list', selectedPlanId: null, applicationView: 'list', selectedJobPositionId: null })
          }}
        />
      ) : activeNav === 'resume' ? (
        <ResumeManagementPage />
      ) : activeNav === 'website' ? (
        <WebsiteManagementPage />
      ) : activeNav === 'application' && applicationView === 'create' ? (
        <JobPositionDetailPage mode="create" onBack={() => navigateTo({ ...readRouteFromLocation(), activeNav: 'application', applicationView: 'list', selectedJobPositionId: null })} />
      ) : activeNav === 'application' && applicationView === 'edit' && selectedJobPositionId !== null ? (
        <JobPositionDetailPage mode="edit" positionId={selectedJobPositionId} onBack={() => navigateTo({ ...readRouteFromLocation(), activeNav: 'application', applicationView: 'list', selectedJobPositionId: null })} />
      ) : activeNav === 'application' ? (
        <ApplicationManagementPage
          onNavigate={(key, params) => {
            if (key === 'jobPositionDetail') {
              if (params?.mode === 'create') {
                navigateTo({ activeNav: 'application', selectedProblemId: null, problemMode: 'overview', chatProblemId: null, trainingView: 'list', selectedPlanId: null, applicationView: 'create', selectedJobPositionId: null })
              } else if (params?.mode === 'edit' && params?.id) {
                navigateTo({ activeNav: 'application', selectedProblemId: null, problemMode: 'overview', chatProblemId: null, trainingView: 'list', selectedPlanId: null, applicationView: 'edit', selectedJobPositionId: Number(params.id) })
              }
            }
          }}
        />
      ) : (
        <div className="backend-note">正在加载题目详情...</div>
      )}
    </AppFrame>
  )
}

export default App
