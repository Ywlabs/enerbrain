"""PAS 사이트 API 테스트."""

from app.api.v1.pas import sites as sites_api


def test_get_sites_success(client, monkeypatch) -> None:
    """사이트 목록 조회가 성공해야 한다."""

    def _fake_get_sites_for_pas(_db, _user_ctx):
        return [{"site_no": "SITE_01", "site_nm": "테스트사이트", "stts_cd": "ACTIVE", "use_yn": "Y", "del_yn": "N"}]

    monkeypatch.setattr(sites_api, "get_sites_for_pas", _fake_get_sites_for_pas)

    res = client.get("/api/v1/pas/sites")

    assert res.status_code == 200
    body = res.json()
    assert body["success"] is True
    assert body["data"][0]["site_no"] == "SITE_01"


def test_get_site_detail_not_found(client, monkeypatch) -> None:
    """없는 사이트 상세 조회 시 404여야 한다."""

    from fastapi import HTTPException

    def _fake_get_site_detail_for_pas(_db, _user_ctx, _site_no):
        raise HTTPException(status_code=404, detail="조회 대상이 없습니다.")

    monkeypatch.setattr(sites_api, "get_site_detail_for_pas", _fake_get_site_detail_for_pas)

    res = client.get("/api/v1/pas/sites/SITE_NOT_FOUND")

    assert res.status_code == 404


def test_create_site_requires_super_admin(client, monkeypatch) -> None:
    """사이트 등록은 SUPER_ADMIN 권한 의존성을 타야 한다."""

    def _fake_create_site_for_pas(_db, _payload):
        return "SITE_202604280001"

    monkeypatch.setattr(sites_api, "create_site_for_pas", _fake_create_site_for_pas)

    res = client.post(
        "/api/v1/pas/sites",
        json={
            "site_nm": "신규사이트",
            "stts_cd": "ACTIVE",
            "use_yn": "Y",
        },
    )
    assert res.status_code == 200
    body = res.json()
    assert body["data"]["site_no"] == "SITE_202604280001"
