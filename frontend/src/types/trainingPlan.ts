export interface TrainingPlanItem {
  id: number
  problem_id: number
  title: string
  company: string
  difficulty: string
  category_slug: string
  tags: string[]
  sort_order: number
  status: '未开始' | '已通过' | '待复盘'
}

export interface TrainingPlanDetail {
  id: number
  name: string
  plan_type: string
  duration_days: number
  total_problems: number
  completed_count: number
  correct_count: number
  created_at: string
  updated_at: string
  items: TrainingPlanItem[]
}

export interface TrainingPlanListItem {
  id: number
  name: string
  plan_type: string
  duration_days: number
  total_problems: number
  completed_count: number
  correct_count: number
  created_at: string
  updated_at: string
}

export interface PlanPreviewProblem {
  problem_id: number
  title: string
  company: string
  difficulty: string
  category_slug: string
  tags: string[]
}

export interface PlanPreview {
  name: string
  plan_type: string
  duration_days: number
  problems: PlanPreviewProblem[]
}
