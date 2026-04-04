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
| `core/` | 설정(`config`), DB(`database`) |
| `common/` | 공통 응답(`ApiResponse`) |
| `dependencies.py` | `DbSession` 등 Depends |

## API

- Base path: 환경 변수 `API_V1_PREFIX` (기본 `/api/v1`)
- 예: `GET /api/v1/health`
- OpenAPI: 서버 기동 후 `/docs`

## 린트

```powershell
ruff check .
ruff format .
```

## 의존성

`pyproject.toml`의 `[project] dependencies`가 단일 출처입니다. Docker 빌드 시에도 동일 파일로 설치하면 됩니다.
