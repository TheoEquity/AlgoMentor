import { useEffect, useState } from 'react'

import { AppFrame } from './components/AppFrame'
import type { NavigationKey } from './components/MainSidebar'
import { getProblem } from './lib/problemApi'
import { ProblemDetailPage } from './pages/ProblemDetailPage'
import { ProblemLibraryPage } from './pages/ProblemLibraryPage'
import { ReviewCenterPage } from './pages/ReviewCenterPage'
import { SystemSettingsPage } from './pages/SystemSettingsPage'
import { TrainingCenterPage } from './pages/TrainingCenterPage'
import type { ProblemDetail } from './types/problem'

function App() {
  const [activeNav, setActiveNav] = useState<NavigationKey>('library')
  const [selectedProblemId, setSelectedProblemId] = useState<number | null>(null)
  const [selectedProblem, setSelectedProblem] = useState<ProblemDetail | null>(null)
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

  const isWorkspace = activeNav === 'library' && selectedProblemId !== null
  const isLibrary = activeNav === 'library' && selectedProblemId === null

  const handleNavigate = (next: NavigationKey) => {
    setActiveNav(next)
    if (next !== 'library') {
      setSelectedProblemId(null)
    }
  }

  const titleMap: Record<NavigationKey, string> = {
    library: isWorkspace ? 'Problem Workspace' : 'Problem Library',
    training: 'Training Center',
    review: 'Review Center',
    system: 'System Management',
  }

  const subtitleMap: Record<NavigationKey, string> = {
    library: isWorkspace ? 'Monaco 工作区、Run/Submit 与右侧结果台' : '传统表格题库与手工录题首批数据接入',
    training: '训练总览页待接入真实统计与推荐模块',
    review: '错题复盘页待接入真实历史记录与归因聚合',
    system: '集中管理 LLM Provider、模型路由与温度参数',
  }

  return (
    <AppFrame
      title={titleMap[activeNav]}
      subtitle={subtitleMap[activeNav]}
      activeNav={activeNav}
      onNavigate={handleNavigate}
    >
      {isLibrary ? (
        <ProblemLibraryPage
          onOpenProblem={(problemId) => {
            setActiveNav('library')
            setSelectedProblemId(problemId)
            setProblemReloadSeed(0)
          }}
        />
      ) : isWorkspace && selectedProblem ? (
        <ProblemDetailPage problem={selectedProblem} onBack={() => setSelectedProblemId(null)} />
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
            setActiveNav('library')
            setSelectedProblemId(problemId)
          }}
        />
      ) : activeNav === 'review' ? (
        <ReviewCenterPage
          onOpenProblem={(problemId) => {
            setActiveNav('library')
            setSelectedProblemId(problemId)
          }}
        />
      ) : (
        <div className="backend-note">正在加载题目详情...</div>
      )}
    </AppFrame>
  )
}

export default App
