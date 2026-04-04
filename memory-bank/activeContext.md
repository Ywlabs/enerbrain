# EnerBrain — 활성 컨텍스트

## 세션 종료 시점 (2026-04-04)

오늘 작업은 여기까지로 마무리. 다음 세션 시작 시 **`progress.md`** 와 본 파일을 먼저 읽을 것.

## 현재 초점

- **백엔드 스켈레톤** 유지: FastAPI + v1 헬스 + Settings + 선택적 PostgreSQL + `ApiResponse`.
- **저장소·문서·원격**: Git `main` + GitHub [Ywlabs/enerbrain](https://github.com/Ywlabs/enerbrain), 루트·`backend/` README, 루트 `.gitignore`.
- **규칙·기획 정리**: `.cursor/rules` EnerBrain 기준 정비, `work/workplan/baseline/`에 베이스라인·작성자 스타일·RAG 참고 노트만 유지(구 workplan 일자 폴더는 삭제됨).

## 오늘 반영된 결정·변경 (요약)

- 원격: `origin` → `https://github.com/Ywlabs/enerbrain.git`, 초기 커밋 및 README 반영분까지 push 완료.
- `work/workplan/202507`, `202606` 삭제 — 맥락은 `baseline/author_development_style.md`에 요약.
- `work/study` 삭제 — RAG 연구 요지는 `baseline/baseline_rag_notes.md`에만 유지.
- `baseline.md`에 RAG 참고 한 줄 + `backend-rules.mdc`는 Flask 레거시가 아닌 **FastAPI 실구조** 기준으로 재작성됨.

## 다음에 하기 좋은 작업

1. PostgreSQL `DATABASE_URL` 설정 후 **Alembic** 도입·첫 마이그레이션.
2. **Inference API** 스텁 + `services/inference` 연결.
3. **MQTT / 배치** 진입점·설정 훅(단계적 구현).

## 열린 고려사항

- 동기 SQLAlchemy vs 추후 **async** 엔진.
- 프론트: Vue 3 vs Grafana 등 **미정** (`.cursor/rules/frontend-rules.mdc`).
- CORS·프론트 저장소 위치.

## 업데이트 시점

기능·아키텍처·원격 저장소 변경 시 **`progress.md`** 와 함께 갱신.
