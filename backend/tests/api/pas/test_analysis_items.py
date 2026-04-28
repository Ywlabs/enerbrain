"""PAS 분석항목 API 테스트."""

from fastapi import HTTPException

from app.api.v1.pas import analysis_items as analysis_items_api


def test_get_analysis_items_success(client, monkeypatch) -> None:
    """분석항목 목록 조회가 성공해야 한다."""

    def _fake_get_analysis_items_for_pas(_db, _user_ctx):
        return [{"analysis_item_no": "AI_01", "biz_no": "BIZ_01", "site_no": "SITE_01", "item_nm": "테스트항목"}]

    monkeypatch.setattr(analysis_items_api, "get_analysis_items_for_pas", _fake_get_analysis_items_for_pas)

    res = client.get("/api/v1/pas/analysis-items")

    assert res.status_code == 200
    body = res.json()
    assert body["success"] is True
    assert body["data"][0]["analysis_item_no"] == "AI_01"


def test_get_analysis_item_detail_not_found(client, monkeypatch) -> None:
    """없는 분석항목 상세 조회는 404여야 한다."""

    def _fake_get_analysis_item_detail_for_pas(_db, _user_ctx, _analysis_item_no):
        raise HTTPException(status_code=404, detail="조회 대상이 없습니다.")

    monkeypatch.setattr(
        analysis_items_api,
        "get_analysis_item_detail_for_pas",
        _fake_get_analysis_item_detail_for_pas,
    )

    res = client.get("/api/v1/pas/analysis-items/AI_NOT_FOUND")

    assert res.status_code == 404


def test_create_analysis_item_success(client, monkeypatch) -> None:
    """분석항목 등록이 성공해야 한다."""

    def _fake_create_analysis_item_for_pas(_db, _user_ctx, _payload):
        return "AI_202604280001"

    monkeypatch.setattr(
        analysis_items_api,
        "create_analysis_item_for_pas",
        _fake_create_analysis_item_for_pas,
    )

    res = client.post(
        "/api/v1/pas/analysis-items",
        json={
            "biz_no": "BIZ_01",
            "item_nm": "신규 분석항목",
            "algm_cd": "XGBOOST",
            "module_path_cn": "app/modules/test.py",
            "entry_func_nm": "run",
            "timeout_sec": 600,
            "retry_cnt": 0,
            "use_yn": "Y",
        },
    )

    assert res.status_code == 200
    assert res.json()["data"]["analysis_item_no"] == "AI_202604280001"


def test_update_analysis_item_forbidden(client, monkeypatch) -> None:
    """권한 없는 분석항목 수정은 403이어야 한다."""

    def _fake_update_analysis_item_for_pas(_db, _user_ctx, _analysis_item_no, _payload):
        raise HTTPException(status_code=403, detail="권한없음")

    monkeypatch.setattr(
        analysis_items_api,
        "update_analysis_item_for_pas",
        _fake_update_analysis_item_for_pas,
    )

    res = client.put(
        "/api/v1/pas/analysis-items/AI_DENIED",
        json={"item_nm": "수정"},
    )

    assert res.status_code == 403
