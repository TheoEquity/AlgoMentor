from __future__ import annotations

import json
from collections.abc import Iterator
from urllib import error, request

from schemas.llm_settings import LLMSettings


class LLMClientError(RuntimeError):
    pass


class LLMClient:
    def generate_json(self, settings: LLMSettings, api_key: str, model: str, prompt: str, temperature: float) -> dict:
        if not settings.enabled:
            raise LLMClientError('AI 功能当前处于停用状态，请先在系统管理中启用。')

        if not api_key:
            raise LLMClientError('系统管理中尚未配置 API Key，当前无法发起真实模型请求。')

        if settings.provider == 'Anthropic Compatible':
            return self._call_anthropic_compatible(settings, api_key, model, prompt, temperature)

        return self._call_openai_compatible(settings, api_key, model, prompt, temperature)

    def generate_text(self, settings: LLMSettings, api_key: str, model: str, prompt: str, temperature: float) -> str:
        if not settings.enabled:
            raise LLMClientError('AI 功能当前处于停用状态，请先在系统管理中启用。')
        if not api_key:
            raise LLMClientError('系统管理中尚未配置 API Key，当前无法发起真实模型请求。')
        if settings.provider == 'Anthropic Compatible':
            return self._call_anthropic_text(settings, api_key, model, prompt, temperature)
        return self._call_openai_text(settings, api_key, model, prompt, temperature)

    def stream_text(self, settings: LLMSettings, api_key: str, model: str, prompt: str, temperature: float) -> Iterator[str]:
        if not settings.enabled:
            raise LLMClientError('AI 功能当前处于停用状态，请先在系统管理中启用。')

        if not api_key:
            raise LLMClientError('系统管理中尚未配置 API Key，当前无法发起真实模型请求。')

        if settings.provider == 'Anthropic Compatible':
            yield from self._stream_anthropic_compatible(settings, api_key, model, prompt, temperature)
            return

        yield from self._stream_openai_compatible(settings, api_key, model, prompt, temperature)

    def parse_json_content(self, content: str) -> dict:
        return self._parse_json_content(content)

    def _call_openai_compatible(
        self,
        settings: LLMSettings,
        api_key: str,
        model: str,
        prompt: str,
        temperature: float,
    ) -> dict:
        url = settings.endpoint_url.rstrip('/')
        if not url.endswith('/chat/completions'):
            url = f'{url}/chat/completions'

        payload = {
            'model': model,
            'temperature': temperature,
            'response_format': {'type': 'json_object'},
            'messages': [
                {
                    'role': 'system',
                    'content': '你是算法训练平台的 AI 助手。请严格返回 JSON 对象，字段仅包含 title、summary、bullets、line_refs。',
                },
                {'role': 'user', 'content': prompt},
            ],
        }
        headers = {
            'Content-Type': 'application/json',
            'Authorization': f'Bearer {api_key}',
        }
        response = self._post_json(url, headers, payload)
        content = response['choices'][0]['message']['content']
        return self._parse_json_content(content)

    def _call_openai_text(
        self,
        settings: LLMSettings,
        api_key: str,
        model: str,
        prompt: str,
        temperature: float,
    ) -> str:
        url = settings.endpoint_url.rstrip('/')
        if not url.endswith('/chat/completions'):
            url = f'{url}/chat/completions'
        payload = {
            'model': model,
            'temperature': temperature,
            'messages': [
                {'role': 'user', 'content': prompt},
            ],
        }
        headers = {
            'Content-Type': 'application/json',
            'Authorization': f'Bearer {api_key}',
        }
        response = self._post_json(url, headers, payload)
        return response['choices'][0]['message']['content']

    def _call_anthropic_text(
        self,
        settings: LLMSettings,
        api_key: str,
        model: str,
        prompt: str,
        temperature: float,
    ) -> str:
        url = settings.endpoint_url.rstrip('/')
        if not url.endswith('/messages'):
            url = f'{url}/messages'
        payload = {
            'model': model,
            'temperature': temperature,
            'max_tokens': 8192,
            'messages': [
                {'role': 'user', 'content': prompt},
            ],
        }
        headers = {
            'Content-Type': 'application/json',
            'x-api-key': api_key,
            'anthropic-version': '2023-06-01',
        }
        response = self._post_json(url, headers, payload)
        return response['content'][0]['text']

    def _stream_openai_compatible(
        self,
        settings: LLMSettings,
        api_key: str,
        model: str,
        prompt: str,
        temperature: float,
    ) -> Iterator[str]:
        url = settings.endpoint_url.rstrip('/')
        if not url.endswith('/chat/completions'):
            url = f'{url}/chat/completions'

        payload = {
            'model': model,
            'temperature': temperature,
            'response_format': {'type': 'json_object'},
            'stream': True,
            'messages': [
                {
                    'role': 'system',
                    'content': '你是算法训练平台的 AI 助手。请严格返回 JSON 对象，字段仅包含 title、summary、bullets、line_refs。',
                },
                {'role': 'user', 'content': prompt},
            ],
        }
        headers = {
            'Content-Type': 'application/json',
            'Authorization': f'Bearer {api_key}',
            'Accept': 'text/event-stream',
        }

        req = request.Request(
            url=url,
            data=json.dumps(payload).encode('utf-8'),
            headers=headers,
            method='POST',
        )

        try:
            with request.urlopen(req, timeout=45) as resp:
                for raw_line in resp:
                    line = raw_line.decode('utf-8', errors='ignore').strip()
                    if not line or not line.startswith('data:'):
                        continue

                    data = line[5:].strip()
                    if data == '[DONE]':
                        break

                    payload = json.loads(data)
                    delta = payload.get('choices', [{}])[0].get('delta', {})
                    content = delta.get('content', '')
                    if isinstance(content, list):
                        content = ''.join(
                            str(item.get('text', '')) if isinstance(item, dict) else str(item)
                            for item in content
                        )
                    if content:
                        yield str(content)
        except error.HTTPError as exc:
            detail = exc.read().decode('utf-8', errors='ignore')
            raise LLMClientError(f'模型请求失败，HTTP {exc.code}。{detail[:400]}') from exc
        except error.URLError as exc:
            raise LLMClientError(f'模型请求失败：{exc.reason}') from exc
        except TimeoutError as exc:
            raise LLMClientError('模型请求超时，请检查 endpoint 可达性和响应时间。') from exc

    def _call_anthropic_compatible(
        self,
        settings: LLMSettings,
        api_key: str,
        model: str,
        prompt: str,
        temperature: float,
    ) -> dict:
        url = settings.endpoint_url.rstrip('/')
        if not url.endswith('/messages'):
            url = f'{url}/messages'

        payload = {
            'model': model,
            'temperature': temperature,
            'max_tokens': 1200,
            'system': '你是算法训练平台的 AI 助手。请严格返回 JSON 对象，字段仅包含 title、summary、bullets、line_refs。',
            'messages': [{'role': 'user', 'content': prompt}],
        }
        headers = {
            'Content-Type': 'application/json',
            'x-api-key': api_key,
            'anthropic-version': '2023-06-01',
        }
        response = self._post_json(url, headers, payload)
        content = ''.join(item.get('text', '') for item in response.get('content', []) if item.get('type') == 'text')
        return self._parse_json_content(content)

    def _stream_anthropic_compatible(
        self,
        settings: LLMSettings,
        api_key: str,
        model: str,
        prompt: str,
        temperature: float,
    ) -> Iterator[str]:
        url = settings.endpoint_url.rstrip('/')
        if not url.endswith('/messages'):
            url = f'{url}/messages'

        payload = {
            'model': model,
            'temperature': temperature,
            'max_tokens': 1200,
            'stream': True,
            'system': '你是算法训练平台的 AI 助手。请严格返回 JSON 对象，字段仅包含 title、summary、bullets、line_refs。',
            'messages': [{'role': 'user', 'content': prompt}],
        }
        headers = {
            'Content-Type': 'application/json',
            'x-api-key': api_key,
            'anthropic-version': '2023-06-01',
            'Accept': 'text/event-stream',
        }

        req = request.Request(
            url=url,
            data=json.dumps(payload).encode('utf-8'),
            headers=headers,
            method='POST',
        )

        try:
            with request.urlopen(req, timeout=45) as resp:
                for raw_line in resp:
                    line = raw_line.decode('utf-8', errors='ignore').strip()
                    if not line or not line.startswith('data:'):
                        continue

                    data = line[5:].strip()
                    if not data:
                        continue

                    payload = json.loads(data)
                    if payload.get('type') != 'content_block_delta':
                        continue

                    delta = payload.get('delta', {})
                    text = delta.get('text', '')
                    if text:
                        yield str(text)
        except error.HTTPError as exc:
            detail = exc.read().decode('utf-8', errors='ignore')
            raise LLMClientError(f'模型请求失败，HTTP {exc.code}。{detail[:400]}') from exc
        except error.URLError as exc:
            raise LLMClientError(f'模型请求失败：{exc.reason}') from exc
        except TimeoutError as exc:
            raise LLMClientError('模型请求超时，请检查 endpoint 可达性和响应时间。') from exc

    def _post_json(self, url: str, headers: dict[str, str], payload: dict) -> dict:
        req = request.Request(
            url=url,
            data=json.dumps(payload).encode('utf-8'),
            headers=headers,
            method='POST',
        )

        try:
            with request.urlopen(req, timeout=45) as resp:
                return json.loads(resp.read().decode('utf-8'))
        except error.HTTPError as exc:
            detail = exc.read().decode('utf-8', errors='ignore')
            raise LLMClientError(f'模型请求失败，HTTP {exc.code}。{detail[:400]}') from exc
        except error.URLError as exc:
            raise LLMClientError(f'模型请求失败：{exc.reason}') from exc
        except TimeoutError as exc:
            raise LLMClientError('模型请求超时，请检查 endpoint 可达性和响应时间。') from exc

    def _parse_json_content(self, content: str) -> dict:
        try:
            return json.loads(content)
        except json.JSONDecodeError:
            return {
                'title': 'AI 分析结果',
                'summary': content.strip() or '模型返回了空结果。',
                'bullets': [],
                'line_refs': [],
            }
