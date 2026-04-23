"""페이지네이션 공통 모델."""

from pydantic import BaseModel, Field


class PageMeta(BaseModel):
    """목록 조회용 페이지 메타 정보."""

    page: int = Field(default=1, ge=1, description="현재 페이지")
    size: int = Field(default=20, ge=1, le=1000, description="페이지 크기")
    total: int = Field(default=0, ge=0, description="전체 건수")
