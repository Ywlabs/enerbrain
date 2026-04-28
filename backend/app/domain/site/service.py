"""사이트 도메인 서비스."""

from datetime import UTC, datetime
from uuid import uuid4

from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from app.dependencies.pas_auth import PasUserContext
from app.domain.site import repository


def _to_site_out(row: dict) -> dict:
    """DB Row를 사이트 응답 포맷으로 변환한다."""
    return {
        "site_no": str(row["SITE_NO"]),
        "site_nm": str(row["SITE_NM"]),
        "chrgr_nm": row.get("CHRGR_NM"),
        "chrgr_email_addr": row.get("CHRGR_EMAIL_ADDR"),
        "chrgr_telno": row.get("CHRGR_TELNO"),
        "site_expln": row.get("SITE_EXPLN"),
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


def _new_site_no() -> str:
    """신규 사이트 번호를 생성한다."""
    ts = datetime.now(UTC).strftime("%Y%m%d%H%M%S")
    suffix = uuid4().hex[:4].upper()
    return f"SITE_{ts}{suffix}"


def get_sites_for_pas(db: Session, user_ctx: PasUserContext) -> list[dict]:
    """PAS 권한을 반영한 사이트 목록을 조회한다."""
    if user_ctx["global_role_cd"] == "SUPER_ADMIN":
        return [_to_site_out(row) for row in repository.get_site_list(db)]
    return [_to_site_out(row) for row in repository.get_site_list_by_site_nos(db, user_ctx["site_scopes"])]


def get_site_detail_for_pas(db: Session, user_ctx: PasUserContext, site_no: str) -> dict:
    """PAS 권한을 반영한 사이트 상세를 조회한다."""
    row = repository.get_site_by_no(db, site_no)
    if row is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="조회 대상이 없습니다.")
    _assert_site_scope(user_ctx, str(row["SITE_NO"]))
    return _to_site_out(row)


def create_site_for_pas(db: Session, payload: dict) -> str:
    """사이트를 등록한다(SUPER_ADMIN 전용)."""
    site_no = _new_site_no()
    repository.insert_site(
        db,
        {
            "site_no": site_no,
            "site_nm": payload["site_nm"],
            "chrgr_nm": payload.get("chrgr_nm"),
            "chrgr_email_addr": payload.get("chrgr_email_addr"),
            "chrgr_telno": payload.get("chrgr_telno"),
            "site_expln": payload.get("site_expln"),
            "stts_cd": payload["stts_cd"],
            "use_yn": payload["use_yn"],
        },
    )
    return site_no


def update_site_for_pas(db: Session, user_ctx: PasUserContext, site_no: str, payload: dict) -> dict:
    """사이트를 수정한다."""
    row = repository.get_site_by_no(db, site_no)
    if row is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="조회 대상이 없습니다.")
    _assert_site_scope(user_ctx, str(row["SITE_NO"]))
    repository.update_site(db, site_no, payload)
    updated = repository.get_site_by_no(db, site_no)
    if updated is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="조회 대상이 없습니다.")
    return _to_site_out(updated)
