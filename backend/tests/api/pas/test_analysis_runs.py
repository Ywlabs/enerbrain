"""PAS 분석실행이력 API 테스트."""

from app.api.v1.pas import analysis_runs as analysis_runs_api


def test_get_analysis_runs_success(client, monkeypatch) -> None:
    """분석실행이력 목록 조회가 성공해야 한다."""

    def _fake_get_analysis_runs_with_filters_for_pas(
        _db,
        _user_ctx,
        *,
        analysis_item_no=None,
        run_stts_cd=None,
        from_dt=None,
        to_dt=None,
    ):
        assert run_stts_cd == "DONE"
        return [{"analysis_run_no": "AR_01", "analysis_item_no": analysis_item_no or "AI_01", "run_stts_cd": "DONE"}]

    monkeypatch.setattr(
        analysis_runs_api,
        "get_analysis_runs_with_filters_for_pas",
        _fake_get_analysis_runs_with_filters_for_pas,
    )

    res = client.get("/api/v1/pas/analysis-runs?analysis_item_no=AI_01&run_stts_cd=DONE")

    assert res.status_code == 200
    body = res.json()
    assert body["success"] is True
    assert body["data"][0]["run_stts_cd"] == "DONE"
