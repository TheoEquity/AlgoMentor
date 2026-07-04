import { useEffect, useRef, useState } from 'react'
import { MarkdownRenderer } from '../components/MarkdownRenderer'
import { createSession, deleteSession, findOrCreateProblemSession, listMessages, listSessions, streamSendMessage, updateSession } from '../lib/chatApi'
import { listAgents } from '../lib/agentApi'
import type { ChatMessage, ChatSession, AgentConfig } from '../types/agent'

function formatTime(iso: string): string {
  const d = new Date(iso)
  const now = new Date()
  const diff = now.getTime() - d.getTime()
  if (diff < 86400000) return d.toLocaleTimeString('zh-CN', { hour: '2-digit', minute: '2-digit' })
  if (diff < 604800000) return `${Math.floor(diff / 86400000)} 天前`
  return d.toLocaleDateString('zh-CN', { month: 'short', day: 'numeric' })
}

function groupByDate(messages: ChatMessage[]): { label: string; msgs: ChatMessage[] }[] {
  const groups: { label: string; msgs: ChatMessage[] }[] = []
  let lastLabel = ''
  for (const msg of messages) {
    const d = new Date(msg.created_at)
    const label = d.toLocaleDateString('zh-CN', { month: 'long', day: 'numeric' })
    if (label !== lastLabel) {
      groups.push({ label, msgs: [] })
      lastLabel = label
    }
    groups[groups.length - 1].msgs.push(msg)
  }
  return groups
}

function parseCodeBlocks(content: string): Array<{ type: 'text' | 'code'; content: string; lang?: string }> {
  const regex = /```(\w*)\n([\s\S]*?)```/g
  const parts: Array<{ type: 'text' | 'code'; content: string; lang?: string }> = []
  let last = 0
  let m
  while ((m = regex.exec(content)) !== null) {
    if (m.index > last) parts.push({ type: 'text', content: content.slice(last, m.index) })
    parts.push({ type: 'code', content: m[2], lang: m[1] || undefined })
    last = m.index + m[0].length
  }
  if (last < content.length) parts.push({ type: 'text', content: content.slice(last) })
  return parts
}

export function ChatPage({ problemId = null }: { problemId?: number | null }) {
  const [sessions, setSessions] = useState<ChatSession[]>([])
  const [agents, setAgents] = useState<AgentConfig[]>([])
  const [activeSessionId, setActiveSessionId] = useState<number | null>(null)
  const [messages, setMessages] = useState<ChatMessage[]>([])
  const [input, setInput] = useState('')
  const [sending, setSending] = useState(false)
  const [streamingContent, setStreamingContent] = useState('')
  const [error, setError] = useState('')
  const streamBufferRef = useRef('')
  const [editingSessionId, setEditingSessionId] = useState<number | null>(null)
  const [editTitle, setEditTitle] = useState('')
  const [creatingSession, setCreatingSession] = useState(false)
  const messagesEndRef = useRef<HTMLDivElement>(null)
  const inputRef = useRef<HTMLTextAreaElement>(null)

  useEffect(() => { void loadData() }, [])
  useEffect(() => {
    if (problemId && agents.length > 0) {
      void initProblemSession()
    }
  }, [problemId, agents])
  useEffect(() => { messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' }) }, [messages])

  async function loadData() {
    try {
      const [ss, aa] = await Promise.all([listSessions(), listAgents(true)])
      setSessions(ss)
      setAgents(aa)
    } catch (e) {
      setError(e instanceof Error ? e.message : '加载失败')
    }
  }

  async function initProblemSession() {
    if (!problemId) return
    try {
      const session = await findOrCreateProblemSession(problemId)
      setSessions((prev) => {
        if (prev.find((s) => s.id === session.id)) return prev
        return [session, ...prev]
      })
      setActiveSessionId(session.id)
      setMessages(await listMessages(session.id))
    } catch (e) {
      setError(e instanceof Error ? e.message : '创建会话失败')
    }
  }

  async function selectSession(id: number) {
    setActiveSessionId(id)
    setError('')
    try {
      setMessages(await listMessages(id))
    } catch { setError('加载消息失败') }
  }

  async function handleCreateSession() {
    if (agents.length === 0) return
    setCreatingSession(true)
    try {
      const s = await createSession({ agent_id: agents[0].id, title: '新对话' })
      setSessions((prev) => [s, ...prev])
      setActiveSessionId(s.id)
      setMessages([])
    } catch (e) {
      setError(e instanceof Error ? e.message : '创建失败')
    } finally { setCreatingSession(false) }
  }

  async function handleRename(id: number) {
    const t = editTitle.trim()
    if (!t) { setEditingSessionId(null); return }
    try {
      const u = await updateSession(id, { title: t })
      setSessions((prev) => prev.map((s) => (s.id === id ? u : s)))
    } catch (e) { setError(e instanceof Error ? e.message : '重命名失败') }
    setEditingSessionId(null)
  }

  async function handleDeleteSession(id: number) {
    try {
      await deleteSession(id)
      setSessions((prev) => prev.filter((s) => s.id !== id))
      if (activeSessionId === id) { setActiveSessionId(null); setMessages([]) }
    } catch (e) { setError(e instanceof Error ? e.message : '删除失败') }
  }

  async function handleSend() {
    const q = input.trim()
    if (!q || activeSessionId === null || sending) return

    setInput('')
    setSending(true)
    setStreamingContent('')
    setError('')
    streamBufferRef.current = ''

    const userMsg: ChatMessage = {
      id: Date.now(), session_id: activeSessionId, role: 'user',
      content: q, tool_calls: null, tool_results: null,
      token_usage: null, created_at: new Date().toISOString(),
    }
    setMessages((prev) => [...prev, userMsg])

    let autoTitle = false
    if (sessions.find((s) => s.id === activeSessionId)?.title === '新对话') autoTitle = true

    try {
      await streamSendMessage(activeSessionId, { query: q }, {
        onChunk(text) {
          streamBufferRef.current += text
          setStreamingContent(streamBufferRef.current)
        },
        onDone(data) {
          const content = streamBufferRef.current
          const ai: ChatMessage = {
            id: Date.now() + 1, session_id: activeSessionId, role: 'assistant',
            content,
            tool_calls: null, tool_results: null,
            token_usage: JSON.stringify(data),
            created_at: new Date().toISOString(),
          }
          streamBufferRef.current = ''
          setMessages((prev) => [...prev, ai])
          setStreamingContent('')
          setSending(false)
        },
        onError(err) { setError(err); streamBufferRef.current = ''; setSending(false) },
      })
    } catch (e) {
      setError(e instanceof Error ? e.message : '发送失败')
      streamBufferRef.current = ''
      setSending(false)
    }

    if (autoTitle) {
      const short = q.slice(0, 28) + (q.length > 28 ? '...' : '')
      try {
        const u = await updateSession(activeSessionId, { title: short })
        setSessions((prev) => prev.map((s) => (s.id === activeSessionId ? u : s)))
      } catch { /* silent */ }
    }
  }

  function handleKeyDown(e: React.KeyboardEvent) {
    if (e.key === 'Enter' && !e.shiftKey) { e.preventDefault(); void handleSend() }
  }

  const agent = sessions.find((s) => s.id === activeSessionId)
  const activeAgent = agents.find((a) => a.id === agent?.agent_id)

  const messageGroups = groupByDate(messages)

  return (
    <div className="chat-page">
      <aside className="chat-sidebar">
        <div className="chat-sidebar-head">
          <button className="chat-new-btn" disabled={creatingSession} onClick={() => void handleCreateSession()}>
            <svg width="16" height="16" viewBox="0 0 16 16" fill="none"><path d="M8 3v10M3 8h10" stroke="currentColor" strokeWidth="2" strokeLinecap="round"/></svg>
            {creatingSession ? '创建中...' : '新对话'}
          </button>
        </div>
        <div className="chat-session-list">
          {sessions.map((s) => (
            <div
              key={s.id}
              className={`chat-session-item${s.id === activeSessionId ? ' active' : ''}`}
              onClick={() => void selectSession(s.id)}
            >
              <div className="chat-session-icon">
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                  <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/>
                </svg>
              </div>
              {editingSessionId === s.id ? (
                <input
                  className="chat-session-input"
                  value={editTitle} onChange={(e) => setEditTitle(e.target.value)}
                  onBlur={() => void handleRename(s.id)}
                  onKeyDown={(e) => { if (e.key === 'Enter') void handleRename(s.id); if (e.key === 'Escape') setEditingSessionId(null) }}
                  onClick={(e) => e.stopPropagation()} autoFocus
                />
              ) : (
                <div className="chat-session-info">
                  <span className="chat-session-title">{s.title}</span>
                  <span className="chat-session-time">{formatTime(s.updated_at)}</span>
                </div>
              )}
              <div className="chat-session-actions">
                <button className="chat-session-act" title="重命名" onClick={(e) => { e.stopPropagation(); setEditingSessionId(s.id); setEditTitle(s.title) }}>
                  <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M17 3a2.8 2.8 0 1 1 4 4L7.5 20.5 2 22l1.5-5.5Z"/></svg>
                </button>
                <button className="chat-session-act chat-session-act-del" title="删除" onClick={(e) => { e.stopPropagation(); void handleDeleteSession(s.id) }}>
                  <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M3 6h18M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6M8 6V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg>
                </button>
              </div>
            </div>
          ))}
        </div>
        <div className="chat-sidebar-foot">
          {activeAgent && (
            <div className="chat-agent-badge">
              <span className="chat-agent-dot" />
              {activeAgent.name}
            </div>
          )}
        </div>
      </aside>

      <div className="chat-main">
        {activeSessionId === null ? (
          <div className="chat-empty">
            <div className="chat-empty-icon">
              <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="var(--text-muted)" strokeWidth="1.5">
                <path d="M12 2a10 10 0 1 0 0 20 10 10 0 0 0 0-20Z"/>
                <path d="M12 16v-4M12 8h.01"/>
              </svg>
            </div>
            <h2>开始对话</h2>
            <p>从左侧选择已有对话，或新建一个对话与 AI 助手交流。</p>
          </div>
        ) : (
          <>
            <div className="chat-header">
              <div className="chat-header-info">
                {activeAgent && <span className="chat-agent-dot chat-agent-dot-lg" />}
                <h3>{activeAgent?.name ?? 'AI 助手'}</h3>
                {activeAgent && <span className="chat-header-model">{activeAgent.model}</span>}
              </div>
            </div>

            <div className="chat-messages">
              {messageGroups.map((group, gi) => (
                <div key={gi}>
                  <div className="chat-date-divider"><span>{group.label}</span></div>
                  {group.msgs.map((msg) => (
                    <div key={msg.id} className={`chat-msg ${msg.role === 'user' ? 'chat-msg-user' : 'chat-msg-ai'}`}>
                      {msg.role === 'assistant' && (
                        <div className="chat-msg-avatar">
                          {activeAgent?.name?.charAt(0) ?? 'A'}
                        </div>
                      )}
                      <div className="chat-msg-body">
                        {msg.role === 'assistant' && msg.tool_calls && (() => {
                          try {
                            const tc = JSON.parse(msg.tool_calls) as Array<{ name: string; arguments: Record<string, unknown>; result: string }>
                            return (
                              <details className="chat-tool-calls">
                                <summary>调用了 {tc.length} 个工具</summary>
                                <div className="chat-tool-list">
                                  {tc.map((t, i) => (
                                    <div key={i} className="chat-tool-item">
                                      <code>{t.name}</code>
                                      <pre>{t.result}</pre>
                                    </div>
                                  ))}
                                </div>
                              </details>
                            )
                          } catch { return null }
                        })()}

                        <div className={`chat-bubble ${msg.role === 'user' ? 'chat-bubble-user' : 'chat-bubble-ai'}`}>
                          {msg.role === 'assistant'
                            ? <MarkdownRenderer className="chat-markdown" markdown={msg.content} />
                            : <span className="chat-text">{msg.content}</span>
                          }
                        </div>

                        {msg.role === 'assistant' && msg.token_usage && (() => {
                          try {
                            const u = JSON.parse(msg.token_usage)
                            return <div className="chat-token">{u.total_tokens} tokens</div>
                          } catch { return null }
                        })()}
                      </div>
                    </div>
                  ))}
                </div>
              ))}

              {sending && (
                <div className="chat-msg chat-msg-ai">
                  <div className="chat-msg-avatar">{activeAgent?.name?.charAt(0) ?? 'A'}</div>
                  <div className="chat-msg-body">
                    <div className="chat-bubble chat-bubble-ai">
                      {streamingContent
                        ? <div className="chat-streaming-cursor"><MarkdownRenderer className="chat-markdown" markdown={streamingContent} /></div>
                        : <div className="chat-typing"><span /><span /><span /></div>
                      }
                    </div>
                  </div>
                </div>
              )}

              {error && <div className="chat-error-banner">{error}</div>}
              <div ref={messagesEndRef} />
            </div>

            <div className="chat-input-area">
              <div className="chat-input-wrapper">
                <textarea
                  ref={inputRef}
                  className="chat-input"
                  value={input}
                  onChange={(e) => setInput(e.target.value)}
                  onKeyDown={handleKeyDown}
                  placeholder="输入消息，Enter 发送，Shift+Enter 换行"
                  rows={1}
                  disabled={sending}
                />
                <button
                  className="chat-send"
                  disabled={!input.trim() || sending}
                  onClick={() => void handleSend()}
                >
                  <svg width="18" height="18" viewBox="0 0 24 24" fill="none"><path d="M22 2L11 13M22 2l-7 20-4-9-9-4 20-7z" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/></svg>
                </button>
              </div>
              <span className="chat-input-hint">AI 回复可能包含不准确信息，请自行判断。</span>
            </div>
          </>
        )}
      </div>
    </div>
  )
}
