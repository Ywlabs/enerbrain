"""보안 관련 공통 유틸."""

import hashlib


def sha256_hex(raw_value: str) -> str:
    """문자열을 SHA-256 해시(hex)로 변환한다."""
    return hashlib.sha256(raw_value.encode("utf-8")).hexdigest()
