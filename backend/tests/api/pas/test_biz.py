"""PAS 프로젝트 API 테스트."""

from fastapi import HTTPException

from app.api.v1.pas import biz as biz_api


def test_get_biz_list_success(client, monkeypatch) -> None:
    """프로젝트 목록 조회가 성공해야 한다."""

    def _fake_get_biz_list_for_pas(_db, _user_ctx):
        return [{"biz_no": "BIZ_01", "site_no": "SITE_01", "biz_nm": "테스트프로젝트"}]

    monkeypatch.setattr(biz_api, "get_biz_list_for_pas", _fake_get_biz_list_for_pas)

    res = client.get("/api/v1/pas/biz")

    assert res.status_code == 200
    body = res.json()
    assert body["success"] is True
    assert body["data"][0]["biz_no"] == "BIZ_01"


def test_get_biz_detail_forbidden(client, monkeypatch) -> None:
    """권한 없는 프로젝트 상세 조회는 403이어야 한다."""

    def _fake_get_biz_detail_for_pas(_db, _user_ctx, _biz_no):
        raise HTTPException(status_code=403, detail="권한없음")

    monkeypatch.setattr(biz_api, "get_biz_detail_for_pas", _fake_get_biz_detail_for_pas)

    res = client.get("/api/v1/pas/biz/BIZ_DENIED")

    assert res.status_code == 403


def test_create_biz_success(client, monkeypatch) -> None:
    """프로젝트 등록이 성공해야 한다."""

    def _fake_create_biz_for_pas(_db, _user_ctx, _payload):
        return "BIZ_202604280001"

    monkeypatch.setattr(biz_api, "create_biz_for_pas", _fake_create_biz_for_pas)

    res = client.post(
        "/api/v1/pas/biz",
        json={
            "site_no": "SITE_01",
            "biz_nm": "신규 프로젝트",
            "stts_cd": "ACTIVE",
            "use_yn": "Y",
        },
    )

    assert res.status_code == 200
    assert res.json()["data"]["biz_no"] == "BIZ_202604280001"


def test_update_biz_not_found(client, monkeypatch) -> None:
    """없는 프로젝트 수정 시 404여야 한다."""

    def _fake_update_biz_for_pas(_db, _user_ctx, _biz_no, _payload):
        raise HTTPException(status_code=404, detail="조회 대상이 없습니다.")

    monkeypatch.setattr(biz_api, "update_biz_for_pas", _fake_update_biz_for_pas)

    res = client.put(
        "/api/v1/pas/biz/BIZ_NOT_FOUND",
        json={"biz_nm": "수정"},
    )

    assert res.status_code == 404
