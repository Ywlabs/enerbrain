"""TB_USER 도메인 스키마."""

from pydantic import BaseModel, Field


class PasLoginIn(BaseModel):
    """PAS 로그인 요청 스키마."""

    user_id: str = Field(min_length=1, max_length=100, description="로그인ID")
    usr_pwd: str = Field(min_length=1, max_length=200, description="사용자비밀번호")


class PasTokenOut(BaseModel):
    """PAS 로그인 응답 토큰 스키마."""

    access_token: str
    token_type: str = "bearer"
    expires_in: int


class PasMeOut(BaseModel):
    """PAS 현재 사용자 정보 응답 스키마."""

    user_no: str
    user_id: str
    user_nm: str
    global_role_cd: str
    site_scopes: list[str]
