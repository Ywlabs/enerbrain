"""PAS 인증 API."""

from fastapi import APIRouter

from app.common.response import ApiResponse

router = APIRouter(prefix="/auth")


@router.post("/login", response_model=ApiResponse)
def login() -> ApiResponse:
    """내부 운영 사용자 로그인(JWT 발급 예정)."""
    return ApiResponse(success=True, message="PAS 로그인 샘플", data={"token": "TODO"})
