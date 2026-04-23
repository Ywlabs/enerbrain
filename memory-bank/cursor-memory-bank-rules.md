# Cursor Memory Bank Rules (EnerBrain)

## 1) 읽기 순서 (필수)

모든 세션 시작 시 아래 순서로 읽고 시작한다.

1. `projectbrief.md`
2. `productContext.md`
3. `systemPatterns.md`
4. `techContext.md`
5. `activeContext.md`
6. `progress.md`

## 2) 업데이트 트리거

아래 조건이면 memory-bank를 반드시 갱신한다.

- DB 구조/테이블/키 정책 변경
- 수집 방식(DB/API/SFTP/FILE) 결정 변경
- 인증/권한 정책 변경
- 사용자의 "memory-bank 업데이트" 요청

## 3) 이번 프로젝트 고정 규칙 (중요)

### 3-1. DB 설계 원칙

- 기준 파일: `work/workplan/baseline/enerbrain_database_v1.sql`
- 물리 FK는 사용하지 않고 의미적 FK 컬럼 + 인덱스로 관리
- PostgreSQL 문법 사용: `JSONB`, `ON CONFLICT`, `COMMENT ON`, 트리거

### 3-2. 코드 테이블 규칙 (`TB_COMM_CD`)

- `TYPE_CD`, `GRP_CD`는 기본적으로 **물리 테이블명/컬럼명**을 사용
- 단, 여러 테이블에서 공통으로 쓰는 컬럼만 `TYPE_CD='COMM_CD'` 사용
- 현재 공통(`COMM_CD`)로 관리하는 대표 그룹:
  - `STTS_CD`, `KEY_STTS_CD`, `QLTY_STTS_CD`, `METRIC_CD`

### 3-3. 수집/정규화 패턴

- 원천 수용: `TB_TS_RAW_JSON`
- 정규화 저장: `TB_TS_FACT`
- 장비 계층: `TB_RTU > TB_METER`
- 수집 워터마크: `TB_CLCT_JOB.LAST_WTMK_VAL`, `LAST_SUCC_CLCT_DT`

### 3-4. API 키 정책

- 프로젝트 키: `TB_BIZ_API_KEY` (프로젝트 단위, API 단위 분할 아님)
- Open API 키: `TB_OPEN_API_KEY` + `TB_OPEN_API_KEY_SVC`
- 평문 키 DB 저장 금지, 해시(`KEY_HASH_CN`)만 저장

## 4) 문서 작성 규칙

- 한국어로 작성
- 변경 사실 + 이유 + 다음 액션을 같이 기록
- 실제 파일 경로/테이블명/컬럼명을 정확히 기재
- 중복/구식 내용은 제거하고 최신 기준으로 덮어쓴다

## 5) 세션 종료 전 체크리스트

- `activeContext.md`: 이번 세션 결정/다음 작업 반영
- `progress.md`: 완료/미완료/주의사항 반영
- 나머지 문서(`projectbrief`, `productContext`, `systemPatterns`, `techContext`) 일관성 확인