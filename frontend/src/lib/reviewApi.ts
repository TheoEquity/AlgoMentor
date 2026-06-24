import type { ReviewListQuery, ReviewListResponse } from '../types/review'
import { requestJSON } from './http'

export async function listReviews(query: ReviewListQuery = {}): Promise<ReviewListResponse> {
  const params = new URLSearchParams()

  if (query.wrong_only) {
    params.set('wrong_only', 'true')
  }
  if (query.company && query.company !== 'all') {
    params.set('company', query.company)
  }
  if (query.tag && query.tag !== 'all') {
    params.set('tag', query.tag)
  }
  if (query.error_type && query.error_type !== 'all') {
    params.set('error_type', query.error_type)
  }

  const search = params.toString()
  return requestJSON<ReviewListResponse>(`/review${search ? `?${search}` : ''}`)
}
