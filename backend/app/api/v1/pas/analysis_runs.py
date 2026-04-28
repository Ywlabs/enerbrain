"""PAS 분석실행이력 API."""

from datetime import datetime

from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from app.common.response import ApiResponse
from app.dependencies.db import get_db
from app.dependencies.pas_auth import PasUserContext, require_pas_jwt
from app.domain.analysis.service import get_analysis_runs_with_filters_for_pas

router = APIRouter(prefix="/analysis-runs")


@router.get(
    "",
    response_model=ApiResponse,
    summary="분석실행이력 목록 조회",
    description="분석항목/실행상태/기간 필터를 적용해 분석실행이력을 조회합니다.",
)
def get_analysis_runs(
    analysis_item_no: str | None = Query(default=None, description="분석항목번호"),
    run_stts_cd: str | None = Query(default=None, description="실행상태코드(RUN/DONE/FAIL)"),
    from_dt: datetime | None = Query(default=None, description="조회 시작 일시(ISO8601)"),
    to_dt: datetime | None = Query(default=None, description="조회 종료 일시(ISO8601)"),
    user_ctx: PasUserContext = Depends(require_pas_jwt),
    db: Session = Depends(get_db),
) -> ApiResponse:
    """PAS 분석실행이력 목록을 조회한다."""
    rows = get_analysis_runs_with_filters_for_pas(
        db,
        user_ctx,
        analysis_item_no=analysis_item_no,
        run_stts_cd=run_stts_cd,
        from_dt=from_dt,
        to_dt=to_dt,
    )
    return ApiResponse(success=True, message="조회 성공", data=rows)
