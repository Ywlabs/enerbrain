"""TB_USER 도메인 리포지토리."""

from sqlalchemy import text
from sqlalchemy.orm import Session


def get_user_for_login(db: Session, user_id: str) -> dict | None:
    """로그인 검증용 사용자 정보를 조회한다."""
    return (
        db.execute(
            text(
                """
                SELECT
                    USER_NO,
                    USER_ID,
                    USER_NM,
                    GLOBAL_ROLE_CD,
                    PW_HASH_CN,
                    FAIL_NOCS,
                    LOCK_DT,
                    STTS_CD,
                    USE_YN,
                    DEL_YN
                FROM TB_USER
                WHERE USER_ID = :user_id
                LIMIT 1
                """
            ),
            {"user_id": user_id},
        )
        .mappings()
        .first()
    )


def increase_login_fail_count(db: Session, user_no: str) -> None:
    """로그인 실패 횟수를 증가한다."""
    db.execute(
        text(
            """
            UPDATE TB_USER
            SET FAIL_NOCS = COALESCE(FAIL_NOCS, 0) + 1
              , UPD_DT = CURRENT_TIMESTAMP
            WHERE USER_NO = :user_no
            """
        ),
        {"user_no": user_no},
    )
    db.commit()


def mark_login_success(db: Session, user_no: str) -> None:
    """로그인 성공 정보를 갱신한다."""
    db.execute(
        text(
            """
            UPDATE TB_USER
            SET FAIL_NOCS = 0
              , LAST_LOGIN_DT = CURRENT_TIMESTAMP
              , UPD_DT = CURRENT_TIMESTAMP
            WHERE USER_NO = :user_no
            """
        ),
        {"user_no": user_no},
    )
    db.commit()


def get_user_site_scopes(db: Session, user_no: str) -> list[str]:
    """사용자 사이트 권한 범위를 조회한다."""
    rows = (
        db.execute(
            text(
                """
                SELECT SITE_NO
                FROM TB_USER_SITE_ROLE
                WHERE USER_NO = :user_no
                  AND USE_YN = 'Y'
                  AND DEL_YN = 'N'
                """
            ),
            {"user_no": user_no},
        )
        .mappings()
        .all()
    )
    return [str(row["SITE_NO"]) for row in rows]


def get_user_by_no(db: Session, user_no: str) -> dict | None:
    """토큰 검증 후 사용자 정보를 조회한다."""
    return (
        db.execute(
            text(
                """
                SELECT
                    USER_NO,
                    USER_ID,
                    USER_NM,
                    GLOBAL_ROLE_CD,
                    STTS_CD,
                    USE_YN,
                    DEL_YN
                FROM TB_USER
                WHERE USER_NO = :user_no
                LIMIT 1
                """
            ),
            {"user_no": user_no},
        )
        .mappings()
        .first()
    )


def insert_login_audit_log(
    db: Session,
    *,
    auth_se_cd: str,
    login_act_se_cd: str,
    user_id: str,
    user_no: str | None = None,
    biz_api_key_no: str | None = None,
    req_ip_addr: str | None = None,
    user_agent_cn: str | None = None,
    fail_rsn_cd: str | None = None,
    fail_dtl_cn: str | None = None,
) -> None:
    """TB_LOGIN_AUDIT_LOG에 인증 이벤트를 적재한다."""
    db.execute(
        text(
            """
            INSERT INTO TB_LOGIN_AUDIT_LOG (
                AUTH_SE_CD,
                LOGIN_ACT_SE_CD,
                USER_ID,
                USER_NO,
                BIZ_API_KEY_NO,
                REQ_IP_ADDR,
                USER_AGENT_CN,
                FAIL_RSN_CD,
                FAIL_DTL_CN
            ) VALUES (
                :auth_se_cd,
                :login_act_se_cd,
                :user_id,
                :user_no,
                :biz_api_key_no,
                :req_ip_addr,
                :user_agent_cn,
                :fail_rsn_cd,
                :fail_dtl_cn
            )
            """
        ),
        {
            "auth_se_cd": auth_se_cd,
            "login_act_se_cd": login_act_se_cd,
            "user_id": user_id,
            "user_no": user_no,
            "biz_api_key_no": biz_api_key_no,
            "req_ip_addr": req_ip_addr,
            "user_agent_cn": user_agent_cn,
            "fail_rsn_cd": fail_rsn_cd,
            "fail_dtl_cn": fail_dtl_cn,
        },
    )
    db.commit()
