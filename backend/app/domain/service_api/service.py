"""서비스 API 도메인 서비스."""

from datetime import UTC, datetime
from uuid import uuid4

from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from app.dependencies.pas_auth import PasUserContext
from app.domain.biz import repository as biz_repository
from app.domain.service_api import repository


def _to_api_service_out(row: dict) -> dict:
    """DB Row를 서비스 API 응답 포맷으로 변환한다."""
    return {
        "api_svc_no": str(row["API_SVC_NO"]),
        "biz_no": str(row["BIZ_NO"]),
        "site_no": str(row["SITE_NO"]),
        "api_nm": str(row["API_NM"]),
        "api_path_cn": str(row["API_PATH_CN"]),
        "req_mthd_cd": str(row["REQ_MTHD_CD"]),
        "api_expln": row.get("API_EXPLN"),
        "test_req_json": row.get("TEST_REQ_JSON"),
        "test_res_json": row.get("TEST_RES_JSON"),
        "stts_cd": str(row["STTS_CD"]),
        "use_yn": str(row["USE_YN"]),
        "del_yn": str(row["DEL_YN"]),
    }


def _assert_site_scope(user_ctx: PasUserContext, site_no: str) -> None:
    """사이트 범위 권한을 검증한다."""
    if user_ctx["global_role_cd"] == "SUPER_ADMIN":
        return
    if site_no in user_ctx["site_scopes"]:
        return
    raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="권한없음")


def _new_api_svc_no() -> str:
    """신규 서비스 API 번호를 생성한다."""
    ts = datetime.now(UTC).strftime("%Y%m%d%H%M%S")
    suffix = uuid4().hex[:4].upper()
    return f"ASV_{ts}{suffix}"


def get_api_services_for_pas(db: Session, user_ctx: PasUserContext) -> list[dict]:
    """PAS 권한을 반영한 서비스 API 메타 목록을 조회한다."""
    if user_ctx["global_role_cd"] == "SUPER_ADMIN":
        return [_to_api_service_out(row) for row in repository.get_api_service_list(db)]
    return [_to_api_service_out(row) for row in repository.get_api_service_list_by_site_nos(db, user_ctx["site_scopes"])]


def get_api_service_detail_for_pas(db: Session, user_ctx: PasUserContext, api_svc_no: str) -> dict:
    """PAS 권한을 반영한 서비스 API 메타 상세를 조회한다."""
    row = repository.get_api_service_by_no(db, api_svc_no)
    if row is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="조회 대상이 없습니다.")
    _assert_site_scope(user_ctx, str(row["SITE_NO"]))
    return _to_api_service_out(row)


def create_api_service_for_pas(db: Session, user_ctx: PasUserContext, payload: dict) -> str:
    """서비스 API 메타를 등록한다."""
    biz_row = biz_repository.get_biz_by_no(db, payload["biz_no"])
    if biz_row is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="조회 대상이 없습니다.")
    _assert_site_scope(user_ctx, str(biz_row["SITE_NO"]))

    api_svc_no = _new_api_svc_no()
    repository.insert_api_service(
        db,
        {
            "api_svc_no": api_svc_no,
            "biz_no": payload["biz_no"],
            "api_nm": payload["api_nm"],
            "api_path_cn": payload["api_path_cn"],
            "req_mthd_cd": payload["req_mthd_cd"],
            "api_expln": payload.get("api_expln"),
            "test_req_json": payload.get("test_req_json"),
            "test_res_json": payload.get("test_res_json"),
            "stts_cd": payload["stts_cd"],
            "use_yn": payload["use_yn"],
        },
    )
    return api_svc_no


def update_api_service_for_pas(
    db: Session,
    user_ctx: PasUserContext,
    api_svc_no: str,
    payload: dict,
) -> dict:
    """서비스 API 메타를 수정한다."""
    row = repository.get_api_service_by_no(db, api_svc_no)
    if row is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="조회 대상이 없습니다.")
    _assert_site_scope(user_ctx, str(row["SITE_NO"]))
    repository.update_api_service(db, api_svc_no, payload)
    updated = repository.get_api_service_by_no(db, api_svc_no)
    if updated is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="조회 대상이 없습니다.")
    return _to_api_service_out(updated)
