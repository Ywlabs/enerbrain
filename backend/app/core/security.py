"""보안 관련 공통 유틸."""

import hashlib
from datetime import UTC, datetime, timedelta
from typing import Any

import jwt
from passlib.context import CryptContext

from app.core.config import settings

_pwd_context = CryptContext(schemes=["argon2", "bcrypt"], deprecated="auto")


def sha256_hex(raw_value: str) -> str:
    """문자열을 SHA-256 해시(hex)로 변환한다."""
    return hashlib.sha256(raw_value.encode("utf-8")).hexdigest()


def verify_password(raw_password: str, pw_hash: str) -> bool:
    """입력 비밀번호와 해시를 비교한다."""
    try:
        return _pwd_context.verify(raw_password, pw_hash)
    except Exception:
        return False


def create_access_token(
    payload: dict[str, Any],
    expires_minutes: int | None = None,
) -> str:
    """JWT 액세스 토큰을 생성한다."""
    exp_minutes = expires_minutes or settings.jwt_access_token_exp_min
    now = datetime.now(UTC)
    to_encode = {
        **payload,
        "iat": now,
        "exp": now + timedelta(minutes=exp_minutes),
        "type": "access",
    }
    return jwt.encode(to_encode, settings.jwt_secret_key, algorithm=settings.jwt_algorithm)


def decode_access_token(token: str) -> dict[str, Any]:
    """JWT 액세스 토큰을 복호화/검증한다."""
    return jwt.decode(
        token,
        settings.jwt_secret_key,
        algorithms=[settings.jwt_algorithm],
    )
