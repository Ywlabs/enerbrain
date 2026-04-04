# EnerBrain — 기술 컨텍스트

## 런타임

- **Python**: 3.11+ 권장(`pyproject.toml` `requires-python`).
- **패키지 정의**: `backend/pyproject.toml`의 `[project] dependencies`가 단일 출처.

## 주요 의존성

- **FastAPI** — 웹 API.
- **Uvicorn[standard]** — ASGI 서버(개발 시 `--reload` = 핫 리로드).
- **pydantic-settings** — `.env` 로딩.
- **SQLAlchemy 2.x** — ORM.
- **psycopg[binary]** — PostgreSQL 드라이버(연결 문자열 예: `postgresql+psycopg://...`).

개발 옵션: `[project.optional-dependencies] dev` — httpx, ruff.

## 로컬 개발

1. 디렉터리: **`d:\Devlop\enerbrain\backend`**
2. 가상환경: **`backend\.venv`만 사용**(저장소 루트 `.venv`는 사용하지 않음).
3. 설치: `pip install -e ".[dev]"`
4. 실행 예:
   - `.\.venv\Scripts\python.exe -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000`
   - 또는 venv 활성화 후 `enerbrain-serve`

전역 Python(예: Python 3.14 단독)에는 uvicorn이 없을 수 있음 → **반드시 `backend\.venv`의 python** 사용.

## 설정

- **`backend/.env`** (git 제외) — 실제 비밀·URL.
- **`backend/.env.example`** — 키 목록 샘플.
- **`app/core/config.py`** — `Settings` 필드와 검증.

## 제약·주의

- DB 미구성 시 `DbSession` 사용 라우트는 503.
- 대용량 모델 파일은 저장소에 커밋하지 않음(경로는 환경 변수).

## Git·원격

- 기본 브랜치: **`main`**.
- 원격: **`https://github.com/Ywlabs/enerbrain.git`** (`origin`).

## Cursor 규칙 파일

- **`.cursor/rules/backend-rules.mdc`** — **FastAPI·`backend/app` 실구조** 기준으로 정리됨(Flask 레거시 아님).
- **`.cursor/rules/frontend-rules.mdc`**, **`memory-bank.mdc`** — EnerBrain 맥락 명시.
