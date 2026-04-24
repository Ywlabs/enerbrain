"""PAS 인증 API."""

from fastapi import APIRouter, Depends, Request
from sqlalchemy.orm import Session

from app.common.response import ApiResponse
from app.dependencies.db import get_db
from app.dependencies.pas_auth import require_pas_jwt
from app.domain.user.schema import PasLoginIn
from app.domain.user.service import authenticate_and_issue_token, get_me

router = APIRouter(prefix="/auth")


@router.post("/login", response_model=ApiResponse)
def login(body: PasLoginIn, request: Request, db: Session = Depends(get_db)) -> ApiResponse:
    """내부 운영 사용자 로그인(JWT 발급)."""
    req_ip_addr = request.client.host if request.client else None
    user_agent_cn = request.headers.get("user-agent")
    token = authenticate_and_issue_token(
        db,
        body.user_id,
        body.usr_pwd,
        req_ip_addr=req_ip_addr,
        user_agent_cn=user_agent_cn,
    )
    return ApiResponse(success=True, message="로그인 성공", data=token.model_dump())


@router.get("/me", response_model=ApiResponse)
def me(user_ctx: dict[str, str] = Depends(require_pas_jwt), db: Session = Depends(get_db)) -> ApiResponse:
    """현재 로그인 사용자 정보를 조회한다."""
    me_out = get_me(db, user_ctx["user_no"])
    return ApiResponse(success=True, message="조회 성공", data=me_out.model_dump())
