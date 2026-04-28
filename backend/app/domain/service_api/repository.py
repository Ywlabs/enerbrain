"""서비스 API 도메인 리포지토리."""

from sqlalchemy import text
from sqlalchemy.orm import Session


def get_api_service_list(db: Session) -> list[dict]:
    """전체 서비스 API 메타 목록을 조회한다."""
    rows = (
        db.execute(
            text(
                """
                SELECT
                    SA.API_SVC_NO,
                    SA.BIZ_NO,
                    B.SITE_NO,
                    SA.API_NM,
                    SA.API_PATH_CN,
                    SA.REQ_MTHD_CD,
                    SA.API_EXPLN,
                    SA.TEST_REQ_JSON,
                    SA.TEST_RES_JSON,
                    SA.STTS_CD,
                    SA.USE_YN,
                    SA.DEL_YN,
                    SA.REG_DT,
                    SA.UPD_DT
                FROM TB_API_SVC SA
                INNER JOIN TB_BIZ B
                    ON B.BIZ_NO = SA.BIZ_NO
                   AND B.DEL_YN = 'N'
                WHERE SA.DEL_YN = 'N'
                ORDER BY SA.API_SVC_NO
                """
            )
        )
        .mappings()
        .all()
    )
    return [dict(row) for row in rows]


def get_api_service_list_by_site_nos(db: Session, site_nos: list[str]) -> list[dict]:
    """권한 사이트 번호로 서비스 API 메타 목록을 조회한다."""
    if not site_nos:
        return []

    placeholders = ", ".join(f":site_no_{idx}" for idx in range(len(site_nos)))
    params = {f"site_no_{idx}": site_no for idx, site_no in enumerate(site_nos)}
    rows = (
        db.execute(
            text(
                f"""
                SELECT
                    SA.API_SVC_NO,
                    SA.BIZ_NO,
                    B.SITE_NO,
                    SA.API_NM,
                    SA.API_PATH_CN,
                    SA.REQ_MTHD_CD,
                    SA.API_EXPLN,
                    SA.TEST_REQ_JSON,
                    SA.TEST_RES_JSON,
                    SA.STTS_CD,
                    SA.USE_YN,
                    SA.DEL_YN,
                    SA.REG_DT,
                    SA.UPD_DT
                FROM TB_API_SVC SA
                INNER JOIN TB_BIZ B
                    ON B.BIZ_NO = SA.BIZ_NO
                   AND B.DEL_YN = 'N'
                WHERE SA.DEL_YN = 'N'
                  AND B.SITE_NO IN ({placeholders})
                ORDER BY SA.API_SVC_NO
                """
            ),
            params,
        )
        .mappings()
        .all()
    )
    return [dict(row) for row in rows]


def get_api_service_by_no(db: Session, api_svc_no: str) -> dict | None:
    """서비스 API 번호로 단건을 조회한다."""
    return (
        db.execute(
            text(
                """
                SELECT
                    SA.API_SVC_NO,
                    SA.BIZ_NO,
                    B.SITE_NO,
                    SA.API_NM,
                    SA.API_PATH_CN,
                    SA.REQ_MTHD_CD,
                    SA.API_EXPLN,
                    SA.TEST_REQ_JSON,
                    SA.TEST_RES_JSON,
                    SA.STTS_CD,
                    SA.USE_YN,
                    SA.DEL_YN,
                    SA.REG_DT,
                    SA.UPD_DT
                FROM TB_API_SVC SA
                INNER JOIN TB_BIZ B
                    ON B.BIZ_NO = SA.BIZ_NO
                   AND B.DEL_YN = 'N'
                WHERE SA.API_SVC_NO = :api_svc_no
                  AND SA.DEL_YN = 'N'
                LIMIT 1
                """
            ),
            {"api_svc_no": api_svc_no},
        )
        .mappings()
        .first()
    )


def insert_api_service(db: Session, payload: dict) -> None:
    """서비스 API 메타를 등록한다."""
    db.execute(
        text(
            """
            INSERT INTO TB_API_SVC (
                API_SVC_NO,
                BIZ_NO,
                API_NM,
                API_PATH_CN,
                REQ_MTHD_CD,
                API_EXPLN,
                TEST_REQ_JSON,
                TEST_RES_JSON,
                STTS_CD,
                USE_YN,
                DEL_YN
            ) VALUES (
                :api_svc_no,
                :biz_no,
                :api_nm,
                :api_path_cn,
                :req_mthd_cd,
                :api_expln,
                :test_req_json,
                :test_res_json,
                :stts_cd,
                :use_yn,
                'N'
            )
            """
        ),
        payload,
    )
    db.commit()


def update_api_service(db: Session, api_svc_no: str, payload: dict) -> None:
    """서비스 API 메타를 수정한다."""
    sets = []
    params: dict[str, object] = {"api_svc_no": api_svc_no}
    for key, value in payload.items():
        sets.append(f"{key} = :{key}")
        params[key] = value

    if not sets:
        return

    sets.append("UPD_DT = CURRENT_TIMESTAMP")
    db.execute(
        text(
            f"""
            UPDATE TB_API_SVC
            SET {", ".join(sets)}
            WHERE API_SVC_NO = :api_svc_no
              AND DEL_YN = 'N'
            """
        ),
        params,
    )
    db.commit()
