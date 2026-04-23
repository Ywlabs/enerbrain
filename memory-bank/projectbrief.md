# EnerBrain — 프로젝트 브리프

## 프로젝트명

**EnerBrain** — 고객사별 에너지 데이터를 수집·정규화·예측·서빙하는 멀티테넌트 분석 플랫폼.

## 핵심 목표

- 고객사(`SITE`) / 프로젝트(`BIZ`) 단위로 에너지 데이터를 운영하고, 예측 API를 제공한다.
- 데이터 수집 소스(DB/API/SFTP/파일)를 유연하게 수용하되 내부 분석 레이어는 표준화한다.
- 시계열 데이터 기반 D+1 예측(발전량/소비량)과 모델 운영(학습/평가/배포)을 체계화한다.
- 프로젝트 단위 API 키를 발급·관리하여 고객사 개발 연동을 단순화한다.

## 현재 확정 범위 (v1 DDL 기준)

- 멀티테넌트 기본 모델: `SITE > BIZ > JOB`
- 수집/매핑/품질: `TB_DATA_SRC`, `TB_CLCT_*`, `TB_MAPP_*`, `TB_QLTY_*`
- 시계열 실데이터: `TB_RTU`, `TB_METER`, `TB_TS_RAW_JSON`, `TB_TS_FACT`
- 예측/모델: `TB_MODEL_*`, `TB_DEPLOY`, `TB_FCST_RSLT`
- API 인증/운영: `TB_API_SVC`, `TB_BIZ_API_KEY`, `TB_OPEN_API_*`, `TB_API_REQ_LOG`
- 공통코드: `TB_COMM_CD` (`TYPE_CD`/`GRP_CD` 정책 반영)

## 현재 기준 문서/산출물

- 설계 원본: `work/workplan/baseline/enerbrain_database_v1.sql`
- 제품/기획 기준: `work/workplan/study/baseline.md`
- 메모리 문서: `memory-bank/*.md`

## 진실의 원천

- DB 설계/샘플 데이터: `work/workplan/baseline/enerbrain_database_v1.sql`
- 구현 상태·할 일: `memory-bank/progress.md`, `memory-bank/activeContext.md`
- 공개 저장소: **https://github.com/Ywlabs/enerbrain**
