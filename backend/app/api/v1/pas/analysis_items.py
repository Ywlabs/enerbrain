"""PAS 분석항목 관리 API."""

from fastapi import APIRouter, Body, Depends, Path
from sqlalchemy.orm import Session

from app.common.response import ApiResponse
from app.dependencies.db import get_db
from app.dependencies.pas_auth import PasUserContext, require_pas_jwt
from app.domain.analysis.schema import AnalysisItemCreateIn, AnalysisItemUpdateIn
from app.domain.analysis.service import (
    create_analysis_item_for_pas,
    get_analysis_item_detail_for_pas,
    get_analysis_items_for_pas,
    update_analysis_item_for_pas,
)

router = APIRouter(prefix="/analysis-items")


@router.get("", response_model=ApiResponse, summary="분석항목 목록 조회")
def get_analysis_items(
    user_ctx: PasUserContext = Depends(require_pas_jwt),
    db: Session = Depends(get_db),
) -> ApiResponse:
    """PAS 분석항목 목록을 조회한다."""
    rows = get_analysis_items_for_pas(db, user_ctx)
    return ApiResponse(success=True, message="조회 성공", data=rows)


@router.get("/{analysis_item_no}", response_model=ApiResponse, summary="분석항목 상세 조회")
def get_analysis_item_detail(
    analysis_item_no: str = Path(description="분석항목 번호"),
    user_ctx: PasUserContext = Depends(require_pas_jwt),
    db: Session = Depends(get_db),
) -> ApiResponse:
    """PAS 분석항목 상세를 조회한다."""
    row = get_analysis_item_detail_for_pas(db, user_ctx, analysis_item_no)
    return ApiResponse(success=True, message="조회 성공", data=row)


@router.post("", response_model=ApiResponse, summary="분석항목 등록")
def create_analysis_item(
    body: AnalysisItemCreateIn = Body(
        examples=[
            {
                "biz_no": "BIZ_GMSC_2026",
                "item_nm": "전력 사용량 예측",
                "algm_cd": "XGBOOST",
                "module_path_cn": "app/modules/predict_power.py",
                "entry_func_nm": "run",
                "timeout_sec": 600,
                "retry_cnt": 1,
                "use_yn": "Y",
            }
        ]
    ),
    user_ctx: PasUserContext = Depends(require_pas_jwt),
    db: Session = Depends(get_db),
) -> ApiResponse:
    """PAS 분석항목을 등록한다."""
    analysis_item_no = create_analysis_item_for_pas(db, user_ctx, body.model_dump())
    return ApiResponse(success=True, message="등록 성공", data={"analysis_item_no": analysis_item_no})


@router.put("/{analysis_item_no}", response_model=ApiResponse, summary="분석항목 수정")
def update_analysis_item(
    analysis_item_no: str = Path(description="분석항목 번호"),
    body: AnalysisItemUpdateIn = Body(examples=[{"item_nm": "전력 사용량 예측-수정", "stts_cd": "ACTIVE"}]),
    user_ctx: PasUserContext = Depends(require_pas_jwt),
    db: Session = Depends(get_db),
) -> ApiResponse:
    """PAS 분석항목을 수정한다."""
    payload = body.model_dump(exclude_unset=True)
    row = update_analysis_item_for_pas(db, user_ctx, analysis_item_no, payload)
    return ApiResponse(success=True, message="수정 성공", data=row)
