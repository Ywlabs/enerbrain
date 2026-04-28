"""PAS 프로젝트 관리 API."""

from fastapi import APIRouter, Body, Depends, Path
from sqlalchemy.orm import Session

from app.common.response import ApiResponse
from app.dependencies.db import get_db
from app.dependencies.pas_auth import PasUserContext, require_pas_jwt
from app.domain.biz.schemas import BizCreateIn, BizUpdateIn
from app.domain.biz.service import create_biz_for_pas, get_biz_detail_for_pas, get_biz_list_for_pas, update_biz_for_pas

router = APIRouter(prefix="/biz")


@router.get("", response_model=ApiResponse, summary="프로젝트 목록 조회")
def get_biz_list(
    user_ctx: PasUserContext = Depends(require_pas_jwt),
    db: Session = Depends(get_db),
) -> ApiResponse:
    """PAS 프로젝트 목록을 조회한다."""
    rows = get_biz_list_for_pas(db, user_ctx)
    return ApiResponse(success=True, message="조회 성공", data=rows)


@router.get("/{biz_no}", response_model=ApiResponse, summary="프로젝트 상세 조회")
def get_biz_detail(
    biz_no: str = Path(description="프로젝트 번호"),
    user_ctx: PasUserContext = Depends(require_pas_jwt),
    db: Session = Depends(get_db),
) -> ApiResponse:
    """PAS 프로젝트 상세를 조회한다."""
    row = get_biz_detail_for_pas(db, user_ctx, biz_no)
    return ApiResponse(success=True, message="조회 성공", data=row)


@router.post("", response_model=ApiResponse, summary="프로젝트 등록")
def create_biz(
    body: BizCreateIn = Body(
        examples=[
            {
                "site_no": "SITE_CABINLAB01",
                "biz_nm": "신규 예측 프로젝트",
                "chrgr_nm": "황정우",
                "chrgr_email_addr": "owner@example.com",
                "biz_cn": "예측 모델 개발",
                "stts_cd": "ACTIVE",
                "use_yn": "Y",
            }
        ]
    ),
    user_ctx: PasUserContext = Depends(require_pas_jwt),
    db: Session = Depends(get_db),
) -> ApiResponse:
    """PAS 프로젝트를 등록한다."""
    biz_no = create_biz_for_pas(db, user_ctx, body.model_dump())
    return ApiResponse(success=True, message="등록 성공", data={"biz_no": biz_no})


@router.put("/{biz_no}", response_model=ApiResponse, summary="프로젝트 수정")
def update_biz(
    biz_no: str = Path(description="프로젝트 번호"),
    body: BizUpdateIn = Body(examples=[{"biz_nm": "신규 예측 프로젝트-수정", "use_yn": "Y"}]),
    user_ctx: PasUserContext = Depends(require_pas_jwt),
    db: Session = Depends(get_db),
) -> ApiResponse:
    """PAS 프로젝트를 수정한다."""
    payload = body.model_dump(exclude_unset=True)
    row = update_biz_for_pas(db, user_ctx, biz_no, payload)
    return ApiResponse(success=True, message="수정 성공", data=row)
