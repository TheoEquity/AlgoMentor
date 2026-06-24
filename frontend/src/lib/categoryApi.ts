import type { ProblemCategory } from '../types/problemCategory'
import { requestJSON } from './http'

export type CategoryCreatePayload = {
  name: string
  slug: string
  sort_order: number
}

export type CategoryUpdatePayload = {
  name?: string
  slug?: string
  sort_order?: number
}

export async function listCategories(): Promise<ProblemCategory[]> {
  return requestJSON<ProblemCategory[]>('/system/problem-categories')
}

export async function createCategory(payload: CategoryCreatePayload): Promise<ProblemCategory> {
  return requestJSON<ProblemCategory>('/system/problem-categories', {
    method: 'POST',
    body: JSON.stringify(payload),
  })
}

export async function updateCategory(categoryId: number, payload: CategoryUpdatePayload): Promise<ProblemCategory> {
  return requestJSON<ProblemCategory>(`/system/problem-categories/${categoryId}`, {
    method: 'PUT',
    body: JSON.stringify(payload),
  })
}

export async function deleteCategory(categoryId: number): Promise<void> {
  await requestJSON<unknown>(`/system/problem-categories/${categoryId}`, {
    method: 'DELETE',
  })
}
