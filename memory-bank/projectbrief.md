# EnerBrain — 프로젝트 브리프

## 프로젝트명

**EnerBrain** — 에너지 데이터의 종합적 사고·분석을 담당하는 **두뇌** 역할. DB 로우 데이터 분석 및 종합 판단.

## 핵심 목표

- 데이터 기반 **AI 예측**, **AI 통계**, **상황 판단**을 **실시간 또는 배치**로 수행하는 기능을 단계적으로 구축한다.
- 기술 기준: **Python**, **FastAPI**, **PostgreSQL** 연동을 기본으로 한다.
- 폴더 구조는 **MVC에 가까운 관례**(라우트 / 서비스 / 모델 / 공통)를 따르되, 과거 Flask 예시는 **참고만** 하고 **신규로** 정리한다.

## 범위(로드맵 참고용, 즉시 전부 구현 아님)

향후 확장 시 참고하는 모듈 구분(WorkPlan baseline):

| 구분 | 역할 | 기술(참고) |
|------|------|------------|
| Inference API | 분석 결과 JSON 서빙 | FastAPI |
| Data Analyzer | 전처리·피처 엔지니어링 | Pandas, SQLAlchemy |
| Forecaster | 에너지 수요·공급 예측 | Prophet, LSTM 등 |
| Fault Detector | 이상·고장 징후 | Isolation Forest, Autoencoder 등 |
| 실시간 메시징 | 장비 데이터 수신·제어 명령 | MQTT(fastapi-mqtt / Paho) |

MSA로 쪼개기 쉬운 **이름·경계**를 유지할 것(예: 예측 vs 고장 진단 vs 스트림).

## 모델·LLM·강화학습 아티팩트

- **코드**(로더, 추론, 프롬프트): `backend/app/services/` 하위 도메인 또는 공용 `llm/` 패키지.
- **가중치·GGUF·체크포인트**: Git에 넣지 않음. 환경 변수 경로 또는 객체 저장소·공유 스토리지.
- **학습 스크립트**: `app` 밖 `training/` 또는 `scripts/` (배포 이미지와 분리).

## 진실의 원천

- 제품 방향·기능 우선순위: `work/workplan/baseline/baseline.md` 및 WorkPlan 문서.
- 구현 상태·다음 작업: 본 Memory Bank의 `progress.md`, `activeContext.md`.
