import { useEffect, useState } from 'react'
import * as echarts from 'echarts'
import type { DashboardData } from '../types/dashboard'
import { getDashboard } from '../lib/dashboardApi'

const DIFFICULTY_COLORS: Record<string, string> = {
  Easy: '#52c41a',
  Medium: '#faad14',
  Hard: '#ff4d4f',
}

const SOURCE_COLORS = ['#5470c6', '#91cc75', '#fac858', '#ee6666', '#73c0de', '#3ba272', '#fc8452', '#9a60b4']
const YEAR_COLORS = ['#e8c600', '#36a2eb', '#ff6384', '#4bc0c0', '#9966ff', '#ff9f40', '#c9cbcf']

export function DashboardPage() {
  const [data, setData] = useState<DashboardData | null>(null)
  const [error, setError] = useState('')

  useEffect(() => {
    let cancelled = false
    void getDashboard()
      .then((result) => {
        if (!cancelled) setData(result)
      })
      .catch((err: unknown) => {
        if (!cancelled) setError(err instanceof Error ? err.message : '加载失败')
      })
    return () => { cancelled = true }
  }, [])

  useEffect(() => {
    if (!data) return
    const el = document.getElementById('chart-source')
    if (!el) return
    const chart = echarts.init(el)
    chart.setOption({
      tooltip: { trigger: 'item', formatter: '{b}: {c} ({d}%)' },
      series: [{
        type: 'pie', radius: ['40%', '60%'],
        label: { show: true, formatter: '{b}\n{c}', fontSize: 11 },
        data: data.source_distribution.map((d, i) => ({
          name: d.name, value: d.count,
          itemStyle: { color: SOURCE_COLORS[i % SOURCE_COLORS.length] },
        })),
      }],
    })
    return () => chart.dispose()
  }, [data])

  useEffect(() => {
    if (!data) return
    const el = document.getElementById('chart-difficulty')
    if (!el) return
    const chart = echarts.init(el)
    chart.setOption({
      tooltip: { trigger: 'item', formatter: '{b}: {c} ({d}%)' },
      series: [{
        type: 'pie', radius: ['40%', '60%'],
        label: { show: true, formatter: '{b}\n{c}', fontSize: 11 },
        data: data.difficulty_distribution.map(d => ({
          name: d.name, value: d.count,
          itemStyle: { color: DIFFICULTY_COLORS[d.name] || '#999' },
        })),
      }],
    })
    return () => chart.dispose()
  }, [data])

  useEffect(() => {
    if (!data) return
    const el = document.getElementById('chart-year')
    if (!el) return
    const chart = echarts.init(el)
    chart.setOption({
      tooltip: { trigger: 'item', formatter: '{b}: {c} ({d}%)' },
      series: [{
        type: 'pie', radius: ['40%', '60%'],
        label: { show: true, formatter: '{b}\n{c}', fontSize: 11 },
        data: data.year_distribution.map((d, i) => ({
          name: d.name, value: d.count,
          itemStyle: { color: YEAR_COLORS[i % YEAR_COLORS.length] },
        })),
      }],
    })
    return () => chart.dispose()
  }, [data])

  useEffect(() => {
    if (!data) return
    const el = document.getElementById('chart-company')
    if (!el) return
    const chart = echarts.init(el)
    const names = data.company_distribution.map(d => d.name)
    const counts = data.company_distribution.map(d => d.count)
    chart.setOption({
      tooltip: { trigger: 'axis', axisPointer: { type: 'shadow' } },
      grid: { left: 50, right: 30, top: 8, bottom: 60 },
      xAxis: {
        type: 'category',
        data: names,
        axisLabel: { rotate: 45, fontSize: 11 },
      },
      yAxis: { type: 'value' },
      series: [{
        type: 'bar',
        data: counts,
        itemStyle: { color: '#52c41a', borderRadius: [3, 3, 0, 0] },
        label: { show: true, position: 'top', fontSize: 10 },
      }],
    })
    return () => chart.dispose()
  }, [data])

  useEffect(() => {
    if (!data) return
    const el = document.getElementById('chart-category')
    if (!el) return
    const chart = echarts.init(el)
    chart.setOption({
      tooltip: { trigger: 'axis', axisPointer: { type: 'shadow' } },
      grid: { left: 40, right: 20, top: 8, bottom: 60 },
      xAxis: {
        type: 'category',
        data: data.category_distribution.map(d => d.name),
        axisLabel: { rotate: 45, fontSize: 11 },
      },
      yAxis: { type: 'value' },
      series: [{
        type: 'bar',
        data: data.category_distribution.map(d => d.count),
        itemStyle: { color: '#1890ff', borderRadius: [3, 3, 0, 0] },
        label: { show: true, position: 'top', fontSize: 10 },
      }],
    })
    return () => chart.dispose()
  }, [data])

  if (error) {
    return <div className="backend-note">{error}</div>
  }

  return (
    <section>
      <div className="page-header" style={{ marginBottom: 12 }}>
        <div>
          <h1>总览</h1>
          <p>题库全局分布与错题统计，快速掌握复习重点。</p>
        </div>
      </div>

      {!data && <div className="backend-note" style={{ marginBottom: 12 }}>正在加载...</div>}

      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: 16, marginBottom: 16 }}>
        <div className="table-card" style={{ padding: '14px 20px' }}>
          <h3 style={{ margin: '0 0 10px', fontSize: 15, fontWeight: 600 }}>来源分布</h3>
          <div id="chart-source" style={{ width: '100%', height: 220 }} />
        </div>
        <div className="table-card" style={{ padding: '14px 20px' }}>
          <h3 style={{ margin: '0 0 10px', fontSize: 15, fontWeight: 600 }}>难度分布</h3>
          <div id="chart-difficulty" style={{ width: '100%', height: 220 }} />
        </div>
        <div className="table-card" style={{ padding: '14px 20px' }}>
          <h3 style={{ margin: '0 0 10px', fontSize: 15, fontWeight: 600 }}>年度分布</h3>
          <div id="chart-year" style={{ width: '100%', height: 220 }} />
        </div>
      </div>

      <div className="table-card" style={{ padding: '14px 20px', marginBottom: 16 }}>
        <h3 style={{ margin: '0 0 10px', fontSize: 15, fontWeight: 600 }}>公司分布</h3>
        <div id="chart-company" style={{ width: '100%', height: 260 }} />
      </div>

      <div className="table-card" style={{ padding: '14px 20px' }}>
        <h3 style={{ margin: '0 0 10px', fontSize: 15, fontWeight: 600 }}>题型分布</h3>
        <div id="chart-category" style={{ width: '100%', height: 260 }} />
      </div>
    </section>
  )
}
