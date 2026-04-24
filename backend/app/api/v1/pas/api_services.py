"""PAS 서비스 API 메타 관리 API."""

from fastapi import APIRouter

from app.common.response import ApiResponse

router = APIRouter(prefix="/api-services")


@router.get("", response_model=ApiResponse)
def get_api_services() -> ApiResponse:
    """서비스 API 메타 목록 조회 샘플."""
    return ApiResponse(success=True, message="PAS 서비스 API 메타 샘플", data=[])
