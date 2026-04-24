# EnerBrain — 기술 컨텍스트

## 핵심 스택

- 백엔드: Python 3.11+, FastAPI, Uvicorn
- DB: MariaDB
- ORM/설정: SQLAlchemy 2.x, pydantic-settings

## 현재 DB 설계 상태

- 기준 파일: `work/workplan/baseline/ener_brain_database_mariadb_v1.sql` (v2.1)
- 특성:
  - 오케스트레이션 MVP 중심 테이블만 유지
  - 사용자/인증 통합(`TB_USER`)
  - API 서비스 메타(`TB_API_SVC`) + 테스트 JSON 저장
  - 샘플 데이터 포함(`SITE/BIZ/ANALYSIS_ITEM/USER_SITE_ROLE`)

## 실행/연동 기술 포인트

- 분석항목 실행:
  - `TB_ANALYSIS_ITEM.MODULE_PATH_CN`
  - `TB_ANALYSIS_ITEM.ENTRY_FUNC_NM`
  - `TB_ANALYSIS_ITEM.PARAMS_JSON`
- 실행 이력:
  - `TB_ANALYSIS_RUN`에 상태/시간/결과 JSON 저장
- 외부 DB 연동:
  - 우선 1개 소스(PostgreSQL 또는 MariaDB)부터 연결 테스트

## 인증/보안

- SAS:
  - 프로젝트 키(`TB_BIZ_API_KEY`) 기반 인증
  - 키 해시 저장, 평문 저장 금지
- PAS:
  - JWT 기반 인증 예정
  - 전역권한(`GLOBAL_ROLE_CD`) + 사이트권한(`TB_USER_SITE_ROLE`) 조합

## 로컬 개발 메모

- 실행 기준: `backend/.venv`
- API 경계:
  - `api/v1/sas/*` = 고객사 호출
  - `api/v1/pas/*` = 내부 운영
- 스키마 변경 시 `work` + `memory-bank` 동시 동기화
