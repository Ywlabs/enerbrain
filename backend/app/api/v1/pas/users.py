"""PAS 사용자 관리 API."""

from fastapi import APIRouter

from app.common.response import ApiResponse

router = APIRouter(prefix="/users")


@router.get("", response_model=ApiResponse)
def get_users() -> ApiResponse:
    """내부 운영 사용자 목록 조회 샘플."""
    return ApiResponse(success=True, message="PAS 사용자 목록 샘플", data=[])
