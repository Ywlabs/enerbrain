# EnerBrain — 시스템 패턴

## 저장소/설계 산출물

- 기준 DDL: `work/workplan/baseline/ener_brain_database_mariadb_v1.sql`
- 기획 메모: `work/workplan/development/20260424.md`
- 메모리 컨텍스트: `memory-bank/*.md`
- 구현 코드: `backend/` (FastAPI)

## 데이터 아키텍처 패턴 (MVP)

### 1) 운영 메타 레이어

- 사이트/프로젝트: `TB_SITE`, `TB_BIZ`
- 분석항목/실행이력: `TB_ANALYSIS_ITEM`, `TB_ANALYSIS_RUN`
- 사용자/권한: `TB_USER`, `TB_USER_SITE_ROLE`
- API/로그: `TB_API_SVC`, `TB_BIZ_API_KEY`, `TB_API_REQ_LOG`
- 감사: `TB_AUDIT_LOG`

### 2) 분석 실행 패턴

1. 프로젝트별 분석항목(`TB_ANALYSIS_ITEM`) 등록  
2. 크론 주기(`CRON_EXPR_CN`)에 따라 실행대상 선택  
3. `MODULE_PATH_CN` + `ENTRY_FUNC_NM` 기반 분석 모듈 실행  
4. 실행결과를 `TB_ANALYSIS_RUN.RUN_RSLT_JSON`에 저장  

### 3) 코드 관리 패턴

- 코드 사전: `TB_COMM_CD(TYPE_CD, GRP_CD, CD_ID)`
- `GLOBAL_ROLE_CD`, `SITE_ROLE_CD`, `RUN_STTS_CD`, `KEY_STTS_CD` 등을 코드화

## 인증/권한 패턴

- SAS(고객사 API):
  - 프로젝트 키(`TB_BIZ_API_KEY`) 필수
  - 키 상태/만료 검증 후 호출 허용
- PAS(내부 운영 API):
  - JWT 기반 사용자 인증 예정
  - 권한 판정:
    - `TB_USER.GLOBAL_ROLE_CD='SUPER_ADMIN'` -> 전체 접근
    - 그 외 `TB_USER_SITE_ROLE` 매핑 사이트 범위 접근

## 기술적 결정

- 물리 FK는 사용하지 않고 의미적 FK 컬럼 + 인덱스로 운영
- DB는 MariaDB 개발 기준으로 단일화
- 백엔드 라우팅은 `api/v1/sas/*`, `api/v1/pas/*` 분리 유지
