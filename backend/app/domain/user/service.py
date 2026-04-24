"""TB_USER 도메인 서비스."""

from datetime import datetime

from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from app.core.config import settings
from app.core.logging import get_logger
from app.core.security import create_access_token, verify_password
from app.domain.user import repository
from app.domain.user.schema import PasMeOut, PasTokenOut

logger = get_logger(__name__)


def _write_login_audit_log(
    db: Session,
    *,
    login_act_se_cd: str,
    user_id: str,
    user_no: str | None = None,
    req_ip_addr: str | None = None,
    user_agent_cn: str | None = None,
    fail_rsn_cd: str | None = None,
    fail_dtl_cn: str | None = None,
) -> None:
    """로그인 감사로그를 적재한다(실패 시 본 흐름은 유지)."""
    try:
        repository.insert_login_audit_log(
            db,
            auth_se_cd="PAS",
            login_act_se_cd=login_act_se_cd,
            user_id=user_id,
            user_no=user_no,
            req_ip_addr=req_ip_addr,
            user_agent_cn=user_agent_cn,
            fail_rsn_cd=fail_rsn_cd,
            fail_dtl_cn=fail_dtl_cn,
        )
    except Exception:
        db.rollback()
        logger.exception("TB_LOGIN_AUDIT_LOG 적재 실패 (user_id=%s)", user_id)


def authenticate_and_issue_token(
    db: Session,
    user_id: str,
    password: str,
    *,
    req_ip_addr: str | None = None,
    user_agent_cn: str | None = None,
) -> PasTokenOut:
    """로그인 인증 후 액세스 토큰을 발급한다."""
    user = repository.get_user_for_login(db, user_id)
    if user is None:
        _write_login_audit_log(
            db,
            login_act_se_cd="FAIL",
            user_id=user_id,
            req_ip_addr=req_ip_addr,
            user_agent_cn=user_agent_cn,
            fail_rsn_cd="USER_NOT_FOUND",
            fail_dtl_cn="사용자 ID가 존재하지 않습니다.",
        )
        logger.warning("PAS 로그인 실패: 사용자 없음 (user_id=%s)", user_id)
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="아이디 또는 비밀번호가 올바르지 않습니다.",
        )

    if user["USE_YN"] != "Y" or user["DEL_YN"] != "N" or user["STTS_CD"] != "ACTIVE":
        _write_login_audit_log(
            db,
            login_act_se_cd="FAIL",
            user_id=user_id,
            user_no=str(user["USER_NO"]),
            req_ip_addr=req_ip_addr,
            user_agent_cn=user_agent_cn,
            fail_rsn_cd="INACTIVE",
            fail_dtl_cn="비활성 또는 삭제된 계정입니다.",
        )
        logger.warning(
            "PAS 로그인 실패: 계정 상태 비정상 (user_no=%s, use_yn=%s, del_yn=%s, stts_cd=%s)",
            user["USER_NO"],
            user["USE_YN"],
            user["DEL_YN"],
            user["STTS_CD"],
        )
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="권한없음")

    lock_dt = user.get("LOCK_DT")
    if lock_dt is not None and isinstance(lock_dt, datetime):
        _write_login_audit_log(
            db,
            login_act_se_cd="LOCKED",
            user_id=user_id,
            user_no=str(user["USER_NO"]),
            req_ip_addr=req_ip_addr,
            user_agent_cn=user_agent_cn,
            fail_rsn_cd="LOCKED",
            fail_dtl_cn="계정 잠금 상태입니다.",
        )
        logger.warning("PAS 로그인 실패: 계정 잠김 (user_no=%s, lock_dt=%s)", user["USER_NO"], lock_dt)
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="계정이 잠겨 있습니다.")

    if not verify_password(password, str(user["PW_HASH_CN"])):
        repository.increase_login_fail_count(db, str(user["USER_NO"]))
        _write_login_audit_log(
            db,
            login_act_se_cd="FAIL",
            user_id=user_id,
            user_no=str(user["USER_NO"]),
            req_ip_addr=req_ip_addr,
            user_agent_cn=user_agent_cn,
            fail_rsn_cd="PASSWORD_MISMATCH",
            fail_dtl_cn="비밀번호가 일치하지 않습니다.",
        )
        logger.warning("PAS 로그인 실패: 비밀번호 불일치 (user_no=%s)", user["USER_NO"])
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="아이디 또는 비밀번호가 올바르지 않습니다.",
        )

    repository.mark_login_success(db, str(user["USER_NO"]))
    _write_login_audit_log(
        db,
        login_act_se_cd="SUCCESS",
        user_id=user_id,
        user_no=str(user["USER_NO"]),
        req_ip_addr=req_ip_addr,
        user_agent_cn=user_agent_cn,
    )
    site_scopes = repository.get_user_site_scopes(db, str(user["USER_NO"]))
    logger.info(
        "PAS 로그인 성공 (user_no=%s, role=%s, site_scope_count=%s)",
        user["USER_NO"],
        user["GLOBAL_ROLE_CD"],
        len(site_scopes),
    )

    access_token = create_access_token(
        {
            "sub": str(user["USER_NO"]),
            "user_id": str(user["USER_ID"]),
            "global_role_cd": str(user["GLOBAL_ROLE_CD"]),
            "site_scopes": site_scopes,
        }
    )

    return PasTokenOut(
        access_token=access_token,
        token_type="bearer",
        expires_in=settings.jwt_access_token_exp_min * 60,
    )


def get_me(db: Session, user_no: str) -> PasMeOut:
    """현재 사용자 정보를 조회한다."""
    user = repository.get_user_by_no(db, user_no)
    if user is None:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="인증이 필요합니다.")

    if user["USE_YN"] != "Y" or user["DEL_YN"] != "N" or user["STTS_CD"] != "ACTIVE":
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="권한없음")

    return PasMeOut(
        user_no=str(user["USER_NO"]),
        user_id=str(user["USER_ID"]),
        user_nm=str(user["USER_NM"]),
        global_role_cd=str(user["GLOBAL_ROLE_CD"]),
        site_scopes=repository.get_user_site_scopes(db, str(user["USER_NO"])),
    )
