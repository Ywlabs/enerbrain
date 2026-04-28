"""사이트 도메인 스키마."""

from pydantic import BaseModel, Field


class SiteOut(BaseModel):
    """사이트 응답 스키마."""

    site_no: str
    site_nm: str
    chrgr_nm: str | None = None
    chrgr_email_addr: str | None = None
    chrgr_telno: str | None = None
    site_expln: str | None = None
    stts_cd: str
    use_yn: str
    del_yn: str


class SiteCreateIn(BaseModel):
    """사이트 등록 요청 스키마."""

    site_nm: str = Field(min_length=1, max_length=100)
    chrgr_nm: str | None = Field(default=None, max_length=100)
    chrgr_email_addr: str | None = Field(default=None, max_length=200)
    chrgr_telno: str | None = Field(default=None, max_length=20)
    site_expln: str | None = Field(default=None, max_length=1000)
    stts_cd: str = Field(default="ACTIVE", min_length=1, max_length=20)
    use_yn: str = Field(default="Y", pattern="^[YN]$")


class SiteUpdateIn(BaseModel):
    """사이트 수정 요청 스키마."""

    site_nm: str | None = Field(default=None, min_length=1, max_length=100)
    chrgr_nm: str | None = Field(default=None, max_length=100)
    chrgr_email_addr: str | None = Field(default=None, max_length=200)
    chrgr_telno: str | None = Field(default=None, max_length=20)
    site_expln: str | None = Field(default=None, max_length=1000)
    stts_cd: str | None = Field(default=None, min_length=1, max_length=20)
    use_yn: str | None = Field(default=None, pattern="^[YN]$")
