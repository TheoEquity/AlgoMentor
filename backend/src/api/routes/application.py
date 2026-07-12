from __future__ import annotations

import asyncio

from fastapi import APIRouter, Depends, HTTPException, Query
from fastapi import status as http_status
from playwright.async_api import async_playwright

from config import Settings
from repositories.application_repository import ApplicationRepository
from repositories.resume_repository import ResumeRepository
from schemas.application import (
    ExtractFromUrlRequest,
    JobPositionCreate,
    JobPositionDetail,
    JobPositionListItem,
    JobPositionUpdate,
    MatchAnalysisRequest,
    MatchAnalysisResponse,
)
from services.recruitment_llm import RecruitmentLLMService

router = APIRouter(prefix='/job-positions', tags=['Job Positions'])


def _get_repo() -> ApplicationRepository:
    return ApplicationRepository(Settings().database_url)


def _resume_repo() -> ResumeRepository:
    return ResumeRepository(Settings().database_url)


def _llm() -> RecruitmentLLMService:
    return RecruitmentLLMService(Settings().database_url)


@router.get('', response_model=list[JobPositionListItem])
def list_positions(
    resume_id: int | None = Query(None),
    repo: ApplicationRepository = Depends(_get_repo),
):
    return repo.list_positions(resume_id=resume_id)


@router.get('/{position_id}', response_model=JobPositionDetail)
def get_position(position_id: int, repo: ApplicationRepository = Depends(_get_repo)):
    pos = repo.get_position(position_id)
    if pos is None:
        raise HTTPException(status_code=404, detail='岗位不存在')
    return pos


@router.post('', response_model=JobPositionListItem, status_code=http_status.HTTP_201_CREATED)
def create_position(
    payload: JobPositionCreate,
    repo: ApplicationRepository = Depends(_get_repo),
):
    pos_id = repo.create_position(payload)
    result = repo.get_position(pos_id)
    if result is None:
        raise HTTPException(status_code=500, detail='创建失败')
    return JobPositionListItem(
        id=result.id,
        resume_id=result.resume_id,
        company_name=result.company_name,
        department=result.department,
        title=result.title,
        location=result.location,
        position_type=result.position_type,
        position_category=result.position_category,
        industry_category=result.industry_category,
        deadline=result.deadline,
        status=result.status,
        status_date=result.status_date,
        notes=result.notes,
        apply_channel=result.apply_channel,
        match_score=result.match_score,
        job_url=result.job_url,
        created_at=result.created_at,
        updated_at=result.updated_at,
    )


@router.put('/{position_id}', response_model=JobPositionDetail)
def update_position(
    position_id: int,
    payload: JobPositionUpdate,
    repo: ApplicationRepository = Depends(_get_repo),
):
    updated = repo.update_position(position_id, payload)
    if not updated:
        raise HTTPException(status_code=404, detail='岗位不存在')
    result = repo.get_position(position_id)
    if result is None:
        raise HTTPException(status_code=500, detail='更新后获取岗位失败')
    return result


@router.delete('/{position_id}', status_code=http_status.HTTP_204_NO_CONTENT)
def delete_position(position_id: int, repo: ApplicationRepository = Depends(_get_repo)):
    deleted = repo.delete_position(position_id)
    if not deleted:
        raise HTTPException(status_code=404, detail='岗位不存在')


@router.post('/extract-from-url')
async def extract_from_url(
    payload: ExtractFromUrlRequest,
    llm: RecruitmentLLMService = Depends(_llm),
):
    if not payload.url:
        raise HTTPException(status_code=400, detail='URL 不能为空')

    page_text = ''
    try:
        async with async_playwright() as p:
            browser = await p.chromium.launch(headless=True)
            context = await browser.new_context(viewport={'width': 1280, 'height': 720})
            page = await context.new_page()
            await page.goto(payload.url, wait_until='networkidle', timeout=30000)
            await asyncio.sleep(3)
            page_text = await page.evaluate('''() => {
                const root = document.querySelector('main, [role="main"], article, .job-detail, .position-detail, .jd-detail') || document.body;
                const clone = root.cloneNode(true);
                clone.querySelectorAll('script, style, noscript, nav, footer, iframe, svg').forEach(el => el.remove());
                clone.querySelectorAll('h1,h2,h3,h4,h5,h6').forEach(el => {
                    const level = parseInt(el.tagName[1]);
                    const prefix = "#".repeat(level);
                    el.textContent = "\\n" + prefix + " " + el.textContent.trim() + "\\n";
                });
                clone.querySelectorAll('p,div,li,section,article').forEach(el => {
                    el.insertAdjacentText('afterend', '\\n');
                });
                clone.querySelectorAll('br').forEach(el => {
                    el.insertAdjacentText('afterend', '\\n');
                });
                return clone.innerText.replace(/\\n{3,}/g, "\\n\\n").trim().substring(0, 8000);
            }''')
            await browser.close()
    except Exception as e:
        raise HTTPException(status_code=500, detail=f'页面加载失败: {e}')

    if not page_text.strip():
        raise HTTPException(status_code=500, detail='页面内容为空，可能被反爬拦截')

    model = llm._get_model('scraping_model')
    prompt = f'''你是一个专业的招聘信息提取助手。请从下方招聘页面文本中提取关键信息，返回纯JSON对象（不含markdown标记）。

提取规则：
1. job_description: 岗位职责、工作内容、职位描述。通常包含"负责""参与""完成"等描述性动词。
2. job_requirements: 任职要求、岗位要求、必备条件。通常包含学历、经验年限、技能等硬性要求。
3. job_preferences: 加分项、优先条件。通常包含"优先""加分""熟悉xxx者优先"等表述。
4. title: 岗位名称，如"后端开发工程师""产品经理"。
5. department: 所属部门/团队名称。
6. location: 工作城市/地点。
7. deadline: 投递/申请截止日期。

重要：只提取页面中明确出现的信息，不要编造。没有对应内容的字段用空字符串""。

页面文本：
{page_text}

返回格式：
{{"job_description":"...","job_requirements":"...","job_preferences":"...","title":"...","department":"...","location":"...","deadline":"..."}}'''

    result = await llm._chat(prompt, 4096, model)
    import re
    import json
    cleaned = re.sub(r'```json\s*', '', result)
    cleaned = re.sub(r'```\s*', '', cleaned)
    try:
        return json.loads(cleaned.strip())
    except json.JSONDecodeError:
        raise HTTPException(status_code=500, detail=f'LLM 解析失败: {result[:200]}')


@router.post('/{position_id}/match-analysis', response_model=MatchAnalysisResponse)
async def match_analysis(
    position_id: int,
    payload: MatchAnalysisRequest,
    repo: ApplicationRepository = Depends(_get_repo),
    resume_repo: ResumeRepository = Depends(_resume_repo),
    llm: RecruitmentLLMService = Depends(_llm),
):
    pos = repo.get_position(position_id)
    if pos is None:
        raise HTTPException(status_code=404, detail='岗位不存在')

    resume = resume_repo.get_resume(payload.resume_id)
    if resume is None:
        raise HTTPException(status_code=404, detail='简历不存在')
    if resume.extracted_info is None:
        raise HTTPException(status_code=400, detail='简历尚未解析，无法匹配')

    model = llm._get_model('resume_model')
    prompt = f'''你是招聘岗位匹配分析专家。请严格按以下规则，基于简历和岗位信息逐项打分并计算加权总分。

简历信息：
{resume.extracted_info}

岗位信息：
公司: {pos.company_name}
部门: {pos.department}
岗位: {pos.title}
地点: {pos.location}
岗位描述: {pos.job_description}
岗位要求: {pos.job_requirements}
优先项: {pos.job_preferences}

评分规则（每项 0-100，comment 必须引用原文证据）：

1. 学历匹配（权重 15%）：简历学历是否满足岗位要求
2. 技能匹配（权重 35%）：简历技能与岗位要求技能的覆盖度
3. 经验匹配（权重 25%）：简历项目/实习经验与岗位要求的契合度
4. 地点匹配（权重 10%）：简历期望城市与岗位地点的匹配度
5. 加分项（权重 15%）：简历是否覆盖岗位优先项内容

综合匹配度 = round(学历*0.15 + 技能*0.35 + 经验*0.25 + 地点*0.10 + 加分*0.15)

请返回纯JSON对象（不要markdown标记）：
{{
    "match_score": <按公式计算的整数>,
    "match_detail": "{{\\"学历匹配\\":{{\\"score\\":<0-100>,\\"comment\\":\\"理由...\\"}},\\"技能匹配\\":{{\\"score\\":<0-100>,\\"comment\\":\\"理由...\\"}},\\"经验匹配\\":{{\\"score\\":<0-100>,\\"comment\\":\\"理由...\\"}},\\"地点匹配\\":{{\\"score\\":<0-100>,\\"comment\\":\\"理由...\\"}},\\"加分项\\":{{\\"score\\":<0-100>,\\"comment\\":\\"理由...\\"}}}}",
    "match_advice": "200字以内的投递建议，包含：是否推荐、核心优势、关键不足、准备建议"
}}'''

    result = await llm._chat(prompt, 4096, model)
    import re
    import json
    cleaned = re.sub(r'```json\s*', '', result)
    cleaned = re.sub(r'```\s*', '', cleaned)
    try:
        data = json.loads(cleaned.strip())
    except json.JSONDecodeError:
        raise HTTPException(status_code=500, detail=f'LLM 解析失败: {result[:200]}')

    update_payload = JobPositionUpdate(
        match_score=int(data.get('match_score', 0)),
        match_detail=str(data.get('match_detail', '')),
        match_advice=str(data.get('match_advice', '')),
    )
    repo.update_position(position_id, update_payload)

    return MatchAnalysisResponse(
        match_score=update_payload.match_score,
        match_detail=update_payload.match_detail,
        match_advice=update_payload.match_advice,
    )


@router.get('/{position_id}/match-result', response_model=MatchAnalysisResponse)
def get_match_result(position_id: int, repo: ApplicationRepository = Depends(_get_repo)):
    pos = repo.get_position(position_id)
    if pos is None:
        raise HTTPException(status_code=404, detail='岗位不存在')
    return MatchAnalysisResponse(
        match_score=pos.match_score,
        match_detail=pos.match_detail,
        match_advice=pos.match_advice,
    )
