"""공통 Depends — Annotated 스타일 권장 (FastAPI 최신 예시와 동일)."""

from collections.abc import Generator
from typing import Annotated

from fastapi import Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.core import database as db_module


def get_db() -> Generator[Session, None, None]:
    """요청 단위 DB 세션. DATABASE_URL 미설정 시 503."""
    if db_module.SessionLocal is None:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="데이터베이스가 구성되지 않았습니다.",
        )
    db = db_module.SessionLocal()
    try:
        yield db
    finally:
        db.close()


# 라우트 시그니처: async def foo(db: DbSession): ...
DbSession = Annotated[Session, Depends(get_db)]
