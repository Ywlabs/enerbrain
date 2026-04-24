"""SAS(고객사 호출) API 키 인증 의존성."""

from datetime import datetime

from fastapi import Depends, Header, HTTPException, status
from sqlalchemy import text
from sqlalchemy.orm import Session

from app.core.security import sha256_hex
from app.dependencies.db import get_db


def require_sas_api_key(
    x_biz_no: str | None = Header(default=None, alias="X-BIZ-NO"),
    x_api_key: str | None = Header(default=None, alias="X-API-KEY"),
    db: Session = Depends(get_db),
) -> dict[str, str]:
    """프로젝트 키를 검증하고 통과 시 식별정보를 반환한다."""
    if not x_biz_no or not x_api_key:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="권한없음")

    key_hash = sha256_hex(x_api_key.strip())
    row = (
        db.execute(
            text(
                """
                SELECT BIZ_API_KEY_NO, BIZ_NO, KEY_STTS_CD, EXPR_DT
                FROM TB_BIZ_API_KEY
                WHERE BIZ_NO = :biz_no
                  AND KEY_HASH_CN IN (:hash_raw, :hash_sha)
                  AND USE_YN = 'Y'
                  AND DEL_YN = 'N'
                LIMIT 1
                """
            ),
            {
                "biz_no": x_biz_no.strip(),
                "hash_raw": key_hash,
                "hash_sha": f"sha256:{key_hash}",
            },
        )
        .mappings()
        .first()
    )

    if row is None or row["KEY_STTS_CD"] != "ACTIVE":
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="권한없음")

    expr_dt = row["EXPR_DT"]
    if expr_dt is not None:
        now = datetime.now(expr_dt.tzinfo) if getattr(expr_dt, "tzinfo", None) else datetime.utcnow()
        if expr_dt <= now:
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="권한없음")

    return {"biz_no": str(row["BIZ_NO"]), "biz_api_key_no": str(row["BIZ_API_KEY_NO"])}
