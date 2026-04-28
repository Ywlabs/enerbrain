# PAS TDD 확장 개발 계획서 
# 기능개발 다 하고 나중에 진행한다. 

## 1. 목적

- PAS 핵심 기능의 회귀 버그를 사전에 차단하기 위해 테스트 주도 개발(TDD) 범위를 단계적으로 확장한다.
- 현재 구축된 API 테스트 기반을 중심으로, 도메인 서비스 단위 테스트와 CI 자동 검증 체계를 추가한다.
- 본 문서는 **향후 개발 항목 정의**만 다루며, 본 문서 작성 시점에는 해당 항목을 실제 구현하지 않는다.

---

## 2. 현재 기준 상태

- API 테스트(PAS) 1차 범위 구축 완료
  - `sites`, `biz`, `analysis_items`, `analysis_runs`, `biz_api_keys`, `api_services`
- 테스트 실행 기준
  - 로컬 수동 실행: `pytest`
- 미구축 항목
  - 도메인 서비스 단위 테스트(`app/domain/*/service.py`)
  - CI 자동 테스트 파이프라인
  - 실패 메시지/에러 포맷 단위 검증 강화

---

## 3. 향후 TDD 확장 항목 (개발 예정)

## 3.1 도메인 서비스 단위 테스트 확장

### 목표

- API 레벨이 아닌 서비스 레벨에서 권한 분기 및 비즈니스 규칙을 직접 검증한다.
- 문제 발생 시 API 계층 이전에서 원인 식별이 가능하도록 테스트 해상도를 높인다.

### 대상 모듈

- `app/domain/site/service.py`
- `app/domain/biz/service.py`
- `app/domain/analysis/service.py`
- `app/domain/service_api/service.py`

### 우선 검증 규칙

- 권한 분기
  - `SUPER_ADMIN` 전체 허용
  - `SITE_SCOPE` 사이트 범위 제한
- 예외 처리
  - 조회 대상 없음: `404`
  - 권한 없음: `403`
- 생성/수정 규칙
  - ID 생성 포맷
  - 필수값 누락/비정상 데이터 방어
- 보안 로직
  - API 키 발급 시 해시 저장/평문 1회 반환 규칙

### 예상 테스트 파일 구조

- `backend/tests/domain/test_site_service.py`
- `backend/tests/domain/test_biz_service.py`
- `backend/tests/domain/test_analysis_service.py`
- `backend/tests/domain/test_service_api_service.py`

---

## 3.2 API 테스트 시나리오 고도화

### 목표

- 현재 1차 API 테스트를 권한/검증/응답 표준까지 확장한다.

### 확장 항목

- 권한 케이스 강화
  - 동일 API에 대해 `SUPER_ADMIN`, `SITE_SCOPE(허용)`, `SITE_SCOPE(비허용)` 분리 검증
- 필터/쿼리 케이스 강화
  - `analysis_runs` 기간/상태/분석항목 조합 검증
- 응답 표준 검증
  - `success/message/data` 구조 일관성
  - 실패 시 `detail` 메시지 정책 확인
- 경계값 검증
  - 빈 문자열/최대 길이/잘못된 타입 입력

### 예상 추가 파일

- `backend/tests/api/pas/test_authz_matrix.py`
- `backend/tests/api/pas/test_analysis_runs_filters.py`
- `backend/tests/api/pas/test_error_response_contract.py`

---

## 3.3 테스트 데이터/fixture 체계화

### 목표

- 테스트별 중복 목킹/데이터 준비를 줄이고, 읽기 쉬운 fixture 기반으로 재구성한다.

### 확장 항목

- 공통 fixture 분리
  - `tests/fixtures/auth.py` (권한별 사용자 컨텍스트)
  - `tests/fixtures/payloads.py` (요청 바디 템플릿)
  - `tests/fixtures/repository_stubs.py` (리포지토리 목 객체)
- 공통 assertion 유틸
  - 응답 스키마 검사 유틸
  - 상태코드/메시지 검사 유틸

---

## 3.4 CI 자동 실행 파이프라인 구축

### 목표

- PR/브랜치 푸시 시 테스트 자동 실행으로 품질 게이트를 강제한다.

### 확장 항목

- GitHub Actions 워크플로 추가
  - Python 설치
  - 의존성 설치 (`pip install -e ".[dev]"`)
  - 테스트 실행 (`pytest -q`)
- 단계 분리
  - Lint 단계
  - Test 단계
- 실패 시 병합 차단 정책 연계(브랜치 보호 규칙)

### 산출물(예정)

- `.github/workflows/backend-test.yml`

---

## 3.5 리팩터링 대상(테스트 용이성 개선)

### 목표

- 서비스 함수의 테스트 난이도를 낮추기 위해 의존성 분리를 강화한다.

### 고려 항목

- ID 생성기 함수 주입 가능 구조로 분리
- 시간 의존 로직(`datetime.now`) 래핑
- 해시 함수/랜덤 키 생성기 분리
- 리포지토리 호출부 인터페이스 단순화

---

## 4. 단계별 수행 우선순위

1. 도메인 서비스 단위 테스트(`biz`, `analysis`) 우선 작성  
2. API 권한 매트릭스 테스트 확장  
3. fixture/유틸 구조 정리  
4. CI 자동 실행 파이프라인 적용  
5. 테스트 용이성 중심 리팩터링 적용

---

## 5. 완료 기준 (TDD 확장 DoD)

- 도메인 서비스 테스트 파일이 핵심 모듈별로 존재한다.
- 권한 분기(200/403/404) 시나리오가 API 및 도메인 레벨에서 모두 검증된다.
- `analysis_runs` 필터 조합 테스트가 포함된다.
- CI에서 lint/test가 자동 실행되고 실패 시 즉시 감지된다.
- 신규 기능 추가 시 테스트 선행 작성 프로세스가 팀 규칙으로 정착된다.

---

## 6. 비범위 (현재 문서 기준)

- 본 계획서에 적힌 항목의 실제 코드 구현
- DB 통합테스트(실DB/테스트컨테이너) 즉시 도입
- 성능 테스트/부하 테스트 자동화

해당 항목은 후속 계획서에서 별도 정의한다.
