"""PAS 프로젝트 API 키 관리 API."""

from fastapi import APIRouter

from app.common.response import ApiResponse

router = APIRouter(prefix="/biz-api-keys")


@router.get("", response_model=ApiResponse)
def get_biz_api_keys() -> ApiResponse:
    """프로젝트 API 키 목록 조회 샘플."""
    return ApiResponse(success=True, message="PAS 프로젝트 API 키 목록 샘플", data=[])
