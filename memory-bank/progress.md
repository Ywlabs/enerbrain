# EnerBrain — 진행 상황

## 동작하는 것

- `backend` FastAPI 앱 기동(Uvicorn).
- `GET /api/v1/health` — `ApiResponse` 형식 JSON.
- Swagger UI: `/docs`.
- `pydantic-settings` 기반 설정, CORS, v1 라우터 집계.
- `pyproject.toml` + `[project.scripts] enerbrain-serve`.
- `DATABASE_URL` 설정 시 SQLAlchemy 엔진·`SessionLocal` 생성(미설정 시 DB 의존 라우트는 503).

## 아직 없음 / 미구현

- Alembic 마이그레이션, 실제 ORM 모델·CRUD.
- Inference / Analyzer / Forecaster / Fault Detector 비즈니스 로직.
- MQTT, 배치 워커, 인증·권한.
- Docker 이미지·CI.
- 프론트엔드(별도 여부 미정).

## 알려진 이슈

- 없음(초기 단계).

## 버전 메모

- Memory Bank 전체를 **2026-04-04 기준 EnerBrain** 내용으로 재생성함.
