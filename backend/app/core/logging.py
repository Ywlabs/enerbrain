"""로깅 설정 유틸."""

import logging


def get_logger(name: str) -> logging.Logger:
    """모듈별 표준 로거를 반환한다."""
    return logging.getLogger(name)
