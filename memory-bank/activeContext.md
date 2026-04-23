# EnerBrain — 활성 컨텍스트

## 세션 기준 (2026-04-23)

이번 세션에서 DB 설계/샘플 데이터/코드정책을 집중 확정했다.

## 현재 초점

- `work/workplan/baseline/enerbrain_database_v1.sql`을 v1 기준 설계 산출물로 확정
- 프로젝트 단위 API 키 운영 정책 확정 (`TB_BIZ_API_KEY`)
- 수집·정규화·예측 데이터 흐름을 실제 테이블로 확장 (`TB_TS_RAW_JSON`, `TB_TS_FACT`, `TB_FCST_RSLT`)
- `TB_COMM_CD` 운영 규칙 정교화 (`COMM_CD` vs `TB_테이블명` 구분)

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
6. PostgreSQL 코멘트/트리거 반영:
   - `COMMENT ON ...`
   - `TB_COMM_CD.MOD_DT` 자동 갱신 트리거

## 다음 작업 후보

1. 수집 서버 구현(멀티 DB + SFTP 커넥터)
2. 매핑 설정 UI/검증 로직 구현
3. API 키 검증 미들웨어 구현(Bearer/X-API-Key)
4. `TB_TS_FACT` 파티셔닝 전략 확정(월 단위 등)

## 열린 고려사항

- 키 로테이션 무중단 정책(유예기간 컬럼 추가 여부)
- 대용량 고객 분리 전략(공유 테이블 vs 전용 분리 기준)
- 재학습 주기(일/주/드리프트 기반) 정책 확정
