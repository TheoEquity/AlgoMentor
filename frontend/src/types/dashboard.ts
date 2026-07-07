export type DistributionItem = {
  name: string
  count: number
}

export type CategoryDistributionItem = {
  slug: string
  name: string
  count: number
}

export type DashboardData = {
  company_distribution: DistributionItem[]
  difficulty_distribution: DistributionItem[]
  category_distribution: CategoryDistributionItem[]
  wrong_distribution: DistributionItem[]
  source_distribution: DistributionItem[]
  year_distribution: DistributionItem[]
}
