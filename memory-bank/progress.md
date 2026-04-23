# EnerBrain — 진행 상황

## 완료된 것

- `work/workplan/baseline/enerbrain_database_v1.sql` 생성/확장 완료
- v1 DB 스키마 반영 완료:
  - 조직/프로젝트/작업
  - 수집/매핑/품질
  - RTU/계측기/시계열 원천/정형
  - 모델/배포/예측결과
  - 프로젝트 키/Open API 키/요청로그/감사로그
- 광명스마트시티 샘플 데이터(INSERT) 전 테이블 수준으로 추가 완료
- `TB_COMM_CD` 정책 반영 완료:
  - 공통 컬럼코드 -> `TYPE_CD='COMM_CD'`
  - 테이블 전용 컬럼코드 -> `TYPE_CD='TB_테이블명'`
- PostgreSQL 메타 개선 완료:
  - `COMMENT ON TABLE/COLUMN` 추가
  - `TB_COMM_CD.MOD_DT` 자동 갱신 트리거 추가

## 현재 동작 기준(설계 레벨)

- 프로젝트 키는 API 단위 분할 없이 프로젝트 단위(`TB_BIZ_API_KEY`)로 운영
- Open API는 별도 키/권한 매핑(`TB_OPEN_API_KEY`, `TB_OPEN_API_KEY_SVC`)으로 운영
- 수집 방식은 DB/API/SFTP/파일 모두 수용 가능(`TB_DATA_SRC.CONN_CN`)
- 원천 비정형 수용 + 정형 시계열 분석 분리(`TB_TS_RAW_JSON` -> `TB_TS_FACT`)

## 아직 구현 필요 (애플리케이션 레벨)

- 수집서버 커넥터 구현 (PostgreSQL/MySQL/MariaDB/SFTP)
- 매핑 규칙 실행 엔진 및 품질검증 실행기
- API 키 검증 미들웨어(해시 비교, 만료/상태 체크, rate limit)
- 예측 API 엔드포인트 및 모델 파이프라인 연동

## 알려진 주의사항

- `TB_TS_FACT.METER_NO`는 `NOT NULL`로 강제됨(중복 방지 목적)
- `TB_COMM_CD.TYPE_CD`는 `VARCHAR(40)`로 확장됨
- 평문 API 키는 DB 저장 금지(해시만 저장)

## 최신 반영 시점

- Memory Bank 동기화: **2026-04-23**
