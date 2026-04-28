"""사이트 도메인 리포지토리."""

from sqlalchemy import text
from sqlalchemy.orm import Session


def get_site_list(db: Session) -> list[dict]:
    """전체 사이트 목록을 조회한다."""
    rows = (
        db.execute(
            text(
                """
                SELECT
                    SITE_NO,
                    SITE_NM,
                    CHRGR_NM,
                    CHRGR_EMAIL_ADDR,
                    CHRGR_TELNO,
                    SITE_EXPLN,
                    STTS_CD,
                    USE_YN,
                    DEL_YN,
                    REG_DT,
                    UPD_DT
                FROM TB_SITE
                WHERE DEL_YN = 'N'
                ORDER BY SITE_NO
                """
            )
        )
        .mappings()
        .all()
    )
    return [dict(row) for row in rows]


def get_site_list_by_site_nos(db: Session, site_nos: list[str]) -> list[dict]:
    """권한 사이트 번호로 사이트 목록을 조회한다."""
    if not site_nos:
        return []

    placeholders = ", ".join(f":site_no_{idx}" for idx in range(len(site_nos)))
    params = {f"site_no_{idx}": site_no for idx, site_no in enumerate(site_nos)}
    rows = (
        db.execute(
            text(
                f"""
                SELECT
                    SITE_NO,
                    SITE_NM,
                    CHRGR_NM,
                    CHRGR_EMAIL_ADDR,
                    CHRGR_TELNO,
                    SITE_EXPLN,
                    STTS_CD,
                    USE_YN,
                    DEL_YN,
                    REG_DT,
                    UPD_DT
                FROM TB_SITE
                WHERE DEL_YN = 'N'
                  AND SITE_NO IN ({placeholders})
                ORDER BY SITE_NO
                """
            ),
            params,
        )
        .mappings()
        .all()
    )
    return [dict(row) for row in rows]


def get_site_by_no(db: Session, site_no: str) -> dict | None:
    """사이트 번호로 단건을 조회한다."""
    return (
        db.execute(
            text(
                """
                SELECT
                    SITE_NO,
                    SITE_NM,
                    CHRGR_NM,
                    CHRGR_EMAIL_ADDR,
                    CHRGR_TELNO,
                    SITE_EXPLN,
                    STTS_CD,
                    USE_YN,
                    DEL_YN,
                    REG_DT,
                    UPD_DT
                FROM TB_SITE
                WHERE SITE_NO = :site_no
                  AND DEL_YN = 'N'
                LIMIT 1
                """
            ),
            {"site_no": site_no},
        )
        .mappings()
        .first()
    )


def insert_site(db: Session, payload: dict) -> None:
    """사이트를 등록한다."""
    db.execute(
        text(
            """
            INSERT INTO TB_SITE (
                SITE_NO,
                SITE_NM,
                CHRGR_NM,
                CHRGR_EMAIL_ADDR,
                CHRGR_TELNO,
                SITE_EXPLN,
                STTS_CD,
                USE_YN,
                DEL_YN
            ) VALUES (
                :site_no,
                :site_nm,
                :chrgr_nm,
                :chrgr_email_addr,
                :chrgr_telno,
                :site_expln,
                :stts_cd,
                :use_yn,
                'N'
            )
            """
        ),
        payload,
    )
    db.commit()


def update_site(db: Session, site_no: str, payload: dict) -> None:
    """사이트를 수정한다."""
    sets = []
    params: dict[str, object] = {"site_no": site_no}
    for key, value in payload.items():
        sets.append(f"{key} = :{key}")
        params[key] = value

    if not sets:
        return

    sets.append("UPD_DT = CURRENT_TIMESTAMP")
    db.execute(
        text(
            f"""
            UPDATE TB_SITE
            SET {", ".join(sets)}
            WHERE SITE_NO = :site_no
              AND DEL_YN = 'N'
            """
        ),
        params,
    )
    db.commit()
