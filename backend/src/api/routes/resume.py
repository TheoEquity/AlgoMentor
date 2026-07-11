from __future__ import annotations

import json
import os
import re
from datetime import UTC, datetime

from fastapi import APIRouter, Depends, Form, HTTPException, UploadFile
from fastapi import status as http_status
from fastapi.responses import StreamingResponse
from pypdf import PdfReader
from docx import Document as DocxDocument

from config import Settings
from repositories.resume_repository import ResumeRepository
from schemas.resume import ResumeExtractedInfo, ResumeDetail, ResumeListItem, ResumeCreate
from services.recruitment_llm import RecruitmentLLMService

router = APIRouter(prefix='/resumes', tags=['Resumes'])

DATA_DIR = os.path.join(os.path.dirname(__file__), '..', '..', 'data', 'resumes')

_ALLOWED_EXTENSIONS = {'.pdf', '.docx', '.txt', '.png', '.jpg', '.jpeg'}
EXT_TO_TYPE = {
    '.pdf': 'pdf',
    '.docx': 'docx',
    '.txt': 'txt',
    '.png': 'png',
    '.jpg': 'jpg',
    '.jpeg': 'jpg',
}

_POSITION_TYPES = ['2027秋招', '2027春招', '2026补录', '日常实习', '暑期实习']


def _get_repo() -> ResumeRepository:
    return ResumeRepository(Settings().database_url)


def _get_llm() -> RecruitmentLLMService:
    return RecruitmentLLMService(Settings().database_url)


def _get_data_dir() -> str:
    path = os.path.join(os.path.dirname(__file__), '..', '..', 'data', 'resumes')
    os.makedirs(path, exist_ok=True)
    return path


from pypdf import PdfReader
from docx import Document as DocxDocument
import pdfplumber


def _read_text_file(file_path: str, file_type: str) -> str:
    raw = ''

    if file_type == 'txt':
        with open(file_path, encoding='utf-8') as f:
            raw = f.read()

    elif file_type == 'pdf':
        try:
            with pdfplumber.open(file_path) as pdf:
                parts: list[str] = []
                for page in pdf.pages:
                    t = page.extract_text()
                    if t:
                        parts.append(t)
                raw = '\n'.join(parts)
        except Exception:
            try:
                reader = PdfReader(file_path)
                parts: list[str] = []
                for page in reader.pages:
                    t = page.extract_text()
                    if t:
                        parts.append(t)
                raw = '\n'.join(parts)
            except Exception as e:
                raise RuntimeError(f'PDF 解析失败: {e}')

    elif file_type == 'docx':
        try:
            doc = DocxDocument(file_path)
            parts: list[str] = []
            for para in doc.paragraphs:
                if para.text.strip():
                    parts.append(para.text.strip())
            raw = '\n'.join(parts)
        except Exception as e:
            raise RuntimeError(f'DOCX 解析失败: {e}')

    else:
        return f'[文件类型: {file_type}，路径: {file_path}]'

    lines = raw.split('\n')
    cleaned: list[str] = []
    for line in lines:
        stripped = line.strip()
        if stripped:
            cleaned.append(stripped)

    return '\n'.join(cleaned)


@router.get('', response_model=list[ResumeListItem])
def list_resumes(repo: ResumeRepository = Depends(_get_repo)):
    return repo.list_resumes()


@router.post('', response_model=ResumeDetail, status_code=http_status.HTTP_201_CREATED)
async def create_resume(
    file: UploadFile,
    name: str = Form(''),
    position_keywords: str = Form('[]'),
    position_type: str = Form('日常实习'),
    position_category: str = Form(''),
    repo: ResumeRepository = Depends(_get_repo),
):
    if not file.filename:
        raise HTTPException(status_code=400, detail='未选择文件')

    ext = os.path.splitext(file.filename)[1].lower()
    if ext not in _ALLOWED_EXTENSIONS:
        raise HTTPException(status_code=400, detail=f'不支持的文件格式: {ext}')

    resume_name = name or os.path.splitext(file.filename)[0]
    if position_type not in _POSITION_TYPES:
        raise HTTPException(status_code=400, detail=f'不支持的岗位性质: {position_type}')

    data_dir = _get_data_dir()
    timestamp = datetime.now(UTC).strftime('%Y%m%d%H%M%S%f')
    safe_name = re.sub(r'[^a-zA-Z0-9_\u4e00-\u9fff.-]', '_', file.filename)
    file_name = f'{timestamp}_{safe_name}'
    file_path = os.path.join(data_dir, file_name)

    content = await file.read()
    with open(file_path, 'wb') as f:
        f.write(content)

    file_type = EXT_TO_TYPE.get(ext, 'txt')

    try:
        keywords = json.loads(position_keywords)
        if not isinstance(keywords, list):
            keywords = []
    except (json.JSONDecodeError, TypeError):
        keywords = []

    payload = ResumeCreate(
        name=resume_name,
        file_type=file_type,
        position_keywords=keywords,
        position_type=position_type,
        position_category=position_category,
    )
    resume_id = repo.create_resume(payload, file_path)

    try:
        llm = _get_llm()
        text = _read_text_file(file_path, file_type)
        if text.strip():
            repo.update_extract_status(resume_id, 'parsing')
            extracted = await llm.extract_resume_info(text)
            repo.update_extracted_info(resume_id, extracted)
    except Exception as e:
        err_msg = str(e) or type(e).__name__
        repo.update_extract_status(resume_id, 'failed', err_msg)

    result = repo.get_resume(resume_id)
    if result is None:
        raise HTTPException(status_code=500, detail='创建后获取简历失败')
    return result


@router.get('/{resume_id}', response_model=ResumeDetail)
def get_resume(resume_id: int, repo: ResumeRepository = Depends(_get_repo)):
    resume = repo.get_resume(resume_id)
    if resume is None:
        raise HTTPException(status_code=404, detail='简历不存在')
    return resume


@router.put('/{resume_id}', response_model=ResumeDetail)
def update_resume(
    resume_id: int,
    name: str | None = Form(None),
    position_keywords: str | None = Form(None),
    position_type: str | None = Form(None),
    position_category: str | None = Form(None),
    repo: ResumeRepository = Depends(_get_repo),
):
    keywords: list[str] | None = None
    if position_keywords is not None:
        try:
            parsed = json.loads(position_keywords)
            keywords = parsed if isinstance(parsed, list) else []
        except (json.JSONDecodeError, TypeError):
            keywords = []

    updated = repo.update_resume(resume_id, name=name, keywords=keywords, position_type=position_type, position_category=position_category)
    if not updated:
        raise HTTPException(status_code=404, detail='简历不存在')

    result = repo.get_resume(resume_id)
    if result is None:
        raise HTTPException(status_code=500, detail='更新后获取简历失败')
    return result


@router.post('/{resume_id}/reparse', status_code=http_status.HTTP_202_ACCEPTED)
async def reparse_resume(resume_id: int, repo: ResumeRepository = Depends(_get_repo)):
    resume = repo.get_resume(resume_id)
    if resume is None:
        raise HTTPException(status_code=404, detail='简历不存在')

    repo.update_extract_status(resume_id, 'parsing')
    try:
        llm = _get_llm()
        text = _read_text_file(resume.file_path, resume.file_type)
        extracted = await llm.extract_resume_info(text)
        repo.update_extracted_info(resume_id, extracted)
        return {'ok': True, 'status': 'success'}
    except Exception as e:
        err_msg = str(e) or type(e).__name__
        repo.update_extract_status(resume_id, 'failed', err_msg)
        return {'ok': False, 'status': 'failed', 'error': err_msg}


@router.get('/{resume_id}/text')
def get_resume_text(resume_id: int, repo: ResumeRepository = Depends(_get_repo)):
    resume = repo.get_resume(resume_id)
    if resume is None:
        raise HTTPException(status_code=404, detail='简历不存在')
    return {
        'status': resume.extract_status,
        'error': resume.extract_error,
        'has_info': resume.extracted_info is not None,
    }


@router.get('/{resume_id}/file')
def get_resume_file(resume_id: int, repo: ResumeRepository = Depends(_get_repo)):
    resume = repo.get_resume(resume_id)
    if resume is None:
        raise HTTPException(status_code=404, detail='简历不存在')

    file_path = resume.file_path
    if not os.path.exists(file_path):
        raise HTTPException(status_code=404, detail='文件不存在')

    content_type_map = {
        'pdf': 'application/pdf',
        'docx': 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
        'txt': 'text/plain',
        'png': 'image/png',
        'jpg': 'image/jpeg',
    }
    content_type = content_type_map.get(resume.file_type, 'application/octet-stream')

    def iterfile():
        with open(file_path, 'rb') as f:
            yield from f

    return StreamingResponse(iterfile(), media_type=content_type)


@router.delete('/{resume_id}', status_code=http_status.HTTP_204_NO_CONTENT)
def delete_resume(resume_id: int, repo: ResumeRepository = Depends(_get_repo)):
    resume = repo.get_resume(resume_id)
    if resume:
        try:
            os.remove(str(resume.file_path))
        except OSError:
            pass

    deleted = repo.delete_resume(resume_id)
    if not deleted:
        raise HTTPException(status_code=404, detail='简历不存在')


@router.put('/{resume_id}/info', response_model=ResumeDetail)
def update_resume_info(
    resume_id: int,
    payload: ResumeExtractedInfo,
    repo: ResumeRepository = Depends(_get_repo),
):
    updated = repo.update_resume_info(resume_id, payload)
    if not updated:
        raise HTTPException(status_code=404, detail='简历不存在')
    result = repo.get_resume(resume_id)
    if result is None:
        raise HTTPException(status_code=500, detail='更新后获取简历失败')
    return result
