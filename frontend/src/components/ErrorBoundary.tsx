import { Component, type ReactNode } from 'react'

type Props = { children: ReactNode; fallback?: ReactNode }
type State = { error: Error | null }

export class ErrorBoundary extends Component<Props, State> {
  state: State = { error: null }

  static getDerivedStateFromError(error: Error): State {
    return { error }
  }

  render() {
    if (this.state.error) {
      if (this.props.fallback) return this.props.fallback
      return (
        <div style={{ padding: 32, margin: 16, background: '#fef2f2', border: '1px solid #fca5a5', borderRadius: 8 }}>
          <h3 style={{ color: '#dc2626', marginTop: 0 }}>组件渲染错误</h3>
          <pre style={{ whiteSpace: 'pre-wrap', fontSize: 13, color: '#991b1b' }}>{this.state.error.message}</pre>
          <pre style={{ whiteSpace: 'pre-wrap', fontSize: 12, color: '#7f1d1d', marginTop: 8 }}>{this.state.error.stack?.slice(0, 500)}</pre>
          <button type="button" className="button" style={{ marginTop: 12 }} onClick={() => this.setState({ error: null })}>重试</button>
        </div>
      )
    }
    return this.props.children
  }
}
