"""DB 세션 의존성."""

from collections.abc import Generator

from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from app.core import database as db_module


def get_db() -> Generator[Session, None, None]:
    """요청 단위 DB 세션을 생성한다."""
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
