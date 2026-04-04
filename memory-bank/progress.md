# EnerBrain — 진행 상황

## 동작하는 것

- `backend` FastAPI 앱 기동(Uvicorn / `enerbrain-serve`).
- `GET /api/v1/health` — `ApiResponse` 형식 JSON.
- Swagger UI: `/docs`.
- `pydantic-settings`, CORS, v1 라우터 집계.
- `pyproject.toml` + `readme = "README.md"` + `[project.scripts] enerbrain-serve`.
- `DATABASE_URL` 설정 시 SQLAlchemy 엔진·`SessionLocal`(미설정 시 DB 의존 라우트는 503).

## 저장소·협업

- **Git**: 브랜치 `main`, 루트 `.gitignore`(`.venv`, `.env`, `__pycache__`, `*.egg-info` 등).
- **GitHub**: [github.com/Ywlabs/enerbrain](https://github.com/Ywlabs/enerbrain) — `origin` 연동, 초기 커밋·README 포함 상태 push됨.
- **문서**: 저장소 루트 `README.md`, `backend/README.md`.

## 기획·규칙 문서 (로컬)

- `work/workplan/baseline/baseline.md` — 제품 베이스라인.
- `baseline/baseline_rag_notes.md` — RAG·LLM 확장 참고(구 `work/study` 내용 흡수).
- `baseline/author_development_style.md` — WorkPlan 기반 작성자·지시 스타일 (AI 참고).
- `.cursor/rules/` — `backend-rules.mdc`(FastAPI), `frontend-rules.mdc`, `memory-bank.mdc`.
- **삭제됨**: `work/workplan/202507`, `202606`, `work/study`(내용은 위 baseline 등에 이전).

## 아직 없음 / 미구현

- Alembic, ORM 모델·CRUD.
- Inference / Analyzer / Forecaster / Fault Detector 비즈니스 로직.
- MQTT, 배치 워커, 인증·권한.
- Docker, CI.
- 프론트엔드(스택·경로 미정).

## 알려진 이슈

- 없음(초기 단계).

## 버전 메모

- Memory Bank: **2026-04-04** 세션 종료 시점 기준으로 원격 저장소·문서·workplan 정리 반영.
