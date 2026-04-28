"""분석 도메인 스키마."""

from pydantic import BaseModel, Field


class AnalysisItemOut(BaseModel):
    """분석항목 응답 스키마."""

    analysis_item_no: str
    biz_no: str
    site_no: str
    item_nm: str
    algm_cd: str
    item_expln: str | None = None
    stts_cd: str
    cron_expr_cn: str | None = None
    module_path_cn: str
    entry_func_nm: str
    model_file_nm_cn: str | None = None
    params_json: dict | list | None = None
    timeout_sec: int
    retry_cnt: int
    use_yn: str
    del_yn: str


class AnalysisItemCreateIn(BaseModel):
    """분석항목 등록 요청 스키마."""

    biz_no: str = Field(min_length=1, max_length=20)
    item_nm: str = Field(min_length=1, max_length=200)
    algm_cd: str = Field(min_length=1, max_length=50)
    item_expln: str | None = Field(default=None, max_length=2000)
    stts_cd: str = Field(default="ACTIVE", min_length=1, max_length=20)
    cron_expr_cn: str | None = Field(default=None, max_length=100)
    module_path_cn: str = Field(min_length=1, max_length=500)
    entry_func_nm: str = Field(default="run", min_length=1, max_length=100)
    model_file_nm_cn: str | None = Field(default=None, max_length=200)
    params_json: dict | list | None = None
    timeout_sec: int = Field(default=600, ge=1, le=86400)
    retry_cnt: int = Field(default=0, ge=0, le=100)
    use_yn: str = Field(default="Y", pattern="^[YN]$")


class AnalysisItemUpdateIn(BaseModel):
    """분석항목 수정 요청 스키마."""

    item_nm: str | None = Field(default=None, min_length=1, max_length=200)
    algm_cd: str | None = Field(default=None, min_length=1, max_length=50)
    item_expln: str | None = Field(default=None, max_length=2000)
    stts_cd: str | None = Field(default=None, min_length=1, max_length=20)
    cron_expr_cn: str | None = Field(default=None, max_length=100)
    module_path_cn: str | None = Field(default=None, min_length=1, max_length=500)
    entry_func_nm: str | None = Field(default=None, min_length=1, max_length=100)
    model_file_nm_cn: str | None = Field(default=None, max_length=200)
    params_json: dict | list | None = None
    timeout_sec: int | None = Field(default=None, ge=1, le=86400)
    retry_cnt: int | None = Field(default=None, ge=0, le=100)
    use_yn: str | None = Field(default=None, pattern="^[YN]$")
