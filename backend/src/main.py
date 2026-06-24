from contextlib import asynccontextmanager

from fastapi import FastAPI, HTTPException, Request
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse

from api.router import api_router
from config import Settings
from core.db import initialize_database


settings = Settings()


@asynccontextmanager
async def lifespan(_: FastAPI):
    initialize_database(settings.database_url)
    yield


app = FastAPI(title=settings.app_name, lifespan=lifespan)
app.include_router(api_router, prefix=settings.api_prefix)


@app.exception_handler(HTTPException)
async def handle_http_exception(_: Request, exc: HTTPException) -> JSONResponse:
    detail = exc.detail if isinstance(exc.detail, str) else '请求处理失败。'
    return JSONResponse(
        status_code=exc.status_code,
        content={
            'detail': detail,
            'error_code': f'http_{exc.status_code}',
        },
    )


@app.exception_handler(RequestValidationError)
async def handle_validation_exception(_: Request, exc: RequestValidationError) -> JSONResponse:
    return JSONResponse(
        status_code=422,
        content={
            'detail': exc.errors(),
            'error_code': 'validation_error',
        },
    )


@app.exception_handler(Exception)
async def handle_unexpected_exception(_: Request, exc: Exception) -> JSONResponse:
    return JSONResponse(
        status_code=500,
        content={
            'detail': str(exc) or '服务器内部异常。',
            'error_code': 'internal_error',
        },
    )


@app.get('/healthz', tags=['system'])
async def healthz() -> dict[str, str]:
    return {'status': 'ok'}
