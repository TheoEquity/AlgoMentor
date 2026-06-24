import 'katex/dist/katex.min.css'

import katex from 'katex'
import { marked } from 'marked'
import { useMemo } from 'react'

type MarkdownRendererProps = {
  markdown: string
}

function renderMath(content: string): string {
  let result = content

  result = result.replace(/\$\$([\s\S]*?)\$\$/g, (_full: string, expr: string) => {
    try {
      return katex.renderToString(expr.trim(), { displayMode: true, throwOnError: false })
    } catch {
      return _full
    }
  })

  result = result.replace(/\$([^$]+?)\$/g, (_full: string, expr: string) => {
    try {
      return katex.renderToString(expr.trim(), { displayMode: false, throwOnError: false })
    } catch {
      return _full
    }
  })

  return result
}

export function MarkdownRenderer({ markdown }: MarkdownRendererProps) {
  const html = useMemo(() => {
    const raw = marked.parse(markdown, { async: false }) as string
    return renderMath(raw)
  }, [markdown])

  return <div className="markdown-body" dangerouslySetInnerHTML={{ __html: html }} />
}
