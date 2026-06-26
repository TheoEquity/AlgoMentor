import 'katex/dist/katex.min.css'

import katex from 'katex'
import { marked } from 'marked'
import { useMemo } from 'react'

type MarkdownRendererProps = {
  markdown: string
}

function extractMath(content: string): { text: string; html: string[] } {
  const html: string[] = []
  const text = content.replace(/```[\s\S]*?```|`[^`\n]+`|\$\$([\s\S]*?)\$\$|\$([^$\n]+?)\$/g, (full: string, displayExpr?: string, inlineExpr?: string) => {
    const expr = displayExpr ?? inlineExpr
    if (!expr) return full
    try {
      const rendered = katex.renderToString(expr.trim(), { displayMode: Boolean(displayExpr), throwOnError: false })
      const index = html.push(rendered) - 1
      return `KATEXPLACEHOLDER${index}`
    } catch {
      return full
    }
  })
  return { text, html }
}

function restoreMath(content: string, html: string[]): string {
  return content.replace(/KATEXPLACEHOLDER(\d+)/g, (_full: string, index: string) => html[Number(index)] ?? _full)
}

export function MarkdownRenderer({ markdown }: MarkdownRendererProps) {
  const html = useMemo(() => {
    const math = extractMath(markdown)
    const raw = marked.parse(math.text, { async: false, breaks: false, gfm: true }) as string
    return restoreMath(raw, math.html)
  }, [markdown])

  return <div className="markdown-body" dangerouslySetInnerHTML={{ __html: html }} />
}
