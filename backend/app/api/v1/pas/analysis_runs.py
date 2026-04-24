"""PAS 분석실행이력 API."""

from fastapi import APIRouter

from app.common.response import ApiResponse

router = APIRouter(prefix="/analysis-runs")


@router.get("", response_model=ApiResponse)
def get_analysis_runs() -> ApiResponse:
    """분석실행이력 조회 샘플."""
    return ApiResponse(success=True, message="PAS 분석실행이력 샘플", data=[])
