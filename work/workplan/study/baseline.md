# EnerBrain Baseline (현행화)

## 프로젝트 정의

- 프로젝트명: EnerBrain
- 목적: 고객사별 분석 작업을 중앙에서 실행/관리하는 오케스트레이션 플랫폼
- 개발 중심: Python + FastAPI + MariaDB

## 현재 기준 아키텍처

- API 경계
  - `SAS`: 고객사 호출 API (프로젝트 키 기반)
  - `PAS`: 내부 운영 API (JWT 예정)
- 핵심 데이터 모델
  - `SITE > BIZ > ANALYSIS_ITEM > ANALYSIS_RUN`
- 권한 모델
  - `TB_USER.GLOBAL_ROLE_CD`(전역권한)
  - `TB_USER_SITE_ROLE`(사이트 범위권한)

## 현재 기준 DB

- 기준 파일: `work/workplan/baseline/ener_brain_database_mariadb_v1.sql`
- 상태: MVP 축소안 확정, 샘플 데이터 포함

## PK/순번 컬럼 생성 규칙 (필수)

- 기본 원칙
  - 로그성/이력성/감사성 테이블의 PK는 `BIGINT UNSIGNED AUTO_INCREMENT`를 기본으로 사용한다.
  - 사람이 읽는 식별자 문자열(`..._NO`)는 업무 엔터티 테이블에만 사용하고, 로그성 테이블에는 강제하지 않는다.
- 적용 대상(현재 확정)
  - `TB_API_REQ_LOG.API_REQ_LOG_NO`: `AUTO_INCREMENT`
  - `TB_LOGIN_AUDIT_LOG.LOGIN_AUDIT_LOG_NO`: `AUTO_INCREMENT`
  - `TB_AUDIT_LOG.AUDIT_LOG_NO`: `AUTO_INCREMENT`
- 코드 구현 규칙
  - `AUTO_INCREMENT` PK는 애플리케이션에서 번호 생성 로직을 작성하지 않는다.
  - INSERT SQL에서 PK 컬럼은 제외하고, DB가 순번을 부여하도록 한다.
  - PK 값을 후속 처리에 사용해야 하면 `lastrowid` 또는 재조회로 취득한다.
- 스키마 작성 규칙
  - 로그 테이블 신규 추가 시 PK는 아래 형태를 표준으로 사용한다.
    - 예: `<PK컬럼명> BIGINT UNSIGNED NOT NULL AUTO_INCREMENT`
  - 정렬/조회 성능을 위해 `REQ_DT` 또는 `REG_DT` 기준 인덱스를 반드시 추가한다.
- 금지 규칙
  - 로그성 테이블 PK를 `yyyymmddhhmmss` 단독 문자열 규칙으로 생성하지 않는다.
  - 로그성 테이블 PK를 난수/접두어 조합 문자열로 직접 생성하지 않는다.

## 단계별 확장 방향

1. MVP: 분석항목 등록/실행/이력 + 서비스 API 제공
2. 확장1: 외부 DB 연동 확대 + 분석모듈 다양화
3. 확장2: 시계열 정규화/모델 레지스트리/배포 전략 고도화

## 현재 우선 과제

1. PAS 로그인/JWT 인증 구현
2. SAS 키 검증 + 요청로그 저장
3. 외부 DB 1종 연동 + 간단 ML 처리
4. 분석 모듈 실행기 구현(모듈 경로/함수 기반)

