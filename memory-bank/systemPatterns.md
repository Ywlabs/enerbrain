# EnerBrain — 시스템 패턴

## 저장소 레이아웃(요약)

- **`backend/`** — FastAPI 애플리케이션 루트(`pyproject.toml`, `app/`).
- **프론트** — 저장소 내 경로는 스택 확정 후 정함(대시보드 목적만 합의).
- **`work/workplan/`** — 기획·설계·베이스라인(코드 아님).
- **`memory-bank/`** — 세션 간 컨텍스트(본 문서들).
- **`.cursor/rules/`** — EnerBrain용 백엔드·프론트·Memory Bank 규칙.

## 백엔드 앱 구조 (`backend/app/`)

| 영역 | 역할 |
|------|------|
| `main.py` | `create_app()`, **lifespan**, CORS, v1 라우터 마운트 |
| `api/v1/` | HTTP 라우터만(Controller에 해당) |
| `services/` | 비즈니스·도메인 로직(추론·전처리·예측 등 확장) |
| `models/` | SQLAlchemy ORM (`Base`는 `core.database`) |
| `schemas/` | Pydantic 요청/응답 |
| `core/` | `config.py`(Settings), `database.py`(엔진·SessionLocal) |
| `common/` | 공통 응답 래퍼 등 |
| `dependencies.py` | `DbSession` 등 `Annotated[..., Depends(...)]` 패턴 |

## 채택한 FastAPI 관행

- **`lifespan`**으로 시작/종료 훅(구 `on_event` 대신).
- **`pydantic-settings`**로 환경 설정.
- DB 세션은 **`dependencies.get_db`** → 라우트에서 `DbSession`; `DATABASE_URL` 없으면 **503**.
- 개발 서버: **`uvicorn`**, 선택적 콘솔 스크립트 **`enerbrain-serve`**(`app/cli.py`).

## API 규칙

- v1 베이스: 설정값 `API_V1_PREFIX`(기본 `/api/v1`).
- 헬스: `GET /api/v1/health` → `ApiResponse`.

## 향후 확장 시 패턴

- 새 도메인 → `api/v1/<feature>.py` + `services/<feature>/`.
- MQTT·워커 → `app` 옆 별도 패키지 또는 `workers/`로 진입점 분리(추가 시 `progress.md` 반영).
- Docker 빌드 시 **`pyproject.toml` 기준 `pip install`** 으로 충분(`requirements.txt` 필수 아님).
