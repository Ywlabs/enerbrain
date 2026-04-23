# EnerBrain — 시스템 패턴

## 저장소/설계 산출물

- 핵심 DDL: `work/workplan/baseline/enerbrain_database_v1.sql`
- 메모리 컨텍스트: `memory-bank/*.md`
- 구현 코드: `backend/` (FastAPI)

## 데이터 아키텍처 패턴

### 1) 운영 메타 레이어

- 조직/프로젝트/작업: `TB_SITE`, `TB_BIZ`, `TB_JOB`, `TB_JOB_RUN`
- 수집/매핑/품질: `TB_DATA_SRC`, `TB_CLCT_*`, `TB_MAPP_*`, `TB_QLTY_*`
- 모델/배포: `TB_MODEL_*`, `TB_DEPLOY`
- API 인증/운영: `TB_API_SVC`, `TB_BIZ_API_KEY`, `TB_OPEN_API_*`, `TB_API_REQ_LOG`

### 2) 실데이터 레이어

- 장비 계층: `TB_RTU` -> `TB_METER`
- 원천 수용: `TB_TS_RAW_JSON`
- 정규화 시계열: `TB_TS_FACT`
- 예측 결과: `TB_FCST_RSLT`

### 3) 코드 관리 패턴

- 코드 사전: `TB_COMM_CD(TYPE_CD, GRP_CD, CD_ID)`
- 규칙:
  - 컬럼명이 여러 테이블에서 동일하면 `TYPE_CD='COMM_CD'`
  - 테이블 전용 컬럼이면 `TYPE_CD='TB_실테이블명'`

## 수집/분석 패턴

1. `TB_DATA_SRC`에 연결정보(`CONN_CN`) 등록  
2. `TB_CLCT_JOB` 스케줄 및 워터마크(`LAST_WTMK_VAL`) 기반 증분 수집  
3. 원천 저장(`TB_TS_RAW_JSON`)  
4. 매핑/품질 처리 후 `TB_TS_FACT` 적재  
5. 학습/추론 결과를 `TB_MODEL_*`, `TB_FCST_RSLT`에 기록

## 인증 패턴

- 프로젝트 키 우선: `TB_BIZ_API_KEY` (API별 분할 대신 프로젝트 단위)
- Open API는 별도 체계: `TB_OPEN_API_KEY` + `TB_OPEN_API_KEY_SVC`
- 요청 추적: `TB_API_REQ_LOG`

## 기술적 결정

- 물리 FK는 미사용, 의미적 FK 컬럼 + 인덱스 기반
- PostgreSQL 기능 사용:
  - `JSONB`
  - `ON CONFLICT`
  - `COMMENT ON`
  - 트리거 함수(`TB_COMM_CD.MOD_DT` 자동 갱신)
