"""고객사 오픈용 예측 조회 API."""

from fastapi import APIRouter

from app.common.response import ApiResponse

router = APIRouter()


@router.get("/forecast", response_model=ApiResponse)
def get_forecast_sample() -> ApiResponse:
    """SAS(고객사 호출) 예측 결과 조회 샘플."""
    return ApiResponse(
        success=True,
        message="SAS 예측 조회 샘플 응답",
        data={"scope": "sas", "description": "고객사 오픈 API"},
    )
