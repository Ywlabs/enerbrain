"""PAS(내부 운영) JWT 인증/권한 의존성."""

from typing import TypedDict

from fastapi import Depends, HTTPException, Path, Query, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy.orm import Session

from app.core.security import decode_access_token
from app.dependencies.db import get_db
from app.domain.user import repository

_bearer_scheme = HTTPBearer(auto_error=False)


class PasUserContext(TypedDict):
    """PAS 인증 후 사용하는 사용자 컨텍스트."""

    user_no: str
    user_id: str
    global_role_cd: str
    site_scopes: list[str]


def _extract_site_scopes(payload: dict, db: Session, user_no: str) -> list[str]:
    """토큰 또는 DB에서 사이트 권한 범위를 추출한다."""
    raw_scopes = payload.get("site_scopes")
    if isinstance(raw_scopes, list):
        return [str(site_no).strip() for site_no in raw_scopes if str(site_no).strip()]
    return repository.get_user_site_scopes(db, user_no)


def require_pas_jwt(
    credentials: HTTPAuthorizationCredentials | None = Depends(_bearer_scheme),
    db: Session = Depends(get_db),
) -> PasUserContext:
    """PAS 요청의 Bearer 토큰을 검증한다."""
    if credentials is None or credentials.scheme.lower() != "bearer":
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="인증이 필요합니다.")

    try:
        payload = decode_access_token(credentials.credentials)
    except Exception:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="인증이 필요합니다.") from None

    user_no = str(payload.get("sub", "")).strip()
    if not user_no:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="인증이 필요합니다.")

    user = repository.get_user_by_no(db, user_no)
    if user is None or user["USE_YN"] != "Y" or user["DEL_YN"] != "N" or user["STTS_CD"] != "ACTIVE":
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="권한없음")

    return {
        "user_no": user_no,
        "user_id": str(user["USER_ID"]),
        "global_role_cd": str(user["GLOBAL_ROLE_CD"]),
        "site_scopes": _extract_site_scopes(payload, db, user_no),
    }


def require_super_admin(user_ctx: PasUserContext = Depends(require_pas_jwt)) -> PasUserContext:
    """전체 관리자 권한을 강제한다."""
    if user_ctx.get("global_role_cd") != "SUPER_ADMIN":
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="권한없음")
    return user_ctx


def require_site_scope(
    site_no: str = Path(description="권한을 확인할 사이트 번호"),
    user_ctx: PasUserContext = Depends(require_pas_jwt),
) -> PasUserContext:
    """경로의 SITE_NO에 대한 사이트 범위 권한을 검증한다."""
    if user_ctx["global_role_cd"] == "SUPER_ADMIN":
        return user_ctx
    if site_no in user_ctx["site_scopes"]:
        return user_ctx
    raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="권한없음")


def require_site_scope_query(
    site_no: str = Query(description="권한을 확인할 사이트 번호"),
    user_ctx: PasUserContext = Depends(require_pas_jwt),
) -> PasUserContext:
    """쿼리의 SITE_NO에 대한 사이트 범위 권한을 검증한다."""
    if user_ctx["global_role_cd"] == "SUPER_ADMIN":
        return user_ctx
    if site_no in user_ctx["site_scopes"]:
        return user_ctx
    raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="권한없음")
