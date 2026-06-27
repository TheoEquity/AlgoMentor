import 'katex/dist/katex.min.css'

import katex from 'katex'
import { marked } from 'marked'
import { useMemo } from 'react'

type MarkdownRendererProps = {
  className?: string
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

function enhanceProblemHtml(content: string): string {
  return content
    .replace(/<h2>(题目描述|输入格式|输出格式|补充说明|样例)<\/h2>/g, (_full: string, title: string) => {
      const kindMap: Record<string, string> = {
        '题目描述': 'description',
        '输入格式': 'input',
        '输出格式': 'output',
        '补充说明': 'notes',
        '样例': 'samples',
      }
      return `<h2 class="problem-section-heading problem-section-${kindMap[title]}">${title}</h2>`
    })
    .replace(/<h3>(样例\s*\d+)<\/h3>/g, '<h3 class="problem-sample-heading">$1</h3>')
    .replace(/<p><strong>(输入：|输出：|说明：)<\/strong><\/p>/g, '<p class="problem-io-label"><strong>$1</strong></p>')
}

export function MarkdownRenderer({ markdown, className }: MarkdownRendererProps) {
  const html = useMemo(() => {
    const math = extractMath(markdown)
    const raw = marked.parse(math.text, { async: false, breaks: true, gfm: true }) as string
    const restored = restoreMath(raw, math.html)
    return enhanceProblemHtml(restored)
  }, [markdown])

  const classes = className ? `markdown-body ${className}` : 'markdown-body'

  return <div className={classes} dangerouslySetInnerHTML={{ __html: html }} />
}
