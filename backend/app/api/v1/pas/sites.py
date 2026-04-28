"""PAS 사이트 관리 API."""

from fastapi import APIRouter, Body, Depends, Path
from sqlalchemy.orm import Session

from app.common.response import ApiResponse
from app.dependencies.db import get_db
from app.dependencies.pas_auth import PasUserContext, require_pas_jwt, require_super_admin
from app.domain.site.schemas import SiteCreateIn, SiteUpdateIn
from app.domain.site.service import create_site_for_pas, get_site_detail_for_pas, get_sites_for_pas, update_site_for_pas

router = APIRouter(prefix="/sites")


@router.get("", response_model=ApiResponse, summary="사이트 목록 조회")
def get_sites(
    user_ctx: PasUserContext = Depends(require_pas_jwt),
    db: Session = Depends(get_db),
) -> ApiResponse:
    """PAS 사이트 목록을 조회한다."""
    rows = get_sites_for_pas(db, user_ctx)
    return ApiResponse(success=True, message="조회 성공", data=rows)


@router.get("/{site_no}", response_model=ApiResponse, summary="사이트 상세 조회")
def get_site_detail(
    site_no: str = Path(description="사이트 번호"),
    user_ctx: PasUserContext = Depends(require_pas_jwt),
    db: Session = Depends(get_db),
) -> ApiResponse:
    """PAS 사이트 상세를 조회한다."""
    row = get_site_detail_for_pas(db, user_ctx, site_no)
    return ApiResponse(success=True, message="조회 성공", data=row)


@router.post("", response_model=ApiResponse, dependencies=[Depends(require_super_admin)], summary="사이트 등록")
def create_site(
    body: SiteCreateIn = Body(
        examples=[
            {
                "site_nm": "테스트고객사",
                "chrgr_nm": "홍길동",
                "chrgr_email_addr": "test@example.com",
                "chrgr_telno": "01012345678",
                "site_expln": "신규 고객사 테스트",
                "stts_cd": "ACTIVE",
                "use_yn": "Y",
            }
        ]
    ),
    db: Session = Depends(get_db),
) -> ApiResponse:
    """PAS 사이트를 등록한다."""
    site_no = create_site_for_pas(db, body.model_dump())
    return ApiResponse(success=True, message="등록 성공", data={"site_no": site_no})


@router.put("/{site_no}", response_model=ApiResponse, summary="사이트 수정")
def update_site(
    site_no: str = Path(description="사이트 번호"),
    body: SiteUpdateIn = Body(examples=[{"site_nm": "테스트고객사-수정", "use_yn": "Y"}]),
    user_ctx: PasUserContext = Depends(require_pas_jwt),
    db: Session = Depends(get_db),
) -> ApiResponse:
    """PAS 사이트를 수정한다."""
    payload = body.model_dump(exclude_unset=True)
    row = update_site_for_pas(db, user_ctx, site_no, payload)
    return ApiResponse(success=True, message="수정 성공", data=row)
