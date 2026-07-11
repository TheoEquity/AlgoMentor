export type LLMProvider = 'OpenAI Compatible' | 'Anthropic Compatible' | 'Custom'

export type LLMSettings = {
  id: number
  provider: LLMProvider
  endpoint_url: string
  solution_model: string
  vision_model: string
  attribution_model: string
  review_model: string
  resume_model: string
  scraping_model: string
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

export type BrowserSettings = {
  id: number
  headless: boolean
  executable_path: string
  viewport_width: number
  viewport_height: number
  timeout_seconds: number
  user_data_dir: string
  proxy_url: string
  updated_at: string
}

export type BrowserSettingsPayload = Omit<BrowserSettings, 'id' | 'updated_at'>
