# EnerBrain — 활성 컨텍스트

## 현재 초점

- **백엔드 스켈레톤 완료**: FastAPI + v1 헬스 + Settings + 선택적 PostgreSQL + 공통 `ApiResponse`.
- **개발 경로 정리**: 가상환경은 **`backend/.venv` 단일 사용**, 루트 `.venv` 제거됨.

## 최근 결정사항

- Docker 시에도 **`requirements.txt` 없이 `pyproject.toml`로 설치** 가능.
- 모델·RL·LLM **아티팩트는 저장소 외부** + 코드는 `services/` 계층.

## 다음에 하기 좋은 작업

1. PostgreSQL 연결 문자열 설정 후 **첫 마이그레이션(Alembic)** 및 샘플 테이블.
2. **Inference API** 스텁 엔드포인트 + `services/inference` 연결.
3. **MQTT / 배치**는 디렉터리·설정 훅만 추가해도 됨(구현은 단계적).

## 열린 고려사항

- 동기 SQLAlchemy 유지 vs 이후 **async 엔진** 전환(부하·요구에 따라).
- **프론트**: 운영 대시보드(Vue 3 vs Grafana 등) **스택 미정** — `.cursor/rules/frontend-rules.mdc`에 방향만 기록.
- 프론트엔드 저장소 위치 및 CORS `CORS_ORIGINS` 운영 값.

## 업데이트 시점

의미 있는 기능 추가·아키텍처 변경 시 본 파일과 **`progress.md`** 를 함께 갱신할 것.
