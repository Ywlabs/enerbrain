# EnerBrain — 진행 상황

## 완료된 것

- `work/workplan/baseline/ener_brain_database_mariadb_v1.sql` 재작성 완료(v2.1 MVP 축소안)
- DB 구조 단순화 완료:
  - 유지: `TB_SITE`, `TB_BIZ`, `TB_ANALYSIS_ITEM`, `TB_ANALYSIS_RUN`
  - 인증/권한: `TB_USER`, `TB_USER_SITE_ROLE`, `TB_BIZ_API_KEY`
  - API/로그: `TB_API_SVC`, `TB_API_REQ_LOG`, `TB_LOGIN_AUDIT_LOG`, `TB_AUDIT_LOG`
  - 공통코드: `TB_COMM_CD`
- 제거 완료:
  - `TB_USER_ROLE`, `TB_USER_AUTH` 별도 테이블, `TB_BIZ_MBR`
  - 기존 대규모 수집/정규화/모델/배포/OpenAPI 테이블군
- `TB_USER` 인증 통합 완료:
  - `PW_HASH_CN`, `PW_ALGO_CD`, `FAIL_NOCS`, `LAST_LOGIN_DT`, `PW_CHG_DT`, `LOCK_DT`
- `TB_API_SVC` 단순화 완료:
  - 고객사 제공용 서비스 API 메타/테스트 전용
  - `TEST_REQ_JSON`, `TEST_RES_JSON` 포함
- 샘플 데이터 반영 완료:
  - `TB_SITE`, `TB_BIZ`, `TB_ANALYSIS_ITEM`, `TB_USER_SITE_ROLE`
  - `SUPER_ADMIN`, 사이트 운영자 샘플 계정 포함
- PAS 로그인/JWT 1차 구현 완료:
  - `POST /api/v1/pas/auth/login`
  - `GET /api/v1/pas/auth/me`
- PAS 권한/CRUD 1차 확장 완료:
  - 권한 컨텍스트 공통화(`PasUserContext`)
  - `SUPER_ADMIN` 전체 접근 + 사이트 범위 제한 분기 적용
  - `sites`, `biz`, `analysis_items`, `biz_api_keys`, `api_services` CRUD(목록/상세/등록/수정) 구현
  - `analysis_runs` 필터 조회 구현(`analysis_item_no`, `run_stts_cd`, 기간)
- Swagger 문서 보강 완료:
  - PAS 주요 API 요약/파라미터 설명/요청 예시 추가
- 테스트 기반 구축 완료:
  - `pytest` dev 의존성 추가
  - `backend/tests/api/pas` 테스트 작성 및 실행 완료
  - PAS API 테스트 총 20건 통과
- 개발 계획 문서화 완료:
  - `work/workplan/development/tdddevplan.md`
  - `work/workplan/development/20260428.md` (분석 공통 엔진 계획)
- PAS 로그인 감사로그 적재 구현 완료:
  - 성공/실패/잠금 이벤트를 `TB_LOGIN_AUDIT_LOG`에 저장
- 로그성 PK 정책 반영 완료:
  - `TB_API_REQ_LOG.API_REQ_LOG_NO` = `AUTO_INCREMENT`
  - `TB_LOGIN_AUDIT_LOG.LOGIN_AUDIT_LOG_NO` = `AUTO_INCREMENT`
  - `TB_AUDIT_LOG.AUDIT_LOG_NO` = `AUTO_INCREMENT`

## 현재 동작 기준(구현 레벨)

- SAS 인증: 프로젝트 키(`TB_BIZ_API_KEY`) 기반
- PAS 인증: JWT 기반 동작, 사용자/권한 원천은 `TB_USER` + `TB_USER_SITE_ROLE`
- 전체관리자: `TB_USER.GLOBAL_ROLE_CD='SUPER_ADMIN'`로 전체 사이트 접근
- 사이트관리자: `TB_USER_SITE_ROLE` 매핑 사이트 범위만 접근

## 아직 구현 필요 (애플리케이션 레벨)

- SAS 키 검증 + rate limit + 요청로그 저장 고도화
- SAS 인증 이벤트(`AUTH_SE_CD='SAS'`) 로그인 감사로그 연계
- 분석 모듈 실행기 구현(파일경로/엔트리함수 실행)
- 외부 DB 1종 연동 + 간단 ML 처리 + `TB_ANALYSIS_RUN` 결과 저장

## 알려진 주의사항

- 비밀번호/API 키 평문 저장 금지(해시만 저장)
- 샘플 해시는 예시값이므로 운영 전 실제 해시로 교체 필요
- 물리 FK 미사용 정책이므로 애플리케이션 레벨 무결성 체크 필요
- 재택 환경에서는 회사 VPN 미연결로 DB 실연동 테스트가 불가함
- DB 연동 검증(실DB CRUD/실행이력)은 회사 출근 후 수행 예정

## 최신 반영 시점

- Memory Bank 동기화: **2026-04-28**
