"""분석 도메인 리포지토리."""

from sqlalchemy import text
from sqlalchemy.orm import Session


def get_analysis_item_list(db: Session) -> list[dict]:
    """전체 분석항목 목록을 조회한다."""
    rows = (
        db.execute(
            text(
                """
                SELECT
                    AI.ANALYSIS_ITEM_NO,
                    AI.BIZ_NO,
                    B.SITE_NO,
                    AI.ITEM_NM,
                    AI.ALGM_CD,
                    AI.ITEM_EXPLN,
                    AI.STTS_CD,
                    AI.CRON_EXPR_CN,
                    AI.MODULE_PATH_CN,
                    AI.ENTRY_FUNC_NM,
                    AI.MODEL_FILE_NM_CN,
                    AI.PARAMS_JSON,
                    AI.TIMEOUT_SEC,
                    AI.RETRY_CNT,
                    AI.USE_YN,
                    AI.DEL_YN,
                    AI.REG_DT,
                    AI.UPD_DT
                FROM TB_ANALYSIS_ITEM AI
                INNER JOIN TB_BIZ B
                    ON B.BIZ_NO = AI.BIZ_NO
                   AND B.DEL_YN = 'N'
                WHERE AI.DEL_YN = 'N'
                ORDER BY AI.ANALYSIS_ITEM_NO
                """
            )
        )
        .mappings()
        .all()
    )
    return [dict(row) for row in rows]


def get_analysis_item_list_by_site_nos(db: Session, site_nos: list[str]) -> list[dict]:
    """권한 사이트 번호로 분석항목 목록을 조회한다."""
    if not site_nos:
        return []

    placeholders = ", ".join(f":site_no_{idx}" for idx in range(len(site_nos)))
    params = {f"site_no_{idx}": site_no for idx, site_no in enumerate(site_nos)}
    rows = (
        db.execute(
            text(
                f"""
                SELECT
                    AI.ANALYSIS_ITEM_NO,
                    AI.BIZ_NO,
                    B.SITE_NO,
                    AI.ITEM_NM,
                    AI.ALGM_CD,
                    AI.ITEM_EXPLN,
                    AI.STTS_CD,
                    AI.CRON_EXPR_CN,
                    AI.MODULE_PATH_CN,
                    AI.ENTRY_FUNC_NM,
                    AI.MODEL_FILE_NM_CN,
                    AI.PARAMS_JSON,
                    AI.TIMEOUT_SEC,
                    AI.RETRY_CNT,
                    AI.USE_YN,
                    AI.DEL_YN,
                    AI.REG_DT,
                    AI.UPD_DT
                FROM TB_ANALYSIS_ITEM AI
                INNER JOIN TB_BIZ B
                    ON B.BIZ_NO = AI.BIZ_NO
                   AND B.DEL_YN = 'N'
                WHERE AI.DEL_YN = 'N'
                  AND B.SITE_NO IN ({placeholders})
                ORDER BY AI.ANALYSIS_ITEM_NO
                """
            ),
            params,
        )
        .mappings()
        .all()
    )
    return [dict(row) for row in rows]


def get_analysis_run_list(db: Session) -> list[dict]:
    """전체 분석실행이력 목록을 조회한다."""
    rows = (
        db.execute(
            text(
                """
                SELECT
                    AR.ANALYSIS_RUN_NO,
                    AR.ANALYSIS_ITEM_NO,
                    AI.BIZ_NO,
                    B.SITE_NO,
                    AR.RUN_BGNG_DT,
                    AR.RUN_END_DT,
                    AR.RUN_STTS_CD,
                    AR.PROC_MSEC,
                    AR.INPUT_NOCS,
                    AR.OUTPUT_NOCS,
                    AR.RUN_RSLT_JSON,
                    AR.RUN_MODEL_JSON,
                    AR.ERR_CN,
                    AR.REG_DT
                FROM TB_ANALYSIS_RUN AR
                INNER JOIN TB_ANALYSIS_ITEM AI
                    ON AI.ANALYSIS_ITEM_NO = AR.ANALYSIS_ITEM_NO
                   AND AI.DEL_YN = 'N'
                INNER JOIN TB_BIZ B
                    ON B.BIZ_NO = AI.BIZ_NO
                   AND B.DEL_YN = 'N'
                ORDER BY AR.RUN_BGNG_DT DESC
                """
            )
        )
        .mappings()
        .all()
    )
    return [dict(row) for row in rows]


def get_analysis_run_list_by_site_nos(db: Session, site_nos: list[str]) -> list[dict]:
    """권한 사이트 번호로 분석실행이력 목록을 조회한다."""
    if not site_nos:
        return []

    placeholders = ", ".join(f":site_no_{idx}" for idx in range(len(site_nos)))
    params = {f"site_no_{idx}": site_no for idx, site_no in enumerate(site_nos)}
    rows = (
        db.execute(
            text(
                f"""
                SELECT
                    AR.ANALYSIS_RUN_NO,
                    AR.ANALYSIS_ITEM_NO,
                    AI.BIZ_NO,
                    B.SITE_NO,
                    AR.RUN_BGNG_DT,
                    AR.RUN_END_DT,
                    AR.RUN_STTS_CD,
                    AR.PROC_MSEC,
                    AR.INPUT_NOCS,
                    AR.OUTPUT_NOCS,
                    AR.RUN_RSLT_JSON,
                    AR.RUN_MODEL_JSON,
                    AR.ERR_CN,
                    AR.REG_DT
                FROM TB_ANALYSIS_RUN AR
                INNER JOIN TB_ANALYSIS_ITEM AI
                    ON AI.ANALYSIS_ITEM_NO = AR.ANALYSIS_ITEM_NO
                   AND AI.DEL_YN = 'N'
                INNER JOIN TB_BIZ B
                    ON B.BIZ_NO = AI.BIZ_NO
                   AND B.DEL_YN = 'N'
                WHERE B.SITE_NO IN ({placeholders})
                ORDER BY AR.RUN_BGNG_DT DESC
                """
            ),
            params,
        )
        .mappings()
        .all()
    )
    return [dict(row) for row in rows]


def search_analysis_run_list(
    db: Session,
    *,
    analysis_item_no: str | None = None,
    run_stts_cd: str | None = None,
    from_dt: object | None = None,
    to_dt: object | None = None,
    site_nos: list[str] | None = None,
) -> list[dict]:
    """필터 조건으로 분석실행이력 목록을 조회한다."""
    where_clauses: list[str] = []
    params: dict[str, object] = {}

    if analysis_item_no:
        where_clauses.append("AR.ANALYSIS_ITEM_NO = :analysis_item_no")
        params["analysis_item_no"] = analysis_item_no
    if run_stts_cd:
        where_clauses.append("AR.RUN_STTS_CD = :run_stts_cd")
        params["run_stts_cd"] = run_stts_cd
    if from_dt is not None:
        where_clauses.append("AR.RUN_BGNG_DT >= :from_dt")
        params["from_dt"] = from_dt
    if to_dt is not None:
        where_clauses.append("AR.RUN_BGNG_DT <= :to_dt")
        params["to_dt"] = to_dt
    if site_nos is not None:
        if not site_nos:
            return []
        placeholders = ", ".join(f":site_no_{idx}" for idx in range(len(site_nos)))
        where_clauses.append(f"B.SITE_NO IN ({placeholders})")
        for idx, site_no in enumerate(site_nos):
            params[f"site_no_{idx}"] = site_no

    where_sql = ""
    if where_clauses:
        where_sql = "WHERE " + " AND ".join(where_clauses)

    rows = (
        db.execute(
            text(
                f"""
                SELECT
                    AR.ANALYSIS_RUN_NO,
                    AR.ANALYSIS_ITEM_NO,
                    AI.BIZ_NO,
                    B.SITE_NO,
                    AR.RUN_BGNG_DT,
                    AR.RUN_END_DT,
                    AR.RUN_STTS_CD,
                    AR.PROC_MSEC,
                    AR.INPUT_NOCS,
                    AR.OUTPUT_NOCS,
                    AR.RUN_RSLT_JSON,
                    AR.RUN_MODEL_JSON,
                    AR.ERR_CN,
                    AR.REG_DT
                FROM TB_ANALYSIS_RUN AR
                INNER JOIN TB_ANALYSIS_ITEM AI
                    ON AI.ANALYSIS_ITEM_NO = AR.ANALYSIS_ITEM_NO
                   AND AI.DEL_YN = 'N'
                INNER JOIN TB_BIZ B
                    ON B.BIZ_NO = AI.BIZ_NO
                   AND B.DEL_YN = 'N'
                {where_sql}
                ORDER BY AR.RUN_BGNG_DT DESC
                """
            ),
            params,
        )
        .mappings()
        .all()
    )
    return [dict(row) for row in rows]


def get_analysis_item_by_no(db: Session, analysis_item_no: str) -> dict | None:
    """분석항목 번호로 단건을 조회한다."""
    return (
        db.execute(
            text(
                """
                SELECT
                    AI.ANALYSIS_ITEM_NO,
                    AI.BIZ_NO,
                    B.SITE_NO,
                    AI.ITEM_NM,
                    AI.ALGM_CD,
                    AI.ITEM_EXPLN,
                    AI.STTS_CD,
                    AI.CRON_EXPR_CN,
                    AI.MODULE_PATH_CN,
                    AI.ENTRY_FUNC_NM,
                    AI.MODEL_FILE_NM_CN,
                    AI.PARAMS_JSON,
                    AI.TIMEOUT_SEC,
                    AI.RETRY_CNT,
                    AI.USE_YN,
                    AI.DEL_YN,
                    AI.REG_DT,
                    AI.UPD_DT
                FROM TB_ANALYSIS_ITEM AI
                INNER JOIN TB_BIZ B
                    ON B.BIZ_NO = AI.BIZ_NO
                   AND B.DEL_YN = 'N'
                WHERE AI.ANALYSIS_ITEM_NO = :analysis_item_no
                  AND AI.DEL_YN = 'N'
                LIMIT 1
                """
            ),
            {"analysis_item_no": analysis_item_no},
        )
        .mappings()
        .first()
    )


def get_site_no_by_biz_no(db: Session, biz_no: str) -> str | None:
    """프로젝트 번호로 사이트 번호를 조회한다."""
    row = (
        db.execute(
            text(
                """
                SELECT SITE_NO
                FROM TB_BIZ
                WHERE BIZ_NO = :biz_no
                  AND DEL_YN = 'N'
                LIMIT 1
                """
            ),
            {"biz_no": biz_no},
        )
        .mappings()
        .first()
    )
    if row is None:
        return None
    return str(row["SITE_NO"])


def insert_analysis_item(db: Session, payload: dict) -> None:
    """분석항목을 등록한다."""
    db.execute(
        text(
            """
            INSERT INTO TB_ANALYSIS_ITEM (
                ANALYSIS_ITEM_NO,
                BIZ_NO,
                ITEM_NM,
                ALGM_CD,
                ITEM_EXPLN,
                STTS_CD,
                CRON_EXPR_CN,
                MODULE_PATH_CN,
                ENTRY_FUNC_NM,
                MODEL_FILE_NM_CN,
                PARAMS_JSON,
                TIMEOUT_SEC,
                RETRY_CNT,
                USE_YN,
                DEL_YN
            ) VALUES (
                :analysis_item_no,
                :biz_no,
                :item_nm,
                :algm_cd,
                :item_expln,
                :stts_cd,
                :cron_expr_cn,
                :module_path_cn,
                :entry_func_nm,
                :model_file_nm_cn,
                :params_json,
                :timeout_sec,
                :retry_cnt,
                :use_yn,
                'N'
            )
            """
        ),
        payload,
    )
    db.commit()


def update_analysis_item(db: Session, analysis_item_no: str, payload: dict) -> None:
    """분석항목을 수정한다."""
    sets = []
    params: dict[str, object] = {"analysis_item_no": analysis_item_no}
    for key, value in payload.items():
        sets.append(f"{key} = :{key}")
        params[key] = value

    if not sets:
        return

    sets.append("UPD_DT = CURRENT_TIMESTAMP")
    db.execute(
        text(
            f"""
            UPDATE TB_ANALYSIS_ITEM
            SET {", ".join(sets)}
            WHERE ANALYSIS_ITEM_NO = :analysis_item_no
              AND DEL_YN = 'N'
            """
        ),
        params,
    )
    db.commit()
