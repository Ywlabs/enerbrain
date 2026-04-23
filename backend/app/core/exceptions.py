"""애플리케이션 공통 예외 정의."""


class AppException(Exception):
    """애플리케이션 도메인 공통 예외."""


class NotFoundException(AppException):
    """조회 대상이 없을 때 사용하는 예외."""


class UnauthorizedException(AppException):
    """인증/인가 실패 시 사용하는 예외."""
