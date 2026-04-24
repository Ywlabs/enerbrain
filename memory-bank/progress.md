# EnerBrain — 진행 상황

## 완료된 것

- `work/workplan/baseline/ener_brain_database_mariadb_v1.sql` 재작성 완료(v2.1 MVP 축소안)
- DB 구조 단순화 완료:
  - 유지: `TB_SITE`, `TB_BIZ`, `TB_ANALYSIS_ITEM`, `TB_ANALYSIS_RUN`
  - 인증/권한: `TB_USER`, `TB_USER_SITE_ROLE`, `TB_BIZ_API_KEY`
  - API/로그: `TB_API_SVC`, `TB_API_REQ_LOG`, `TB_AUDIT_LOG`
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

## 현재 동작 기준(설계 레벨)

- SAS 인증: 프로젝트 키(`TB_BIZ_API_KEY`) 기반
- PAS 인증: 내부 JWT 예정, 사용자/권한 원천은 `TB_USER` + `TB_USER_SITE_ROLE`
- 전체관리자: `TB_USER.GLOBAL_ROLE_CD='SUPER_ADMIN'`로 전체 사이트 접근
- 사이트관리자: `TB_USER_SITE_ROLE` 매핑 사이트 범위만 접근

## 아직 구현 필요 (애플리케이션 레벨)

- PAS 로그인/JWT 발급/검증 구현
- PAS 권한 판정(전역/사이트 범위) 구현
- SAS 키 검증 + rate limit + 요청로그 저장 고도화
- 분석 모듈 실행기 구현(파일경로/엔트리함수 실행)
- 외부 DB 1종 연동 + 간단 ML 처리 + `TB_ANALYSIS_RUN` 결과 저장

## 알려진 주의사항

- 비밀번호/API 키 평문 저장 금지(해시만 저장)
- 샘플 해시는 예시값이므로 운영 전 실제 해시로 교체 필요
- 물리 FK 미사용 정책이므로 애플리케이션 레벨 무결성 체크 필요

## 최신 반영 시점

- Memory Bank 동기화: **2026-04-24**
