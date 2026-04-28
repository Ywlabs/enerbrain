"""PAS 서비스 API 메타 API 테스트."""

from fastapi import HTTPException

from app.api.v1.pas import api_services as api_services_api


def test_get_api_services_success(client, monkeypatch) -> None:
    """서비스 API 메타 목록 조회가 성공해야 한다."""

    def _fake_get_api_services_for_pas(_db, _user_ctx):
        return [{"api_svc_no": "ASV_01", "biz_no": "BIZ_01", "site_no": "SITE_01", "api_nm": "테스트 API"}]

    monkeypatch.setattr(api_services_api, "get_api_services_for_pas", _fake_get_api_services_for_pas)

    res = client.get("/api/v1/pas/api-services")

    assert res.status_code == 200
    assert res.json()["data"][0]["api_svc_no"] == "ASV_01"


def test_get_api_service_detail_not_found(client, monkeypatch) -> None:
    """없는 서비스 API 메타 상세 조회는 404여야 한다."""

    def _fake_get_api_service_detail_for_pas(_db, _user_ctx, _api_svc_no):
        raise HTTPException(status_code=404, detail="조회 대상이 없습니다.")

    monkeypatch.setattr(
        api_services_api,
        "get_api_service_detail_for_pas",
        _fake_get_api_service_detail_for_pas,
    )

    res = client.get("/api/v1/pas/api-services/ASV_NOT_FOUND")

    assert res.status_code == 404


def test_create_api_service_success(client, monkeypatch) -> None:
    """서비스 API 메타 등록이 성공해야 한다."""

    def _fake_create_api_service_for_pas(_db, _user_ctx, _payload):
        return "ASV_202604280001"

    monkeypatch.setattr(
        api_services_api,
        "create_api_service_for_pas",
        _fake_create_api_service_for_pas,
    )

    res = client.post(
        "/api/v1/pas/api-services",
        json={
            "biz_no": "BIZ_01",
            "api_nm": "실시간 조회",
            "api_path_cn": "/api/v1/sas/realtime",
            "req_mthd_cd": "GET",
            "stts_cd": "ACTIVE",
            "use_yn": "Y",
        },
    )

    assert res.status_code == 200
    assert res.json()["data"]["api_svc_no"] == "ASV_202604280001"


def test_update_api_service_forbidden(client, monkeypatch) -> None:
    """권한 없는 서비스 API 메타 수정은 403이어야 한다."""

    def _fake_update_api_service_for_pas(_db, _user_ctx, _api_svc_no, _payload):
        raise HTTPException(status_code=403, detail="권한없음")

    monkeypatch.setattr(
        api_services_api,
        "update_api_service_for_pas",
        _fake_update_api_service_for_pas,
    )

    res = client.put(
        "/api/v1/pas/api-services/ASV_DENIED",
        json={"api_nm": "수정"},
    )

    assert res.status_code == 403
