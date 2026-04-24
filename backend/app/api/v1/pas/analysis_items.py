"""PAS 분석항목 관리 API."""

from fastapi import APIRouter

from app.common.response import ApiResponse

router = APIRouter(prefix="/analysis-items")


@router.get("", response_model=ApiResponse)
def get_analysis_items() -> ApiResponse:
    """분석항목 목록 조회 샘플."""
    return ApiResponse(success=True, message="PAS 분석항목 목록 샘플", data=[])
