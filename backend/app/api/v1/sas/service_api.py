"""SAS 서비스 API 메타 조회 API."""

from fastapi import APIRouter

from app.common.response import ApiResponse

router = APIRouter(prefix="/service-api")


@router.get("", response_model=ApiResponse)
def get_service_api_info() -> ApiResponse:
    """고객사 제공 서비스 API 메타 조회 샘플."""
    return ApiResponse(success=True, message="SAS 서비스 API 메타 샘플", data={})
