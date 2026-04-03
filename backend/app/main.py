"""FastAPI 진입점 — lifespan 사용 (on_event 대체 권장)."""

from contextlib import asynccontextmanager
from typing import AsyncIterator

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api.v1.router import api_router as api_v1_router
from app.core.config import settings


@asynccontextmanager
async def lifespan(_app: FastAPI) -> AsyncIterator[None]:
    """앱 시작/종료 훅 — DB 풀 예열, MQTT 등은 여기에 추가."""
    yield


def create_app() -> FastAPI:
    """앱 팩토리 — 테스트에서 오버라이드하기 쉬움."""
    application = FastAPI(
        title=settings.app_name,
        lifespan=lifespan,
    )
    application.add_middleware(
        CORSMiddleware,
        allow_origins=settings.cors_origins,
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )
    application.include_router(api_v1_router, prefix=settings.api_v1_prefix)
    return application


app = create_app()
