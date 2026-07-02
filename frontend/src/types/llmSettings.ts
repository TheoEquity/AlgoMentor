export type LLMProvider = 'OpenAI Compatible' | 'Anthropic Compatible' | 'Custom'

export type LLMSettings = {
  id: number
  provider: LLMProvider
  endpoint_url: string
  solution_model: string
  vision_model: string
  attribution_model: string
  review_model: string
  solution_temperature: number
  attribution_temperature: number
  review_temperature: number
  api_key_configured: boolean
  api_key_masked: string
  enabled: boolean
  updated_at: string
}

export type LLMSettingsPayload = Omit<LLMSettings, 'id' | 'updated_at' | 'api_key_configured' | 'api_key_masked'> & {
  api_key?: string
  clear_api_key?: boolean
}
