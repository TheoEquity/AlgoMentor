import type { BrowserSettings, BrowserSettingsPayload, LLMSettings, LLMSettingsPayload } from '../types/llmSettings'
import { requestJSON } from './http'

export async function getLLMSettings(): Promise<LLMSettings> {
  return requestJSON<LLMSettings>('/system/llm-settings')
}

export async function updateLLMSettings(payload: LLMSettingsPayload): Promise<LLMSettings> {
  return requestJSON<LLMSettings>('/system/llm-settings', {
    method: 'PUT',
    body: JSON.stringify(payload),
  })
}

export async function getBrowserSettings(): Promise<BrowserSettings> {
  return requestJSON<BrowserSettings>('/system/browser-settings')
}

export async function updateBrowserSettings(payload: BrowserSettingsPayload): Promise<BrowserSettings> {
  return requestJSON<BrowserSettings>('/system/browser-settings', {
    method: 'PUT',
    body: JSON.stringify(payload),
  })
}
