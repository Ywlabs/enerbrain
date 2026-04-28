# EnerBrain — 활성 컨텍스트

## 세션 기준 (2026-04-28)

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

## 이번 세션 반영 사항 (2026-04-28)

1. PAS 권한 고도화 1차 구현:
   - `SUPER_ADMIN` 전체 허용 + 사이트 범위(`SITE_SCOPE`) 제한
   - `pas_auth` 공통 의존성 확장(`PasUserContext`, 사이트 범위 검증 함수)
2. PAS 핵심 CRUD 1차 구현:
   - `sites`, `biz`, `analysis_items` 목록/상세/등록/수정 구현
   - `analysis_runs` 필터 조회(분석항목/상태/기간) 구현
   - `biz_api_keys`, `api_services` 목록/상세/등록/수정 구현
3. TDD 기반 테스트 확장:
   - `backend/tests/api/pas/*` 테스트 추가
   - PAS API 테스트 20건 통과 확인
4. 개발 계획 문서화:
   - `work/workplan/development/tdddevplan.md` 작성
   - `work/workplan/development/20260428.md` 작성(분석 공통 엔진 계획)
5. 운영 제약:
   - 회사 VPN 미연결 환경(재택)으로 DB 실연동 테스트 미수행
   - DB 연동 검증은 회사에서 후속 수행 예정

## 다음 작업 후보

1. 분석 공통 실행 엔진 구현:
   - `module_runner` 동적 실행(파일경로/엔트리함수)
   - `result_writer`로 `TB_ANALYSIS_RUN` 상태/결과 저장
   - 타임아웃/재시도/에러처리 공통화
2. 회사 환경 DB 연동 검증:
   - VPN 환경에서 실제 DB 접속 후 CRUD/권한/실행이력 검증
3. SAS 검증 고도화:
   - 키 상태/만료 + rate limit + `TB_API_REQ_LOG` 저장
4. SAS 로그인 감사 연계:
   - API 키 인증 성공/실패를 `TB_LOGIN_AUDIT_LOG`(`AUTH_SE_CD='SAS'`)로 적재
5. 외부 DB 1종 연동 후 간단 ML 실행:
   - 데이터 조회 -> 분석모듈 실행 -> `TB_ANALYSIS_RUN` 결과 저장

## 열린 고려사항

- 사이트 범위 권한만으로 충분한지(프로젝트 범위 권한 재도입 여부)
- SAS 테스트 기능 범위(`TB_API_SVC.TEST_REQ_JSON/TEST_RES_JSON`) 확정
- 분석결과 영구 저장 테이블 추가 필요 여부(초기에는 `TB_ANALYSIS_RUN.RUN_RSLT_JSON` 활용)
