"""헬스 체크."""

from fastapi import APIRouter

from app.common.response import ApiResponse

router = APIRouter(tags=["헬스"])


@router.get("/health", response_model=ApiResponse)
def health() -> ApiResponse:
    """서버 생존 확인."""
    return ApiResponse(success=True, message="정상", data={"status": "ok"})
