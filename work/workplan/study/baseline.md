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

## 단계별 확장 방향

1. MVP: 분석항목 등록/실행/이력 + 서비스 API 제공
2. 확장1: 외부 DB 연동 확대 + 분석모듈 다양화
3. 확장2: 시계열 정규화/모델 레지스트리/배포 전략 고도화

## 현재 우선 과제

1. PAS 로그인/JWT 인증 구현
2. SAS 키 검증 + 요청로그 저장
3. 외부 DB 1종 연동 + 간단 ML 처리
4. 분석 모듈 실행기 구현(모듈 경로/함수 기반)

