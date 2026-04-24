# EnerBrain — 활성 컨텍스트

## 세션 기준 (2026-04-24)

DB/아키텍처를 대규모 MLOps 범용형에서 **오케스트레이션 MVP 중심**으로 축소 확정했다.

## 현재 초점

- 기준 DDL: `work/workplan/baseline/ener_brain_database_mariadb_v1.sql`
- 핵심 구조: `SITE > BIZ > ANALYSIS_ITEM > ANALYSIS_RUN`
- API 경계:
  - `SAS`: 고객사 호출 API(프로젝트 키 필수)
  - `PAS`: 내부 운영 API(JWT 적용)
- 권한 모델:
  - `TB_USER.GLOBAL_ROLE_CD` 전역권한
  - `TB_USER_SITE_ROLE` 사이트 범위권한

## 이번 세션 핵심 결정

1. 대규모 시계열/모델/배포 테이블군 제거(초기 MVP에서 제외)
2. `TB_USER_ROLE` 제거, `TB_USER`에 전역권한/인증정보 통합
3. `TB_BIZ_MBR` 제거(인력관리 성격 제외)
4. `TB_API_SVC`를 고객사 제공 서비스 API 메타/테스트 전용으로 단순화
5. 로그인 감사로그 신설:
   - `TB_LOGIN_AUDIT_LOG` 추가
   - PAS 로그인 성공/실패/잠금 이벤트 DB 적재 구현
6. 로그성 테이블 PK 정책 확정:
   - `TB_API_REQ_LOG`, `TB_LOGIN_AUDIT_LOG`, `TB_AUDIT_LOG` PK는 `BIGINT UNSIGNED AUTO_INCREMENT` 사용
7. 샘플 데이터 추가:
   - `TB_SITE`, `TB_BIZ`, `TB_ANALYSIS_ITEM`, `TB_USER_SITE_ROLE`

## 다음 작업 후보

1. PAS 권한 고도화:
   - 전역/사이트 권한 판정 세분화(`SUPER_ADMIN`, `SITE_SCOPE`)
2. SAS 검증 고도화:
   - 키 상태/만료 + rate limit + `TB_API_REQ_LOG` 저장
3. SAS 로그인 감사 연계:
   - API 키 인증 성공/실패를 `TB_LOGIN_AUDIT_LOG`(`AUTH_SE_CD='SAS'`)로 적재
4. 외부 DB 1종 연동 후 간단 ML 실행:
   - 데이터 조회 -> 분석모듈 실행 -> `TB_ANALYSIS_RUN` 결과 저장
5. 분석 모듈 실행기(파일경로/엔트리함수 기반) 구현

## 열린 고려사항

- 사이트 범위 권한만으로 충분한지(프로젝트 범위 권한 재도입 여부)
- SAS 테스트 기능 범위(`TB_API_SVC.TEST_REQ_JSON/TEST_RES_JSON`) 확정
- 분석결과 영구 저장 테이블 추가 필요 여부(초기에는 `TB_ANALYSIS_RUN.RUN_RSLT_JSON` 활용)
