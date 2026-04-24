"""PAS(내부 운영) JWT 인증/권한 의존성 스텁."""

from fastapi import HTTPException, status


def require_pas_jwt() -> dict[str, str]:
    """내부 운영 JWT 인증 스텁."""
    raise HTTPException(
        status_code=status.HTTP_501_NOT_IMPLEMENTED,
        detail="PAS JWT 인증은 다음 단계에서 구현됩니다.",
    )
