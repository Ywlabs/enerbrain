"""SFTP CSV 수집 커넥터 스텁."""

from typing import Any

from app.domain.ingestion.connectors.base import BaseConnector


class SftpCsvConnector(BaseConnector):
    """SFTP/FTP CSV 원천 데이터 수집 구현체."""

    def collect(self, config: dict[str, Any]) -> list[dict[str, Any]]:
        return []
