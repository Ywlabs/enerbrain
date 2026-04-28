"""PAS 프로젝트 API 키 관리 API."""

from fastapi import APIRouter, Body, Depends, Path
from sqlalchemy.orm import Session

from app.common.response import ApiResponse
from app.dependencies.db import get_db
from app.dependencies.pas_auth import PasUserContext, require_pas_jwt
from app.domain.biz.schemas import BizApiKeyCreateIn, BizApiKeyUpdateIn
from app.domain.biz.service import (
    create_biz_api_key_for_pas,
    get_biz_api_key_detail_for_pas,
    get_biz_api_keys_for_pas,
    update_biz_api_key_for_pas,
)

router = APIRouter(prefix="/biz-api-keys")


@router.get("", response_model=ApiResponse, summary="프로젝트 API 키 목록 조회")
def get_biz_api_keys(
    user_ctx: PasUserContext = Depends(require_pas_jwt),
    db: Session = Depends(get_db),
) -> ApiResponse:
    """PAS 프로젝트 API 키 목록을 조회한다."""
    rows = get_biz_api_keys_for_pas(db, user_ctx)
    return ApiResponse(success=True, message="조회 성공", data=rows)


@router.get("/{biz_api_key_no}", response_model=ApiResponse, summary="프로젝트 API 키 상세 조회")
def get_biz_api_key_detail(
    biz_api_key_no: str = Path(description="프로젝트 API 키 번호"),
    user_ctx: PasUserContext = Depends(require_pas_jwt),
    db: Session = Depends(get_db),
) -> ApiResponse:
    """PAS 프로젝트 API 키 상세를 조회한다."""
    row = get_biz_api_key_detail_for_pas(db, user_ctx, biz_api_key_no)
    return ApiResponse(success=True, message="조회 성공", data=row)


@router.post("", response_model=ApiResponse, summary="프로젝트 API 키 발급")
def create_biz_api_key(
    body: BizApiKeyCreateIn = Body(
        examples=[
            {
                "biz_no": "BIZ_GMSC_2026",
                "key_nm": "운영키-1",
                "rate_lmt_per_min": 120,
                "issue_cn": "운영 시스템 연동",
                "use_yn": "Y",
            }
        ]
    ),
    user_ctx: PasUserContext = Depends(require_pas_jwt),
    db: Session = Depends(get_db),
) -> ApiResponse:
    """PAS 프로젝트 API 키를 등록한다."""
    created = create_biz_api_key_for_pas(db, user_ctx, body.model_dump())
    return ApiResponse(success=True, message="등록 성공", data=created)


@router.put("/{biz_api_key_no}", response_model=ApiResponse, summary="프로젝트 API 키 수정")
def update_biz_api_key(
    biz_api_key_no: str = Path(description="프로젝트 API 키 번호"),
    body: BizApiKeyUpdateIn = Body(
        examples=[
            {
                "key_nm": "운영키-1-수정",
                "key_stts_cd": "ACTIVE",
                "rate_lmt_per_min": 100,
                "use_yn": "Y",
            }
        ]
    ),
    user_ctx: PasUserContext = Depends(require_pas_jwt),
    db: Session = Depends(get_db),
) -> ApiResponse:
    """PAS 프로젝트 API 키를 수정한다."""
    payload = body.model_dump(exclude_unset=True)
    row = update_biz_api_key_for_pas(db, user_ctx, biz_api_key_no, payload)
    return ApiResponse(success=True, message="수정 성공", data=row)
