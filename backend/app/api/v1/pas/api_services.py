"""PAS 서비스 API 메타 관리 API."""

from fastapi import APIRouter, Body, Depends, Path
from sqlalchemy.orm import Session

from app.common.response import ApiResponse
from app.dependencies.db import get_db
from app.dependencies.pas_auth import PasUserContext, require_pas_jwt
from app.domain.service_api.schema import ServiceApiCreateIn, ServiceApiUpdateIn
from app.domain.service_api.service import (
    create_api_service_for_pas,
    get_api_service_detail_for_pas,
    get_api_services_for_pas,
    update_api_service_for_pas,
)

router = APIRouter(prefix="/api-services")


@router.get("", response_model=ApiResponse, summary="서비스 API 메타 목록 조회")
def get_api_services(
    user_ctx: PasUserContext = Depends(require_pas_jwt),
    db: Session = Depends(get_db),
) -> ApiResponse:
    """PAS 서비스 API 메타 목록을 조회한다."""
    rows = get_api_services_for_pas(db, user_ctx)
    return ApiResponse(success=True, message="조회 성공", data=rows)


@router.get("/{api_svc_no}", response_model=ApiResponse, summary="서비스 API 메타 상세 조회")
def get_api_service_detail(
    api_svc_no: str = Path(description="서비스 API 번호"),
    user_ctx: PasUserContext = Depends(require_pas_jwt),
    db: Session = Depends(get_db),
) -> ApiResponse:
    """PAS 서비스 API 메타 상세를 조회한다."""
    row = get_api_service_detail_for_pas(db, user_ctx, api_svc_no)
    return ApiResponse(success=True, message="조회 성공", data=row)


@router.post("", response_model=ApiResponse, summary="서비스 API 메타 등록")
def create_api_service(
    body: ServiceApiCreateIn = Body(
        examples=[
            {
                "biz_no": "BIZ_GMSC_2026",
                "api_nm": "실시간 전력 조회",
                "api_path_cn": "/api/v1/sas/power/realtime",
                "req_mthd_cd": "GET",
                "api_expln": "현재 시점 전력량을 조회합니다.",
                "use_yn": "Y",
            }
        ]
    ),
    user_ctx: PasUserContext = Depends(require_pas_jwt),
    db: Session = Depends(get_db),
) -> ApiResponse:
    """PAS 서비스 API 메타를 등록한다."""
    api_svc_no = create_api_service_for_pas(db, user_ctx, body.model_dump())
    return ApiResponse(success=True, message="등록 성공", data={"api_svc_no": api_svc_no})


@router.put("/{api_svc_no}", response_model=ApiResponse, summary="서비스 API 메타 수정")
def update_api_service(
    api_svc_no: str = Path(description="서비스 API 번호"),
    body: ServiceApiUpdateIn = Body(
        examples=[
            {
                "api_nm": "실시간 전력 조회(수정)",
                "api_expln": "현시점 전력량/온도를 함께 조회합니다.",
                "stts_cd": "ACTIVE",
                "use_yn": "Y",
            }
        ]
    ),
    user_ctx: PasUserContext = Depends(require_pas_jwt),
    db: Session = Depends(get_db),
) -> ApiResponse:
    """PAS 서비스 API 메타를 수정한다."""
    payload = body.model_dump(exclude_unset=True)
    row = update_api_service_for_pas(db, user_ctx, api_svc_no, payload)
    return ApiResponse(success=True, message="수정 성공", data=row)
