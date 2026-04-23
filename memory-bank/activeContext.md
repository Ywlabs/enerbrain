# EnerBrain — 활성 컨텍스트

## 세션 기준 (2026-04-23)

이번 세션에서 DB 설계 산출물을 MariaDB 개발 기준으로 확정하고, 백엔드 API 경계 및 패키지 구조를 1차 정리했다.

## 현재 초점

- MariaDB 개발 기준 DDL 확정:
  - `work/workplan/baseline/ener_brain_database_mariadb_v1.sql`
  - 테이블 COMMENT + 주요 컬럼 COMMENT 후행 반영 섹션 추가
- API 경계 확정:
  - `SAS`: 고객사 호출 오픈 API
  - `PAS`: 내부 운영/관리 API
- `backend/app/api/v1/sas/*`, `backend/app/api/v1/pas/*` 라우팅 분리 반영
- `SAS` 라우트 단 강제 키 검증 적용:
  - 헤더 `X-BIZ-NO`, `X-API-KEY` 필수
  - 실패 시 `403 권한없음`

## 이번 세션 핵심 결정

1. 멀티테넌트 구조: `SITE > BIZ > JOB`
2. 장비 계층: `RTU > METER`
3. 소스 수집 정책:
   - DB 직접 수집 가능
   - 불가 시 SFTP/CSV 대안 허용
4. 매핑 정책:
   - 원천 -> 표준 지표 코드 매핑을 설정으로 관리
5. 인증 정책:
   - 프로젝트 키는 API 단위 분할 없이 프로젝트 단위 관리
   - `SAS`는 프로젝트 키 기반 인증 강제
   - `PAS`는 내부 JWT(관리자 세션) 적용 예정
6. 백엔드 구조 정책:
   - 초기에는 Python/FastAPI 단일 스택으로 진행
   - `domain/infra/workers` 스캐폴드 생성 완료

## 다음 작업 후보

1. 외부 DB 연동(우선 1개 소스) 구현:
   - 연결 테스트 -> 원천 수집 -> `TB_TS_RAW_JSON` 저장
2. 간단 ML 처리(베이스라인) 연결:
   - `TB_TS_FACT` 조회 -> 간단 학습/예측 -> `TB_FCST_RSLT` 저장
3. `PAS` 내부 JWT 인증/권한 최소 구현:
   - 로그인(ID/PW) -> 토큰 발급 -> 라우트 보호
4. `SAS` 키 검증 로직 고도화:
   - 상태/만료 외 rate limit, 요청 로그(`TB_API_REQ_LOG`) 반영

## 열린 고려사항

- 키 로테이션 무중단 정책(유예기간 컬럼 추가 여부)
- 대용량 고객 분리 전략(공유 테이블 vs 전용 분리 기준)
- 재학습 주기(일/주/드리프트 기반) 정책 확정
- `TB_USER` 기반 권한 모델 확장 방식:
  - 전역 관리자/사이트 관리자/프로젝트 관리자 역할 테이블 추가 여부
