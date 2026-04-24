"""SAS 분석결과 조회 API."""

from fastapi import APIRouter

from app.common.response import ApiResponse

router = APIRouter(prefix="/result")


@router.get("", response_model=ApiResponse)
def get_result() -> ApiResponse:
    """고객사 분석결과 조회 샘플."""
    return ApiResponse(success=True, message="SAS 분석결과 샘플", data={})
