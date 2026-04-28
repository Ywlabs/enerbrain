"""서비스 API 도메인 스키마."""

from pydantic import BaseModel, Field


class ServiceApiOut(BaseModel):
    """서비스 API 메타 응답 스키마."""

    api_svc_no: str
    biz_no: str
    site_no: str
    api_nm: str
    api_path_cn: str
    req_mthd_cd: str
    api_expln: str | None = None
    test_req_json: dict | list | None = None
    test_res_json: dict | list | None = None
    stts_cd: str
    use_yn: str
    del_yn: str


class ServiceApiCreateIn(BaseModel):
    """서비스 API 메타 등록 요청 스키마."""

    biz_no: str = Field(min_length=1, max_length=20)
    api_nm: str = Field(min_length=1, max_length=200)
    api_path_cn: str = Field(min_length=1, max_length=500)
    req_mthd_cd: str = Field(min_length=1, max_length=10)
    api_expln: str | None = Field(default=None, max_length=1000)
    test_req_json: dict | list | None = None
    test_res_json: dict | list | None = None
    stts_cd: str = Field(default="ACTIVE", min_length=1, max_length=20)
    use_yn: str = Field(default="Y", pattern="^[YN]$")


class ServiceApiUpdateIn(BaseModel):
    """서비스 API 메타 수정 요청 스키마."""

    api_nm: str | None = Field(default=None, min_length=1, max_length=200)
    api_path_cn: str | None = Field(default=None, min_length=1, max_length=500)
    req_mthd_cd: str | None = Field(default=None, min_length=1, max_length=10)
    api_expln: str | None = Field(default=None, max_length=1000)
    test_req_json: dict | list | None = None
    test_res_json: dict | list | None = None
    stts_cd: str | None = Field(default=None, min_length=1, max_length=20)
    use_yn: str | None = Field(default=None, pattern="^[YN]$")
