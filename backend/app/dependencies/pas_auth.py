"""PAS(내부 운영) JWT 인증/권한 의존성."""

from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy.orm import Session

from app.core.security import decode_access_token
from app.dependencies.db import get_db
from app.domain.user import repository

_bearer_scheme = HTTPBearer(auto_error=False)


def require_pas_jwt(
    credentials: HTTPAuthorizationCredentials | None = Depends(_bearer_scheme),
    db: Session = Depends(get_db),
) -> dict[str, str]:
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
    }


def require_super_admin(user_ctx: dict[str, str] = Depends(require_pas_jwt)) -> dict[str, str]:
    """전체 관리자 권한을 강제한다."""
    if user_ctx.get("global_role_cd") != "SUPER_ADMIN":
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="권한없음")
    return user_ctx
