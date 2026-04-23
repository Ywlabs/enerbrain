# EnerBrain — 진행 상황

## 완료된 것

- `work/workplan/baseline/enerbrain_database_v1.sql` 생성/확장 완료
- `work/workplan/baseline/ener_brain_database_mariadb_v1.sql` 생성 완료
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
- MariaDB 메타 보완 완료:
  - 테이블 COMMENT 일괄 반영 섹션 추가
  - 주요 컬럼 COMMENT 반영 및 호환 오류(`MODIFY ... CHECK`) 제거
- 백엔드 API 구조 반영 완료:
  - `api/v1/sas/*`, `api/v1/pas/*` 분리
  - `SAS=고객사 오픈 API`, `PAS=내부 운영 API` 역할 확정
- `SAS` 라우트 접근 제어 반영 완료:
  - `X-BIZ-NO`, `X-API-KEY` 필수
  - 실패 시 라우트 단 `403 권한없음`
- 백엔드 패키지 스캐폴드 확장 완료:
  - `domain/*`, `infra/*`, `workers/*`, `core/common` 보강

## 현재 동작 기준(설계 레벨)

- 프로젝트 키는 API 단위 분할 없이 프로젝트 단위(`TB_BIZ_API_KEY`)로 운영
- Open API는 별도 키/권한 매핑(`TB_OPEN_API_KEY`, `TB_OPEN_API_KEY_SVC`)으로 운영
- 수집 방식은 DB/API/SFTP/파일 모두 수용 가능(`TB_DATA_SRC.CONN_CN`)
- 원천 비정형 수용 + 정형 시계열 분석 분리(`TB_TS_RAW_JSON` -> `TB_TS_FACT`)
- API 경계:
  - `SAS`: 고객사 호출 API(프로젝트 키 필수)
  - `PAS`: 내부 운영 API(JWT 인증 예정)

## 아직 구현 필요 (애플리케이션 레벨)

- 수집서버 커넥터 구현 (PostgreSQL/MySQL/MariaDB/SFTP)
- 매핑 규칙 실행 엔진 및 품질검증 실행기
- `SAS` API 키 검증 고도화(rate limit, 요청로그 저장)
- 예측 API 엔드포인트 및 모델 파이프라인 연동
- `PAS` 내부 인증/인가 구현(JWT + `TB_USER` 기반 역할)
- 외부 DB 연동 후 간단 ML 베이스라인 학습/예측 플로우 구현

## 알려진 주의사항

- `TB_TS_FACT.METER_NO`는 `NOT NULL`로 강제됨(중복 방지 목적)
- `TB_COMM_CD.TYPE_CD`는 `VARCHAR(40)`로 확장됨
- 평문 API 키는 DB 저장 금지(해시만 저장)

## 최신 반영 시점

- Memory Bank 동기화: **2026-04-23**
