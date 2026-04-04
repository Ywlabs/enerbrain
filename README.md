# EnerBrain

에너지 데이터의 종합적 사고·분석을 담당하는 **두뇌** 역할을 목표로 하는 프로젝트입니다. DB 로우 데이터 분석, AI 예측·통계, 상황 판단 등을 **실시간 또는 배치**로 확장해 나갈 예정입니다.

**원격 저장소:** [github.com/Ywlabs/enerbrain](https://github.com/Ywlabs/enerbrain)

---

## 기술 스택 (현재)

| 영역 | 내용 |
|------|------|
| 백엔드 | Python 3.11+, [FastAPI](https://fastapi.tiangolo.com/), Uvicorn |
| DB | PostgreSQL 연동 예정 (`psycopg` / SQLAlchemy 2.x) |
| 설정 | `pydantic-settings`, `.env` |

프론트엔드(운영 대시보드)는 **Vue 3 커스텀 vs Grafana 등** 검토 단계입니다. (`.cursor/rules/frontend-rules.mdc` 참고)

---

## 저장소 구조

```
enerbrain/
├── backend/              # FastAPI 애플리케이션 (pyproject.toml, app/)
├── memory-bank/          # 프로젝트 컨텍스트 문서 (Cursor / 협업용)
├── work/workplan/baseline/  # 기획 베이스라인·RAG 참고 노트 등
└── .cursor/rules/        # Cursor 규칙 (백엔드·프론트·Memory Bank)
```

상세 아키텍처는 `memory-bank/systemPatterns.md`, 제품 방향은 `memory-bank/productContext.md`를 참고하세요.

---

## 빠른 시작 (백엔드)

```powershell
cd backend
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -e ".[dev]"
```

실행 (택 1):

```powershell
# 가상환경 활성화 후
python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

# 또는 (pip install -e . 이후)
enerbrain-serve
```

- API 문서: http://127.0.0.1:8000/docs  
- 헬스: http://127.0.0.1:8000/api/v1/health  

**주의:** 반드시 **`backend` 폴더**에서 실행하고, 시스템 전역 Python이 아니라 **`backend\.venv`** 의 Python을 사용하세요.

---

## 환경 변수

`backend/.env.example`을 복사해 `backend/.env`를 만듭니다.

- `DATABASE_URL` — 예: `postgresql+psycopg://user:password@localhost:5432/enerbrain` (미설정 시 DB 세션 의존 API는 503)
- `CORS_ORIGINS` — 프론트 개발 서버 주소 등 (JSON 배열 또는 콤마 구분)

---

## 기획·참고 문서

- `work/workplan/baseline/baseline.md` — 프로젝트 베이스라인
- `work/workplan/baseline/baseline_rag_notes.md` — RAG·LLM 확장 시 참고
- `work/workplan/baseline/author_development_style.md` — 작업 지시·문서화 스타일 (AI 협업용)

---

## 라이선스

미정 — 조직 정책에 맞게 추후 명시합니다.
