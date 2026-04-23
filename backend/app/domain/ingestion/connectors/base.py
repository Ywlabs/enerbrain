"""수집 커넥터 인터페이스."""

from abc import ABC, abstractmethod
from typing import Any


class BaseConnector(ABC):
    """모든 외부 수집 커넥터의 공통 인터페이스."""

    @abstractmethod
    def collect(self, config: dict[str, Any]) -> list[dict[str, Any]]:
        """외부 원천 데이터를 수집한다."""
