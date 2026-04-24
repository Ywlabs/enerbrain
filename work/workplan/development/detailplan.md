## EnerBrain 상세 작업 리스트 (MVP)

### 1) 인증/권한

- [x] PAS 로그인 API 구현 (`/api/v1/pas/auth/login`)
- [x] PAS JWT 검증 의존성 적용 (`require_pas_jwt`)
- [x] PAS me API 구현 (`/api/v1/pas/auth/me`)
- [x] 로그인 요청 파라미터 `usr_pwd` 반영
- [ ] SUPER_ADMIN / SITE_SCOPE 권한 판정 로직 추가
- [ ] JWT 만료/재발급 정책(Refresh Token) 설계

### 2) SAS 인증/보안

- [x] SAS 프로젝트 키 검증 의존성 적용
- [ ] 키 검증 실패 사유 코드화(만료/폐기/미존재)
- [ ] 요청 로그(`TB_API_REQ_LOG`) 저장 구현
- [ ] Rate Limit 적용(분당 호출 제한)

### 3) 운영 CRUD (PAS)

- [ ] 사이트 CRUD (`TB_SITE`)
- [ ] 프로젝트 CRUD (`TB_BIZ`)
- [ ] 분석항목 CRUD (`TB_ANALYSIS_ITEM`)
- [ ] 프로젝트 키 발급/폐기 (`TB_BIZ_API_KEY`)
- [ ] 서비스 API 메타 CRUD (`TB_API_SVC`)

### 4) 분석 실행 엔진

- [ ] `module_runner` 동적 실행 구현
- [ ] `scheduler` 크론 실행 구현
- [ ] 실행 결과 `TB_ANALYSIS_RUN` 저장 구현
- [ ] `RUN_RSLT_JSON` / `RUN_MODEL_JSON` 표준 키 확정

### 5) 외부 DB 연동 + ML

- [ ] 외부 DB 1종 연결 테스트
- [ ] 샘플 데이터 조회/전처리
- [ ] 간단 학습/예측 파이프라인 실행
- [ ] 모델 dump 로컬 저장 + 실행이력 기록

### 6) 운영 안정화

- [ ] `/health/db` 연결 체크 엔드포인트
- [ ] 공통 예외 포맷 표준화
- [ ] 감사로그(`TB_AUDIT_LOG`) 기록 포인트 정의
- [ ] API 문서(OpenAPI) 예시/설명 보강
