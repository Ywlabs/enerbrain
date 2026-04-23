"""공통 Depends — Annotated 스타일 권장 (FastAPI 최신 예시와 동일)."""

from collections.abc import Generator
from datetime import datetime
from typing import Annotated

from fastapi import Depends, Header, HTTPException, status
from sqlalchemy import text
from sqlalchemy.orm import Session

from app.core import database as db_module
from app.core.security import sha256_hex


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


def require_sas_api_key(
    db: DbSession,
    x_biz_no: Annotated[str | None, Header(alias="X-BIZ-NO")] = None,
    x_api_key: Annotated[str | None, Header(alias="X-API-KEY")] = None,
) -> dict[str, str]:
    """SAS(고객사 오픈 API) 호출용 프로젝트 API 키를 검증한다."""
    if not x_biz_no or not x_api_key:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="권한없음",
        )

    key_hash = sha256_hex(x_api_key.strip())
    candidate_hashes = [key_hash, f"sha256:{key_hash}"]

    row = (
        db.execute(
            text(
                """
                SELECT
                    BIZ_API_KEY_NO,
                    SITE_NO,
                    BIZ_NO,
                    KEY_STTS_CD,
                    EXPR_DT
                FROM TB_BIZ_API_KEY
                WHERE BIZ_NO = :biz_no
                  AND KEY_HASH_CN IN (:hash_1, :hash_2)
                  AND USE_YN = 'Y'
                  AND DEL_YN = 'N'
                LIMIT 1
                """
            ),
            {
                "biz_no": x_biz_no.strip(),
                "hash_1": candidate_hashes[0],
                "hash_2": candidate_hashes[1],
            },
        )
        .mappings()
        .first()
    )

    if row is None or row["KEY_STTS_CD"] != "ACTIVE":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="권한없음",
        )

    expr_dt = row["EXPR_DT"]
    if expr_dt is not None:
        now = datetime.now(expr_dt.tzinfo) if getattr(expr_dt, "tzinfo", None) else datetime.utcnow()
        if expr_dt <= now:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="권한없음",
            )

    return {
        "site_no": str(row["SITE_NO"]),
        "biz_no": str(row["BIZ_NO"]),
        "biz_api_key_no": str(row["BIZ_API_KEY_NO"]),
    }
