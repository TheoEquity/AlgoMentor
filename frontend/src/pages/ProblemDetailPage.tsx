import Editor, { DiffEditor } from '@monaco-editor/react'
import { useEffect, useMemo, useRef, useState } from 'react'

import { MarkdownRenderer } from '../components/MarkdownRenderer'
import { analyzeHint, streamAttributionAnalysis, streamReviewAnalysis, streamSolutionAnalysis } from '../lib/analysisApi'
import { createSubmission, listSubmissions } from '../lib/submissionApi'
import type { AnalysisResult, AnalysisStreamMeta } from '../types/analysis'
import type { ProblemDetail } from '../types/problem'
import type { SubmissionResult, SubmissionRunType, SubmissionVerdict } from '../types/submission'

type WorkspaceLanguage = 'Python' | 'C++' | 'Java'
type WorkspaceTab = 'workspace' | 'history'
type WorkbenchTab = 'result' | 'hint' | 'explain' | 'review'
type DrawerTab = 'input' | 'output' | 'diff'
type HintStrength = 'light' | 'medium' | 'strong'

type ProblemDetailPageProps = {
  problem: ProblemDetail
  onBack: () => void
}

type EditorDiagnostic = {
  line: number
  message: string
  severity: 'warning' | 'error'
}

type StreamPreview = {
  title: string
  summary: string
  bullets: string[]
  lineRefs: EditorDiagnostic[]
}

type StreamSectionKey = 'summary' | 'bullets' | 'lineRefs'
type StreamSectionStatus = 'waiting' | 'streaming' | 'done'

type StreamProgressItem = {
  key: StreamSectionKey
  label: string
  status: StreamSectionStatus
}

type RetryFailureContext = {
  message: string
  timeLabel: string
}

const hintStepLabels = ['读题澄清', '关键观察', '算法方向', '边界条件', '伪代码骨架', '代码风险点']

const hintStrengthOptions: Array<{ value: HintStrength; label: string }> = [
  { value: 'light', label: '轻提示' },
  { value: 'medium', label: '中提示' },
  { value: 'strong', label: '强提示' },
]

function createEmptyStreamPreview(): StreamPreview {
  return {
    title: '',
    summary: '',
    bullets: [],
    lineRefs: [],
  }
}

function mergeStreamPreviews(primary: StreamPreview, fallback: StreamPreview): StreamPreview {
  return {
    title: primary.title || fallback.title,
    summary: primary.summary || fallback.summary,
    bullets: primary.bullets.length > 0 ? primary.bullets : fallback.bullets,
    lineRefs: primary.lineRefs.length > 0 ? primary.lineRefs : fallback.lineRefs,
  }
}

function buildStreamMetaText(meta: AnalysisStreamMeta | null): string {
  if (!meta) {
    return ''
  }

  return [meta.provider, meta.model].filter(Boolean).join(' / ')
}

function buildStreamProgress(preview: StreamPreview, isStreaming: boolean): StreamProgressItem[] {
  const buildStatus = (hasContent: boolean): StreamSectionStatus => {
    if (hasContent) {
      return isStreaming ? 'streaming' : 'done'
    }

    return 'waiting'
  }

  return [
    { key: 'summary', label: '摘要', status: buildStatus(Boolean(preview.summary.trim())) },
    { key: 'bullets', label: '要点', status: buildStatus(preview.bullets.length > 0) },
    { key: 'lineRefs', label: '行提示', status: buildStatus(preview.lineRefs.length > 0) },
  ]
}

function buildTimeLabel(): string {
  return new Date().toLocaleTimeString('zh-CN', {
    hour12: false,
    hour: '2-digit',
    minute: '2-digit',
    second: '2-digit',
  })
}

function getAnalysisStatusLabel(status: AnalysisStreamMeta['execution_status'] | AnalysisResult['execution_status']): string {
  if (status === 'degraded') {
    return '降级结果'
  }

  if (status === 'streaming') {
    return '流式生成中'
  }

  return '正常结果'
}

function getAnalysisStatusClassName(status: AnalysisStreamMeta['execution_status'] | AnalysisResult['execution_status']): string {
  if (status === 'degraded') {
    return 'analysis-status-badge degraded'
  }

  if (status === 'streaming') {
    return 'analysis-status-badge streaming'
  }

  return 'analysis-status-badge completed'
}

function decodeJSONStringFragment(value: string): string {
  try {
    return JSON.parse(`"${value}"`) as string
  } catch {
    return value
  }
}

function extractJSONStringField(streamText: string, fieldName: string): string {
  const pattern = new RegExp(`"${fieldName}"\\s*:\\s*"((?:\\\\.|[^"])*)"`)
  const match = streamText.match(pattern)
  return match ? decodeJSONStringFragment(match[1]) : ''
}

function extractJSONStringArray(streamText: string, fieldName: string): string[] {
  const blockPattern = new RegExp(`"${fieldName}"\\s*:\\s*\\[([\\s\\S]*?)\\]`)
  const blockMatch = streamText.match(blockPattern)
  if (!blockMatch) {
    return []
  }

  const values: string[] = []
  const itemPattern = /"((?:\\.|[^"])*)"/g
  for (const match of blockMatch[1].matchAll(itemPattern)) {
    values.push(decodeJSONStringFragment(match[1]))
  }

  return values.filter(Boolean)
}

function extractLineRefs(streamText: string): EditorDiagnostic[] {
  const blockPattern = /"line_refs"\s*:\s*\[([\s\S]*?)\]/
  const blockMatch = streamText.match(blockPattern)
  if (!blockMatch) {
    return []
  }

  const lineRefs: EditorDiagnostic[] = []
  const objectPattern = /\{[^{}]*?"line"\s*:\s*(\d+)[^{}]*?"message"\s*:\s*"((?:\\.|[^"])*)"[^{}]*?(?:"severity"\s*:\s*"(warning|error)")?[^{}]*?\}/g
  for (const match of blockMatch[1].matchAll(objectPattern)) {
    const line = Number(match[1])
    if (!Number.isFinite(line) || line <= 0) {
      continue
    }

    lineRefs.push({
      line,
      message: decodeJSONStringFragment(match[2]),
      severity: match[3] === 'error' ? 'error' : 'warning',
    })
  }

  return lineRefs
}

function parseDiagnosticLine(language: WorkspaceLanguage, source: string): number | null {
  const patterns: RegExp[] = []

  if (language === 'Python') {
    patterns.push(/File\s+"[^"]+",\s+line\s+(\d+)/)
  }

  if (language === 'Java') {
    patterns.push(/Main\.java:(\d+):/)
  }

  if (language === 'C++') {
    patterns.push(/:(\d+):(\d+):/)
  }

  for (const pattern of patterns) {
    const match = source.match(pattern)
    if (!match) {
      continue
    }

    const line = Number(match[1])
    if (Number.isFinite(line) && line > 0) {
      return line
    }
  }

  return null
}

function buildOutputText(activeCase: SubmissionResult['case_results'][number] | null, submission: SubmissionResult | null): string {
  if (activeCase?.actual_output_text) {
    return activeCase.actual_output_text
  }

  if (submission?.compiler_output) {
    return submission.compiler_output
  }

  if (activeCase?.stderr_output) {
    return activeCase.stderr_output
  }

  if (submission?.stderr_output) {
    return submission.stderr_output
  }

  return '暂无输出'
}

function mergeSubmissionAnalysis(
  submission: SubmissionResult,
  analysis: AnalysisResult,
): SubmissionResult {
  if (analysis.analysis_type === 'attribution') {
    return {
      ...submission,
      attribution_analysis: { ...analysis, analysis_type: 'attribution' },
    }
  }

  if (analysis.analysis_type === 'review') {
    return {
      ...submission,
      review_analysis: { ...analysis, analysis_type: 'review' },
    }
  }

  return submission
}

function buildHistorySummary(submission: SubmissionResult): string {
  if (submission.attribution_analysis?.summary) {
    return submission.attribution_analysis.summary
  }

  if (submission.review_analysis?.summary) {
    return submission.review_analysis.summary
  }

  if (submission.stderr_output) {
    return submission.stderr_output
  }

  if (submission.compiler_output) {
    return submission.compiler_output
  }

  if (submission.failed_actual_output || submission.failed_expected_output) {
    return `Expected: ${submission.failed_expected_output || '<empty>'} | Actual: ${submission.failed_actual_output || '<empty>'}`
  }

  return submission.verdict === 'AC' ? '该次提交已经通过，可直接查看复盘结论。' : '当前记录还没有归因摘要，可点击进入后继续分析。'
}

function deriveWorkbenchTab(submission: SubmissionResult): WorkbenchTab {
  if (submission.verdict === 'AC') {
    return submission.run_type === 'submit' ? 'review' : 'result'
  }

  if (submission.verdict === 'RE' || submission.verdict === 'CE' || submission.verdict === 'TLE') {
    return 'explain'
  }

  return 'result'
}

function deriveDrawerTab(submission: SubmissionResult): DrawerTab {
  return submission.verdict === 'WA' ? 'diff' : 'output'
}

function buildInitialDrafts(problem: ProblemDetail): Record<WorkspaceLanguage, string> {
  return {
    Python: problem.starter_templates.Python ?? 'def solve() -> None:\n    pass\n',
    'C++': problem.starter_templates['C++'] ?? '#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}\n',
    Java:
      problem.starter_templates.Java ??
      'public class Main {\n    public static void main(String[] args) throws Exception {\n    }\n}\n',
  }
}

function parseStreamPreview(streamText: string): StreamPreview {
  if (!streamText.trim()) {
    return createEmptyStreamPreview()
  }

  try {
    const parsed = JSON.parse(streamText) as Partial<AnalysisResult>
    return {
      title: typeof parsed.title === 'string' ? parsed.title : '',
      summary: typeof parsed.summary === 'string' ? parsed.summary : '',
      bullets: Array.isArray(parsed.bullets) ? parsed.bullets.map((item) => String(item)).filter(Boolean) : [],
      lineRefs: Array.isArray(parsed.line_refs)
        ? parsed.line_refs
            .filter((item): item is EditorDiagnostic => {
              if (!item || typeof item !== 'object') {
                return false
              }

              const candidate = item as Record<string, unknown>
              return typeof candidate.line === 'number' && typeof candidate.message === 'string'
            })
            .map((item) => ({
              line: item.line,
              message: item.message,
              severity: item.severity === 'error' ? 'error' : 'warning',
            }))
        : [],
    }
  } catch {
    return {
      title: extractJSONStringField(streamText, 'title') || 'AI 正在生成',
      summary: extractJSONStringField(streamText, 'summary') || streamText.replace(/[{}["]+/g, ' ').replace(/\s+/g, ' ').trim(),
      bullets: extractJSONStringArray(streamText, 'bullets'),
      lineRefs: extractLineRefs(streamText),
    }
  }
}

function verdictClassName(verdict: SubmissionVerdict | ProblemDetail['status']): string {
  switch (verdict) {
    case 'AC':
    case '已通过':
      return 'ac'
    case 'WA':
    case '待修正':
      return 'wa'
    case 'RE':
    case '待复盘':
      return 'review'
    case 'CE':
    case 'TLE':
    case '未开始':
    default:
      return 'review'
  }
}

function deriveDiagnostics(language: WorkspaceLanguage, submission: SubmissionResult | null): EditorDiagnostic[] {
  if (!submission) {
    return []
  }

  if (submission.verdict === 'RE') {
    const errorLine = parseDiagnosticLine(language, submission.stderr_output) ?? 1
    return [
      {
        line: errorLine,
        message: submission.stderr_output || '运行时异常发生在接近输入处理的位置。',
        severity: 'error',
      },
    ]
  }

  if (submission.verdict === 'WA') {
    return [
      {
        line: 5,
        message: '输出与预期不一致，优先检查边界条件和最终打印逻辑。',
        severity: 'warning',
      },
    ]
  }

  if (submission.verdict === 'CE') {
    const errorLine = parseDiagnosticLine(language, submission.compiler_output) ?? 1
    return [
      {
        line: errorLine,
        message: submission.compiler_output || '编译失败，请先修复模板或语法错误。',
        severity: 'error',
      },
    ]
  }

  return []
}

export function ProblemDetailPage({ problem, onBack }: ProblemDetailPageProps) {
  const supportedLanguages = problem.supported_languages as WorkspaceLanguage[]
  const [selectedLanguage, setSelectedLanguage] = useState<WorkspaceLanguage>(supportedLanguages[0] ?? 'Python')
  const [drafts, setDrafts] = useState<Record<WorkspaceLanguage, string>>(() => buildInitialDrafts(problem))
  const [customInput, setCustomInput] = useState(problem.examples[0]?.input ?? '')
  const [workspaceTab, setWorkspaceTab] = useState<WorkspaceTab>('workspace')
  const [workbenchTab, setWorkbenchTab] = useState<WorkbenchTab>('result')
  const [drawerTab, setDrawerTab] = useState<DrawerTab>('input')
  const [isSubmitting, setIsSubmitting] = useState(false)
  const [requestError, setRequestError] = useState('')
  const [analysisError, setAnalysisError] = useState('')
  const [isAnalyzing, setIsAnalyzing] = useState(false)
  const [analysisStreamText, setAnalysisStreamText] = useState('')
  const [analysisStreamPreview, setAnalysisStreamPreview] = useState<StreamPreview>(createEmptyStreamPreview)
  const [analysisStreamMeta, setAnalysisStreamMeta] = useState<AnalysisStreamMeta | null>(null)
  const [analysisAttemptCount, setAnalysisAttemptCount] = useState(0)
  const [analysisLastFailure, setAnalysisLastFailure] = useState<RetryFailureContext | null>(null)
  const [analysis, setAnalysis] = useState<AnalysisResult | null>(null)
  const [reviewAnalysis, setReviewAnalysis] = useState<AnalysisResult | null>(null)
  const [reviewError, setReviewError] = useState('')
  const [isReviewing, setIsReviewing] = useState(false)
  const [reviewStreamText, setReviewStreamText] = useState('')
  const [reviewStreamPreview, setReviewStreamPreview] = useState<StreamPreview>(createEmptyStreamPreview)
  const [reviewStreamMeta, setReviewStreamMeta] = useState<AnalysisStreamMeta | null>(null)
  const [reviewAttemptCount, setReviewAttemptCount] = useState(0)
  const [reviewLastFailure, setReviewLastFailure] = useState<RetryFailureContext | null>(null)
  const [hintStrength, setHintStrength] = useState<HintStrength>('light')
  const [hintStep, setHintStep] = useState(1)
  const [hints, setHints] = useState<AnalysisResult[]>([])
  const [isHinting, setIsHinting] = useState(false)
  const [hintError, setHintError] = useState('')
  const [latestSubmission, setLatestSubmission] = useState<SubmissionResult | null>(null)
  const [submissionHistory, setSubmissionHistory] = useState<SubmissionResult[]>([])
  const [selectedCaseIndex, setSelectedCaseIndex] = useState(1)
  const editorRef = useRef<any>(null)
  const monacoRef = useRef<any>(null)
  const decorationIdsRef = useRef<string[]>([])

  useEffect(() => {
    const nextDrafts = buildInitialDrafts(problem)
    setSelectedLanguage((problem.supported_languages[0] as WorkspaceLanguage | undefined) ?? 'Python')
    setDrafts(nextDrafts)
    setCustomInput(problem.examples[0]?.input ?? '')
    setWorkspaceTab('workspace')
    setWorkbenchTab('result')
    setDrawerTab('input')
    setAnalysis(null)
    setAnalysisStreamText('')
    setAnalysisStreamPreview(createEmptyStreamPreview())
    setAnalysisStreamMeta(null)
    setAnalysisAttemptCount(0)
    setAnalysisLastFailure(null)
    setReviewAnalysis(null)
    setReviewStreamText('')
    setReviewStreamPreview(createEmptyStreamPreview())
    setReviewStreamMeta(null)
    setReviewAttemptCount(0)
    setReviewLastFailure(null)
    setHintStrength('light')
    setHintStep(1)
    setHints([])
    setHintError('')
    setAnalysisError('')
    setReviewError('')
    setLatestSubmission(null)
    setSubmissionHistory([])
    setSelectedCaseIndex(1)
    setRequestError('')
  }, [problem])

  useEffect(() => {
    let cancelled = false
    setRequestError('')

    void listSubmissions(problem.id, 6)
      .then((items) => {
        if (cancelled) {
          return
        }

        setSubmissionHistory(items)
        if (items.length > 0) {
          setLatestSubmission(items[0])
          setSelectedLanguage(items[0].language)
          setWorkbenchTab(deriveWorkbenchTab(items[0]))
          setDrawerTab(deriveDrawerTab(items[0]))
          setSelectedCaseIndex(items[0].failed_case_index ?? 1)
          setAnalysis(items[0].attribution_analysis)
          setReviewAnalysis(items[0].review_analysis)
          setAnalysisStreamText('')
          setReviewStreamText('')
          setAnalysisStreamPreview(createEmptyStreamPreview())
          setReviewStreamPreview(createEmptyStreamPreview())
          setAnalysisStreamMeta(null)
          setReviewStreamMeta(null)
          setAnalysisAttemptCount(0)
          setReviewAttemptCount(0)
          setAnalysisLastFailure(null)
          setReviewLastFailure(null)
        }
      })
      .catch((error: unknown) => {
        if (!cancelled) {
          setRequestError(error instanceof Error ? error.message : '提交记录加载失败')
        }
      })

    return () => {
      cancelled = true
    }
  }, [problem.id])

  const currentCode = drafts[selectedLanguage]
  const analysisPreview = useMemo(
    () => mergeStreamPreviews(analysisStreamPreview, parseStreamPreview(analysisStreamText)),
    [analysisStreamPreview, analysisStreamText],
  )
  const reviewPreview = useMemo(
    () => mergeStreamPreviews(reviewStreamPreview, parseStreamPreview(reviewStreamText)),
    [reviewStreamPreview, reviewStreamText],
  )
  const analysisProgress = useMemo(() => buildStreamProgress(analysisPreview, isAnalyzing), [analysisPreview, isAnalyzing])
  const reviewProgress = useMemo(() => buildStreamProgress(reviewPreview, isReviewing), [reviewPreview, isReviewing])
  const diagnostics = useMemo(() => {
    if (analysis?.line_refs.length) {
      return analysis.line_refs
    }

    if (isAnalyzing && analysisPreview.lineRefs.length) {
      return analysisPreview.lineRefs
    }

    return deriveDiagnostics(latestSubmission?.language ?? selectedLanguage, latestSubmission)
  }, [analysis, analysisPreview.lineRefs, isAnalyzing, latestSubmission, selectedLanguage])
  const activeCase = latestSubmission?.case_results[selectedCaseIndex - 1] ?? latestSubmission?.case_results[0] ?? null
  const outputText = buildOutputText(activeCase, latestSubmission)

  const runAnalysis = async (targetSubmission: SubmissionResult | null) => {
    if (targetSubmission?.attribution_analysis) {
      setAnalysis(targetSubmission.attribution_analysis)
      setAnalysisStreamText('')
      setAnalysisStreamPreview(createEmptyStreamPreview())
      setAnalysisStreamMeta(null)
      setAnalysisAttemptCount(0)
      setAnalysisLastFailure(null)
      setAnalysisError('')
      return
    }

    setIsAnalyzing(true)
    setAnalysisAttemptCount((current) => current + 1)
    setAnalysisError('')
    setAnalysis(null)
    setAnalysisStreamText('')
    setAnalysisStreamPreview(createEmptyStreamPreview())
    setAnalysisStreamMeta(null)

    try {
      let finalResult: AnalysisResult | null = null
      if (targetSubmission) {
        await streamAttributionAnalysis(
          { submission_id: targetSubmission.id },
          {
            onMeta: (meta) => {
              setAnalysisStreamMeta(meta)
            },
            onStatus: (status) => {
              setAnalysisStreamMeta((current) => (current ? { ...current, ...status } : current))
            },
            onChunk: (text) => {
              setAnalysisStreamText((current) => current + text)
            },
            onTitle: (title) => {
              setAnalysisStreamPreview((current) => ({ ...current, title: title || current.title }))
            },
            onSummary: (summary) => {
              setAnalysisStreamPreview((current) => ({ ...current, summary }))
            },
            onBullet: (bullet) => {
              setAnalysisStreamPreview((current) => ({
                ...current,
                bullets: current.bullets.includes(bullet) ? current.bullets : [...current.bullets, bullet],
              }))
            },
            onLineRef: (lineRef) => {
              setAnalysisStreamPreview((current) => ({
                ...current,
                lineRefs: current.lineRefs.some((item) => item.line === lineRef.line && item.message === lineRef.message)
                  ? current.lineRefs
                  : [...current.lineRefs, lineRef],
              }))
            },
            onDone: (result) => {
              finalResult = result
              setAnalysis(result)
            },
          },
        )
      } else {
        await streamSolutionAnalysis(
          {
            problem_id: problem.id,
            language: selectedLanguage,
            code_text: currentCode,
          },
          {
            onMeta: (meta) => {
              setAnalysisStreamMeta(meta)
            },
            onStatus: (status) => {
              setAnalysisStreamMeta((current) => (current ? { ...current, ...status } : current))
            },
            onChunk: (text) => {
              setAnalysisStreamText((current) => current + text)
            },
            onTitle: (title) => {
              setAnalysisStreamPreview((current) => ({ ...current, title: title || current.title }))
            },
            onSummary: (summary) => {
              setAnalysisStreamPreview((current) => ({ ...current, summary }))
            },
            onBullet: (bullet) => {
              setAnalysisStreamPreview((current) => ({
                ...current,
                bullets: current.bullets.includes(bullet) ? current.bullets : [...current.bullets, bullet],
              }))
            },
            onLineRef: (lineRef) => {
              setAnalysisStreamPreview((current) => ({
                ...current,
                lineRefs: current.lineRefs.some((item) => item.line === lineRef.line && item.message === lineRef.message)
                  ? current.lineRefs
                  : [...current.lineRefs, lineRef],
              }))
            },
            onDone: (result) => {
              finalResult = result
              setAnalysis(result)
            },
          },
        )
      }

      if (targetSubmission) {
        if (!finalResult) {
          return
        }
        const result = finalResult
        const merged = mergeSubmissionAnalysis(targetSubmission, result)
        setLatestSubmission((current) => (current?.id === merged.id ? merged : current))
        setSubmissionHistory((current) => current.map((item) => (item.id === merged.id ? merged : item)))
      }
    } catch (error) {
      const message = error instanceof Error ? error.message : '分析失败'
      setAnalysisError(message)
      setAnalysisLastFailure({ message, timeLabel: buildTimeLabel() })
    } finally {
      setIsAnalyzing(false)
    }
  }

  const runReviewAnalysis = async (targetSubmission: SubmissionResult) => {
    if (targetSubmission.review_analysis) {
      setReviewAnalysis(targetSubmission.review_analysis)
      setReviewStreamText('')
      setReviewStreamPreview(createEmptyStreamPreview())
      setReviewStreamMeta(null)
      setReviewAttemptCount(0)
      setReviewLastFailure(null)
      setReviewError('')
      return
    }

    setIsReviewing(true)
    setReviewAttemptCount((current) => current + 1)
    setReviewError('')
    setReviewAnalysis(null)
    setReviewStreamText('')
    setReviewStreamPreview(createEmptyStreamPreview())
    setReviewStreamMeta(null)

    try {
      let finalResult: AnalysisResult | null = null
      await streamReviewAnalysis(
        { submission_id: targetSubmission.id },
        {
          onMeta: (meta) => {
            setReviewStreamMeta(meta)
          },
          onStatus: (status) => {
            setReviewStreamMeta((current) => (current ? { ...current, ...status } : current))
          },
          onChunk: (text) => {
            setReviewStreamText((current) => current + text)
          },
          onTitle: (title) => {
            setReviewStreamPreview((current) => ({ ...current, title: title || current.title }))
          },
          onSummary: (summary) => {
            setReviewStreamPreview((current) => ({ ...current, summary }))
          },
          onBullet: (bullet) => {
            setReviewStreamPreview((current) => ({
              ...current,
              bullets: current.bullets.includes(bullet) ? current.bullets : [...current.bullets, bullet],
            }))
          },
          onLineRef: (lineRef) => {
            setReviewStreamPreview((current) => ({
              ...current,
              lineRefs: current.lineRefs.some((item) => item.line === lineRef.line && item.message === lineRef.message)
                ? current.lineRefs
                : [...current.lineRefs, lineRef],
            }))
          },
          onDone: (result) => {
            finalResult = result
            setReviewAnalysis(result)
          },
        },
      )

      if (!finalResult) {
        return
      }

      const result = finalResult
      const merged = mergeSubmissionAnalysis(targetSubmission, result)
      setLatestSubmission((current) => (current?.id === merged.id ? merged : current))
      setSubmissionHistory((current) => current.map((item) => (item.id === merged.id ? merged : item)))
    } catch (error) {
      const message = error instanceof Error ? error.message : '复盘失败'
      setReviewError(message)
      setReviewLastFailure({ message, timeLabel: buildTimeLabel() })
    } finally {
      setIsReviewing(false)
    }
  }

  const requestNextHint = async () => {
    setIsHinting(true)
    setHintError('')

    try {
      const result = await analyzeHint({
        problem_id: problem.id,
        language: selectedLanguage,
        code_text: currentCode,
        hint_step: hintStep,
        hint_strength: hintStrength,
        submission_id: latestSubmission?.id ?? null,
      })
      setHints((current) => [...current, result])
      setHintStep((current) => Math.min(current + 1, hintStepLabels.length))
    } catch (error) {
      setHintError(error instanceof Error ? error.message : '提示生成失败')
    } finally {
      setIsHinting(false)
    }
  }

  const focusSubmission = (submission: SubmissionResult) => {
    setSelectedLanguage(submission.language)
    setLatestSubmission(submission)
    setWorkspaceTab('workspace')
    setWorkbenchTab(deriveWorkbenchTab(submission))
    setDrawerTab(deriveDrawerTab(submission))
    setSelectedCaseIndex(submission.failed_case_index ?? 1)
    setAnalysisStreamText('')
    setReviewStreamText('')
    setAnalysisStreamPreview(createEmptyStreamPreview())
    setReviewStreamPreview(createEmptyStreamPreview())
    setAnalysisStreamMeta(null)
    setReviewStreamMeta(null)
    setAnalysisAttemptCount(0)
    setReviewAttemptCount(0)
    setAnalysisLastFailure(null)
    setReviewLastFailure(null)
    void runAnalysis(submission)

    if (submission.run_type === 'submit') {
      void runReviewAnalysis(submission)
      return
    }

    setReviewAnalysis(null)
    setReviewError('')
  }

  useEffect(() => {
    if (!editorRef.current || !monacoRef.current) {
      return
    }

    const monaco = monacoRef.current
    decorationIdsRef.current = editorRef.current.deltaDecorations(
      decorationIdsRef.current,
      diagnostics.map((item) => ({
        range: new monaco.Range(item.line, 1, item.line, 1),
        options: {
          isWholeLine: true,
          glyphMarginClassName: item.severity === 'error' ? 'editor-glyph-error' : 'editor-glyph-warning',
          linesDecorationsClassName:
            item.severity === 'error' ? 'editor-line-decoration-error' : 'editor-line-decoration-warning',
          className: item.severity === 'error' ? 'editor-inline-highlight-error' : 'editor-inline-highlight-warning',
          hoverMessage: [{ value: item.message }],
        },
      })),
    )
  }, [diagnostics, selectedLanguage])

  const handleEditorMount = (editor: any, monaco: any) => {
    editorRef.current = editor
    monacoRef.current = monaco
  }

  const handleCodeChange = (value: string | undefined) => {
    setDrafts((current) => ({
      ...current,
      [selectedLanguage]: value ?? '',
    }))
  }

  const runSubmission = async (runType: SubmissionRunType) => {
    setIsSubmitting(true)
    setRequestError('')

    try {
      const result = await createSubmission({
        problem_id: problem.id,
        language: selectedLanguage,
        run_type: runType,
        code_text: currentCode,
        custom_input: customInput,
      })

      setSubmissionHistory((current) => [result, ...current].slice(0, 6))
      focusSubmission(result)
    } catch (error) {
      setRequestError(error instanceof Error ? error.message : '提交失败')
    } finally {
      setIsSubmitting(false)
    }
  }

  return (
    <section className="workspace-layout">
      <div className="workspace-header-card">
        <div className="workspace-header-main">
          <button type="button" className="button ghost" onClick={onBack}>
            返回题库
          </button>
          <div>
            <h1>{problem.title}</h1>
            <p>
              {problem.company} / {problem.difficulty} / {problem.category_slug}
            </p>
          </div>
        </div>

        <div className="workspace-actions">
          <div className="language-switcher" aria-label="语言切换">
            {supportedLanguages.map((language) => (
              <button
                key={language}
                type="button"
                className={`chip-button${language === selectedLanguage ? ' active' : ''}`}
                onClick={() => setSelectedLanguage(language)}
              >
                {language}
              </button>
            ))}
          </div>

          <button type="button" className="button" disabled={isSubmitting} onClick={() => void runSubmission('run')}>
            {isSubmitting ? '处理中...' : '自测'}
          </button>
          <button
            type="button"
            className="button primary"
            disabled={isSubmitting}
            onClick={() => void runSubmission('submit')}
          >
            {isSubmitting ? '处理中...' : '提交'}
          </button>
        </div>
      </div>

      <div className="summary-strip">
        <span className="summary-pill">{problem.external_id || problem.slug}</span>
        <span className="summary-pill">支持语言 {problem.supported_languages.join(' / ')}</span>
        <span className="summary-pill">{(problem.time_limit_ms ?? 2000)} ms</span>
        <span className="summary-pill">{((problem.memory_limit_kb ?? 262144) / 1024).toFixed(0)} MB</span>
      </div>

      <div className="workspace-grid">
        <div className="workspace-main-column">
          <div className="workspace-panel">
            <div className="workspace-tabs">
              <button
                type="button"
                className={`workspace-tab${workspaceTab === 'workspace' ? ' active' : ''}`}
                onClick={() => setWorkspaceTab('workspace')}
              >
                题面 + 代码
              </button>
              <button
                type="button"
                className={`workspace-tab${workspaceTab === 'history' ? ' active' : ''}`}
                onClick={() => setWorkspaceTab('history')}
              >
                提交记录
              </button>
            </div>

            {workspaceTab === 'workspace' ? (
              <div className="workspace-content-split">
                <div className="workspace-read-column">
                  <article className="statement-panel">
                    <section>
                      <h2>题面</h2>
                      <MarkdownRenderer className="problem-markdown" markdown={problem.statement_markdown} />
                    </section>
                  </article>

                  <div className="console-drawer workspace-inline-drawer">
                    <div className="workspace-tabs">
                      <button
                        type="button"
                        className={`workspace-tab${drawerTab === 'input' ? ' active' : ''}`}
                        onClick={() => setDrawerTab('input')}
                      >
                        自定义输入
                      </button>
                      <button
                        type="button"
                        className={`workspace-tab${drawerTab === 'output' ? ' active' : ''}`}
                        onClick={() => setDrawerTab('output')}
                      >
                        输出结果
                      </button>
                      <button
                        type="button"
                        className={`workspace-tab${drawerTab === 'diff' ? ' active' : ''}`}
                        onClick={() => setDrawerTab('diff')}
                      >
                        失败样例对比
                      </button>
                    </div>

                    {drawerTab === 'input' ? (
                      <div className="drawer-pane">
                        <textarea
                          className="input-editor"
                          value={customInput}
                          onChange={(event) => setCustomInput(event.target.value)}
                          placeholder="输入自定义 stdin"
                        />
                      </div>
                    ) : null}

                    {drawerTab === 'output' ? (
                      <div className="drawer-pane">
                        <pre className="output-block">{outputText}</pre>
                      </div>
                    ) : null}

                    {drawerTab === 'diff' ? (
                      <div className="drawer-pane">
                        {activeCase ? (
                          <DiffEditor
                            height="260px"
                            language="text"
                            original={activeCase.expected_output_text}
                            modified={activeCase.actual_output_text}
                            theme="light"
                            options={{
                              automaticLayout: true,
                              readOnly: true,
                              renderSideBySide: true,
                              originalEditable: false,
                              minimap: { enabled: false },
                            }}
                          />
                        ) : (
                          <div className="empty-panel">当前没有可展示的差异结果。</div>
                        )}
                      </div>
                    ) : null}
                  </div>
                </div>

                <div className="editor-panel workspace-editor-column">
                  <div className="editor-toolbar">
                    <span>当前语言：{selectedLanguage}</span>
                    <span>草稿自动保存在当前会话</span>
                  </div>
                  <Editor
                    height="760px"
                    language={selectedLanguage === 'C++' ? 'cpp' : selectedLanguage.toLowerCase()}
                    value={currentCode}
                    theme="vs-dark"
                    onChange={handleCodeChange}
                    onMount={handleEditorMount}
                    loading={<div className="editor-loading">正在加载 Monaco Editor...</div>}
                    options={{
                      automaticLayout: true,
                      minimap: { enabled: false },
                      scrollBeyondLastLine: false,
                      fontSize: 14,
                      glyphMargin: true,
                      lineNumbersMinChars: 3,
                      tabSize: 2,
                    }}
                  />
                </div>
              </div>
            ) : null}

            {workspaceTab === 'history' ? (
              <div className="history-panel">
                {submissionHistory.length === 0 ? (
                  <div className="empty-panel">当前还没有提交记录，先执行一次 Run 或 Submit。</div>
                ) : (
                  <div className="history-list">
                    {submissionHistory.map((item) => (
                      <button
                        key={item.id}
                        type="button"
                        className={`history-item${latestSubmission?.id === item.id ? ' active' : ''}`}
                        onClick={() => focusSubmission(item)}
                      >
                        <div className="history-item-main">
                          <div className="history-item-header">
                            <div>
                              <strong>#{item.id}</strong>
                              <span>{item.run_type === 'run' ? '自测运行' : '正式提交'}</span>
                            </div>
                            <span className={`status-badge ${verdictClassName(item.verdict)}`}>{item.verdict}</span>
                          </div>
                          <div className="history-item-meta">
                            <span>{item.language}</span>
                            <span>{item.runtime_ms} ms</span>
                            <span>{item.memory_kb} KB</span>
                            <span>{item.created_at.replace('T', ' ').replace('Z', '')}</span>
                          </div>
                          <p className="history-item-summary">{buildHistorySummary(item)}</p>
                          <div className="history-item-tags">
                            {item.attribution_analysis ? <span className="summary-pill summary-pill-active">已保存归因</span> : null}
                            {item.review_analysis ? <span className="summary-pill">已保存复盘</span> : null}
                          </div>
                        </div>
                      </button>
                    ))}
                  </div>
                )}
              </div>
            ) : null}
          </div>

        </div>

        <aside className="workbench-panel">
          <div className="workspace-tabs workbench-tabs">
            <button
              type="button"
              className={`workspace-tab${workbenchTab === 'result' ? ' active' : ''}`}
              onClick={() => setWorkbenchTab('result')}
            >
              判题结果
            </button>
            <button
              type="button"
              className={`workspace-tab${workbenchTab === 'hint' ? ' active' : ''}`}
              onClick={() => setWorkbenchTab('hint')}
            >
              分步提示
            </button>
            <button
              type="button"
              className={`workspace-tab${workbenchTab === 'explain' ? ' active' : ''}`}
              onClick={() => setWorkbenchTab('explain')}
            >
              错误归因
            </button>
            <button
              type="button"
              className={`workspace-tab${workbenchTab === 'review' ? ' active' : ''}`}
              onClick={() => setWorkbenchTab('review')}
            >
              训练复盘
            </button>
          </div>

          {requestError ? <div className="backend-note">接口请求失败：{requestError}</div> : null}

          {workbenchTab === 'result' ? (
            <div className="workbench-section">
              <div className="result-status-card">
                <span className={`status-badge ${verdictClassName(latestSubmission?.verdict ?? problem.status)}`}>
                  {latestSubmission?.verdict ?? problem.status}
                </span>
                <div className="result-metrics">
                  <strong>{latestSubmission?.runtime_ms ?? 0} ms</strong>
                  <span>{latestSubmission?.memory_kb ?? 0} KB</span>
                </div>
              </div>

              {latestSubmission?.stderr_output ? <pre className="stderr-card">{latestSubmission.stderr_output}</pre> : null}
              {latestSubmission?.compiler_output ? <pre className="stderr-card">{latestSubmission.compiler_output}</pre> : null}

              <div className="case-list">
                {(latestSubmission?.case_results ?? []).map((item) => (
                  <button
                    key={`${item.case_index}-${item.case_type}`}
                    type="button"
                    className={`case-item${selectedCaseIndex === item.case_index ? ' active' : ''}`}
                    onClick={() => setSelectedCaseIndex(item.case_index)}
                  >
                    <div>
                      <strong>Case {item.case_index}</strong>
                      <span>{item.case_type}</span>
                    </div>
                    <span className={`status-badge ${verdictClassName(item.verdict)}`}>{item.verdict}</span>
                  </button>
                ))}
              </div>
            </div>
          ) : null}

          {workbenchTab === 'hint' ? (
            <div className="workbench-section hint-section">
              <div className="result-status-card">
                <div>
                  <strong>渐进式提示</strong>
                  <div className="analysis-meta-text">按做题过程逐步释放线索，优先保留独立思考空间。</div>
                </div>
                <button type="button" className="button primary" disabled={isHinting} onClick={() => void requestNextHint()}>
                  {isHinting ? '生成中...' : `获取第 ${hintStep} 步`}
                </button>
              </div>

              <div className="hint-control-row">
                {hintStrengthOptions.map((item) => (
                  <button
                    key={item.value}
                    type="button"
                    className={`chip-button${hintStrength === item.value ? ' active' : ''}`}
                    onClick={() => setHintStrength(item.value)}
                  >
                    {item.label}
                  </button>
                ))}
              </div>

              {hintError ? <div className="backend-note">提示生成失败：{hintError}</div> : null}

              <div className="stream-progress-row">
                {hintStepLabels.map((label, index) => (
                  <span key={label} className={`stream-progress-pill ${index < hints.length ? 'done' : index + 1 === hintStep ? 'streaming' : 'waiting'}`}>
                    {index + 1}. {label}
                  </span>
                ))}
              </div>

              {hints.length === 0 ? (
                <p>点击获取提示后，会从读题澄清开始逐步给出线索。</p>
              ) : (
                <div className="diagnostic-list">
                  {hints.map((item, index) => (
                    <div key={`${item.title}-${index}`} className="diagnostic-item">
                      <strong>{item.title}</strong>
                      <span>{item.summary}</span>
                      {item.bullets.length > 0 ? (
                        <ul className="review-bullet-list">
                          {item.bullets.map((bullet) => (
                            <li key={bullet}>{bullet}</li>
                          ))}
                        </ul>
                      ) : null}
                    </div>
                  ))}
                </div>
              )}
            </div>
          ) : null}

          {workbenchTab === 'explain' ? (
            <div className="workbench-section explain-section">
              <div className="result-status-card">
                <div>
                  <strong>{analysis?.title ?? 'AI 分析'}</strong>
                  <div className="analysis-meta-text">
                    {analysis ? `${analysis.provider} / ${analysis.model}` : '尚未触发分析'}
                  </div>
                  {analysis ? (
                    <div className={getAnalysisStatusClassName(analysis.execution_status)}>{getAnalysisStatusLabel(analysis.execution_status)}</div>
                  ) : null}
                </div>
                <button
                  type="button"
                  className="button"
                  disabled={isAnalyzing}
                  onClick={() => void runAnalysis(latestSubmission)}
                >
                  {isAnalyzing ? '分析中...' : latestSubmission ? '重新归因' : '分析当前代码'}
                </button>
              </div>

              {analysisError ? <div className="backend-note">AI 分析失败：{analysisError}</div> : null}

              {isAnalyzing ? (
                <div className="streaming-panel">
                  <div className="streaming-panel-header">
                    <div>
                      <strong>{analysisPreview.title || 'AI 正在生成归因结果'}</strong>
                      {buildStreamMetaText(analysisStreamMeta) ? (
                        <div className="analysis-meta-text">{buildStreamMetaText(analysisStreamMeta)}</div>
                      ) : null}
                      {analysisStreamMeta ? (
                        <div className={getAnalysisStatusClassName(analysisStreamMeta.execution_status)}>
                          {getAnalysisStatusLabel(analysisStreamMeta.execution_status)}
                        </div>
                      ) : null}
                    </div>
                    <span className="streaming-status">流式输出中</span>
                  </div>
                  {analysisStreamMeta?.endpoint_url ? (
                    <div className="analysis-meta-block">
                      <strong>Endpoint</strong>
                      <code>{analysisStreamMeta.endpoint_url}</code>
                    </div>
                  ) : null}
                  <div className="stream-retry-card">
                    <div className="stream-retry-row">
                      <strong>本轮生成</strong>
                      <span>第 {analysisAttemptCount} 次</span>
                    </div>
                    {analysisLastFailure ? (
                      <div className="stream-retry-row stream-retry-warning">
                        <strong>上次失败</strong>
                        <span>
                          {analysisLastFailure.timeLabel} · {analysisLastFailure.message}
                        </span>
                      </div>
                    ) : (
                      <div className="stream-retry-row">
                        <strong>上次失败</strong>
                        <span>当前没有失败记录</span>
                      </div>
                    )}
                  </div>
                  <div className="stream-progress-row">
                    {analysisProgress.map((item) => (
                      <span key={item.key} className={`stream-progress-pill ${item.status}`}>
                        {item.label} {item.status === 'done' ? '已完成' : item.status === 'streaming' ? '生成中' : '等待中'}
                      </span>
                    ))}
                  </div>
                  {analysisPreview.summary ? <p className="streaming-summary">{analysisPreview.summary}</p> : null}
                  {analysisStreamMeta?.status_reason ? <div className="backend-note">当前状态说明：{analysisStreamMeta.status_reason}</div> : null}
                  {analysisPreview.bullets.length > 0 ? (
                    <div className="diagnostic-list">
                      {analysisPreview.bullets.map((item) => (
                        <div key={item} className="diagnostic-item">
                          <span>{item}</span>
                        </div>
                      ))}
                    </div>
                  ) : null}
                  {analysisPreview.lineRefs.length > 0 ? (
                    <div className="diagnostic-list">
                      {analysisPreview.lineRefs.map((item) => (
                        <div key={`${item.line}-${item.message}`} className="diagnostic-item">
                          <strong>Line {item.line}</strong>
                          <span>{item.message}</span>
                        </div>
                      ))}
                    </div>
                  ) : null}
                  {analysisStreamText ? (
                    <details className="streaming-raw-block">
                      <summary>查看流式原文</summary>
                      <pre className="stderr-card">{analysisStreamText}</pre>
                    </details>
                  ) : null}
                </div>
              ) : null}

              {analysis ? (
                <>
                  <p>{analysis.summary}</p>
                  <div className="diagnostic-list">
                    {analysis.bullets.map((item) => (
                      <div key={item} className="diagnostic-item">
                        <span>{item}</span>
                      </div>
                    ))}
                  </div>
                  <div className="analysis-meta-block">
                    <strong>Endpoint</strong>
                    <code>{analysis.endpoint_url}</code>
                  </div>
                  {analysis.status_reason ? <div className="backend-note">状态说明：{analysis.status_reason}</div> : null}
                </>
              ) : (
                <p>当前还没有分析结果，可以直接分析当前代码，或在 Run / Submit 后查看归因结果。</p>
              )}

              <div className="diagnostic-list">
                {diagnostics.map((item) => (
                  <div key={`${item.line}-${item.message}`} className="diagnostic-item">
                    <strong>Line {item.line}</strong>
                    <span>{item.message}</span>
                  </div>
                ))}
              </div>
            </div>
          ) : null}

          {workbenchTab === 'review' ? (
            <div className="workbench-section review-section">
              <div className="result-status-card">
                <div>
                  <strong>{reviewAnalysis?.title ?? '训练复盘'}</strong>
                  <div className="analysis-meta-text">
                    {reviewAnalysis ? `${reviewAnalysis.provider} / ${reviewAnalysis.model}` : '尚未触发复盘'}
                  </div>
                  {reviewAnalysis ? (
                    <div className={getAnalysisStatusClassName(reviewAnalysis.execution_status)}>{getAnalysisStatusLabel(reviewAnalysis.execution_status)}</div>
                  ) : null}
                </div>
                <button
                  type="button"
                  className="button"
                  disabled={isReviewing || !latestSubmission}
                  onClick={() => {
                    if (latestSubmission) {
                      void runReviewAnalysis(latestSubmission)
                    }
                  }}
                >
                  {isReviewing ? '生成中...' : '刷新复盘'}
                </button>
              </div>

              {reviewError ? <div className="backend-note">复盘生成失败：{reviewError}</div> : null}

              {isReviewing ? (
                <div className="streaming-panel">
                  <div className="streaming-panel-header">
                    <div>
                      <strong>{reviewPreview.title || 'AI 正在生成复盘建议'}</strong>
                      {buildStreamMetaText(reviewStreamMeta) ? (
                        <div className="analysis-meta-text">{buildStreamMetaText(reviewStreamMeta)}</div>
                      ) : null}
                      {reviewStreamMeta ? (
                        <div className={getAnalysisStatusClassName(reviewStreamMeta.execution_status)}>
                          {getAnalysisStatusLabel(reviewStreamMeta.execution_status)}
                        </div>
                      ) : null}
                    </div>
                    <span className="streaming-status">流式输出中</span>
                  </div>
                  {reviewStreamMeta?.endpoint_url ? (
                    <div className="analysis-meta-block">
                      <strong>Endpoint</strong>
                      <code>{reviewStreamMeta.endpoint_url}</code>
                    </div>
                  ) : null}
                  <div className="stream-retry-card">
                    <div className="stream-retry-row">
                      <strong>本轮生成</strong>
                      <span>第 {reviewAttemptCount} 次</span>
                    </div>
                    {reviewLastFailure ? (
                      <div className="stream-retry-row stream-retry-warning">
                        <strong>上次失败</strong>
                        <span>
                          {reviewLastFailure.timeLabel} · {reviewLastFailure.message}
                        </span>
                      </div>
                    ) : (
                      <div className="stream-retry-row">
                        <strong>上次失败</strong>
                        <span>当前没有失败记录</span>
                      </div>
                    )}
                  </div>
                  <div className="stream-progress-row">
                    {reviewProgress.map((item) => (
                      <span key={item.key} className={`stream-progress-pill ${item.status}`}>
                        {item.label} {item.status === 'done' ? '已完成' : item.status === 'streaming' ? '生成中' : '等待中'}
                      </span>
                    ))}
                  </div>
                  {reviewPreview.summary ? <p className="streaming-summary">{reviewPreview.summary}</p> : null}
                  {reviewStreamMeta?.status_reason ? <div className="backend-note">当前状态说明：{reviewStreamMeta.status_reason}</div> : null}
                  {reviewPreview.bullets.length > 0 ? (
                    <div className="diagnostic-list">
                      {reviewPreview.bullets.map((item) => (
                        <div key={item} className="diagnostic-item">
                          <span>{item}</span>
                        </div>
                      ))}
                    </div>
                  ) : null}
                  {reviewPreview.lineRefs.length > 0 ? (
                    <div className="diagnostic-list">
                      {reviewPreview.lineRefs.map((item) => (
                        <div key={`${item.line}-${item.message}`} className="diagnostic-item">
                          <strong>Line {item.line}</strong>
                          <span>{item.message}</span>
                        </div>
                      ))}
                    </div>
                  ) : null}
                  {reviewStreamText ? (
                    <details className="streaming-raw-block">
                      <summary>查看流式原文</summary>
                      <pre className="stderr-card">{reviewStreamText}</pre>
                    </details>
                  ) : null}
                </div>
              ) : null}

              {reviewAnalysis ? (
                <>
                  <p>{reviewAnalysis.summary}</p>
                  <div className="diagnostic-list">
                    {reviewAnalysis.bullets.map((item) => (
                      <div key={item} className="diagnostic-item">
                        <span>{item}</span>
                      </div>
                    ))}
                  </div>
                  {reviewAnalysis.status_reason ? <div className="backend-note">状态说明：{reviewAnalysis.status_reason}</div> : null}
                </>
              ) : (
                <>
                  <p>最近一次结果会优先进入这里，形成 Submit 之后立即复盘的链路。</p>
                  <ul className="review-bullet-list">
                    <li>最近 Verdict：{latestSubmission?.verdict ?? '尚未提交'}</li>
                    <li>当前语言：{selectedLanguage}</li>
                    <li>最近动作：{latestSubmission?.run_type === 'submit' ? '正式提交' : '自测运行'}</li>
                  </ul>
                </>
              )}
            </div>
          ) : null}
        </aside>
      </div>

      <div className="backend-note">
        当前 `Run/Submit` 已接入 <code>/api/v1/submissions</code>，后端已返回真实 Judge0 判题结果与统一结构化字段。
      </div>
    </section>
  )
}
