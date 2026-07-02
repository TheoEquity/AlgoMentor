from __future__ import annotations

import json
import re
from collections.abc import Iterator
from json import JSONDecodeError
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

    def generate_json_with_image(
        self,
        settings: LLMSettings,
        api_key: str,
        model: str,
        prompt: str,
        temperature: float,
        image_data_url: str,
    ) -> dict:
        if not settings.enabled:
            raise LLMClientError('AI 功能当前处于停用状态，请先在系统管理中启用。')

        if not api_key:
            raise LLMClientError('系统管理中尚未配置 API Key，当前无法发起真实模型请求。')

        if settings.provider == 'Anthropic Compatible':
            return self._call_anthropic_compatible_with_image(settings, api_key, model, prompt, temperature, image_data_url)

        return self._call_openai_compatible_with_image(settings, api_key, model, prompt, temperature, image_data_url)

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

    def _call_openai_compatible_with_image(
        self,
        settings: LLMSettings,
        api_key: str,
        model: str,
        prompt: str,
        temperature: float,
        image_data_url: str,
    ) -> dict:
        url = settings.endpoint_url.rstrip('/')
        if not url.endswith('/chat/completions'):
            url = f'{url}/chat/completions'

        payload = {
            'model': model,
            'temperature': temperature,
            'messages': [
                {
                    'role': 'user',
                    'content': [
                        {'type': 'image_url', 'image_url': {'url': image_data_url}},
                        {'type': 'text', 'text': f'{prompt}\n\n请仅返回 JSON 对象，不要输出代码块。'},
                    ],
                },
            ],
        }
        headers = {
            'Content-Type': 'application/json',
            'Authorization': f'Bearer {api_key}',
        }
        response = self._post_json(url, headers, payload, timeout=120)
        content = self._extract_openai_message_text(response)
        structured = self._extract_problem_payload_from_text(content)
        if structured:
            return structured
        parsed = self._parse_json_content(content)
        if not parsed:
            snippet = content.strip().replace('\n', '\\n')[:400]
            raise LLMClientError(f'视觉模型返回空对象。原始内容片段：{snippet or "<empty>"}')
        return parsed

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
        return self._extract_openai_message_text(response)

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
        response = self._post_json(url, headers, payload, timeout=120)
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

    def _call_anthropic_compatible_with_image(
        self,
        settings: LLMSettings,
        api_key: str,
        model: str,
        prompt: str,
        temperature: float,
        image_data_url: str,
    ) -> dict:
        media_type, data = self._parse_data_url(image_data_url)
        url = settings.endpoint_url.rstrip('/')
        if not url.endswith('/messages'):
            url = f'{url}/messages'

        payload = {
            'model': model,
            'temperature': temperature,
            'max_tokens': 2000,
            'system': '你是算法训练平台的 AI 助手。请严格返回 JSON 对象。',
            'messages': [
                {
                    'role': 'user',
                    'content': [
                        {'type': 'text', 'text': prompt},
                        {
                            'type': 'image',
                            'source': {
                                'type': 'base64',
                                'media_type': media_type,
                                'data': data,
                            },
                        },
                    ],
                },
            ],
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

    def _post_json(self, url: str, headers: dict[str, str], payload: dict, timeout: int = 45) -> dict:
        req = request.Request(
            url=url,
            data=json.dumps(payload).encode('utf-8'),
            headers=headers,
            method='POST',
        )

        try:
            with request.urlopen(req, timeout=timeout) as resp:
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
            candidate = self._extract_json_object(content)
            if candidate is not None:
                return candidate
            return {
                'title': 'AI 分析结果',
                'summary': content.strip() or '模型返回了空结果。',
                'bullets': [],
                'line_refs': [],
            }

    def _extract_openai_message_text(self, response: dict) -> str:
        content = response['choices'][0]['message'].get('content', '')
        if isinstance(content, str):
            return content
        if isinstance(content, list):
            parts: list[str] = []
            for item in content:
                if isinstance(item, str):
                    parts.append(item)
                    continue
                if not isinstance(item, dict):
                    continue
                text = item.get('text')
                if isinstance(text, str) and text.strip():
                    parts.append(text)
                    continue
                if item.get('type') == 'output_text':
                    text = item.get('text', '')
                    if isinstance(text, str) and text.strip():
                        parts.append(text)
            return '\n'.join(part.strip() for part in parts if part and part.strip())
        return str(content)

    def _extract_problem_payload_from_text(self, content: str) -> dict:
        text = self._strip_outer_code_fence(content)
        if '"statement_markdown"' not in text and '"title"' not in text:
            return {}

        payload: dict[str, object] = {}

        title = self._extract_named_string_field(text, 'title')
        if title:
            payload['title'] = title

        statement = self._extract_multiline_string_field(text, 'statement_markdown', 'examples')
        if statement:
            payload['statement_markdown'] = statement

        analysis = self._extract_trailing_string_field(text, 'analysis')
        if analysis:
            payload['analysis'] = analysis

        examples_block = self._extract_array_field(text, 'examples', 'analysis')
        if examples_block:
            try:
                parsed_examples = json.loads(examples_block)
            except JSONDecodeError:
                parsed_examples = []
            if isinstance(parsed_examples, list):
                payload['examples'] = parsed_examples

        return payload

    def _strip_outer_code_fence(self, content: str) -> str:
        text = content.strip()
        if not text.startswith('```'):
            return text
        first_newline = text.find('\n')
        if first_newline == -1:
            return text
        last_fence = text.rfind('```')
        if last_fence <= first_newline:
            return text[first_newline + 1:].strip()
        return text[first_newline + 1:last_fence].strip()

    def _extract_named_string_field(self, text: str, field_name: str) -> str:
        match = re.search(rf'"{re.escape(field_name)}"\s*:\s*"((?:\\.|[^"\\])*)"', text, re.DOTALL)
        if not match:
            return ''
        return self._decode_model_string(match.group(1))

    def _extract_multiline_string_field(self, text: str, field_name: str, next_field_name: str) -> str:
        match = re.search(
            rf'"{re.escape(field_name)}"\s*:\s*"([\s\S]*?)"\s*,\s*"{re.escape(next_field_name)}"\s*:',
            text,
            re.DOTALL,
        )
        if not match:
            return ''
        return self._decode_model_string(match.group(1))

    def _extract_trailing_string_field(self, text: str, field_name: str) -> str:
        match = re.search(rf'"{re.escape(field_name)}"\s*:\s*"([\s\S]*?)"\s*$', text.rstrip().rstrip('}').rstrip(), re.DOTALL)
        if not match:
            return ''
        return self._decode_model_string(match.group(1))

    def _extract_array_field(self, text: str, field_name: str, next_field_name: str) -> str:
        match = re.search(
            rf'"{re.escape(field_name)}"\s*:\s*(\[[\s\S]*?\])\s*,\s*"{re.escape(next_field_name)}"\s*:',
            text,
            re.DOTALL,
        )
        if not match:
            return ''
        return match.group(1).strip()

    def _decode_model_string(self, value: str) -> str:
        decoded = value.replace('\\n', '\n')
        decoded = decoded.replace('\\t', '\t')
        decoded = decoded.replace('\\"', '"')
        decoded = decoded.replace('\\/', '/')
        decoded = decoded.replace('\\\\', '\\')
        return decoded.strip()

    def _extract_json_object(self, content: str) -> dict | None:
        fenced_match = self._extract_fenced_json(content)
        if fenced_match is not None:
            return fenced_match

        decoder = json.JSONDecoder()
        for index, char in enumerate(content):
            if char != '{':
                continue
            try:
                parsed, _ = decoder.raw_decode(content[index:])
            except JSONDecodeError:
                continue
            if isinstance(parsed, dict):
                return parsed
        return None

    def _extract_fenced_json(self, content: str) -> dict | None:
        marker = '```'
        start = content.find(marker)
        while start != -1:
            fence_end = content.find('\n', start)
            if fence_end == -1:
                return None
            end = content.find(marker, fence_end + 1)
            if end == -1:
                return None
            candidate = content[fence_end + 1:end].strip()
            try:
                parsed = json.loads(candidate)
            except JSONDecodeError:
                start = content.find(marker, end + len(marker))
                continue
            if isinstance(parsed, dict):
                return parsed
            start = content.find(marker, end + len(marker))
        return None

    def _parse_data_url(self, value: str) -> tuple[str, str]:
        prefix = 'data:'
        if not value.startswith(prefix) or ',' not in value:
            raise LLMClientError('上传的图片数据格式无效，请重新选择图片。')
        header, data = value.split(',', 1)
        if ';base64' not in header:
            raise LLMClientError('当前仅支持 base64 编码的图片数据。')
        media_type = header[len(prefix):].split(';', 1)[0].strip() or 'image/png'
        return media_type, data
