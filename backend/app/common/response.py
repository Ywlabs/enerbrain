"""API 공통 JSON 응답 형식 (WorkPlan 패턴과 호환)."""

from typing import Any

from pydantic import BaseModel, Field


class ApiResponse(BaseModel):
    """success / message / data 구조."""

    success: bool = Field(description="성공 여부")
    message: str = Field(description="사용자용 메시지")
    data: Any = Field(default=None, description="본문 데이터")
