"""환경 변수 기반 설정 (pydantic-settings)."""

from pydantic import field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """애플리케이션 설정 — .env 및 환경 변수에서 로드."""

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore",
    )

    app_name: str = "EnerBrain API"
    api_v1_prefix: str = "/api/v1"
    # PostgreSQL 연결 문자열 (SQLAlchemy 2 + psycopg3: postgresql+psycopg://...)
    database_url: str | None = None
    cors_origins: list[str] = ["http://localhost:5173"]

    @field_validator("cors_origins", mode="before")
    @classmethod
    def parse_cors_origins(cls, v: object) -> object:
        # 환경 변수에 단일 문자열로 넣은 경우 콤마 분리 지원
        if isinstance(v, str) and not v.strip().startswith("["):
            return [origin.strip() for origin in v.split(",") if origin.strip()]
        return v


settings = Settings()
