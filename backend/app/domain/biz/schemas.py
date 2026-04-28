"""프로젝트(BIZ) 도메인 스키마."""

from datetime import datetime

from pydantic import BaseModel, Field


class BizOut(BaseModel):
    """프로젝트 응답 스키마."""

    biz_no: str
    site_no: str
    biz_nm: str
    chrgr_nm: str | None = None
    chrgr_email_addr: str | None = None
    biz_cn: str | None = None
    stts_cd: str
    use_yn: str
    del_yn: str


class BizCreateIn(BaseModel):
    """프로젝트 등록 요청 스키마."""

    site_no: str = Field(min_length=1, max_length=20)
    biz_nm: str = Field(min_length=1, max_length=200)
    chrgr_nm: str | None = Field(default=None, max_length=100)
    chrgr_email_addr: str | None = Field(default=None, max_length=200)
    biz_cn: str | None = Field(default=None, max_length=2000)
    stts_cd: str = Field(default="ACTIVE", min_length=1, max_length=20)
    use_yn: str = Field(default="Y", pattern="^[YN]$")


class BizUpdateIn(BaseModel):
    """프로젝트 수정 요청 스키마."""

    biz_nm: str | None = Field(default=None, min_length=1, max_length=200)
    chrgr_nm: str | None = Field(default=None, max_length=100)
    chrgr_email_addr: str | None = Field(default=None, max_length=200)
    biz_cn: str | None = Field(default=None, max_length=2000)
    stts_cd: str | None = Field(default=None, min_length=1, max_length=20)
    use_yn: str | None = Field(default=None, pattern="^[YN]$")


class BizApiKeyOut(BaseModel):
    """프로젝트 API 키 응답 스키마."""

    biz_api_key_no: str
    biz_no: str
    site_no: str
    key_nm: str
    key_prefix_cn: str
    key_stts_cd: str
    expr_dt: datetime | None = None
    rate_lmt_per_min: int | None = None
    issue_cn: str | None = None
    last_use_dt: datetime | None = None
    revoke_dt: datetime | None = None
    use_yn: str
    del_yn: str


class BizApiKeyCreateIn(BaseModel):
    """프로젝트 API 키 등록 요청 스키마."""

    biz_no: str = Field(min_length=1, max_length=20)
    key_nm: str = Field(min_length=1, max_length=100)
    expr_dt: datetime | None = None
    rate_lmt_per_min: int | None = Field(default=None, ge=1, le=100000)
    issue_cn: str | None = Field(default=None, max_length=1000)
    use_yn: str = Field(default="Y", pattern="^[YN]$")


class BizApiKeyUpdateIn(BaseModel):
    """프로젝트 API 키 수정 요청 스키마."""

    key_nm: str | None = Field(default=None, min_length=1, max_length=100)
    key_stts_cd: str | None = Field(default=None, min_length=1, max_length=20)
    expr_dt: datetime | None = None
    rate_lmt_per_min: int | None = Field(default=None, ge=1, le=100000)
    issue_cn: str | None = Field(default=None, max_length=1000)
    revoke_dt: datetime | None = None
    use_yn: str | None = Field(default=None, pattern="^[YN]$")
