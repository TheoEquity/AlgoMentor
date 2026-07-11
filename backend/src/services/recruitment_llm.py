from __future__ import annotations

import json
import re

import httpx

from repositories.llm_settings_repository import LLMSettingsRepository


class RecruitmentLLMService:
    def __init__(self, database_url: str) -> None:
        self.database_url = database_url
        self._model_cache: dict[str, str] = {}

    def _get_llm_repo(self) -> LLMSettingsRepository:
        return LLMSettingsRepository(self.database_url)

    def _load_settings(self) -> dict:
        repo = self._get_llm_repo()
        settings_raw = repo.get_settings()
        if hasattr(settings_raw, 'model_dump'):
            return settings_raw.model_dump()
        elif isinstance(settings_raw, dict):
            return settings_raw
        return {}

    async def _chat(self, prompt: str, max_tokens: int = 2048, model: str | None = None) -> str:
        if not self._model_cache:
            self._model_cache = self._load_settings()
        settings = self._model_cache

        if not settings.get('enabled'):
            raise RuntimeError('LLM 未配置或未启用')

        base_url = (settings.get('endpoint_url') or '').rstrip('/')
        repo = self._get_llm_repo()
        api_key = repo.get_api_key()
        if not api_key:
            raise RuntimeError('LLM API Key 未配置')
        if model is None:
            model = settings.get('solution_model') or 'gpt-4.1-mini'

        async with httpx.AsyncClient(timeout=180) as client:
            response = await client.post(
                f'{base_url}/chat/completions',
                headers={
                    'Content-Type': 'application/json',
                    'Authorization': f'Bearer {api_key}',
                },
                json={
                    'model': model,
                    'messages': [
                        {'role': 'system', 'content': 'You are a helpful assistant. Always respond with valid JSON only.'},
                        {'role': 'user', 'content': prompt},
                    ],
                    'max_tokens': max_tokens,
                    'temperature': 0.1,
                },
            )
            response.raise_for_status()
            data = response.json()
            return data['choices'][0]['message']['content']

    async def extract_resume_info(self, text: str) -> dict:
        model = self._get_model('resume_model')
        prompt = '''你是一个简历信息提取引擎。分析下方简历文本并提取结构化信息。只返回纯 JSON（不要 markdown 标记，不要额外文字）。

规则：
1. 字段如果原文没有提及，用空字符串""或空数组[]
2. 日期格式统一为 YYYY.MM 或 YYYY（如 "2023.09"）
3. GPA 保留原格式（如 "3.9/4.0"）
4. 技能、课程、荣誉、证书逐条提取，不要合并
5. 学历：判断"本科/硕士/博士/大专/高中"
6. 语言水平的 level 用：母语/流利/良好/基础
7. 城市从"期望城市"、"意向城市"、"所在地"等字段提取
8. 自我评价从"自我评价"、"个人评价"、"个人总结"等字段提取，没有则为空字符串
9. 不要在 JSON 中编造任何信息，忠实提取原文

简历文本：
''' + text[:6000] + '''

返回格式：
{"name":"","email":"","phone":"","target_city":"","education":[{"school":"","degree":"","major":"","start_date":"","end_date":"","gpa":"","courses":[],"honors":[]}],"skills":[],"experiences":[{"company":"","title":"","start_date":"","end_date":"","description":""}],"projects":[{"name":"","role":"","tech_stack":[],"start_date":"","end_date":"","description":""}],"certifications":[],"languages":[],"self_evaluation":""}'''

        result = await self._chat(prompt, 8192, model)
        cleaned = re.sub(r'```json\s*', '', result)
        cleaned = re.sub(r'```\s*', '', cleaned)
        return json.loads(cleaned.strip())

    async def classify_position_type(self, title: str, description: str) -> str:
        model = self._get_model('scraping_model')
        prompt = f'''请根据以下岗位信息判断岗位性质，只能返回以下之一（不要返回其他内容）：
"2027秋招", "2027春招", "2026补录", "日常实习", "暑期实习", "社招"

判断规则：
- 如果标题或描述明确提到"2027届"、"秋招"、"秋季招聘" → "2027秋招"
- 如果提到"2027届"、"春招"、"春季招聘" → "2027春招"
- 如果提到"2026届"、"补录"、"补招" → "2026补录"
- 如果提到"实习"但没有年份限定 → "日常实习"
- 如果提到"暑期实习" → "暑期实习"
- 如果提到"社会招聘"、"社招" → "社招"
- 默认根据上下文推断

岗位名称: {title}
岗位描述: {description[:1000]}'''

        result = await self._chat(prompt, 100, model)
        return result.strip().strip('"')

    async def match_position(
        self,
        resume_info: dict,
        position_title: str,
        position_description: str,
        position_location: str | None,
        degree_requirement: str | None,
        position_category: str = '',
    ) -> dict:
        model = self._get_model('scraping_model')
        info = resume_info if isinstance(resume_info, dict) else resume_info.model_dump()
        latest_edu = (info.get('education') or [None])[0] or {}
        resume_text = f'''
姓名: {info.get('name', '')}
学校: {latest_edu.get('school', '')}
学历: {latest_edu.get('degree', '')}
专业: {latest_edu.get('major', '')}
毕业时间: {latest_edu.get('end_date', '')}
技能: {', '.join(info.get('skills', []))}
经历: {json.dumps(info.get('experiences', []), ensure_ascii=False)}
项目: {json.dumps(info.get('projects', []), ensure_ascii=False)}
'''.strip()

        category_hint = f'\n岗位类别偏好: {position_category}' if position_category else ''

        prompt = f'''你是一个校招岗位匹配专家。请根据以下简历信息和岗位描述，评估匹配度（0-100分），并给出简洁的匹配理由。

简历信息：
{resume_text}{category_hint}

岗位信息：
岗位名称: {position_title}
工作地点: {position_location or '未知'}
学历要求: {degree_requirement or '未明确'}
岗位描述: {position_description[:1500]}

评估维度：学校层次匹配、专业相关度、技能匹配度、实习/项目经验相关性、地点偏好、岗位类别匹配

返回纯 JSON（不要包含 markdown 代码块标记）：
{{
  "score": 数字(0-100),
  "reason": "匹配理由（50字以内）"
}}'''

        result = await self._chat(prompt, 500, model)
        cleaned = re.sub(r'```json\s*', '', result)
        cleaned = re.sub(r'```\s*', '', cleaned)
        return json.loads(cleaned.strip())

    def _get_model(self, key: str) -> str | None:
        if key not in self._model_cache:
            settings = self._load_settings()
            self._model_cache = settings
        return self._model_cache.get(key) or 'gpt-4.1-mini'
