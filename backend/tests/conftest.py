"""PAS API 테스트 공통 fixture."""

from collections.abc import Generator

import pytest
from fastapi.testclient import TestClient

from app.dependencies.db import get_db
from app.dependencies.pas_auth import require_pas_jwt, require_super_admin
from app.main import create_app


@pytest.fixture
def client() -> Generator[TestClient, None, None]:
    """의존성 오버라이드가 적용된 테스트 클라이언트를 제공한다."""
    app = create_app()

    def _fake_get_db() -> Generator[object, None, None]:
        yield object()

    def _fake_require_pas_jwt() -> dict[str, object]:
        return {
            "user_no": "USER_TEST",
            "user_id": "tester",
            "global_role_cd": "SUPER_ADMIN",
            "site_scopes": ["SITE_01"],
        }

    def _fake_require_super_admin() -> dict[str, object]:
        return {
            "user_no": "USER_TEST",
            "user_id": "tester",
            "global_role_cd": "SUPER_ADMIN",
            "site_scopes": ["SITE_01"],
        }

    app.dependency_overrides[get_db] = _fake_get_db
    app.dependency_overrides[require_pas_jwt] = _fake_require_pas_jwt
    app.dependency_overrides[require_super_admin] = _fake_require_super_admin

    with TestClient(app) as test_client:
        yield test_client

    app.dependency_overrides.clear()
