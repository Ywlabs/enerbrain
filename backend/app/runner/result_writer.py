"""분석 실행 결과 저장 스텁."""

from typing import Any


def build_run_result(run_stts_cd: str, run_rslt: dict[str, Any], run_model: dict[str, Any]) -> dict[str, Any]:
    """TB_ANALYSIS_RUN 저장 payload 스텁."""
    return {
        "run_stts_cd": run_stts_cd,
        "run_rslt_json": run_rslt,
        "run_model_json": run_model,
    }
