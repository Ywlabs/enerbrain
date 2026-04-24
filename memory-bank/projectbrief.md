# EnerBrain — 프로젝트 브리프

## 프로젝트명

**EnerBrain** — 고객사별 에너지 데이터를 수집·정규화·예측·서빙하는 멀티테넌트 분석 플랫폼.

## 핵심 목표

- 고객사(`SITE`) / 프로젝트(`BIZ`) 단위 분석항목을 중앙에서 실행·관리한다.
- 프로젝트별 분석 모듈(파이썬 파일)과 실행주기(cron)를 설정 기반으로 운영한다.
- 프로젝트 단위 API 키를 발급·관리하여 고객사 연동을 단순화한다.
- 내부 운영자는 PAS API로 사이트/프로젝트/분석항목을 관리한다.

## 현재 확정 범위 (v2.1 DDL 기준)

- 멀티테넌트 기본 모델: `SITE > BIZ > ANALYSIS_ITEM`
- 분석 실행 이력: `TB_ANALYSIS_RUN`
- 사용자/권한: `TB_USER`, `TB_USER_SITE_ROLE`
- API 인증/운영: `TB_API_SVC`, `TB_BIZ_API_KEY`, `TB_API_REQ_LOG`
- 공통/감사: `TB_COMM_CD`, `TB_AUDIT_LOG`
- API 구분: `SAS`(고객사 오픈), `PAS`(내부 운영)

## 현재 기준 문서/산출물

- 설계 기준: `work/workplan/baseline/ener_brain_database_mariadb_v1.sql`
- 개발 계획: `work/workplan/development/20260424.md`
- 제품/기획 기준: `work/workplan/study/baseline.md`
- 메모리 문서: `memory-bank/*.md`

## 진실의 원천

- DB 설계/샘플 데이터: `work/workplan/baseline/ener_brain_database_mariadb_v1.sql`
- 구현 상태·할 일: `memory-bank/progress.md`, `memory-bank/activeContext.md`
- 공개 저장소: **https://github.com/Ywlabs/enerbrain**
