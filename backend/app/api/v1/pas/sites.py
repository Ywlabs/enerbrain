"""PAS 사이트 관리 API."""

from fastapi import APIRouter

from app.common.response import ApiResponse

router = APIRouter(prefix="/sites")


@router.get("", response_model=ApiResponse)
def get_sites() -> ApiResponse:
    """사이트 목록 조회 샘플."""
    return ApiResponse(success=True, message="PAS 사이트 목록 샘플", data=[])
