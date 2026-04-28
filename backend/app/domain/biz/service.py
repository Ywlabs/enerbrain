"""프로젝트(BIZ) 도메인 서비스."""

from datetime import UTC, datetime
import hashlib
import secrets
from uuid import uuid4

from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from app.dependencies.pas_auth import PasUserContext
from app.domain.biz import repository


def _to_biz_out(row: dict) -> dict:
    """DB Row를 프로젝트 응답 포맷으로 변환한다."""
    return {
        "biz_no": str(row["BIZ_NO"]),
        "site_no": str(row["SITE_NO"]),
        "biz_nm": str(row["BIZ_NM"]),
        "chrgr_nm": row.get("CHRGR_NM"),
        "chrgr_email_addr": row.get("CHRGR_EMAIL_ADDR"),
        "biz_cn": row.get("BIZ_CN"),
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


def _new_biz_no() -> str:
    """신규 프로젝트 번호를 생성한다."""
    ts = datetime.now(UTC).strftime("%Y%m%d%H%M%S")
    suffix = uuid4().hex[:4].upper()
    return f"BIZ_{ts}{suffix}"


def _new_biz_api_key_no() -> str:
    """신규 프로젝트 API 키 번호를 생성한다."""
    ts = datetime.now(UTC).strftime("%Y%m%d%H%M%S")
    suffix = uuid4().hex[:4].upper()
    return f"BAK_{ts}{suffix}"


def _new_raw_api_key() -> str:
    """신규 API 키 평문을 생성한다."""
    return f"ebk_{secrets.token_urlsafe(24)}"


def _to_biz_api_key_out(row: dict) -> dict:
    """DB Row를 프로젝트 API 키 응답 포맷으로 변환한다."""
    return {
        "biz_api_key_no": str(row["BIZ_API_KEY_NO"]),
        "biz_no": str(row["BIZ_NO"]),
        "site_no": str(row["SITE_NO"]),
        "key_nm": str(row["KEY_NM"]),
        "key_prefix_cn": str(row["KEY_PREFIX_CN"]),
        "key_stts_cd": str(row["KEY_STTS_CD"]),
        "expr_dt": row.get("EXPR_DT"),
        "rate_lmt_per_min": row.get("RATE_LMT_PER_MIN"),
        "issue_cn": row.get("ISSUE_CN"),
        "last_use_dt": row.get("LAST_USE_DT"),
        "revoke_dt": row.get("REVOKE_DT"),
        "use_yn": str(row["USE_YN"]),
        "del_yn": str(row["DEL_YN"]),
    }


def get_biz_list_for_pas(db: Session, user_ctx: PasUserContext) -> list[dict]:
    """PAS 권한을 반영한 프로젝트 목록을 조회한다."""
    if user_ctx["global_role_cd"] == "SUPER_ADMIN":
        return [_to_biz_out(row) for row in repository.get_biz_list(db)]
    return [_to_biz_out(row) for row in repository.get_biz_list_by_site_nos(db, user_ctx["site_scopes"])]


def get_biz_api_keys_for_pas(db: Session, user_ctx: PasUserContext) -> list[dict]:
    """PAS 권한을 반영한 프로젝트 API 키 목록을 조회한다."""
    if user_ctx["global_role_cd"] == "SUPER_ADMIN":
        return [_to_biz_api_key_out(row) for row in repository.get_biz_api_key_list(db)]
    return [_to_biz_api_key_out(row) for row in repository.get_biz_api_key_list_by_site_nos(db, user_ctx["site_scopes"])]


def get_biz_detail_for_pas(db: Session, user_ctx: PasUserContext, biz_no: str) -> dict:
    """PAS 권한을 반영한 프로젝트 상세를 조회한다."""
    row = repository.get_biz_by_no(db, biz_no)
    if row is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="조회 대상이 없습니다.")
    _assert_site_scope(user_ctx, str(row["SITE_NO"]))
    return _to_biz_out(row)


def create_biz_for_pas(db: Session, user_ctx: PasUserContext, payload: dict) -> str:
    """프로젝트를 등록한다."""
    _assert_site_scope(user_ctx, payload["site_no"])
    biz_no = _new_biz_no()
    repository.insert_biz(
        db,
        {
            "biz_no": biz_no,
            "site_no": payload["site_no"],
            "biz_nm": payload["biz_nm"],
            "chrgr_nm": payload.get("chrgr_nm"),
            "chrgr_email_addr": payload.get("chrgr_email_addr"),
            "biz_cn": payload.get("biz_cn"),
            "stts_cd": payload["stts_cd"],
            "use_yn": payload["use_yn"],
        },
    )
    return biz_no


def update_biz_for_pas(db: Session, user_ctx: PasUserContext, biz_no: str, payload: dict) -> dict:
    """프로젝트를 수정한다."""
    row = repository.get_biz_by_no(db, biz_no)
    if row is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="조회 대상이 없습니다.")
    _assert_site_scope(user_ctx, str(row["SITE_NO"]))
    repository.update_biz(db, biz_no, payload)
    updated = repository.get_biz_by_no(db, biz_no)
    if updated is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="조회 대상이 없습니다.")
    return _to_biz_out(updated)


def get_biz_api_key_detail_for_pas(db: Session, user_ctx: PasUserContext, biz_api_key_no: str) -> dict:
    """PAS 권한을 반영한 프로젝트 API 키 상세를 조회한다."""
    row = repository.get_biz_api_key_by_no(db, biz_api_key_no)
    if row is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="조회 대상이 없습니다.")
    _assert_site_scope(user_ctx, str(row["SITE_NO"]))
    return _to_biz_api_key_out(row)


def create_biz_api_key_for_pas(db: Session, user_ctx: PasUserContext, payload: dict) -> dict:
    """프로젝트 API 키를 등록한다."""
    biz_row = repository.get_biz_by_no(db, payload["biz_no"])
    if biz_row is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="조회 대상이 없습니다.")
    _assert_site_scope(user_ctx, str(biz_row["SITE_NO"]))

    raw_key = _new_raw_api_key()
    key_hash_cn = hashlib.sha256(raw_key.encode("utf-8")).hexdigest()
    key_prefix_cn = raw_key[:12]
    biz_api_key_no = _new_biz_api_key_no()
    repository.insert_biz_api_key(
        db,
        {
            "biz_api_key_no": biz_api_key_no,
            "biz_no": payload["biz_no"],
            "key_nm": payload["key_nm"],
            "key_hash_cn": key_hash_cn,
            "key_prefix_cn": key_prefix_cn,
            "key_stts_cd": "ACTIVE",
            "expr_dt": payload.get("expr_dt"),
            "rate_lmt_per_min": payload.get("rate_lmt_per_min"),
            "issue_cn": payload.get("issue_cn"),
            "revoke_dt": None,
            "use_yn": payload["use_yn"],
        },
    )
    return {
        "biz_api_key_no": biz_api_key_no,
        "key_prefix_cn": key_prefix_cn,
        "api_key": raw_key,
    }


def update_biz_api_key_for_pas(
    db: Session,
    user_ctx: PasUserContext,
    biz_api_key_no: str,
    payload: dict,
) -> dict:
    """프로젝트 API 키를 수정한다."""
    row = repository.get_biz_api_key_by_no(db, biz_api_key_no)
    if row is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="조회 대상이 없습니다.")
    _assert_site_scope(user_ctx, str(row["SITE_NO"]))
    repository.update_biz_api_key(db, biz_api_key_no, payload)
    updated = repository.get_biz_api_key_by_no(db, biz_api_key_no)
    if updated is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="조회 대상이 없습니다.")
    return _to_biz_api_key_out(updated)
