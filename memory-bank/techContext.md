# EnerBrain — 기술 컨텍스트

## 핵심 스택

- 백엔드: Python 3.11+, FastAPI, Uvicorn
- DB: PostgreSQL (운영 메타/시계열/예측 결과 저장)
- ORM/설정: SQLAlchemy 2.x, pydantic-settings

## 현재 DB 설계 상태

- 기준 파일: `work/workplan/baseline/enerbrain_database_v1.sql`
- PostgreSQL 문법 사용:
  - `JSONB`
  - `ON CONFLICT`
  - `COMMENT ON TABLE/COLUMN`
  - `plpgsql` 트리거 함수 (`TB_COMM_CD.MOD_DT` 자동 갱신)

## 수집 기술 제약/지원

- 수집 소스 타입: `DB`, `API`, `SFTP`, `FILE`, `MQTT` (코드값 기준)
- 연결 정보는 `TB_DATA_SRC.CONN_CN(JSONB)`로 저장
- 지원 범위는 수집 서버 구현에 의존:
  - PostgreSQL / MySQL / MariaDB 드라이버 분기 필요
  - 타임존/증분키/SQL 방언 차이 처리 필요

## 운영 경계 (중요)

- 수집서버 책임:
  - 원천 연결(DB/파일/SFTP/API)
  - 프로토콜 상세(Modbus 주소/채널/스케일링)
- EnerBrain 책임:
  - 원천 수용(`TB_TS_RAW_JSON`)
  - 정규화(`TB_TS_FACT`)
  - 품질/학습/예측/API 서빙

## 인증/보안

- 프로젝트 키: `TB_BIZ_API_KEY` (프로젝트 단위)
- Open API 키: `TB_OPEN_API_KEY` + 서비스권한 `TB_OPEN_API_KEY_SVC`
- 키 저장은 해시 기반(`KEY_HASH_CN`), 평문 저장 금지 원칙

## 로컬 개발 메모

- 실행 기준: `backend/.venv` 환경 사용
- DB 스키마 검증 시 PostgreSQL에서 DDL 직접 실행 후 확인
- 스키마 변경 시 `memory-bank` 문서 동기화 유지
