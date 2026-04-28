"""분석 도메인 서비스."""

from datetime import UTC, datetime
from uuid import uuid4

from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from app.dependencies.pas_auth import PasUserContext
from app.domain.analysis import repository


def _to_analysis_item_out(row: dict) -> dict:
    """DB Row를 분석항목 응답 포맷으로 변환한다."""
    return {
        "analysis_item_no": str(row["ANALYSIS_ITEM_NO"]),
        "biz_no": str(row["BIZ_NO"]),
        "site_no": str(row["SITE_NO"]),
        "item_nm": str(row["ITEM_NM"]),
        "algm_cd": str(row["ALGM_CD"]),
        "item_expln": row.get("ITEM_EXPLN"),
        "stts_cd": str(row["STTS_CD"]),
        "cron_expr_cn": row.get("CRON_EXPR_CN"),
        "module_path_cn": str(row["MODULE_PATH_CN"]),
        "entry_func_nm": str(row["ENTRY_FUNC_NM"]),
        "model_file_nm_cn": row.get("MODEL_FILE_NM_CN"),
        "params_json": row.get("PARAMS_JSON"),
        "timeout_sec": int(row["TIMEOUT_SEC"]),
        "retry_cnt": int(row["RETRY_CNT"]),
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


def _new_analysis_item_no() -> str:
    """신규 분석항목 번호를 생성한다."""
    ts = datetime.now(UTC).strftime("%Y%m%d%H%M%S")
    suffix = uuid4().hex[:4].upper()
    return f"AI_{ts}{suffix}"


def get_analysis_items_for_pas(db: Session, user_ctx: PasUserContext) -> list[dict]:
    """PAS 권한을 반영한 분석항목 목록을 조회한다."""
    if user_ctx["global_role_cd"] == "SUPER_ADMIN":
        return [_to_analysis_item_out(row) for row in repository.get_analysis_item_list(db)]
    return [_to_analysis_item_out(row) for row in repository.get_analysis_item_list_by_site_nos(db, user_ctx["site_scopes"])]


def get_analysis_runs_for_pas(db: Session, user_ctx: PasUserContext) -> list[dict]:
    """PAS 권한을 반영한 분석실행이력 목록을 조회한다."""
    if user_ctx["global_role_cd"] == "SUPER_ADMIN":
        return repository.get_analysis_run_list(db)
    return repository.get_analysis_run_list_by_site_nos(db, user_ctx["site_scopes"])


def get_analysis_runs_with_filters_for_pas(
    db: Session,
    user_ctx: PasUserContext,
    *,
    analysis_item_no: str | None = None,
    run_stts_cd: str | None = None,
    from_dt: datetime | None = None,
    to_dt: datetime | None = None,
) -> list[dict]:
    """PAS 권한과 필터 조건을 반영한 분석실행이력 목록을 조회한다."""
    if user_ctx["global_role_cd"] == "SUPER_ADMIN":
        return repository.search_analysis_run_list(
            db,
            analysis_item_no=analysis_item_no,
            run_stts_cd=run_stts_cd,
            from_dt=from_dt,
            to_dt=to_dt,
            site_nos=None,
        )
    return repository.search_analysis_run_list(
        db,
        analysis_item_no=analysis_item_no,
        run_stts_cd=run_stts_cd,
        from_dt=from_dt,
        to_dt=to_dt,
        site_nos=user_ctx["site_scopes"],
    )


def get_analysis_item_detail_for_pas(db: Session, user_ctx: PasUserContext, analysis_item_no: str) -> dict:
    """PAS 권한을 반영한 분석항목 상세를 조회한다."""
    row = repository.get_analysis_item_by_no(db, analysis_item_no)
    if row is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="조회 대상이 없습니다.")
    _assert_site_scope(user_ctx, str(row["SITE_NO"]))
    return _to_analysis_item_out(row)


def create_analysis_item_for_pas(db: Session, user_ctx: PasUserContext, payload: dict) -> str:
    """분석항목을 등록한다."""
    site_no = repository.get_site_no_by_biz_no(db, payload["biz_no"])
    if site_no is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="조회 대상이 없습니다.")
    _assert_site_scope(user_ctx, site_no)
    analysis_item_no = _new_analysis_item_no()
    repository.insert_analysis_item(
        db,
        {
            "analysis_item_no": analysis_item_no,
            "biz_no": payload["biz_no"],
            "item_nm": payload["item_nm"],
            "algm_cd": payload["algm_cd"],
            "item_expln": payload.get("item_expln"),
            "stts_cd": payload["stts_cd"],
            "cron_expr_cn": payload.get("cron_expr_cn"),
            "module_path_cn": payload["module_path_cn"],
            "entry_func_nm": payload["entry_func_nm"],
            "model_file_nm_cn": payload.get("model_file_nm_cn"),
            "params_json": payload.get("params_json"),
            "timeout_sec": payload["timeout_sec"],
            "retry_cnt": payload["retry_cnt"],
            "use_yn": payload["use_yn"],
        },
    )
    return analysis_item_no


def update_analysis_item_for_pas(
    db: Session,
    user_ctx: PasUserContext,
    analysis_item_no: str,
    payload: dict,
) -> dict:
    """분석항목을 수정한다."""
    row = repository.get_analysis_item_by_no(db, analysis_item_no)
    if row is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="조회 대상이 없습니다.")
    _assert_site_scope(user_ctx, str(row["SITE_NO"]))
    repository.update_analysis_item(db, analysis_item_no, payload)
    updated = repository.get_analysis_item_by_no(db, analysis_item_no)
    if updated is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="조회 대상이 없습니다.")
    return _to_analysis_item_out(updated)
