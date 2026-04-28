"""프로젝트(BIZ) 도메인 리포지토리."""

from sqlalchemy import text
from sqlalchemy.orm import Session


def get_biz_list(db: Session) -> list[dict]:
    """전체 프로젝트 목록을 조회한다."""
    rows = (
        db.execute(
            text(
                """
                SELECT
                    BIZ_NO,
                    SITE_NO,
                    BIZ_NM,
                    CHRGR_NM,
                    CHRGR_EMAIL_ADDR,
                    BIZ_CN,
                    STTS_CD,
                    USE_YN,
                    DEL_YN,
                    REG_DT,
                    UPD_DT
                FROM TB_BIZ
                WHERE DEL_YN = 'N'
                ORDER BY BIZ_NO
                """
            )
        )
        .mappings()
        .all()
    )
    return [dict(row) for row in rows]


def get_biz_list_by_site_nos(db: Session, site_nos: list[str]) -> list[dict]:
    """권한 사이트 번호로 프로젝트 목록을 조회한다."""
    if not site_nos:
        return []

    placeholders = ", ".join(f":site_no_{idx}" for idx in range(len(site_nos)))
    params = {f"site_no_{idx}": site_no for idx, site_no in enumerate(site_nos)}
    rows = (
        db.execute(
            text(
                f"""
                SELECT
                    BIZ_NO,
                    SITE_NO,
                    BIZ_NM,
                    CHRGR_NM,
                    CHRGR_EMAIL_ADDR,
                    BIZ_CN,
                    STTS_CD,
                    USE_YN,
                    DEL_YN,
                    REG_DT,
                    UPD_DT
                FROM TB_BIZ
                WHERE DEL_YN = 'N'
                  AND SITE_NO IN ({placeholders})
                ORDER BY BIZ_NO
                """
            ),
            params,
        )
        .mappings()
        .all()
    )
    return [dict(row) for row in rows]


def get_biz_api_key_list(db: Session) -> list[dict]:
    """전체 프로젝트 API 키 목록을 조회한다."""
    rows = (
        db.execute(
            text(
                """
                SELECT
                    BK.BIZ_API_KEY_NO,
                    BK.BIZ_NO,
                    B.SITE_NO,
                    BK.KEY_NM,
                    BK.KEY_PREFIX_CN,
                    BK.KEY_STTS_CD,
                    BK.EXPR_DT,
                    BK.RATE_LMT_PER_MIN,
                    BK.ISSUE_CN,
                    BK.LAST_USE_DT,
                    BK.REVOKE_DT,
                    BK.USE_YN,
                    BK.DEL_YN,
                    BK.REG_DT,
                    BK.UPD_DT
                FROM TB_BIZ_API_KEY BK
                INNER JOIN TB_BIZ B
                    ON B.BIZ_NO = BK.BIZ_NO
                   AND B.DEL_YN = 'N'
                WHERE BK.DEL_YN = 'N'
                ORDER BY BK.BIZ_API_KEY_NO
                """
            )
        )
        .mappings()
        .all()
    )
    return [dict(row) for row in rows]


def get_biz_api_key_list_by_site_nos(db: Session, site_nos: list[str]) -> list[dict]:
    """권한 사이트 번호로 프로젝트 API 키 목록을 조회한다."""
    if not site_nos:
        return []

    placeholders = ", ".join(f":site_no_{idx}" for idx in range(len(site_nos)))
    params = {f"site_no_{idx}": site_no for idx, site_no in enumerate(site_nos)}
    rows = (
        db.execute(
            text(
                f"""
                SELECT
                    BK.BIZ_API_KEY_NO,
                    BK.BIZ_NO,
                    B.SITE_NO,
                    BK.KEY_NM,
                    BK.KEY_PREFIX_CN,
                    BK.KEY_STTS_CD,
                    BK.EXPR_DT,
                    BK.RATE_LMT_PER_MIN,
                    BK.ISSUE_CN,
                    BK.LAST_USE_DT,
                    BK.REVOKE_DT,
                    BK.USE_YN,
                    BK.DEL_YN,
                    BK.REG_DT,
                    BK.UPD_DT
                FROM TB_BIZ_API_KEY BK
                INNER JOIN TB_BIZ B
                    ON B.BIZ_NO = BK.BIZ_NO
                   AND B.DEL_YN = 'N'
                WHERE BK.DEL_YN = 'N'
                  AND B.SITE_NO IN ({placeholders})
                ORDER BY BK.BIZ_API_KEY_NO
                """
            ),
            params,
        )
        .mappings()
        .all()
    )
    return [dict(row) for row in rows]


def get_biz_by_no(db: Session, biz_no: str) -> dict | None:
    """프로젝트 번호로 단건을 조회한다."""
    return (
        db.execute(
            text(
                """
                SELECT
                    BIZ_NO,
                    SITE_NO,
                    BIZ_NM,
                    CHRGR_NM,
                    CHRGR_EMAIL_ADDR,
                    BIZ_CN,
                    STTS_CD,
                    USE_YN,
                    DEL_YN,
                    REG_DT,
                    UPD_DT
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


def insert_biz(db: Session, payload: dict) -> None:
    """프로젝트를 등록한다."""
    db.execute(
        text(
            """
            INSERT INTO TB_BIZ (
                BIZ_NO,
                SITE_NO,
                BIZ_NM,
                CHRGR_NM,
                CHRGR_EMAIL_ADDR,
                BIZ_CN,
                STTS_CD,
                USE_YN,
                DEL_YN
            ) VALUES (
                :biz_no,
                :site_no,
                :biz_nm,
                :chrgr_nm,
                :chrgr_email_addr,
                :biz_cn,
                :stts_cd,
                :use_yn,
                'N'
            )
            """
        ),
        payload,
    )
    db.commit()


def update_biz(db: Session, biz_no: str, payload: dict) -> None:
    """프로젝트를 수정한다."""
    sets = []
    params: dict[str, object] = {"biz_no": biz_no}
    for key, value in payload.items():
        sets.append(f"{key} = :{key}")
        params[key] = value

    if not sets:
        return

    sets.append("UPD_DT = CURRENT_TIMESTAMP")
    db.execute(
        text(
            f"""
            UPDATE TB_BIZ
            SET {", ".join(sets)}
            WHERE BIZ_NO = :biz_no
              AND DEL_YN = 'N'
            """
        ),
        params,
    )
    db.commit()


def get_biz_api_key_by_no(db: Session, biz_api_key_no: str) -> dict | None:
    """프로젝트 API 키 번호로 단건을 조회한다."""
    return (
        db.execute(
            text(
                """
                SELECT
                    BK.BIZ_API_KEY_NO,
                    BK.BIZ_NO,
                    B.SITE_NO,
                    BK.KEY_NM,
                    BK.KEY_HASH_CN,
                    BK.KEY_PREFIX_CN,
                    BK.KEY_STTS_CD,
                    BK.EXPR_DT,
                    BK.RATE_LMT_PER_MIN,
                    BK.ISSUE_CN,
                    BK.LAST_USE_DT,
                    BK.REVOKE_DT,
                    BK.USE_YN,
                    BK.DEL_YN,
                    BK.REG_DT,
                    BK.UPD_DT
                FROM TB_BIZ_API_KEY BK
                INNER JOIN TB_BIZ B
                    ON B.BIZ_NO = BK.BIZ_NO
                   AND B.DEL_YN = 'N'
                WHERE BK.BIZ_API_KEY_NO = :biz_api_key_no
                  AND BK.DEL_YN = 'N'
                LIMIT 1
                """
            ),
            {"biz_api_key_no": biz_api_key_no},
        )
        .mappings()
        .first()
    )


def insert_biz_api_key(db: Session, payload: dict) -> None:
    """프로젝트 API 키를 등록한다."""
    db.execute(
        text(
            """
            INSERT INTO TB_BIZ_API_KEY (
                BIZ_API_KEY_NO,
                BIZ_NO,
                KEY_NM,
                KEY_HASH_CN,
                KEY_PREFIX_CN,
                KEY_STTS_CD,
                EXPR_DT,
                RATE_LMT_PER_MIN,
                ISSUE_CN,
                REVOKE_DT,
                USE_YN,
                DEL_YN
            ) VALUES (
                :biz_api_key_no,
                :biz_no,
                :key_nm,
                :key_hash_cn,
                :key_prefix_cn,
                :key_stts_cd,
                :expr_dt,
                :rate_lmt_per_min,
                :issue_cn,
                :revoke_dt,
                :use_yn,
                'N'
            )
            """
        ),
        payload,
    )
    db.commit()


def update_biz_api_key(db: Session, biz_api_key_no: str, payload: dict) -> None:
    """프로젝트 API 키를 수정한다."""
    sets = []
    params: dict[str, object] = {"biz_api_key_no": biz_api_key_no}
    for key, value in payload.items():
        sets.append(f"{key} = :{key}")
        params[key] = value

    if not sets:
        return

    sets.append("UPD_DT = CURRENT_TIMESTAMP")
    db.execute(
        text(
            f"""
            UPDATE TB_BIZ_API_KEY
            SET {", ".join(sets)}
            WHERE BIZ_API_KEY_NO = :biz_api_key_no
              AND DEL_YN = 'N'
            """
        ),
        params,
    )
    db.commit()
