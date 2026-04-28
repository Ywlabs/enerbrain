"""PAS 프로젝트 API 키 API 테스트."""

from fastapi import HTTPException

from app.api.v1.pas import biz_api_keys as biz_api_keys_api


def test_get_biz_api_keys_success(client, monkeypatch) -> None:
    """프로젝트 API 키 목록 조회가 성공해야 한다."""

    def _fake_get_biz_api_keys_for_pas(_db, _user_ctx):
        return [{"biz_api_key_no": "BAK_01", "biz_no": "BIZ_01", "site_no": "SITE_01", "key_nm": "운영키"}]

    monkeypatch.setattr(biz_api_keys_api, "get_biz_api_keys_for_pas", _fake_get_biz_api_keys_for_pas)

    res = client.get("/api/v1/pas/biz-api-keys")

    assert res.status_code == 200
    assert res.json()["data"][0]["biz_api_key_no"] == "BAK_01"


def test_get_biz_api_key_detail_forbidden(client, monkeypatch) -> None:
    """권한 없는 프로젝트 API 키 상세는 403이어야 한다."""

    def _fake_get_biz_api_key_detail_for_pas(_db, _user_ctx, _biz_api_key_no):
        raise HTTPException(status_code=403, detail="권한없음")

    monkeypatch.setattr(
        biz_api_keys_api,
        "get_biz_api_key_detail_for_pas",
        _fake_get_biz_api_key_detail_for_pas,
    )

    res = client.get("/api/v1/pas/biz-api-keys/BAK_DENIED")

    assert res.status_code == 403


def test_create_biz_api_key_success(client, monkeypatch) -> None:
    """프로젝트 API 키 발급이 성공해야 한다."""

    def _fake_create_biz_api_key_for_pas(_db, _user_ctx, _payload):
        return {
            "biz_api_key_no": "BAK_202604280001",
            "key_prefix_cn": "ebk_xxxprefix",
            "api_key": "ebk_xxxrawvalue",
        }

    monkeypatch.setattr(
        biz_api_keys_api,
        "create_biz_api_key_for_pas",
        _fake_create_biz_api_key_for_pas,
    )

    res = client.post(
        "/api/v1/pas/biz-api-keys",
        json={
            "biz_no": "BIZ_01",
            "key_nm": "운영키",
            "rate_lmt_per_min": 100,
            "use_yn": "Y",
        },
    )

    assert res.status_code == 200
    body = res.json()
    assert body["data"]["biz_api_key_no"] == "BAK_202604280001"
    assert body["data"]["api_key"].startswith("ebk_")


def test_update_biz_api_key_not_found(client, monkeypatch) -> None:
    """없는 프로젝트 API 키 수정은 404여야 한다."""

    def _fake_update_biz_api_key_for_pas(_db, _user_ctx, _biz_api_key_no, _payload):
        raise HTTPException(status_code=404, detail="조회 대상이 없습니다.")

    monkeypatch.setattr(
        biz_api_keys_api,
        "update_biz_api_key_for_pas",
        _fake_update_biz_api_key_for_pas,
    )

    res = client.put(
        "/api/v1/pas/biz-api-keys/BAK_NOT_FOUND",
        json={"key_nm": "수정"},
    )

    assert res.status_code == 404
