"""내부 운영/관리 화면용 프로젝트 API."""

from fastapi import APIRouter

from app.common.response import ApiResponse

router = APIRouter()


@router.get("/projects", response_model=ApiResponse)
def get_projects_sample() -> ApiResponse:
    """PAS(내부 운영) 영역 프로젝트 목록 조회 샘플."""
    return ApiResponse(
        success=True,
        message="PAS 프로젝트 조회 샘플 응답",
        data={"scope": "pas", "description": "내부 운영/관리 API"},
    )
