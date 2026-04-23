# EnerBrain — 백엔드

FastAPI 기반 API 서버입니다. 저장소 루트 개요는 [상위 README](../README.md)를 참고하세요.

## 요구 사항

- Python **3.11 이상**
- (선택) PostgreSQL — `DATABASE_URL` 설정 시 SQLAlchemy 세션 사용

## 설치

```powershell
cd backend
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -e ".[dev]"
```

## 실행

```powershell
# backend 디렉터리에서, venv 활성화 후
python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

또는 `pip install -e .` 이후:

```powershell
enerbrain-serve
```

## 앱 구조 (`app/`)

| 경로 | 역할 |
|------|------|
| `main.py` | 앱 팩토리, lifespan, CORS, 라우터 마운트 |
| `api/v1/` | HTTP 라우터 |
| `services/` | 비즈니스 로직 |
| `models/` | SQLAlchemy ORM |
| `schemas/` | Pydantic 스키마 |
| `domain/` | 도메인별 패키지(서비스/리포지토리/모델/스키마) |
| `infra/` | DB 트랜잭션/리포지토리 베이스/외부 어댑터 |
| `workers/` | 수집/정규화/학습 워커 진입점 |
| `core/` | 설정(`config`), DB(`database`) |
| `common/` | 공통 응답(`ApiResponse`) |
| `dependencies.py` | `DbSession` 등 Depends |

## API

- Base path: 환경 변수 `API_V1_PREFIX` (기본 `/api/v1`)
- 예: `GET /api/v1/health`
- `GET /api/v1/sas/*`: 고객사 호출 오픈 API (예측/조회)
  - 필수 헤더: `X-BIZ-NO`, `X-API-KEY` (프로젝트 발급 키)
  - 누락/검증 실패 시 라우트 진입 전 `403 권한없음`
- `GET /api/v1/pas/*`: 내부 운영/관리 API (관리자 CRUD)
- OpenAPI: 서버 기동 후 `/docs`

## 린트

```powershell
ruff check .
ruff format .
```

## 의존성

`pyproject.toml`의 `[project] dependencies`가 단일 출처입니다. Docker 빌드 시에도 동일 파일로 설치하면 됩니다.
