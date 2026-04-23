-- EnerBrain Database V1 (MariaDB)
-- 작성 목적:
-- 1) SITE > BIZ(프로젝트) > JOB(태스크) 중심 구조
-- 2) 물리 FK 미사용, 의미적 FK 컬럼/인덱스 기반
-- 3) 프로젝트별 API 키 + Open API 키 분리 관리

CREATE DATABASE IF NOT EXISTS enerbrain
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_general_ci;
USE enerbrain;

-- =====================================================================
-- 00. 공통 코드
-- =====================================================================

-- 회사 공통 표준 단일 코드 테이블
CREATE TABLE IF NOT EXISTS TB_COMM_CD (
    TYPE_CD             VARCHAR(40) NOT NULL,                             -- 테이블명(분류 대분류)
    GRP_CD              VARCHAR(20) NOT NULL,                             -- 컬럼명(분류 그룹)
    CD_ID               VARCHAR(50) NOT NULL,                             -- 코드ID
    CD_NM               VARCHAR(20) NOT NULL,                             -- 코드명
    EXPLN               VARCHAR(100) NOT NULL,                            -- 설명
    SORT_ORD            DECIMAL(10,0) NOT NULL,                           -- 정렬순서
    REG_DT              DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,      -- 생성일시
    REG_USER_ID         DECIMAL(10,0) NOT NULL DEFAULT 0,                 -- 생성자
    MOD_DT              DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,      -- 수정일시
    MOD_USER_ID         DECIMAL(10,0) NOT NULL DEFAULT 0,                 -- 수정자
    DEL_YN              CHAR(1) NOT NULL DEFAULT 'N' CHECK (DEL_YN IN ('Y','N')), -- 삭제여부
    PRIMARY KEY (TYPE_CD, GRP_CD, CD_ID)
) ENGINE=InnoDB COMMENT='시스템공통코드';
CREATE INDEX IX_TB_COMM_CD_01 ON TB_COMM_CD (GRP_CD);

DROP TRIGGER IF EXISTS TRG_SET_TB_COMM_CD_MOD_DT;
DELIMITER //
CREATE TRIGGER TRG_SET_TB_COMM_CD_MOD_DT
BEFORE UPDATE ON TB_COMM_CD
FOR EACH ROW
BEGIN
    SET NEW.MOD_DT = CURRENT_TIMESTAMP;
END//
DELIMITER ;

-- =====================================================================
-- 01. 사용자 / 고객사 / 프로젝트
-- =====================================================================

CREATE TABLE IF NOT EXISTS TB_USER (
    USER_NO             VARCHAR(20) PRIMARY KEY,                          -- 사용자번호
    USER_ID             VARCHAR(100) NOT NULL UNIQUE,                     -- 사용자ID
    USER_NM             VARCHAR(100) NOT NULL,                            -- 사용자명
    EMAIL_ADDR          VARCHAR(200),                                     -- 이메일주소
    TELNO               VARCHAR(11),                                      -- 전화번호
    STTS_CD             VARCHAR(20),                                      -- 상태코드
    USE_YN              CHAR(1) NOT NULL DEFAULT 'Y' CHECK (USE_YN IN ('Y','N')),
    DEL_YN              CHAR(1) NOT NULL DEFAULT 'N' CHECK (DEL_YN IN ('Y','N')),
    REG_DT              DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UPD_DT              DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS TB_SITE (
    SITE_NO             VARCHAR(20) PRIMARY KEY,                          -- 사이트번호(고객사)
    SITE_NM             VARCHAR(100) NOT NULL,                            -- 사이트명
    SITE_EXPLN          VARCHAR(4000),                                    -- 사이트설명
    SITE_URL_ADDR       VARCHAR(2000),                                    -- 사이트URL주소
    SITE_TELNO          VARCHAR(11),                                      -- 사이트전화번호
    PLAN_SE_CD          VARCHAR(20),                                      -- 요금제구분코드
    STTS_CD             VARCHAR(20),                                      -- 상태코드
    USE_YN              CHAR(1) NOT NULL DEFAULT 'Y' CHECK (USE_YN IN ('Y','N')),
    DEL_YN              CHAR(1) NOT NULL DEFAULT 'N' CHECK (DEL_YN IN ('Y','N')),
    REG_DT              DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UPD_DT              DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS TB_BIZ (
    BIZ_NO              VARCHAR(20) PRIMARY KEY,                          -- 사업번호(프로젝트번호)
    SITE_NO             VARCHAR(20) NOT NULL,                             -- 사이트번호 (의미 FK: TB_SITE.SITE_NO)
    BIZ_NM              VARCHAR(200) NOT NULL,                            -- 사업명(프로젝트명)
    BIZ_CN              VARCHAR(2000),                                    -- 사업내용
    BIZ_PRPS            VARCHAR(4000),                                    -- 사업목적
    BIZ_BGNG_DT         DATETIME,                                         -- 사업시작일시
    BIZ_END_DT          DATETIME,                                         -- 사업종료일시
    BIZ_STTS_CD         VARCHAR(20),                                      -- 사업상태코드
    USE_YN              CHAR(1) NOT NULL DEFAULT 'Y' CHECK (USE_YN IN ('Y','N')),
    DEL_YN              CHAR(1) NOT NULL DEFAULT 'N' CHECK (DEL_YN IN ('Y','N')),
    REG_DT              DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UPD_DT              DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;
CREATE INDEX IX_TB_BIZ_01 ON TB_BIZ (SITE_NO);

CREATE TABLE IF NOT EXISTS TB_BIZ_MBR (
    BIZ_MBR_NO          VARCHAR(20) PRIMARY KEY,                          -- 사업구성원번호
    BIZ_NO              VARCHAR(20) NOT NULL,                             -- 사업번호 (의미 FK: TB_BIZ.BIZ_NO)
    USER_NO             VARCHAR(20) NOT NULL,                             -- 사용자번호 (의미 FK: TB_USER.USER_NO)
    ROLE_SE_CD          VARCHAR(20) NOT NULL,                             -- 역할구분코드
    USE_YN              CHAR(1) NOT NULL DEFAULT 'Y' CHECK (USE_YN IN ('Y','N')),
    DEL_YN              CHAR(1) NOT NULL DEFAULT 'N' CHECK (DEL_YN IN ('Y','N')),
    REG_DT              DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UPD_DT              DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY UQ_TB_BIZ_MBR_01 (BIZ_NO, USER_NO, ROLE_SE_CD)
) ENGINE=InnoDB;
CREATE INDEX IX_TB_BIZ_MBR_01 ON TB_BIZ_MBR (BIZ_NO);
CREATE INDEX IX_TB_BIZ_MBR_02 ON TB_BIZ_MBR (USER_NO);

-- =====================================================================
-- 02. 작업 / 실행
-- =====================================================================

CREATE TABLE IF NOT EXISTS TB_JOB (
    JOB_NO              VARCHAR(20) PRIMARY KEY,                          -- 작업번호(TASK)
    BIZ_NO              VARCHAR(20) NOT NULL,                             -- 사업번호 (의미 FK: TB_BIZ.BIZ_NO)
    JOB_NM              VARCHAR(100) NOT NULL,                            -- 작업명
    JOB_SE_CD           VARCHAR(20) NOT NULL,                             -- 작업구분코드
    JOB_EXPLN           VARCHAR(4000),                                    -- 작업설명
    JOB_CNFG_CN         JSON,                                             -- 작업설정내용(JSON)
    JOB_BGNG_DT         DATETIME,                                         -- 작업시작일시
    JOB_END_DT          DATETIME,                                         -- 작업종료일시
    JOB_STTS_CD         VARCHAR(20),                                      -- 작업상태코드
    USE_YN              CHAR(1) NOT NULL DEFAULT 'Y' CHECK (USE_YN IN ('Y','N')),
    DEL_YN              CHAR(1) NOT NULL DEFAULT 'N' CHECK (DEL_YN IN ('Y','N')),
    REG_DT              DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UPD_DT              DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;
CREATE INDEX IX_TB_JOB_01 ON TB_JOB (BIZ_NO);
CREATE INDEX IX_TB_JOB_02 ON TB_JOB (JOB_SE_CD, JOB_STTS_CD);

CREATE TABLE IF NOT EXISTS TB_JOB_RUN (
    JOB_RUN_NO          VARCHAR(20) PRIMARY KEY,                          -- 작업실행번호
    JOB_NO              VARCHAR(20) NOT NULL,                             -- 작업번호 (의미 FK: TB_JOB.JOB_NO)
    RUN_BGNG_DT         DATETIME NOT NULL,                                -- 실행시작일시
    RUN_END_DT          DATETIME,                                         -- 실행종료일시
    RUN_STTS_CD         VARCHAR(20) NOT NULL,                             -- 실행상태코드
    RUN_RSLT_CN         VARCHAR(4000),                                    -- 실행결과내용
    ERR_CN              VARCHAR(4000),                                    -- 오류내용
    REG_DT              DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UPD_DT              DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;
CREATE INDEX IX_TB_JOB_RUN_01 ON TB_JOB_RUN (JOB_NO);
CREATE INDEX IX_TB_JOB_RUN_02 ON TB_JOB_RUN (RUN_STTS_CD, RUN_BGNG_DT);

-- =====================================================================
-- 03. 데이터 수집 / 매핑 / 품질
-- =====================================================================

CREATE TABLE IF NOT EXISTS TB_DATA_SRC (
    DATA_SRC_NO         VARCHAR(20) PRIMARY KEY,                          -- 데이터소스번호
    BIZ_NO              VARCHAR(20) NOT NULL,                             -- 사업번호 (의미 FK: TB_BIZ.BIZ_NO)
    SRC_SE_CD           VARCHAR(20) NOT NULL,                             -- 소스구분코드(DB/MQTT/FILE/SFTP/API)
    DATA_SRC_NM         VARCHAR(200) NOT NULL,                            -- 데이터소스명
    CONN_CN             JSON NOT NULL,                                    -- 연결내용(JSON)
    SRC_EXPLN           VARCHAR(4000),                                    -- 소스설명
    STTS_CD             VARCHAR(20),                                      -- 상태코드
    USE_YN              CHAR(1) NOT NULL DEFAULT 'Y' CHECK (USE_YN IN ('Y','N')),
    DEL_YN              CHAR(1) NOT NULL DEFAULT 'N' CHECK (DEL_YN IN ('Y','N')),
    REG_DT              DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UPD_DT              DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;
CREATE INDEX IX_TB_DATA_SRC_01 ON TB_DATA_SRC (BIZ_NO);
CREATE INDEX IX_TB_DATA_SRC_02 ON TB_DATA_SRC (SRC_SE_CD);

CREATE TABLE IF NOT EXISTS TB_CLCT_JOB (
    CLCT_JOB_NO         VARCHAR(20) PRIMARY KEY,                          -- 수집작업번호
    DATA_SRC_NO         VARCHAR(20) NOT NULL,                             -- 데이터소스번호 (의미 FK: TB_DATA_SRC.DATA_SRC_NO)
    CLCT_JOB_NM         VARCHAR(100) NOT NULL,                            -- 수집작업명
    CRON_EXPR_CN        VARCHAR(100),                                     -- 스케줄식
    INCRM_KEY_CN        VARCHAR(200),                                     -- 증분키내용
    LAST_WTMK_VAL       VARCHAR(200),                                     -- 마지막워터마크값
    LAST_SUCC_CLCT_DT   DATETIME,                                         -- 마지막성공수집일시
    RETRY_CNT           DECIMAL(10,0) NOT NULL DEFAULT 0,                 -- 재시도횟수
    STTS_CD             VARCHAR(20),                                      -- 상태코드
    USE_YN              CHAR(1) NOT NULL DEFAULT 'Y' CHECK (USE_YN IN ('Y','N')),
    DEL_YN              CHAR(1) NOT NULL DEFAULT 'N' CHECK (DEL_YN IN ('Y','N')),
    REG_DT              DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UPD_DT              DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;
CREATE INDEX IX_TB_CLCT_JOB_01 ON TB_CLCT_JOB (DATA_SRC_NO);

CREATE TABLE IF NOT EXISTS TB_CLCT_RUN (
    CLCT_RUN_NO         VARCHAR(20) PRIMARY KEY,                          -- 수집실행번호
    CLCT_JOB_NO         VARCHAR(20) NOT NULL,                             -- 수집작업번호 (의미 FK: TB_CLCT_JOB.CLCT_JOB_NO)
    CLCT_BGNG_DT        DATETIME NOT NULL,                                -- 수집시작일시
    CLCT_END_DT         DATETIME,                                         -- 수집종료일시
    CLCT_STTS_CD        VARCHAR(20) NOT NULL,                             -- 수집상태코드
    CLCT_NOCS           DECIMAL(10,0) NOT NULL DEFAULT 0,                 -- 수집건수
    FAIL_NOCS           DECIMAL(10,0) NOT NULL DEFAULT 0,                 -- 실패건수
    ERR_CN              VARCHAR(4000),                                    -- 오류내용
    REG_DT              DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UPD_DT              DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;
CREATE INDEX IX_TB_CLCT_RUN_01 ON TB_CLCT_RUN (CLCT_JOB_NO);
CREATE INDEX IX_TB_CLCT_RUN_02 ON TB_CLCT_RUN (CLCT_STTS_CD, CLCT_BGNG_DT);

CREATE TABLE IF NOT EXISTS TB_MAPP_RULE (
    MAPP_RULE_NO        VARCHAR(20) PRIMARY KEY,                          -- 매핑규칙번호
    DATA_SRC_NO         VARCHAR(20) NOT NULL,                             -- 데이터소스번호 (의미 FK: TB_DATA_SRC.DATA_SRC_NO)
    MAPP_RULE_NM        VARCHAR(100) NOT NULL,                            -- 매핑규칙명
    MAPP_RULE_EXPLN     VARCHAR(4000),                                    -- 매핑규칙설명
    CURR_VER_NO         DECIMAL(10,0) NOT NULL DEFAULT 1,                 -- 현재버전번호
    USE_YN              CHAR(1) NOT NULL DEFAULT 'Y' CHECK (USE_YN IN ('Y','N')),
    DEL_YN              CHAR(1) NOT NULL DEFAULT 'N' CHECK (DEL_YN IN ('Y','N')),
    REG_DT              DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UPD_DT              DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;
CREATE INDEX IX_TB_MAPP_RULE_01 ON TB_MAPP_RULE (DATA_SRC_NO);

CREATE TABLE IF NOT EXISTS TB_MAPP_RULE_VER (
    MAPP_RULE_VER_NO    VARCHAR(20) PRIMARY KEY,                          -- 매핑규칙버전번호
    MAPP_RULE_NO        VARCHAR(20) NOT NULL,                             -- 매핑규칙번호 (의미 FK: TB_MAPP_RULE.MAPP_RULE_NO)
    VER_NO              DECIMAL(10,0) NOT NULL,                           -- 버전번호
    RULE_CN             JSON NOT NULL,                                    -- 규칙내용(JSON)
    APLCN_BGNG_DT       DATETIME,                                         -- 적용시작일시
    APLCN_END_DT        DATETIME,                                         -- 적용종료일시
    STTS_CD             VARCHAR(20),                                      -- 상태코드
    REG_DT              DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UPD_DT              DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY UQ_TB_MAPP_RULE_VER_01 (MAPP_RULE_NO, VER_NO)
) ENGINE=InnoDB;
CREATE INDEX IX_TB_MAPP_RULE_VER_01 ON TB_MAPP_RULE_VER (MAPP_RULE_NO);

CREATE TABLE IF NOT EXISTS TB_QLTY_RULE (
    QLTY_RULE_NO        VARCHAR(20) PRIMARY KEY,                          -- 품질규칙번호
    MAPP_RULE_VER_NO    VARCHAR(20) NOT NULL,                             -- 매핑규칙버전번호 (의미 FK: TB_MAPP_RULE_VER.MAPP_RULE_VER_NO)
    QLTY_RULE_NM        VARCHAR(100) NOT NULL,                            -- 품질규칙명
    QLTY_RULE_CN        JSON NOT NULL,                                    -- 품질규칙내용(JSON)
    USE_YN              CHAR(1) NOT NULL DEFAULT 'Y' CHECK (USE_YN IN ('Y','N')),
    DEL_YN              CHAR(1) NOT NULL DEFAULT 'N' CHECK (DEL_YN IN ('Y','N')),
    REG_DT              DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UPD_DT              DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;
CREATE INDEX IX_TB_QLTY_RULE_01 ON TB_QLTY_RULE (MAPP_RULE_VER_NO);

CREATE TABLE IF NOT EXISTS TB_QLTY_RSLT (
    QLTY_RSLT_NO        VARCHAR(20) PRIMARY KEY,                          -- 품질결과번호
    CLCT_RUN_NO         VARCHAR(20) NOT NULL,                             -- 수집실행번호 (의미 FK: TB_CLCT_RUN.CLCT_RUN_NO)
    QLTY_RULE_NO        VARCHAR(20) NOT NULL,                             -- 품질규칙번호 (의미 FK: TB_QLTY_RULE.QLTY_RULE_NO)
    CHK_NOCS            DECIMAL(10,0) NOT NULL DEFAULT 0,                 -- 검사건수
    FAIL_NOCS           DECIMAL(10,0) NOT NULL DEFAULT 0,                 -- 실패건수
    QLTY_STTS_CD        VARCHAR(20) NOT NULL,                             -- 품질상태코드
    RSLT_CN             VARCHAR(4000),                                    -- 결과내용
    REG_DT              DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;
CREATE INDEX IX_TB_QLTY_RSLT_01 ON TB_QLTY_RSLT (CLCT_RUN_NO);
CREATE INDEX IX_TB_QLTY_RSLT_02 ON TB_QLTY_RSLT (QLTY_RULE_NO);

-- =====================================================================
-- 03-1. 시계열 원천/정형 데이터
-- =====================================================================

CREATE TABLE IF NOT EXISTS TB_RTU (
    RTU_NO              VARCHAR(20) PRIMARY KEY,                          -- RTU번호
    SITE_NO             VARCHAR(20) NOT NULL,                             -- 사이트번호 (의미 FK: TB_SITE.SITE_NO)
    BIZ_NO              VARCHAR(20) NOT NULL,                             -- 사업번호 (의미 FK: TB_BIZ.BIZ_NO)
    RTU_NM              VARCHAR(100) NOT NULL,                            -- RTU명
    RTU_SE_CD           VARCHAR(20) NOT NULL,                             -- RTU구분코드
    INSTL_LOC_NM        VARCHAR(200),                                     -- 설치위치명
    STTS_CD             VARCHAR(20),                                      -- 상태코드
    USE_YN              CHAR(1) NOT NULL DEFAULT 'Y' CHECK (USE_YN IN ('Y','N')),
    DEL_YN              CHAR(1) NOT NULL DEFAULT 'N' CHECK (DEL_YN IN ('Y','N')),
    REG_DT              DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UPD_DT              DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;
CREATE INDEX IX_TB_RTU_01 ON TB_RTU (SITE_NO, BIZ_NO);
CREATE INDEX IX_TB_RTU_02 ON TB_RTU (RTU_SE_CD, STTS_CD);

-- 참고:
-- 1) EnerBrain은 분석/예측 관점의 계측기 메타만 관리한다.
-- 2) Modbus 주소/채널/레지스터/스케일링 계수는 수집서버 영역에서 관리한다.
CREATE TABLE IF NOT EXISTS TB_METER (
    METER_NO            VARCHAR(20) PRIMARY KEY,                          -- 계측기번호
    SITE_NO             VARCHAR(20) NOT NULL,                             -- 사이트번호 (의미 FK: TB_SITE.SITE_NO)
    BIZ_NO              VARCHAR(20) NOT NULL,                             -- 사업번호 (의미 FK: TB_BIZ.BIZ_NO)
    RTU_NO              VARCHAR(20) NOT NULL,                             -- RTU번호 (의미 FK: TB_RTU.RTU_NO)
    METER_NM            VARCHAR(100) NOT NULL,                            -- 계측기명
    METER_SE_CD         VARCHAR(20) NOT NULL,                             -- 계측기구분코드
    MEASURE_SE_CD       VARCHAR(20),                                      -- 측정구분코드
    INSTL_LOC_NM        VARCHAR(200),                                     -- 설치위치명
    STTS_CD             VARCHAR(20),                                      -- 상태코드
    USE_YN              CHAR(1) NOT NULL DEFAULT 'Y' CHECK (USE_YN IN ('Y','N')),
    DEL_YN              CHAR(1) NOT NULL DEFAULT 'N' CHECK (DEL_YN IN ('Y','N')),
    REG_DT              DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UPD_DT              DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;
CREATE INDEX IX_TB_METER_01 ON TB_METER (SITE_NO, BIZ_NO, RTU_NO);
CREATE INDEX IX_TB_METER_02 ON TB_METER (METER_SE_CD, STTS_CD);

CREATE TABLE IF NOT EXISTS TB_TS_RAW_JSON (
    TS_RAW_NO            VARCHAR(20) PRIMARY KEY,                         -- 시계열원천번호
    SITE_NO              VARCHAR(20) NOT NULL,                            -- 사이트번호
    BIZ_NO               VARCHAR(20) NOT NULL,                            -- 사업번호
    DATA_SRC_NO          VARCHAR(20) NOT NULL,                            -- 데이터소스번호
    CLCT_RUN_NO          VARCHAR(20),                                     -- 수집실행번호
    RTU_NO               VARCHAR(20),                                     -- RTU번호
    METER_NO             VARCHAR(20),                                     -- 계측기번호
    SRC_ROW_ID           VARCHAR(100),                                    -- 원천행식별값
    SRC_TS_DT            DATETIME,                                        -- 원천기준일시
    PAYLOAD_CN           JSON NOT NULL,                                   -- 원천페이로드내용
    MAPP_RULE_VER_NO     VARCHAR(20),                                     -- 매핑규칙버전번호
    PRCS_STTS_CD         VARCHAR(20) NOT NULL,                            -- 처리상태코드
    ERR_CN               VARCHAR(4000),                                   -- 오류내용
    REG_DT               DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;
CREATE INDEX IX_TB_TS_RAW_JSON_01 ON TB_TS_RAW_JSON (SITE_NO, BIZ_NO, SRC_TS_DT);
CREATE INDEX IX_TB_TS_RAW_JSON_02 ON TB_TS_RAW_JSON (DATA_SRC_NO, PRCS_STTS_CD);
CREATE INDEX IX_TB_TS_RAW_JSON_03 ON TB_TS_RAW_JSON (RTU_NO, SRC_TS_DT);
CREATE INDEX IX_TB_TS_RAW_JSON_04 ON TB_TS_RAW_JSON (METER_NO, SRC_TS_DT);

CREATE TABLE IF NOT EXISTS TB_TS_FACT (
    TS_FACT_NO           VARCHAR(20) PRIMARY KEY,                         -- 시계열팩트번호
    SITE_NO              VARCHAR(20) NOT NULL,                            -- 사이트번호
    BIZ_NO               VARCHAR(20) NOT NULL,                            -- 사업번호
    RTU_NO               VARCHAR(20) NOT NULL,                            -- RTU번호
    METER_NO             VARCHAR(20) NOT NULL,                            -- 계측기번호
    TS_DT                DATETIME NOT NULL,                               -- 기준일시
    METRIC_CD            VARCHAR(50) NOT NULL,                            -- 측정지표코드
    VAL                  DECIMAL(18,6) NOT NULL,                          -- 측정값
    UNIT_CD              VARCHAR(20),                                     -- 단위코드
    QLTY_STTS_CD         VARCHAR(20),                                     -- 품질상태코드
    TS_RAW_NO            VARCHAR(20),                                     -- 원천시계열번호
    REG_DT               DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UPD_DT               DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY UQ_TB_TS_FACT_01 (SITE_NO, BIZ_NO, RTU_NO, METER_NO, TS_DT, METRIC_CD)
) ENGINE=InnoDB COMMENT='정규화 시계열 팩트';
CREATE INDEX IX_TB_TS_FACT_01 ON TB_TS_FACT (SITE_NO, BIZ_NO, TS_DT);
CREATE INDEX IX_TB_TS_FACT_02 ON TB_TS_FACT (BIZ_NO, RTU_NO, TS_DT);
CREATE INDEX IX_TB_TS_FACT_03 ON TB_TS_FACT (METRIC_CD, TS_DT);
CREATE INDEX IX_TB_TS_FACT_04 ON TB_TS_FACT (METER_NO, TS_DT);

CREATE TABLE IF NOT EXISTS TB_FCST_RSLT (
    FCST_RSLT_NO         VARCHAR(20) PRIMARY KEY,                         -- 예측결과번호
    JOB_RUN_NO           VARCHAR(20),                                     -- 작업실행번호
    MODEL_VER_NO         VARCHAR(20),                                     -- 모델버전번호
    SITE_NO              VARCHAR(20) NOT NULL,                            -- 사이트번호
    BIZ_NO               VARCHAR(20) NOT NULL,                            -- 사업번호
    RTU_NO               VARCHAR(20),                                     -- RTU번호
    METER_NO             VARCHAR(20),                                     -- 계측기번호
    TARGET_YMD           VARCHAR(8) NOT NULL,                             -- 예측대상일자(YYYYMMDD)
    FCST_TS_DT           DATETIME NOT NULL,                               -- 예측기준일시
    METRIC_CD            VARCHAR(50) NOT NULL,                            -- 예측지표코드
    FCST_VAL             DECIMAL(18,6) NOT NULL,                          -- 예측값
    LOWER_VAL            DECIMAL(18,6),                                   -- 하한값
    UPPER_VAL            DECIMAL(18,6),                                   -- 상한값
    REG_DT               DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UPD_DT               DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;
CREATE INDEX IX_TB_FCST_RSLT_01 ON TB_FCST_RSLT (SITE_NO, BIZ_NO, TARGET_YMD);
CREATE INDEX IX_TB_FCST_RSLT_02 ON TB_FCST_RSLT (BIZ_NO, RTU_NO, FCST_TS_DT);
CREATE INDEX IX_TB_FCST_RSLT_03 ON TB_FCST_RSLT (MODEL_VER_NO, METRIC_CD);
CREATE INDEX IX_TB_FCST_RSLT_04 ON TB_FCST_RSLT (METER_NO, FCST_TS_DT);

-- =====================================================================
-- 04. 알고리즘 / 모델 / 배포
-- =====================================================================

CREATE TABLE IF NOT EXISTS TB_ALGM (
    ALGM_NO             VARCHAR(20) PRIMARY KEY,                          -- 알고리즘번호
    ALGM_NM             VARCHAR(100) NOT NULL,                            -- 알고리즘명
    ALGM_SE_CD          VARCHAR(20) NOT NULL,                             -- 알고리즘구분코드(ML/DL/RL)
    ALGM_EXPLN          VARCHAR(4000),                                    -- 알고리즘설명
    DFLT_CNFG_CN        JSON,                                             -- 기본설정내용(JSON)
    USE_YN              CHAR(1) NOT NULL DEFAULT 'Y' CHECK (USE_YN IN ('Y','N')),
    DEL_YN              CHAR(1) NOT NULL DEFAULT 'N' CHECK (DEL_YN IN ('Y','N')),
    REG_DT              DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UPD_DT              DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;
CREATE INDEX IX_TB_ALGM_01 ON TB_ALGM (ALGM_SE_CD);

CREATE TABLE IF NOT EXISTS TB_MODEL_VER (
    MODEL_VER_NO        VARCHAR(20) PRIMARY KEY,                          -- 모델버전번호
    JOB_NO              VARCHAR(20) NOT NULL,                             -- 작업번호 (의미 FK: TB_JOB.JOB_NO)
    ALGM_NO             VARCHAR(20) NOT NULL,                             -- 알고리즘번호 (의미 FK: TB_ALGM.ALGM_NO)
    VER_NO              DECIMAL(10,0) NOT NULL,                           -- 버전번호
    MODEL_NM            VARCHAR(200) NOT NULL,                            -- 모델명
    TRN_BGNG_DT         DATETIME,                                         -- 학습시작일시
    TRN_END_DT          DATETIME,                                         -- 학습종료일시
    MODEL_STTS_CD       VARCHAR(20) NOT NULL,                             -- 모델상태코드
    ARTFCT_PATH_NM      VARCHAR(300),                                     -- 아티팩트경로명
    CNFG_CN             JSON,                                             -- 모델설정내용(JSON)
    REG_DT              DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UPD_DT              DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY UQ_TB_MODEL_VER_01 (JOB_NO, VER_NO)
) ENGINE=InnoDB;
CREATE INDEX IX_TB_MODEL_VER_01 ON TB_MODEL_VER (JOB_NO);
CREATE INDEX IX_TB_MODEL_VER_02 ON TB_MODEL_VER (ALGM_NO);

CREATE TABLE IF NOT EXISTS TB_MODEL_EVAL (
    MODEL_EVAL_NO       VARCHAR(20) PRIMARY KEY,                          -- 모델평가번호
    MODEL_VER_NO        VARCHAR(20) NOT NULL,                             -- 모델버전번호 (의미 FK: TB_MODEL_VER.MODEL_VER_NO)
    EVAL_DT             DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,      -- 평가일시
    METRIC_CN           JSON NOT NULL,                                    -- 평가지표내용(JSON)
    PASS_YN             CHAR(1) NOT NULL DEFAULT 'N' CHECK (PASS_YN IN ('Y','N')),
    EVAL_EXPLN          VARCHAR(4000),                                    -- 평가설명
    REG_DT              DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;
CREATE INDEX IX_TB_MODEL_EVAL_01 ON TB_MODEL_EVAL (MODEL_VER_NO);

CREATE TABLE IF NOT EXISTS TB_DEPLOY (
    DEPLOY_NO           VARCHAR(20) PRIMARY KEY,                          -- 배포번호
    MODEL_VER_NO        VARCHAR(20) NOT NULL,                             -- 모델버전번호 (의미 FK: TB_MODEL_VER.MODEL_VER_NO)
    DEPLOY_SE_CD        VARCHAR(20) NOT NULL,                             -- 배포구분코드(SHADOW/CANARY/PROD)
    DEPLOY_STTS_CD      VARCHAR(20) NOT NULL,                             -- 배포상태코드
    DEPLOY_BGNG_DT      DATETIME NOT NULL,                                -- 배포시작일시
    DEPLOY_END_DT       DATETIME,                                         -- 배포종료일시
    ROUTE_RT            DECIMAL(5,2),                                     -- 라우팅비율
    ROLLBACK_YN         CHAR(1) NOT NULL DEFAULT 'N' CHECK (ROLLBACK_YN IN ('Y','N')),
    REG_DT              DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UPD_DT              DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;
CREATE INDEX IX_TB_DEPLOY_01 ON TB_DEPLOY (MODEL_VER_NO);
CREATE INDEX IX_TB_DEPLOY_02 ON TB_DEPLOY (DEPLOY_STTS_CD, DEPLOY_BGNG_DT);

-- =====================================================================
-- 05. 서비스 API / 프로젝트 키 / Open API 키
-- =====================================================================

CREATE TABLE IF NOT EXISTS TB_API_SVC (
    API_SVC_NO          VARCHAR(20) PRIMARY KEY,                          -- API서비스번호
    SITE_NO             VARCHAR(20) NOT NULL,                             -- 사이트번호 (의미 FK: TB_SITE.SITE_NO)
    BIZ_NO              VARCHAR(20),                                      -- 사업번호(프로젝트 전용 API일 때) (의미 FK: TB_BIZ.BIZ_NO)
    API_NM              VARCHAR(300) NOT NULL,                            -- API명
    API_EXPLN           VARCHAR(4000),                                    -- API설명
    BASE_URL_ADDR       VARCHAR(2000) NOT NULL,                           -- 기본URL주소
    API_VER_CD          VARCHAR(20) NOT NULL,                             -- API버전코드
    OPEN_API_YN         CHAR(1) NOT NULL DEFAULT 'N' CHECK (OPEN_API_YN IN ('Y','N')), -- 공개 API 여부
    STTS_CD             VARCHAR(20),                                      -- 상태코드
    USE_YN              CHAR(1) NOT NULL DEFAULT 'Y' CHECK (USE_YN IN ('Y','N')),
    DEL_YN              CHAR(1) NOT NULL DEFAULT 'N' CHECK (DEL_YN IN ('Y','N')),
    REG_DT              DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UPD_DT              DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;
CREATE INDEX IX_TB_API_SVC_01 ON TB_API_SVC (SITE_NO);
CREATE INDEX IX_TB_API_SVC_02 ON TB_API_SVC (BIZ_NO);
CREATE INDEX IX_TB_API_SVC_03 ON TB_API_SVC (OPEN_API_YN, STTS_CD);

-- 프로젝트 생성 시 발급해서 "고객사 해당 프로젝트 개발자"에게 전달하는 키
CREATE TABLE IF NOT EXISTS TB_BIZ_API_KEY (
    BIZ_API_KEY_NO      VARCHAR(20) PRIMARY KEY,                          -- 프로젝트API키번호
    SITE_NO             VARCHAR(20) NOT NULL,                             -- 사이트번호 (의미 FK: TB_SITE.SITE_NO)
    BIZ_NO              VARCHAR(20) NOT NULL,                             -- 사업번호 (의미 FK: TB_BIZ.BIZ_NO)
    KEY_NM              VARCHAR(100) NOT NULL,                            -- 키명
    KEY_HASH_CN         VARCHAR(256) NOT NULL,                            -- 키해시내용
    KEY_PREFIX_CN       VARCHAR(20) NOT NULL,                             -- 키접두내용(표시용)
    KEY_STTS_CD         VARCHAR(20) NOT NULL,                             -- 키상태코드(ACTIVE/REVOKED/EXPIRED)
    ISSUE_TRGT_USER_NO  VARCHAR(20),                                      -- 발급대상사용자번호 (의미 FK: TB_USER.USER_NO)
    ISSUE_CN            VARCHAR(2000),                                    -- 발급설명
    ISSUE_DT            DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,      -- 발급일시
    EXPR_DT             DATETIME,                                         -- 만료일시
    LAST_USE_DT         DATETIME,                                         -- 최종사용일시
    REVOKE_DT           DATETIME,                                         -- 폐기일시
    RATE_LMT_PER_MIN    DECIMAL(10,0),                                    -- 분당호출제한건수
    IP_WHTLST_CN        VARCHAR(4000),                                    -- IP허용목록내용
    USE_YN              CHAR(1) NOT NULL DEFAULT 'Y' CHECK (USE_YN IN ('Y','N')),
    DEL_YN              CHAR(1) NOT NULL DEFAULT 'N' CHECK (DEL_YN IN ('Y','N')),
    REG_DT              DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UPD_DT              DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB COMMENT='프로젝트별 API 인증키';
CREATE INDEX IX_TB_BIZ_API_KEY_01 ON TB_BIZ_API_KEY (SITE_NO, BIZ_NO);
CREATE INDEX IX_TB_BIZ_API_KEY_02 ON TB_BIZ_API_KEY (KEY_STTS_CD, EXPR_DT);

CREATE TABLE IF NOT EXISTS TB_BIZ_API_KEY_ISSU_HIS (
    BIZ_API_KEY_ISSU_HIS_NO  VARCHAR(20) PRIMARY KEY,                     -- 프로젝트API키발급이력번호
    BIZ_API_KEY_NO           VARCHAR(20) NOT NULL,                        -- 프로젝트API키번호 (의미 FK: TB_BIZ_API_KEY.BIZ_API_KEY_NO)
    ISSU_SE_CD               VARCHAR(20) NOT NULL,                        -- 발급구분코드(ISSUE/ROTATE/REVOKE)
    ISSU_DT                  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, -- 발급일시
    ISSU_USER_NO             VARCHAR(20),                                 -- 발급사용자번호 (의미 FK: TB_USER.USER_NO)
    ISSU_RSN                 VARCHAR(4000),                               -- 발급사유
    REG_DT                   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;
CREATE INDEX IX_TB_BIZ_API_KEY_ISSU_HIS_01 ON TB_BIZ_API_KEY_ISSU_HIS (BIZ_API_KEY_NO, ISSU_DT);

-- Open API용 외부 클라이언트(불특정 다수 중 승인된 앱 단위)
CREATE TABLE IF NOT EXISTS TB_OPEN_API_CLNT (
    OPEN_API_CLNT_NO     VARCHAR(20) PRIMARY KEY,                         -- 오픈API클라이언트번호
    SITE_NO              VARCHAR(20) NOT NULL,                            -- 사이트번호 (의미 FK: TB_SITE.SITE_NO)
    CLNT_NM              VARCHAR(200) NOT NULL,                           -- 클라이언트명
    CLNT_ORG_NM          VARCHAR(200),                                    -- 클라이언트조직명
    CLNT_EMAIL_ADDR      VARCHAR(200),                                    -- 클라이언트이메일주소
    CLNT_TELNO           VARCHAR(11),                                     -- 클라이언트전화번호
    APP_URL_ADDR         VARCHAR(2000),                                   -- 앱URL주소
    CLNT_STTS_CD         VARCHAR(20) NOT NULL,                            -- 클라이언트상태코드
    USE_YN               CHAR(1) NOT NULL DEFAULT 'Y' CHECK (USE_YN IN ('Y','N')),
    DEL_YN               CHAR(1) NOT NULL DEFAULT 'N' CHECK (DEL_YN IN ('Y','N')),
    REG_DT               DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UPD_DT               DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;
CREATE INDEX IX_TB_OPEN_API_CLNT_01 ON TB_OPEN_API_CLNT (SITE_NO, CLNT_STTS_CD);

CREATE TABLE IF NOT EXISTS TB_OPEN_API_KEY (
    OPEN_API_KEY_NO      VARCHAR(20) PRIMARY KEY,                         -- 오픈API키번호
    OPEN_API_CLNT_NO     VARCHAR(20) NOT NULL,                            -- 오픈API클라이언트번호 (의미 FK: TB_OPEN_API_CLNT.OPEN_API_CLNT_NO)
    API_KEY_HASH_CN      VARCHAR(256) NOT NULL,                           -- API키해시내용
    API_KEY_PREFIX_CN    VARCHAR(20) NOT NULL,                            -- API키접두내용
    KEY_STTS_CD          VARCHAR(20) NOT NULL,                            -- 키상태코드
    ISSUE_DT             DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,     -- 발급일시
    EXPR_DT              DATETIME,                                        -- 만료일시
    LAST_USE_DT          DATETIME,                                        -- 최종사용일시
    RATE_LMT_PER_MIN     DECIMAL(10,0),                                   -- 분당호출제한건수
    DAILY_QTA_NOCS       DECIMAL(10,0),                                   -- 일별할당건수
    USE_YN               CHAR(1) NOT NULL DEFAULT 'Y' CHECK (USE_YN IN ('Y','N')),
    DEL_YN               CHAR(1) NOT NULL DEFAULT 'N' CHECK (DEL_YN IN ('Y','N')),
    REG_DT               DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UPD_DT               DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;
CREATE INDEX IX_TB_OPEN_API_KEY_01 ON TB_OPEN_API_KEY (OPEN_API_CLNT_NO);
CREATE INDEX IX_TB_OPEN_API_KEY_02 ON TB_OPEN_API_KEY (KEY_STTS_CD, EXPR_DT);

CREATE TABLE IF NOT EXISTS TB_OPEN_API_KEY_SVC (
    OPEN_API_KEY_SVC_NO  VARCHAR(20) PRIMARY KEY,                         -- 오픈API키서비스번호
    OPEN_API_KEY_NO      VARCHAR(20) NOT NULL,                            -- 오픈API키번호 (의미 FK: TB_OPEN_API_KEY.OPEN_API_KEY_NO)
    API_SVC_NO           VARCHAR(20) NOT NULL,                            -- API서비스번호 (의미 FK: TB_API_SVC.API_SVC_NO)
    AUTHRT_SE_CD         VARCHAR(20) NOT NULL,                            -- 권한구분코드(READ/WRITE/ADMIN)
    USE_YN               CHAR(1) NOT NULL DEFAULT 'Y' CHECK (USE_YN IN ('Y','N')),
    DEL_YN               CHAR(1) NOT NULL DEFAULT 'N' CHECK (DEL_YN IN ('Y','N')),
    REG_DT               DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UPD_DT               DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY UQ_TB_OPEN_API_KEY_SVC_01 (OPEN_API_KEY_NO, API_SVC_NO, AUTHRT_SE_CD)
) ENGINE=InnoDB;
CREATE INDEX IX_TB_OPEN_API_KEY_SVC_01 ON TB_OPEN_API_KEY_SVC (OPEN_API_KEY_NO);
CREATE INDEX IX_TB_OPEN_API_KEY_SVC_02 ON TB_OPEN_API_KEY_SVC (API_SVC_NO);

-- API 요청 추적 로그(프로젝트키/오픈키 공통)
CREATE TABLE IF NOT EXISTS TB_API_REQ_LOG (
    API_REQ_LOG_NO       VARCHAR(20) PRIMARY KEY,                         -- API요청로그번호
    SITE_NO              VARCHAR(20) NOT NULL,                            -- 사이트번호
    BIZ_NO               VARCHAR(20),                                     -- 사업번호
    API_SVC_NO           VARCHAR(20) NOT NULL,                            -- API서비스번호
    KEY_SE_CD            VARCHAR(20) NOT NULL,                            -- 키구분코드(BIZ/OPEN)
    BIZ_API_KEY_NO       VARCHAR(20),                                     -- 프로젝트API키번호
    OPEN_API_KEY_NO      VARCHAR(20),                                     -- 오픈API키번호
    REQ_DT               DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,     -- 요청일시
    REQ_IP_ADDR          VARCHAR(45),                                     -- 요청IP주소
    REQ_MTHD_CD          VARCHAR(10),                                     -- 요청메서드코드
    REQ_PATH_NM          VARCHAR(1000),                                   -- 요청경로명
    RES_STTS_CD          VARCHAR(10),                                     -- 응답상태코드
    PROC_MSEC            DECIMAL(10,0),                                   -- 처리밀리초
    ERR_CN               VARCHAR(4000)                                    -- 오류내용
) ENGINE=InnoDB;
CREATE INDEX IX_TB_API_REQ_LOG_01 ON TB_API_REQ_LOG (API_SVC_NO, REQ_DT);
CREATE INDEX IX_TB_API_REQ_LOG_02 ON TB_API_REQ_LOG (BIZ_API_KEY_NO, OPEN_API_KEY_NO);

-- =====================================================================
-- 06. 감사 로그
-- =====================================================================

CREATE TABLE IF NOT EXISTS TB_AUDIT_LOG (
    AUDIT_LOG_NO         VARCHAR(20) PRIMARY KEY,                         -- 감사로그번호
    SITE_NO              VARCHAR(20),                                     -- 사이트번호
    BIZ_NO               VARCHAR(20),                                     -- 사업번호
    USER_NO              VARCHAR(20),                                     -- 사용자번호
    TRGT_TBL_NM          VARCHAR(100) NOT NULL,                           -- 대상테이블명
    TRGT_PK_NO           VARCHAR(50) NOT NULL,                            -- 대상PK번호
    ACT_SE_CD            VARCHAR(20) NOT NULL,                            -- 행위구분코드
    CHG_CN               JSON,                                            -- 변경내용(JSON)
    REG_DT               DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;
CREATE INDEX IX_TB_AUDIT_LOG_01 ON TB_AUDIT_LOG (SITE_NO, BIZ_NO, REG_DT);
CREATE INDEX IX_TB_AUDIT_LOG_02 ON TB_AUDIT_LOG (USER_NO, REG_DT);

-- =====================================================================
-- 07. 권장 초기 코드 (선택)
-- =====================================================================

-- TYPE_CD: 물리 테이블명, GRP_CD: 물리 컬럼명
INSERT IGNORE INTO TB_COMM_CD (
    TYPE_CD, GRP_CD, CD_ID, CD_NM, EXPLN, SORT_ORD, REG_USER_ID, MOD_USER_ID
)
VALUES
('COMM_CD', 'STTS_CD', 'ACTIVE', '활성', '공통 활성 상태', 1, 0, 0),
('COMM_CD', 'STTS_CD', 'RUN', '실행중', '공통 실행 상태', 2, 0, 0),
('COMM_CD', 'STTS_CD', 'DONE', '완료', '공통 완료 상태', 3, 0, 0),
('COMM_CD', 'STTS_CD', 'FAIL', '실패', '공통 실패 상태', 4, 0, 0),
('TB_BIZ', 'BIZ_STTS_CD', 'RUN', '운영중', '사업 운영 상태', 1, 0, 0),
('TB_BIZ_MBR', 'ROLE_SE_CD', 'PM', 'PM', '프로젝트 매니저', 1, 0, 0),
('TB_DATA_SRC', 'SRC_SE_CD', 'DB', 'DB', '외부 데이터베이스 연결', 1, 0, 0),
('TB_DATA_SRC', 'SRC_SE_CD', 'MQTT', 'MQTT', '메시지 브로커 연결', 2, 0, 0),
('TB_DATA_SRC', 'SRC_SE_CD', 'FILE', 'FILE', '파일 수집', 3, 0, 0),
('TB_DATA_SRC', 'SRC_SE_CD', 'SFTP', 'SFTP', 'SFTP 수집', 4, 0, 0),
('TB_DATA_SRC', 'SRC_SE_CD', 'API', 'API', '외부 API 수집', 5, 0, 0),
('TB_CLCT_RUN', 'CLCT_STTS_CD', 'DONE', '완료', '수집 실행 완료', 1, 0, 0),
('TB_CLCT_RUN', 'CLCT_STTS_CD', 'FAIL', '실패', '수집 실행 실패', 2, 0, 0),
('TB_JOB', 'JOB_SE_CD', 'ANLS', '분석', '분석 작업', 1, 0, 0),
('TB_JOB', 'JOB_SE_CD', 'TRN', '학습', '모델 학습 작업', 2, 0, 0),
('TB_JOB', 'JOB_SE_CD', 'INFR', '추론', '실시간 또는 배치 추론 작업', 3, 0, 0),
('TB_JOB', 'JOB_STTS_CD', 'RUN', '운영중', '작업 운영 상태', 1, 0, 0),
('TB_JOB_RUN', 'RUN_STTS_CD', 'DONE', '완료', '작업 실행 완료', 1, 0, 0),
('TB_ALGM', 'ALGM_SE_CD', 'ML', '머신러닝', 'ML 알고리즘', 1, 0, 0),
('TB_ALGM', 'ALGM_SE_CD', 'DL', '딥러닝', 'DL 알고리즘', 2, 0, 0),
('TB_ALGM', 'ALGM_SE_CD', 'RL', '강화학습', 'RL 알고리즘', 3, 0, 0),
('TB_MODEL_VER', 'MODEL_STTS_CD', 'READY', '준비', '배포 가능한 모델 상태', 1, 0, 0),
('TB_DEPLOY', 'DEPLOY_SE_CD', 'PROD', '운영', '운영 배포', 1, 0, 0),
('TB_DEPLOY', 'DEPLOY_SE_CD', 'CANARY', '카나리', '카나리 배포', 2, 0, 0),
('TB_DEPLOY', 'DEPLOY_SE_CD', 'SHADOW', '섀도우', '섀도우 배포', 3, 0, 0),
('TB_DEPLOY', 'DEPLOY_STTS_CD', 'RUN', '운영중', '운영 배포 진행 상태', 1, 0, 0),
('TB_API_SVC', 'OPEN_API_YN', 'Y', '예', 'Open API 공개 여부-예', 1, 0, 0),
('TB_API_SVC', 'OPEN_API_YN', 'N', '아니오', 'Open API 공개 여부-아니오', 2, 0, 0),
('COMM_CD', 'KEY_STTS_CD', 'ACTIVE', '활성', '정상 사용 가능', 1, 0, 0),
('COMM_CD', 'KEY_STTS_CD', 'REVOKED', '폐기', '관리자 폐기', 2, 0, 0),
('COMM_CD', 'KEY_STTS_CD', 'EXPIRED', '만료', '만료일 경과', 3, 0, 0),
('TB_BIZ_API_KEY_ISSU_HIS', 'ISSU_SE_CD', 'ISSUE', '발급', 'API 키 신규 발급', 1, 0, 0),
('TB_BIZ_API_KEY_ISSU_HIS', 'ISSU_SE_CD', 'ROTATE', '교체', 'API 키 교체 발급', 2, 0, 0),
('TB_BIZ_API_KEY_ISSU_HIS', 'ISSU_SE_CD', 'REVOKE', '폐기', 'API 키 폐기 처리', 3, 0, 0),
('TB_OPEN_API_KEY_SVC', 'AUTHRT_SE_CD', 'READ', '조회', '조회 권한', 1, 0, 0),
('TB_OPEN_API_KEY_SVC', 'AUTHRT_SE_CD', 'WRITE', '수정', '수정 권한', 2, 0, 0),
('TB_OPEN_API_KEY_SVC', 'AUTHRT_SE_CD', 'ADMIN', '관리', '관리 권한', 3, 0, 0),
('TB_API_REQ_LOG', 'KEY_SE_CD', 'BIZ', '프로젝트키', '프로젝트 전용 키', 1, 0, 0),
('TB_API_REQ_LOG', 'KEY_SE_CD', 'OPEN', '오픈키', 'Open API 키', 2, 0, 0),
('TB_RTU', 'RTU_SE_CD', 'PV', '태양광', '태양광 발전 RTU', 1, 0, 0),
('TB_RTU', 'RTU_SE_CD', 'LOAD', '소비', '전력 소비 RTU', 2, 0, 0),
('TB_METER', 'METER_SE_CD', 'PWR', '전력계', '전력 계측기', 1, 0, 0),
('TB_METER', 'METER_SE_CD', 'ENV', '환경계', '환경 계측기', 2, 0, 0),
('TB_METER', 'METER_SE_CD', 'INVERTER', '인버터', '태양광 인버터 계측기', 3, 0, 0),
('TB_TS_RAW_JSON', 'PRCS_STTS_CD', 'READY', '대기', '정규화 대기 상태', 1, 0, 0),
('TB_TS_RAW_JSON', 'PRCS_STTS_CD', 'DONE', '완료', '정규화 완료 상태', 2, 0, 0),
('TB_TS_RAW_JSON', 'PRCS_STTS_CD', 'FAIL', '실패', '정규화 실패 상태', 3, 0, 0),
('COMM_CD', 'QLTY_STTS_CD', 'GOOD', '정상', '품질 정상 데이터', 1, 0, 0),
('COMM_CD', 'QLTY_STTS_CD', 'WARN', '경고', '품질 경고 데이터', 2, 0, 0),
('COMM_CD', 'QLTY_STTS_CD', 'BAD', '오류', '품질 오류 데이터', 3, 0, 0),
('COMM_CD', 'METRIC_CD', 'PV_GEN_KW', '발전전력', '태양광 발전 전력(kW)', 1, 0, 0),
('COMM_CD', 'METRIC_CD', 'LOAD_KW', '소비전력', '소비 전력(kW)', 2, 0, 0),
('COMM_CD', 'METRIC_CD', 'IRRADIANCE', '일사량', '태양 일사량', 3, 0, 0),
('COMM_CD', 'METRIC_CD', 'TEMP_C', '기온', '섭씨 기온', 4, 0, 0);

-- =====================================================================
-- 08. 광명스마트시티 샘플 데이터
-- =====================================================================

-- 08-1) 샘플 코드값은 07 섹션의 공통 초기코드를 재사용한다.

-- 08-2) 조직/프로젝트/사용자
INSERT IGNORE INTO TB_USER (
    USER_NO, USER_ID, USER_NM, EMAIL_ADDR, TELNO, STTS_CD, USE_YN, DEL_YN
)
VALUES
('USR_HWANGJW001', 'hwangjw_pm', '황정우', 'hwangjw@cabinlab.co.kr', '01012341234', 'ACTIVE', 'Y', 'N');

INSERT IGNORE INTO TB_SITE (
    SITE_NO, SITE_NM, SITE_EXPLN, SITE_URL_ADDR, SITE_TELNO, PLAN_SE_CD, STTS_CD, USE_YN, DEL_YN
)
VALUES
('SITE_CABINLAB01', '캐빈랩', '에너브레인 고객사 캐빈랩', 'https://cabinlab.co.kr', '0212345678', 'BASIC', 'ACTIVE', 'Y', 'N');

INSERT IGNORE INTO TB_BIZ (
    BIZ_NO, SITE_NO, BIZ_NM, BIZ_CN, BIZ_PRPS, BIZ_BGNG_DT, BIZ_STTS_CD, USE_YN, DEL_YN
)
VALUES
(
    'BIZ_GMSC_2026',
    'SITE_CABINLAB01',
    '광명스마트시티',
    '태양광 발전량 및 전력 소비량 예측 운영 프로젝트',
    '일 단위(D+1) 발전량/소비량 예측 API 제공',
    '2026-01-01 00:00:00',
    'RUN',
    'Y',
    'N'
);

INSERT IGNORE INTO TB_BIZ_MBR (
    BIZ_MBR_NO, BIZ_NO, USER_NO, ROLE_SE_CD, USE_YN, DEL_YN
)
VALUES
('BMBR_GMSC_PM01', 'BIZ_GMSC_2026', 'USR_HWANGJW001', 'PM', 'Y', 'N');

-- 08-3) 데이터 수집/매핑
INSERT IGNORE INTO TB_DATA_SRC (
    DATA_SRC_NO, BIZ_NO, SRC_SE_CD, DATA_SRC_NM, CONN_CN, SRC_EXPLN, STTS_CD, USE_YN, DEL_YN
)
VALUES
(
    'DS_GMSC_ENERGY01',
    'BIZ_GMSC_2026',
    'DB',
    '광명 에너지 집계 DB',
    '{"db_type":"postgresql","host":"10.20.30.11","port":5432,"database":"gms_energy","schema":"public","table":"cust_tbl"}',
    '태양광 발전/소비 원천 데이터',
    'ACTIVE',
    'Y',
    'N'
),
(
    'DS_GMSC_WEATH01',
    'BIZ_GMSC_2026',
    'API',
    '광명 기상 API',
    '{"provider":"kma","endpoint":"https://api.weather.example/v1/obs"}',
    '일사량/기온 외생변수 데이터',
    'ACTIVE',
    'Y',
    'N'
);

INSERT IGNORE INTO TB_CLCT_JOB (
    CLCT_JOB_NO, DATA_SRC_NO, CLCT_JOB_NM, CRON_EXPR_CN, INCRM_KEY_CN, LAST_WTMK_VAL, LAST_SUCC_CLCT_DT, RETRY_CNT, STTS_CD, USE_YN, DEL_YN
)
VALUES
(
    'CJ_GMSC_ENERGY01',
    'DS_GMSC_ENERGY01',
    '광명 에너지 일배치 수집',
    '0 2 * * *',
    'measured_at',
    '2026-04-22T23:59:59',
    '2026-04-23 02:10:00',
    3,
    'RUN',
    'Y',
    'N'
),
(
    'CJ_GMSC_WEATH01',
    'DS_GMSC_WEATH01',
    '광명 기상 일배치 수집',
    '10 2 * * *',
    'obs_time',
    '2026-04-22T23:59:59',
    '2026-04-23 02:20:00',
    3,
    'RUN',
    'Y',
    'N'
);

INSERT IGNORE INTO TB_CLCT_RUN (
    CLCT_RUN_NO, CLCT_JOB_NO, CLCT_BGNG_DT, CLCT_END_DT, CLCT_STTS_CD, CLCT_NOCS, FAIL_NOCS, ERR_CN
)
VALUES
('CR_GMSC_ENERGY01', 'CJ_GMSC_ENERGY01', '2026-04-23 02:00:00', '2026-04-23 02:10:00', 'DONE', 2880, 0, NULL),
('CR_GMSC_WEATH01', 'CJ_GMSC_WEATH01', '2026-04-23 02:10:00', '2026-04-23 02:20:00', 'DONE', 1440, 0, NULL);

INSERT IGNORE INTO TB_MAPP_RULE (
    MAPP_RULE_NO, DATA_SRC_NO, MAPP_RULE_NM, MAPP_RULE_EXPLN, CURR_VER_NO, USE_YN, DEL_YN
)
VALUES
('MR_GMSC_ENERGY', 'DS_GMSC_ENERGY01', '광명 에너지 매핑', 'cust_tbl -> TS_FACT 매핑 규칙', 1, 'Y', 'N'),
('MR_GMSC_WEATH', 'DS_GMSC_WEATH01', '광명 기상 매핑', '기상 API -> TS_FACT 매핑 규칙', 1, 'Y', 'N');

INSERT IGNORE INTO TB_MAPP_RULE_VER (
    MAPP_RULE_VER_NO, MAPP_RULE_NO, VER_NO, RULE_CN, APLCN_BGNG_DT, STTS_CD
)
VALUES
(
    'MRV_GMSC_ENE01',
    'MR_GMSC_ENERGY',
    1,
    '{
      "source_table":"cust_tbl",
      "timestamp_column":"measured_at",
      "timezone":"Asia/Seoul",
      "mappings":[
        {"source":"pv_kw","metric_cd":"PV_GEN_KW","unit_cd":"kW"},
        {"source":"load_kw","metric_cd":"LOAD_KW","unit_cd":"kW"}
      ]
    }',
    '2026-01-01 00:00:00',
    'RUN'
),
(
    'MRV_GMSC_WEA01',
    'MR_GMSC_WEATH',
    1,
    '{
      "source_table":"weather_api",
      "timestamp_column":"obs_time",
      "timezone":"Asia/Seoul",
      "mappings":[
        {"source":"irradiance","metric_cd":"IRRADIANCE","unit_cd":"Wm2"},
        {"source":"temp_c","metric_cd":"TEMP_C","unit_cd":"C"}
      ]
    }',
    '2026-01-01 00:00:00',
    'RUN'
);

INSERT IGNORE INTO TB_QLTY_RULE (
    QLTY_RULE_NO, MAPP_RULE_VER_NO, QLTY_RULE_NM, QLTY_RULE_CN, USE_YN, DEL_YN
)
VALUES
(
    'QR_GMSC_ENE01',
    'MRV_GMSC_ENE01',
    '발전/소비 음수값 점검',
    '{"checks":[{"metric_cd":"PV_GEN_KW","min":0},{"metric_cd":"LOAD_KW","min":0}]}',
    'Y',
    'N'
),
(
    'QR_GMSC_WEA01',
    'MRV_GMSC_WEA01',
    '기온/일사량 범위 점검',
    '{"checks":[{"metric_cd":"TEMP_C","min":-40,"max":60},{"metric_cd":"IRRADIANCE","min":0,"max":1500}]}',
    'Y',
    'N'
);

INSERT IGNORE INTO TB_QLTY_RSLT (
    QLTY_RSLT_NO, CLCT_RUN_NO, QLTY_RULE_NO, CHK_NOCS, FAIL_NOCS, QLTY_STTS_CD, RSLT_CN
)
VALUES
('QRS_GMSC_ENE01', 'CR_GMSC_ENERGY01', 'QR_GMSC_ENE01', 2880, 0, 'GOOD', '품질검증 정상'),
('QRS_GMSC_WEA01', 'CR_GMSC_WEATH01', 'QR_GMSC_WEA01', 1440, 0, 'GOOD', '품질검증 정상');

-- 08-4) RTU/계측기/시계열
INSERT IGNORE INTO TB_RTU (
    RTU_NO, SITE_NO, BIZ_NO, RTU_NM, RTU_SE_CD, INSTL_LOC_NM, STTS_CD, USE_YN, DEL_YN
)
VALUES
('RTU_GMSC_PV01', 'SITE_CABINLAB01', 'BIZ_GMSC_2026', '태양광 RTU 1호', 'PV', '광명 발전동 옥상', 'ACTIVE', 'Y', 'N'),
('RTU_GMSC_LD01', 'SITE_CABINLAB01', 'BIZ_GMSC_2026', '소비 RTU 1호', 'LOAD', '광명 통합관제실', 'ACTIVE', 'Y', 'N');

INSERT IGNORE INTO TB_METER (
    METER_NO, SITE_NO, BIZ_NO, RTU_NO, METER_NM, METER_SE_CD, MEASURE_SE_CD, INSTL_LOC_NM, STTS_CD, USE_YN, DEL_YN
)
VALUES
('MTR_GMSC_PV01', 'SITE_CABINLAB01', 'BIZ_GMSC_2026', 'RTU_GMSC_PV01', '태양광 인버터 계측기 1', 'INVERTER', 'PWR', '태양광 판넬 라인 A', 'ACTIVE', 'Y', 'N'),
('MTR_GMSC_LD01', 'SITE_CABINLAB01', 'BIZ_GMSC_2026', 'RTU_GMSC_LD01', '부하 전력 계측기 1', 'PWR', 'PWR', '수전반 A', 'ACTIVE', 'Y', 'N'),
('MTR_GMSC_ENV01', 'SITE_CABINLAB01', 'BIZ_GMSC_2026', 'RTU_GMSC_PV01', '환경 계측기 1', 'ENV', 'ENV', '옥상 기상대', 'ACTIVE', 'Y', 'N');

INSERT IGNORE INTO TB_TS_RAW_JSON (
    TS_RAW_NO, SITE_NO, BIZ_NO, DATA_SRC_NO, CLCT_RUN_NO, RTU_NO, METER_NO, SRC_ROW_ID, SRC_TS_DT, PAYLOAD_CN, MAPP_RULE_VER_NO, PRCS_STTS_CD, ERR_CN
)
VALUES
(
    'RAW_GMSC_0001',
    'SITE_CABINLAB01',
    'BIZ_GMSC_2026',
    'DS_GMSC_ENERGY01',
    'CR_GMSC_ENERGY01',
    'RTU_GMSC_PV01',
    'MTR_GMSC_PV01',
    'cust_tbl:1001',
    '2026-04-23 00:00:00',
    '{"pv_kw":125.42,"load_kw":301.77,"measured_at":"2026-04-23T00:00:00+09:00"}',
    'MRV_GMSC_ENE01',
    'DONE',
    NULL
),
(
    'RAW_GMSC_0002',
    'SITE_CABINLAB01',
    'BIZ_GMSC_2026',
    'DS_GMSC_WEATH01',
    'CR_GMSC_WEATH01',
    'RTU_GMSC_PV01',
    'MTR_GMSC_ENV01',
    'weather:2001',
    '2026-04-23 00:00:00',
    '{"irradiance":412.5,"temp_c":21.3,"obs_time":"2026-04-23T00:00:00+09:00"}',
    'MRV_GMSC_WEA01',
    'DONE',
    NULL
);

INSERT IGNORE INTO TB_TS_FACT (
    TS_FACT_NO, SITE_NO, BIZ_NO, RTU_NO, METER_NO, TS_DT, METRIC_CD, VAL, UNIT_CD, QLTY_STTS_CD, TS_RAW_NO
)
VALUES
('TSF_GMSC_0001', 'SITE_CABINLAB01', 'BIZ_GMSC_2026', 'RTU_GMSC_PV01', 'MTR_GMSC_PV01', '2026-04-22 15:00:00', 'PV_GEN_KW', 125.42, 'kW', 'GOOD', 'RAW_GMSC_0001'),
('TSF_GMSC_0002', 'SITE_CABINLAB01', 'BIZ_GMSC_2026', 'RTU_GMSC_LD01', 'MTR_GMSC_LD01', '2026-04-22 15:00:00', 'LOAD_KW', 301.77, 'kW', 'GOOD', 'RAW_GMSC_0001'),
('TSF_GMSC_0003', 'SITE_CABINLAB01', 'BIZ_GMSC_2026', 'RTU_GMSC_PV01', 'MTR_GMSC_ENV01', '2026-04-22 15:00:00', 'IRRADIANCE', 412.50, 'Wm2', 'GOOD', 'RAW_GMSC_0002'),
('TSF_GMSC_0004', 'SITE_CABINLAB01', 'BIZ_GMSC_2026', 'RTU_GMSC_PV01', 'MTR_GMSC_ENV01', '2026-04-22 15:00:00', 'TEMP_C', 21.30, 'C', 'GOOD', 'RAW_GMSC_0002');

-- 08-5) 작업/모델/배포
INSERT IGNORE INTO TB_JOB (
    JOB_NO, BIZ_NO, JOB_NM, JOB_SE_CD, JOB_EXPLN, JOB_CNFG_CN, JOB_BGNG_DT, JOB_STTS_CD, USE_YN, DEL_YN
)
VALUES
(
    'JOB_GMSC_TRN01',
    'BIZ_GMSC_2026',
    '광명 D+1 예측 모델 학습',
    'TRN',
    '1년치 데이터 기반 발전량/소비량 예측 모델 학습',
    '{"lookback_days":365,"target_horizon_days":1,"metrics":["PV_GEN_KW","LOAD_KW"],"exogenous":["IRRADIANCE","TEMP_C"]}',
    '2026-04-23 03:00:00',
    'RUN',
    'Y',
    'N'
),
(
    'JOB_GMSC_INFR1',
    'BIZ_GMSC_2026',
    '광명 D+1 예측 추론',
    'INFR',
    '요청된 일자의 발전량/소비량 예측 추론',
    '{"required_params":["target_ymd"],"optional_params":["rtu_no","meter_no"]}',
    '2026-04-23 04:00:00',
    'RUN',
    'Y',
    'N'
);

INSERT IGNORE INTO TB_JOB_RUN (
    JOB_RUN_NO, JOB_NO, RUN_BGNG_DT, RUN_END_DT, RUN_STTS_CD, RUN_RSLT_CN, ERR_CN
)
VALUES
('JR_GMSC_TRN001', 'JOB_GMSC_TRN01', '2026-04-23 03:00:00', '2026-04-23 03:40:00', 'DONE', '학습 완료', NULL),
('JR_GMSC_INF001', 'JOB_GMSC_INFR1', '2026-04-23 04:00:00', '2026-04-23 04:00:10', 'DONE', '추론 완료', NULL);

INSERT IGNORE INTO TB_ALGM (
    ALGM_NO, ALGM_NM, ALGM_SE_CD, ALGM_EXPLN, DFLT_CNFG_CN, USE_YN, DEL_YN
)
VALUES
(
    'ALGM_LGBM_REG',
    'LightGBM 회귀',
    'ML',
    'D+1 발전/소비량 예측 모델',
    '{"objective":"regression","n_estimators":500,"learning_rate":0.03}',
    'Y',
    'N'
);

INSERT IGNORE INTO TB_MODEL_VER (
    MODEL_VER_NO, JOB_NO, ALGM_NO, VER_NO, MODEL_NM, TRN_BGNG_DT, TRN_END_DT, MODEL_STTS_CD, ARTFCT_PATH_NM, CNFG_CN
)
VALUES
(
    'MV_GMSC_202604',
    'JOB_GMSC_TRN01',
    'ALGM_LGBM_REG',
    1,
    '광명 D+1 예측모델 v1',
    '2026-04-23 03:00:00',
    '2026-04-23 03:40:00',
    'READY',
    's3://enerbrain/models/gmsc/202604/v1',
    '{"train_period":"2025-04-01~2026-03-31"}'
);

INSERT IGNORE INTO TB_MODEL_EVAL (
    MODEL_EVAL_NO, MODEL_VER_NO, EVAL_DT, METRIC_CN, PASS_YN, EVAL_EXPLN
)
VALUES
(
    'ME_GMSC_0001',
    'MV_GMSC_202604',
    '2026-04-23 03:45:00',
    '{"PV_GEN_KW":{"MAPE":6.2},"LOAD_KW":{"MAPE":4.8}}',
    'Y',
    '목표 성능 기준 충족'
);

INSERT IGNORE INTO TB_DEPLOY (
    DEPLOY_NO, MODEL_VER_NO, DEPLOY_SE_CD, DEPLOY_STTS_CD, DEPLOY_BGNG_DT, DEPLOY_END_DT, ROUTE_RT, ROLLBACK_YN
)
VALUES
('DP_GMSC_PROD01', 'MV_GMSC_202604', 'PROD', 'RUN', '2026-04-23 05:00:00', NULL, 100.00, 'N');

INSERT IGNORE INTO TB_FCST_RSLT (
    FCST_RSLT_NO, JOB_RUN_NO, MODEL_VER_NO, SITE_NO, BIZ_NO, RTU_NO, METER_NO, TARGET_YMD, FCST_TS_DT, METRIC_CD, FCST_VAL, LOWER_VAL, UPPER_VAL
)
VALUES
('FRC_GMSC_0001', 'JR_GMSC_INF001', 'MV_GMSC_202604', 'SITE_CABINLAB01', 'BIZ_GMSC_2026', 'RTU_GMSC_PV01', 'MTR_GMSC_PV01', '20260424', '2026-04-24 12:00:00', 'PV_GEN_KW', 138.25, 126.10, 149.90),
('FRC_GMSC_0002', 'JR_GMSC_INF001', 'MV_GMSC_202604', 'SITE_CABINLAB01', 'BIZ_GMSC_2026', 'RTU_GMSC_LD01', 'MTR_GMSC_LD01', '20260424', '2026-04-24 12:00:00', 'LOAD_KW', 289.40, 275.00, 304.80);

-- 08-6) API/키/요청로그
INSERT IGNORE INTO TB_API_SVC (
    API_SVC_NO, SITE_NO, BIZ_NO, API_NM, API_EXPLN, BASE_URL_ADDR, API_VER_CD, OPEN_API_YN, STTS_CD, USE_YN, DEL_YN
)
VALUES
(
    'API_GMSC_FCST01',
    'SITE_CABINLAB01',
    'BIZ_GMSC_2026',
    '광명 D+1 예측 API',
    'target_ymd 입력으로 발전량/소비량 예측값 제공',
    'https://api.enerbrain.ai/gmsc/forecast',
    'v1',
    'N',
    'ACTIVE',
    'Y',
    'N'
);

INSERT IGNORE INTO TB_BIZ_API_KEY (
    BIZ_API_KEY_NO, SITE_NO, BIZ_NO, KEY_NM, KEY_HASH_CN, KEY_PREFIX_CN, KEY_STTS_CD, ISSUE_TRGT_USER_NO, ISSUE_CN, ISSUE_DT, EXPR_DT, LAST_USE_DT, REVOKE_DT, RATE_LMT_PER_MIN, IP_WHTLST_CN, USE_YN, DEL_YN
)
VALUES
(
    'BK_GMSC_PM_001',
    'SITE_CABINLAB01',
    'BIZ_GMSC_2026',
    '광명 PM 개발키',
    'sha256:84e8e7f8b9f9f0f4c1fdd33e3c2f06b8ef7c5cf8e9f4a29f4acb83c8a7b6f111',
    'gmsc_pm_',
    'ACTIVE',
    'USR_HWANGJW001',
    '프로젝트 시작 시 PM 전달용 키',
    '2026-04-23 09:00:00',
    '2027-04-22 23:59:59',
    '2026-04-23 09:10:00',
    NULL,
    120,
    '203.0.113.0/24',
    'Y',
    'N'
);

INSERT IGNORE INTO TB_BIZ_API_KEY_ISSU_HIS (
    BIZ_API_KEY_ISSU_HIS_NO, BIZ_API_KEY_NO, ISSU_SE_CD, ISSU_DT, ISSU_USER_NO, ISSU_RSN
)
VALUES
('BKH_GMSC_0001', 'BK_GMSC_PM_001', 'ISSUE', '2026-04-23 09:00:00', 'USR_HWANGJW001', '프로젝트 초기 발급');

INSERT IGNORE INTO TB_OPEN_API_CLNT (
    OPEN_API_CLNT_NO, SITE_NO, CLNT_NM, CLNT_ORG_NM, CLNT_EMAIL_ADDR, CLNT_TELNO, APP_URL_ADDR, CLNT_STTS_CD, USE_YN, DEL_YN
)
VALUES
(
    'OAC_GMSC_0001',
    'SITE_CABINLAB01',
    '광명 외부포털',
    '광명시 데이터포털팀',
    'portal@gmcity.go.kr',
    '0211112222',
    'https://portal.gmcity.go.kr',
    'ACTIVE',
    'Y',
    'N'
);

INSERT IGNORE INTO TB_OPEN_API_KEY (
    OPEN_API_KEY_NO, OPEN_API_CLNT_NO, API_KEY_HASH_CN, API_KEY_PREFIX_CN, KEY_STTS_CD, ISSUE_DT, EXPR_DT, LAST_USE_DT, RATE_LMT_PER_MIN, DAILY_QTA_NOCS, USE_YN, DEL_YN
)
VALUES
(
    'OAK_GMSC_0001',
    'OAC_GMSC_0001',
    'sha256:31b5a4f8f6de89f39cbcc4ea97794646b1fb8ceac0a33a7cf4fe2aabc11ad222',
    'gm_open_',
    'ACTIVE',
    '2026-04-23 10:00:00',
    '2026-12-31 23:59:59',
    NULL,
    30,
    10000,
    'Y',
    'N'
);

INSERT IGNORE INTO TB_OPEN_API_KEY_SVC (
    OPEN_API_KEY_SVC_NO, OPEN_API_KEY_NO, API_SVC_NO, AUTHRT_SE_CD, USE_YN, DEL_YN
)
VALUES
('OAKS_GMSC_001', 'OAK_GMSC_0001', 'API_GMSC_FCST01', 'READ', 'Y', 'N');

INSERT IGNORE INTO TB_API_REQ_LOG (
    API_REQ_LOG_NO, SITE_NO, BIZ_NO, API_SVC_NO, KEY_SE_CD, BIZ_API_KEY_NO, OPEN_API_KEY_NO, REQ_DT, REQ_IP_ADDR, REQ_MTHD_CD, REQ_PATH_NM, RES_STTS_CD, PROC_MSEC, ERR_CN
)
VALUES
(
    'ARL_GMSC_0001',
    'SITE_CABINLAB01',
    'BIZ_GMSC_2026',
    'API_GMSC_FCST01',
    'BIZ',
    'BK_GMSC_PM_001',
    NULL,
    '2026-04-23 09:10:00',
    '203.0.113.10',
    'GET',
    '/gmsc/forecast?target_ymd=20260424',
    '200',
    85,
    NULL
);

-- 08-7) 감사 로그 샘플
INSERT IGNORE INTO TB_AUDIT_LOG (
    AUDIT_LOG_NO, SITE_NO, BIZ_NO, USER_NO, TRGT_TBL_NM, TRGT_PK_NO, ACT_SE_CD, CHG_CN
)
VALUES
(
    'ADT_GMSC_0001',
    'SITE_CABINLAB01',
    'BIZ_GMSC_2026',
    'USR_HWANGJW001',
    'TB_BIZ_API_KEY',
    'BK_GMSC_PM_001',
    'CREATE',
    '{"message":"광명스마트시티 PM 키 발급"}'
);

-- =====================================================================
-- 09. 테이블 설명(Comment) 일괄 정의
-- =====================================================================
-- 주의:
-- 1) CREATE TABLE 시점의 COMMENT 누락을 보완하기 위한 후행 정의
-- 2) 본 섹션은 스키마 생성 후 마지막에 실행해도 무방함

ALTER TABLE TB_COMM_CD COMMENT = '시스템 공통 코드';
ALTER TABLE TB_USER COMMENT = '사용자 기본 정보';
ALTER TABLE TB_SITE COMMENT = '고객사(사이트) 기본 정보';
ALTER TABLE TB_BIZ COMMENT = '사이트 하위 프로젝트(사업) 정보';
ALTER TABLE TB_BIZ_MBR COMMENT = '프로젝트 참여 사용자 정보';

ALTER TABLE TB_JOB COMMENT = '프로젝트 작업(태스크) 정의';
ALTER TABLE TB_JOB_RUN COMMENT = '작업 실행 이력';

ALTER TABLE TB_DATA_SRC COMMENT = '프로젝트별 외부 데이터 소스';
ALTER TABLE TB_CLCT_JOB COMMENT = '데이터 수집 작업 정의';
ALTER TABLE TB_CLCT_RUN COMMENT = '데이터 수집 실행 이력';
ALTER TABLE TB_MAPP_RULE COMMENT = '원천 데이터 매핑 규칙';
ALTER TABLE TB_MAPP_RULE_VER COMMENT = '매핑 규칙 버전 이력';
ALTER TABLE TB_QLTY_RULE COMMENT = '데이터 품질 점검 규칙';
ALTER TABLE TB_QLTY_RSLT COMMENT = '데이터 품질 점검 결과';

ALTER TABLE TB_RTU COMMENT = 'RTU 장비 마스터';
ALTER TABLE TB_METER COMMENT = 'RTU 하위 계측기 마스터';
ALTER TABLE TB_TS_RAW_JSON COMMENT = '원천 시계열 JSON 적재';
ALTER TABLE TB_TS_FACT COMMENT = '정규화 시계열 팩트';
ALTER TABLE TB_FCST_RSLT COMMENT = '예측 결과 시계열';

ALTER TABLE TB_ALGM COMMENT = '알고리즘 마스터';
ALTER TABLE TB_MODEL_VER COMMENT = '모델 버전 관리';
ALTER TABLE TB_MODEL_EVAL COMMENT = '모델 평가 결과';
ALTER TABLE TB_DEPLOY COMMENT = '모델 배포 이력';

ALTER TABLE TB_API_SVC COMMENT = '서비스 API 정의';
ALTER TABLE TB_BIZ_API_KEY COMMENT = '프로젝트별 API 인증키';
ALTER TABLE TB_BIZ_API_KEY_ISSU_HIS COMMENT = '프로젝트 API 키 발급/회전/폐기 이력';
ALTER TABLE TB_OPEN_API_CLNT COMMENT = 'Open API 외부 클라이언트';
ALTER TABLE TB_OPEN_API_KEY COMMENT = 'Open API 인증키';
ALTER TABLE TB_OPEN_API_KEY_SVC COMMENT = 'Open API 키별 서비스 권한';
ALTER TABLE TB_API_REQ_LOG COMMENT = 'API 요청/응답 추적 로그';

ALTER TABLE TB_AUDIT_LOG COMMENT = '시스템 감사 로그';

-- =====================================================================
-- 10. 컬럼 설명(Comment) 일괄 보완
-- =====================================================================
-- 주의:
-- 1) MariaDB는 컬럼 COMMENT 변경 시 MODIFY COLUMN 전체 정의가 필요함
-- 2) 호환성을 위해 MODIFY 구문에서 CHECK 제약은 재선언하지 않음

ALTER TABLE TB_COMM_CD
    MODIFY COLUMN TYPE_CD VARCHAR(40) NOT NULL COMMENT '테이블명(분류 대분류)',
    MODIFY COLUMN GRP_CD VARCHAR(20) NOT NULL COMMENT '컬럼명(분류 그룹)',
    MODIFY COLUMN CD_ID VARCHAR(50) NOT NULL COMMENT '코드ID',
    MODIFY COLUMN CD_NM VARCHAR(20) NOT NULL COMMENT '코드명',
    MODIFY COLUMN EXPLN VARCHAR(100) NOT NULL COMMENT '설명',
    MODIFY COLUMN SORT_ORD DECIMAL(10,0) NOT NULL COMMENT '정렬순서',
    MODIFY COLUMN REG_DT DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '생성일시',
    MODIFY COLUMN REG_USER_ID DECIMAL(10,0) NOT NULL DEFAULT 0 COMMENT '생성자',
    MODIFY COLUMN MOD_DT DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '수정일시',
    MODIFY COLUMN MOD_USER_ID DECIMAL(10,0) NOT NULL DEFAULT 0 COMMENT '수정자',
    MODIFY COLUMN DEL_YN CHAR(1) NOT NULL DEFAULT 'N' COMMENT '삭제여부';

ALTER TABLE TB_USER
    MODIFY COLUMN USER_NO VARCHAR(20) NOT NULL COMMENT '사용자번호',
    MODIFY COLUMN USER_ID VARCHAR(100) NOT NULL COMMENT '사용자ID',
    MODIFY COLUMN USER_NM VARCHAR(100) NOT NULL COMMENT '사용자명',
    MODIFY COLUMN EMAIL_ADDR VARCHAR(200) NULL COMMENT '이메일주소',
    MODIFY COLUMN TELNO VARCHAR(11) NULL COMMENT '전화번호',
    MODIFY COLUMN STTS_CD VARCHAR(20) NULL COMMENT '상태코드',
    MODIFY COLUMN USE_YN CHAR(1) NOT NULL DEFAULT 'Y' COMMENT '사용여부',
    MODIFY COLUMN DEL_YN CHAR(1) NOT NULL DEFAULT 'N' COMMENT '삭제여부',
    MODIFY COLUMN REG_DT DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '생성일시',
    MODIFY COLUMN UPD_DT DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '수정일시';

ALTER TABLE TB_SITE
    MODIFY COLUMN SITE_NO VARCHAR(20) NOT NULL COMMENT '사이트번호(고객사)',
    MODIFY COLUMN SITE_NM VARCHAR(100) NOT NULL COMMENT '사이트명',
    MODIFY COLUMN SITE_EXPLN VARCHAR(4000) NULL COMMENT '사이트설명',
    MODIFY COLUMN SITE_URL_ADDR VARCHAR(2000) NULL COMMENT '사이트URL주소',
    MODIFY COLUMN SITE_TELNO VARCHAR(11) NULL COMMENT '사이트전화번호',
    MODIFY COLUMN PLAN_SE_CD VARCHAR(20) NULL COMMENT '요금제구분코드',
    MODIFY COLUMN STTS_CD VARCHAR(20) NULL COMMENT '상태코드',
    MODIFY COLUMN USE_YN CHAR(1) NOT NULL DEFAULT 'Y' COMMENT '사용여부',
    MODIFY COLUMN DEL_YN CHAR(1) NOT NULL DEFAULT 'N' COMMENT '삭제여부',
    MODIFY COLUMN REG_DT DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '생성일시',
    MODIFY COLUMN UPD_DT DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '수정일시';

ALTER TABLE TB_BIZ
    MODIFY COLUMN BIZ_NO VARCHAR(20) NOT NULL COMMENT '사업번호(프로젝트번호)',
    MODIFY COLUMN SITE_NO VARCHAR(20) NOT NULL COMMENT '사이트번호',
    MODIFY COLUMN BIZ_NM VARCHAR(200) NOT NULL COMMENT '사업명(프로젝트명)',
    MODIFY COLUMN BIZ_CN VARCHAR(2000) NULL COMMENT '사업내용',
    MODIFY COLUMN BIZ_PRPS VARCHAR(4000) NULL COMMENT '사업목적',
    MODIFY COLUMN BIZ_BGNG_DT DATETIME NULL COMMENT '사업시작일시',
    MODIFY COLUMN BIZ_END_DT DATETIME NULL COMMENT '사업종료일시',
    MODIFY COLUMN BIZ_STTS_CD VARCHAR(20) NULL COMMENT '사업상태코드',
    MODIFY COLUMN USE_YN CHAR(1) NOT NULL DEFAULT 'Y' COMMENT '사용여부',
    MODIFY COLUMN DEL_YN CHAR(1) NOT NULL DEFAULT 'N' COMMENT '삭제여부',
    MODIFY COLUMN REG_DT DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '생성일시',
    MODIFY COLUMN UPD_DT DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '수정일시';

ALTER TABLE TB_BIZ_MBR
    MODIFY COLUMN BIZ_MBR_NO VARCHAR(20) NOT NULL COMMENT '사업구성원번호',
    MODIFY COLUMN BIZ_NO VARCHAR(20) NOT NULL COMMENT '사업번호',
    MODIFY COLUMN USER_NO VARCHAR(20) NOT NULL COMMENT '사용자번호',
    MODIFY COLUMN ROLE_SE_CD VARCHAR(20) NOT NULL COMMENT '역할구분코드',
    MODIFY COLUMN USE_YN CHAR(1) NOT NULL DEFAULT 'Y' COMMENT '사용여부',
    MODIFY COLUMN DEL_YN CHAR(1) NOT NULL DEFAULT 'N' COMMENT '삭제여부',
    MODIFY COLUMN REG_DT DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '생성일시',
    MODIFY COLUMN UPD_DT DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '수정일시';

ALTER TABLE TB_JOB
    MODIFY COLUMN JOB_NO VARCHAR(20) NOT NULL COMMENT '작업번호(TASK)',
    MODIFY COLUMN BIZ_NO VARCHAR(20) NOT NULL COMMENT '사업번호',
    MODIFY COLUMN JOB_NM VARCHAR(100) NOT NULL COMMENT '작업명',
    MODIFY COLUMN JOB_SE_CD VARCHAR(20) NOT NULL COMMENT '작업구분코드',
    MODIFY COLUMN JOB_EXPLN VARCHAR(4000) NULL COMMENT '작업설명',
    MODIFY COLUMN JOB_CNFG_CN JSON NULL COMMENT '작업설정내용(JSON)',
    MODIFY COLUMN JOB_BGNG_DT DATETIME NULL COMMENT '작업시작일시',
    MODIFY COLUMN JOB_END_DT DATETIME NULL COMMENT '작업종료일시',
    MODIFY COLUMN JOB_STTS_CD VARCHAR(20) NULL COMMENT '작업상태코드',
    MODIFY COLUMN USE_YN CHAR(1) NOT NULL DEFAULT 'Y' COMMENT '사용여부',
    MODIFY COLUMN DEL_YN CHAR(1) NOT NULL DEFAULT 'N' COMMENT '삭제여부',
    MODIFY COLUMN REG_DT DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '생성일시',
    MODIFY COLUMN UPD_DT DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '수정일시';

ALTER TABLE TB_JOB_RUN
    MODIFY COLUMN JOB_RUN_NO VARCHAR(20) NOT NULL COMMENT '작업실행번호',
    MODIFY COLUMN JOB_NO VARCHAR(20) NOT NULL COMMENT '작업번호',
    MODIFY COLUMN RUN_BGNG_DT DATETIME NOT NULL COMMENT '실행시작일시',
    MODIFY COLUMN RUN_END_DT DATETIME NULL COMMENT '실행종료일시',
    MODIFY COLUMN RUN_STTS_CD VARCHAR(20) NOT NULL COMMENT '실행상태코드',
    MODIFY COLUMN RUN_RSLT_CN VARCHAR(4000) NULL COMMENT '실행결과내용',
    MODIFY COLUMN ERR_CN VARCHAR(4000) NULL COMMENT '오류내용',
    MODIFY COLUMN REG_DT DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '생성일시',
    MODIFY COLUMN UPD_DT DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '수정일시';

ALTER TABLE TB_DATA_SRC
    MODIFY COLUMN DATA_SRC_NO VARCHAR(20) NOT NULL COMMENT '데이터소스번호',
    MODIFY COLUMN BIZ_NO VARCHAR(20) NOT NULL COMMENT '사업번호',
    MODIFY COLUMN SRC_SE_CD VARCHAR(20) NOT NULL COMMENT '소스구분코드(DB/MQTT/FILE/SFTP/API)',
    MODIFY COLUMN DATA_SRC_NM VARCHAR(200) NOT NULL COMMENT '데이터소스명',
    MODIFY COLUMN CONN_CN JSON NOT NULL COMMENT '연결내용(JSON)',
    MODIFY COLUMN SRC_EXPLN VARCHAR(4000) NULL COMMENT '소스설명',
    MODIFY COLUMN STTS_CD VARCHAR(20) NULL COMMENT '상태코드',
    MODIFY COLUMN USE_YN CHAR(1) NOT NULL DEFAULT 'Y' COMMENT '사용여부',
    MODIFY COLUMN DEL_YN CHAR(1) NOT NULL DEFAULT 'N' COMMENT '삭제여부',
    MODIFY COLUMN REG_DT DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '생성일시',
    MODIFY COLUMN UPD_DT DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '수정일시';

ALTER TABLE TB_CLCT_JOB
    MODIFY COLUMN CLCT_JOB_NO VARCHAR(20) NOT NULL COMMENT '수집작업번호',
    MODIFY COLUMN DATA_SRC_NO VARCHAR(20) NOT NULL COMMENT '데이터소스번호',
    MODIFY COLUMN CLCT_JOB_NM VARCHAR(100) NOT NULL COMMENT '수집작업명',
    MODIFY COLUMN CRON_EXPR_CN VARCHAR(100) NULL COMMENT '스케줄식',
    MODIFY COLUMN INCRM_KEY_CN VARCHAR(200) NULL COMMENT '증분키내용',
    MODIFY COLUMN LAST_WTMK_VAL VARCHAR(200) NULL COMMENT '마지막워터마크값',
    MODIFY COLUMN LAST_SUCC_CLCT_DT DATETIME NULL COMMENT '마지막성공수집일시',
    MODIFY COLUMN RETRY_CNT DECIMAL(10,0) NOT NULL DEFAULT 0 COMMENT '재시도횟수',
    MODIFY COLUMN STTS_CD VARCHAR(20) NULL COMMENT '상태코드',
    MODIFY COLUMN USE_YN CHAR(1) NOT NULL DEFAULT 'Y' COMMENT '사용여부',
    MODIFY COLUMN DEL_YN CHAR(1) NOT NULL DEFAULT 'N' COMMENT '삭제여부',
    MODIFY COLUMN REG_DT DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '생성일시',
    MODIFY COLUMN UPD_DT DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '수정일시';

ALTER TABLE TB_CLCT_RUN
    MODIFY COLUMN CLCT_RUN_NO VARCHAR(20) NOT NULL COMMENT '수집실행번호',
    MODIFY COLUMN CLCT_JOB_NO VARCHAR(20) NOT NULL COMMENT '수집작업번호',
    MODIFY COLUMN CLCT_BGNG_DT DATETIME NOT NULL COMMENT '수집시작일시',
    MODIFY COLUMN CLCT_END_DT DATETIME NULL COMMENT '수집종료일시',
    MODIFY COLUMN CLCT_STTS_CD VARCHAR(20) NOT NULL COMMENT '수집상태코드',
    MODIFY COLUMN CLCT_NOCS DECIMAL(10,0) NOT NULL DEFAULT 0 COMMENT '수집건수',
    MODIFY COLUMN FAIL_NOCS DECIMAL(10,0) NOT NULL DEFAULT 0 COMMENT '실패건수',
    MODIFY COLUMN ERR_CN VARCHAR(4000) NULL COMMENT '오류내용',
    MODIFY COLUMN REG_DT DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '생성일시',
    MODIFY COLUMN UPD_DT DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '수정일시';

ALTER TABLE TB_MAPP_RULE
    MODIFY COLUMN MAPP_RULE_NO VARCHAR(20) NOT NULL COMMENT '매핑규칙번호',
    MODIFY COLUMN DATA_SRC_NO VARCHAR(20) NOT NULL COMMENT '데이터소스번호',
    MODIFY COLUMN MAPP_RULE_NM VARCHAR(100) NOT NULL COMMENT '매핑규칙명',
    MODIFY COLUMN MAPP_RULE_EXPLN VARCHAR(4000) NULL COMMENT '매핑규칙설명',
    MODIFY COLUMN CURR_VER_NO DECIMAL(10,0) NOT NULL DEFAULT 1 COMMENT '현재버전번호',
    MODIFY COLUMN USE_YN CHAR(1) NOT NULL DEFAULT 'Y' COMMENT '사용여부',
    MODIFY COLUMN DEL_YN CHAR(1) NOT NULL DEFAULT 'N' COMMENT '삭제여부',
    MODIFY COLUMN REG_DT DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '생성일시',
    MODIFY COLUMN UPD_DT DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '수정일시';

ALTER TABLE TB_MAPP_RULE_VER
    MODIFY COLUMN MAPP_RULE_VER_NO VARCHAR(20) NOT NULL COMMENT '매핑규칙버전번호',
    MODIFY COLUMN MAPP_RULE_NO VARCHAR(20) NOT NULL COMMENT '매핑규칙번호',
    MODIFY COLUMN VER_NO DECIMAL(10,0) NOT NULL COMMENT '버전번호',
    MODIFY COLUMN RULE_CN JSON NOT NULL COMMENT '규칙내용(JSON)',
    MODIFY COLUMN APLCN_BGNG_DT DATETIME NULL COMMENT '적용시작일시',
    MODIFY COLUMN APLCN_END_DT DATETIME NULL COMMENT '적용종료일시',
    MODIFY COLUMN STTS_CD VARCHAR(20) NULL COMMENT '상태코드',
    MODIFY COLUMN REG_DT DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '생성일시',
    MODIFY COLUMN UPD_DT DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '수정일시';

ALTER TABLE TB_QLTY_RULE
    MODIFY COLUMN QLTY_RULE_NO VARCHAR(20) NOT NULL COMMENT '품질규칙번호',
    MODIFY COLUMN MAPP_RULE_VER_NO VARCHAR(20) NOT NULL COMMENT '매핑규칙버전번호',
    MODIFY COLUMN QLTY_RULE_NM VARCHAR(100) NOT NULL COMMENT '품질규칙명',
    MODIFY COLUMN QLTY_RULE_CN JSON NOT NULL COMMENT '품질규칙내용(JSON)',
    MODIFY COLUMN USE_YN CHAR(1) NOT NULL DEFAULT 'Y' COMMENT '사용여부',
    MODIFY COLUMN DEL_YN CHAR(1) NOT NULL DEFAULT 'N' COMMENT '삭제여부',
    MODIFY COLUMN REG_DT DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '생성일시',
    MODIFY COLUMN UPD_DT DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '수정일시';

ALTER TABLE TB_QLTY_RSLT
    MODIFY COLUMN QLTY_RSLT_NO VARCHAR(20) NOT NULL COMMENT '품질결과번호',
    MODIFY COLUMN CLCT_RUN_NO VARCHAR(20) NOT NULL COMMENT '수집실행번호',
    MODIFY COLUMN QLTY_RULE_NO VARCHAR(20) NOT NULL COMMENT '품질규칙번호',
    MODIFY COLUMN CHK_NOCS DECIMAL(10,0) NOT NULL DEFAULT 0 COMMENT '검사건수',
    MODIFY COLUMN FAIL_NOCS DECIMAL(10,0) NOT NULL DEFAULT 0 COMMENT '실패건수',
    MODIFY COLUMN QLTY_STTS_CD VARCHAR(20) NOT NULL COMMENT '품질상태코드',
    MODIFY COLUMN RSLT_CN VARCHAR(4000) NULL COMMENT '결과내용',
    MODIFY COLUMN REG_DT DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '생성일시';

ALTER TABLE TB_RTU
    MODIFY COLUMN RTU_NO VARCHAR(20) NOT NULL COMMENT 'RTU번호',
    MODIFY COLUMN SITE_NO VARCHAR(20) NOT NULL COMMENT '사이트번호',
    MODIFY COLUMN BIZ_NO VARCHAR(20) NOT NULL COMMENT '사업번호',
    MODIFY COLUMN RTU_NM VARCHAR(100) NOT NULL COMMENT 'RTU명',
    MODIFY COLUMN RTU_SE_CD VARCHAR(20) NOT NULL COMMENT 'RTU구분코드',
    MODIFY COLUMN INSTL_LOC_NM VARCHAR(200) NULL COMMENT '설치위치명',
    MODIFY COLUMN STTS_CD VARCHAR(20) NULL COMMENT '상태코드',
    MODIFY COLUMN USE_YN CHAR(1) NOT NULL DEFAULT 'Y' COMMENT '사용여부',
    MODIFY COLUMN DEL_YN CHAR(1) NOT NULL DEFAULT 'N' COMMENT '삭제여부',
    MODIFY COLUMN REG_DT DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '생성일시',
    MODIFY COLUMN UPD_DT DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '수정일시';

ALTER TABLE TB_METER
    MODIFY COLUMN METER_NO VARCHAR(20) NOT NULL COMMENT '계측기번호',
    MODIFY COLUMN SITE_NO VARCHAR(20) NOT NULL COMMENT '사이트번호',
    MODIFY COLUMN BIZ_NO VARCHAR(20) NOT NULL COMMENT '사업번호',
    MODIFY COLUMN RTU_NO VARCHAR(20) NOT NULL COMMENT 'RTU번호',
    MODIFY COLUMN METER_NM VARCHAR(100) NOT NULL COMMENT '계측기명',
    MODIFY COLUMN METER_SE_CD VARCHAR(20) NOT NULL COMMENT '계측기구분코드',
    MODIFY COLUMN MEASURE_SE_CD VARCHAR(20) NULL COMMENT '측정구분코드',
    MODIFY COLUMN INSTL_LOC_NM VARCHAR(200) NULL COMMENT '설치위치명',
    MODIFY COLUMN STTS_CD VARCHAR(20) NULL COMMENT '상태코드',
    MODIFY COLUMN USE_YN CHAR(1) NOT NULL DEFAULT 'Y' COMMENT '사용여부',
    MODIFY COLUMN DEL_YN CHAR(1) NOT NULL DEFAULT 'N' COMMENT '삭제여부',
    MODIFY COLUMN REG_DT DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '생성일시',
    MODIFY COLUMN UPD_DT DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '수정일시';

ALTER TABLE TB_TS_RAW_JSON
    MODIFY COLUMN TS_RAW_NO VARCHAR(20) NOT NULL COMMENT '시계열원천번호',
    MODIFY COLUMN SITE_NO VARCHAR(20) NOT NULL COMMENT '사이트번호',
    MODIFY COLUMN BIZ_NO VARCHAR(20) NOT NULL COMMENT '사업번호',
    MODIFY COLUMN DATA_SRC_NO VARCHAR(20) NOT NULL COMMENT '데이터소스번호',
    MODIFY COLUMN CLCT_RUN_NO VARCHAR(20) NULL COMMENT '수집실행번호',
    MODIFY COLUMN RTU_NO VARCHAR(20) NULL COMMENT 'RTU번호',
    MODIFY COLUMN METER_NO VARCHAR(20) NULL COMMENT '계측기번호',
    MODIFY COLUMN SRC_ROW_ID VARCHAR(100) NULL COMMENT '원천행식별값',
    MODIFY COLUMN SRC_TS_DT DATETIME NULL COMMENT '원천기준일시',
    MODIFY COLUMN PAYLOAD_CN JSON NOT NULL COMMENT '원천페이로드내용',
    MODIFY COLUMN MAPP_RULE_VER_NO VARCHAR(20) NULL COMMENT '매핑규칙버전번호',
    MODIFY COLUMN PRCS_STTS_CD VARCHAR(20) NOT NULL COMMENT '처리상태코드',
    MODIFY COLUMN ERR_CN VARCHAR(4000) NULL COMMENT '오류내용',
    MODIFY COLUMN REG_DT DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '생성일시';

ALTER TABLE TB_TS_FACT
    MODIFY COLUMN TS_FACT_NO VARCHAR(20) NOT NULL COMMENT '시계열팩트번호',
    MODIFY COLUMN SITE_NO VARCHAR(20) NOT NULL COMMENT '사이트번호',
    MODIFY COLUMN BIZ_NO VARCHAR(20) NOT NULL COMMENT '사업번호',
    MODIFY COLUMN RTU_NO VARCHAR(20) NOT NULL COMMENT 'RTU번호',
    MODIFY COLUMN METER_NO VARCHAR(20) NOT NULL COMMENT '계측기번호',
    MODIFY COLUMN TS_DT DATETIME NOT NULL COMMENT '기준일시',
    MODIFY COLUMN METRIC_CD VARCHAR(50) NOT NULL COMMENT '측정지표코드',
    MODIFY COLUMN VAL DECIMAL(18,6) NOT NULL COMMENT '측정값',
    MODIFY COLUMN UNIT_CD VARCHAR(20) NULL COMMENT '단위코드',
    MODIFY COLUMN QLTY_STTS_CD VARCHAR(20) NULL COMMENT '품질상태코드',
    MODIFY COLUMN TS_RAW_NO VARCHAR(20) NULL COMMENT '원천시계열번호',
    MODIFY COLUMN REG_DT DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '생성일시',
    MODIFY COLUMN UPD_DT DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '수정일시';

ALTER TABLE TB_FCST_RSLT
    MODIFY COLUMN FCST_RSLT_NO VARCHAR(20) NOT NULL COMMENT '예측결과번호',
    MODIFY COLUMN JOB_RUN_NO VARCHAR(20) NULL COMMENT '작업실행번호',
    MODIFY COLUMN MODEL_VER_NO VARCHAR(20) NULL COMMENT '모델버전번호',
    MODIFY COLUMN SITE_NO VARCHAR(20) NOT NULL COMMENT '사이트번호',
    MODIFY COLUMN BIZ_NO VARCHAR(20) NOT NULL COMMENT '사업번호',
    MODIFY COLUMN RTU_NO VARCHAR(20) NULL COMMENT 'RTU번호',
    MODIFY COLUMN METER_NO VARCHAR(20) NULL COMMENT '계측기번호',
    MODIFY COLUMN TARGET_YMD VARCHAR(8) NOT NULL COMMENT '예측대상일자(YYYYMMDD)',
    MODIFY COLUMN FCST_TS_DT DATETIME NOT NULL COMMENT '예측기준일시',
    MODIFY COLUMN METRIC_CD VARCHAR(50) NOT NULL COMMENT '예측지표코드',
    MODIFY COLUMN FCST_VAL DECIMAL(18,6) NOT NULL COMMENT '예측값',
    MODIFY COLUMN LOWER_VAL DECIMAL(18,6) NULL COMMENT '하한값',
    MODIFY COLUMN UPPER_VAL DECIMAL(18,6) NULL COMMENT '상한값',
    MODIFY COLUMN REG_DT DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '생성일시',
    MODIFY COLUMN UPD_DT DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '수정일시';

ALTER TABLE TB_ALGM
    MODIFY COLUMN ALGM_NO VARCHAR(20) NOT NULL COMMENT '알고리즘번호',
    MODIFY COLUMN ALGM_NM VARCHAR(100) NOT NULL COMMENT '알고리즘명',
    MODIFY COLUMN ALGM_SE_CD VARCHAR(20) NOT NULL COMMENT '알고리즘구분코드(ML/DL/RL)',
    MODIFY COLUMN ALGM_EXPLN VARCHAR(4000) NULL COMMENT '알고리즘설명',
    MODIFY COLUMN DFLT_CNFG_CN JSON NULL COMMENT '기본설정내용(JSON)',
    MODIFY COLUMN USE_YN CHAR(1) NOT NULL DEFAULT 'Y' COMMENT '사용여부',
    MODIFY COLUMN DEL_YN CHAR(1) NOT NULL DEFAULT 'N' COMMENT '삭제여부',
    MODIFY COLUMN REG_DT DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '생성일시',
    MODIFY COLUMN UPD_DT DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '수정일시';

ALTER TABLE TB_MODEL_VER
    MODIFY COLUMN MODEL_VER_NO VARCHAR(20) NOT NULL COMMENT '모델버전번호',
    MODIFY COLUMN JOB_NO VARCHAR(20) NOT NULL COMMENT '작업번호',
    MODIFY COLUMN ALGM_NO VARCHAR(20) NOT NULL COMMENT '알고리즘번호',
    MODIFY COLUMN VER_NO DECIMAL(10,0) NOT NULL COMMENT '버전번호',
    MODIFY COLUMN MODEL_NM VARCHAR(200) NOT NULL COMMENT '모델명',
    MODIFY COLUMN TRN_BGNG_DT DATETIME NULL COMMENT '학습시작일시',
    MODIFY COLUMN TRN_END_DT DATETIME NULL COMMENT '학습종료일시',
    MODIFY COLUMN MODEL_STTS_CD VARCHAR(20) NOT NULL COMMENT '모델상태코드',
    MODIFY COLUMN ARTFCT_PATH_NM VARCHAR(300) NULL COMMENT '아티팩트경로명',
    MODIFY COLUMN CNFG_CN JSON NULL COMMENT '모델설정내용(JSON)',
    MODIFY COLUMN REG_DT DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '생성일시',
    MODIFY COLUMN UPD_DT DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '수정일시';

ALTER TABLE TB_MODEL_EVAL
    MODIFY COLUMN MODEL_EVAL_NO VARCHAR(20) NOT NULL COMMENT '모델평가번호',
    MODIFY COLUMN MODEL_VER_NO VARCHAR(20) NOT NULL COMMENT '모델버전번호',
    MODIFY COLUMN EVAL_DT DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '평가일시',
    MODIFY COLUMN METRIC_CN JSON NOT NULL COMMENT '평가지표내용(JSON)',
    MODIFY COLUMN PASS_YN CHAR(1) NOT NULL DEFAULT 'N' COMMENT '통과여부',
    MODIFY COLUMN EVAL_EXPLN VARCHAR(4000) NULL COMMENT '평가설명',
    MODIFY COLUMN REG_DT DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '생성일시';

ALTER TABLE TB_DEPLOY
    MODIFY COLUMN DEPLOY_NO VARCHAR(20) NOT NULL COMMENT '배포번호',
    MODIFY COLUMN MODEL_VER_NO VARCHAR(20) NOT NULL COMMENT '모델버전번호',
    MODIFY COLUMN DEPLOY_SE_CD VARCHAR(20) NOT NULL COMMENT '배포구분코드(SHADOW/CANARY/PROD)',
    MODIFY COLUMN DEPLOY_STTS_CD VARCHAR(20) NOT NULL COMMENT '배포상태코드',
    MODIFY COLUMN DEPLOY_BGNG_DT DATETIME NOT NULL COMMENT '배포시작일시',
    MODIFY COLUMN DEPLOY_END_DT DATETIME NULL COMMENT '배포종료일시',
    MODIFY COLUMN ROUTE_RT DECIMAL(5,2) NULL COMMENT '라우팅비율',
    MODIFY COLUMN ROLLBACK_YN CHAR(1) NOT NULL DEFAULT 'N' COMMENT '롤백여부',
    MODIFY COLUMN REG_DT DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '생성일시',
    MODIFY COLUMN UPD_DT DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '수정일시';

ALTER TABLE TB_API_SVC
    MODIFY COLUMN API_SVC_NO VARCHAR(20) NOT NULL COMMENT 'API서비스번호',
    MODIFY COLUMN SITE_NO VARCHAR(20) NOT NULL COMMENT '사이트번호',
    MODIFY COLUMN BIZ_NO VARCHAR(20) NULL COMMENT '사업번호(프로젝트 전용 API일 때)',
    MODIFY COLUMN API_NM VARCHAR(300) NOT NULL COMMENT 'API명',
    MODIFY COLUMN API_EXPLN VARCHAR(4000) NULL COMMENT 'API설명',
    MODIFY COLUMN BASE_URL_ADDR VARCHAR(2000) NOT NULL COMMENT '기본URL주소',
    MODIFY COLUMN API_VER_CD VARCHAR(20) NOT NULL COMMENT 'API버전코드',
    MODIFY COLUMN OPEN_API_YN CHAR(1) NOT NULL DEFAULT 'N' COMMENT '공개 API 여부',
    MODIFY COLUMN STTS_CD VARCHAR(20) NULL COMMENT '상태코드',
    MODIFY COLUMN USE_YN CHAR(1) NOT NULL DEFAULT 'Y' COMMENT '사용여부',
    MODIFY COLUMN DEL_YN CHAR(1) NOT NULL DEFAULT 'N' COMMENT '삭제여부',
    MODIFY COLUMN REG_DT DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '생성일시',
    MODIFY COLUMN UPD_DT DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '수정일시';

ALTER TABLE TB_BIZ_API_KEY
    MODIFY COLUMN BIZ_API_KEY_NO VARCHAR(20) NOT NULL COMMENT '프로젝트API키번호',
    MODIFY COLUMN SITE_NO VARCHAR(20) NOT NULL COMMENT '사이트번호',
    MODIFY COLUMN BIZ_NO VARCHAR(20) NOT NULL COMMENT '사업번호',
    MODIFY COLUMN KEY_NM VARCHAR(100) NOT NULL COMMENT '키명',
    MODIFY COLUMN KEY_HASH_CN VARCHAR(256) NOT NULL COMMENT '키해시내용',
    MODIFY COLUMN KEY_PREFIX_CN VARCHAR(20) NOT NULL COMMENT '키접두내용(표시용)',
    MODIFY COLUMN KEY_STTS_CD VARCHAR(20) NOT NULL COMMENT '키상태코드(ACTIVE/REVOKED/EXPIRED)',
    MODIFY COLUMN ISSUE_TRGT_USER_NO VARCHAR(20) NULL COMMENT '발급대상사용자번호',
    MODIFY COLUMN ISSUE_CN VARCHAR(2000) NULL COMMENT '발급설명',
    MODIFY COLUMN ISSUE_DT DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '발급일시',
    MODIFY COLUMN EXPR_DT DATETIME NULL COMMENT '만료일시',
    MODIFY COLUMN LAST_USE_DT DATETIME NULL COMMENT '최종사용일시',
    MODIFY COLUMN REVOKE_DT DATETIME NULL COMMENT '폐기일시',
    MODIFY COLUMN RATE_LMT_PER_MIN DECIMAL(10,0) NULL COMMENT '분당호출제한건수',
    MODIFY COLUMN IP_WHTLST_CN VARCHAR(4000) NULL COMMENT 'IP허용목록내용',
    MODIFY COLUMN USE_YN CHAR(1) NOT NULL DEFAULT 'Y' COMMENT '사용여부',
    MODIFY COLUMN DEL_YN CHAR(1) NOT NULL DEFAULT 'N' COMMENT '삭제여부',
    MODIFY COLUMN REG_DT DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '생성일시',
    MODIFY COLUMN UPD_DT DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '수정일시';

ALTER TABLE TB_BIZ_API_KEY_ISSU_HIS
    MODIFY COLUMN BIZ_API_KEY_ISSU_HIS_NO VARCHAR(20) NOT NULL COMMENT '프로젝트API키발급이력번호',
    MODIFY COLUMN BIZ_API_KEY_NO VARCHAR(20) NOT NULL COMMENT '프로젝트API키번호',
    MODIFY COLUMN ISSU_SE_CD VARCHAR(20) NOT NULL COMMENT '발급구분코드(ISSUE/ROTATE/REVOKE)',
    MODIFY COLUMN ISSU_DT DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '발급일시',
    MODIFY COLUMN ISSU_USER_NO VARCHAR(20) NULL COMMENT '발급사용자번호',
    MODIFY COLUMN ISSU_RSN VARCHAR(4000) NULL COMMENT '발급사유',
    MODIFY COLUMN REG_DT DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '생성일시';

ALTER TABLE TB_OPEN_API_CLNT
    MODIFY COLUMN OPEN_API_CLNT_NO VARCHAR(20) NOT NULL COMMENT '오픈API클라이언트번호',
    MODIFY COLUMN SITE_NO VARCHAR(20) NOT NULL COMMENT '사이트번호',
    MODIFY COLUMN CLNT_NM VARCHAR(200) NOT NULL COMMENT '클라이언트명',
    MODIFY COLUMN CLNT_ORG_NM VARCHAR(200) NULL COMMENT '클라이언트조직명',
    MODIFY COLUMN CLNT_EMAIL_ADDR VARCHAR(200) NULL COMMENT '클라이언트이메일주소',
    MODIFY COLUMN CLNT_TELNO VARCHAR(11) NULL COMMENT '클라이언트전화번호',
    MODIFY COLUMN APP_URL_ADDR VARCHAR(2000) NULL COMMENT '앱URL주소',
    MODIFY COLUMN CLNT_STTS_CD VARCHAR(20) NOT NULL COMMENT '클라이언트상태코드',
    MODIFY COLUMN USE_YN CHAR(1) NOT NULL DEFAULT 'Y' COMMENT '사용여부',
    MODIFY COLUMN DEL_YN CHAR(1) NOT NULL DEFAULT 'N' COMMENT '삭제여부',
    MODIFY COLUMN REG_DT DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '생성일시',
    MODIFY COLUMN UPD_DT DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '수정일시';

ALTER TABLE TB_OPEN_API_KEY
    MODIFY COLUMN OPEN_API_KEY_NO VARCHAR(20) NOT NULL COMMENT '오픈API키번호',
    MODIFY COLUMN OPEN_API_CLNT_NO VARCHAR(20) NOT NULL COMMENT '오픈API클라이언트번호',
    MODIFY COLUMN API_KEY_HASH_CN VARCHAR(256) NOT NULL COMMENT 'API키해시내용',
    MODIFY COLUMN API_KEY_PREFIX_CN VARCHAR(20) NOT NULL COMMENT 'API키접두내용',
    MODIFY COLUMN KEY_STTS_CD VARCHAR(20) NOT NULL COMMENT '키상태코드',
    MODIFY COLUMN ISSUE_DT DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '발급일시',
    MODIFY COLUMN EXPR_DT DATETIME NULL COMMENT '만료일시',
    MODIFY COLUMN LAST_USE_DT DATETIME NULL COMMENT '최종사용일시',
    MODIFY COLUMN RATE_LMT_PER_MIN DECIMAL(10,0) NULL COMMENT '분당호출제한건수',
    MODIFY COLUMN DAILY_QTA_NOCS DECIMAL(10,0) NULL COMMENT '일별할당건수',
    MODIFY COLUMN USE_YN CHAR(1) NOT NULL DEFAULT 'Y' COMMENT '사용여부',
    MODIFY COLUMN DEL_YN CHAR(1) NOT NULL DEFAULT 'N' COMMENT '삭제여부',
    MODIFY COLUMN REG_DT DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '생성일시',
    MODIFY COLUMN UPD_DT DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '수정일시';

ALTER TABLE TB_OPEN_API_KEY_SVC
    MODIFY COLUMN OPEN_API_KEY_SVC_NO VARCHAR(20) NOT NULL COMMENT '오픈API키서비스번호',
    MODIFY COLUMN OPEN_API_KEY_NO VARCHAR(20) NOT NULL COMMENT '오픈API키번호',
    MODIFY COLUMN API_SVC_NO VARCHAR(20) NOT NULL COMMENT 'API서비스번호',
    MODIFY COLUMN AUTHRT_SE_CD VARCHAR(20) NOT NULL COMMENT '권한구분코드(READ/WRITE/ADMIN)',
    MODIFY COLUMN USE_YN CHAR(1) NOT NULL DEFAULT 'Y' COMMENT '사용여부',
    MODIFY COLUMN DEL_YN CHAR(1) NOT NULL DEFAULT 'N' COMMENT '삭제여부',
    MODIFY COLUMN REG_DT DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '생성일시',
    MODIFY COLUMN UPD_DT DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '수정일시';

ALTER TABLE TB_API_REQ_LOG
    MODIFY COLUMN API_REQ_LOG_NO VARCHAR(20) NOT NULL COMMENT 'API요청로그번호',
    MODIFY COLUMN SITE_NO VARCHAR(20) NOT NULL COMMENT '사이트번호',
    MODIFY COLUMN BIZ_NO VARCHAR(20) NULL COMMENT '사업번호',
    MODIFY COLUMN API_SVC_NO VARCHAR(20) NOT NULL COMMENT 'API서비스번호',
    MODIFY COLUMN KEY_SE_CD VARCHAR(20) NOT NULL COMMENT '키구분코드(BIZ/OPEN)',
    MODIFY COLUMN BIZ_API_KEY_NO VARCHAR(20) NULL COMMENT '프로젝트API키번호',
    MODIFY COLUMN OPEN_API_KEY_NO VARCHAR(20) NULL COMMENT '오픈API키번호',
    MODIFY COLUMN REQ_DT DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '요청일시',
    MODIFY COLUMN REQ_IP_ADDR VARCHAR(45) NULL COMMENT '요청IP주소',
    MODIFY COLUMN REQ_MTHD_CD VARCHAR(10) NULL COMMENT '요청메서드코드',
    MODIFY COLUMN REQ_PATH_NM VARCHAR(1000) NULL COMMENT '요청경로명',
    MODIFY COLUMN RES_STTS_CD VARCHAR(10) NULL COMMENT '응답상태코드',
    MODIFY COLUMN PROC_MSEC DECIMAL(10,0) NULL COMMENT '처리밀리초',
    MODIFY COLUMN ERR_CN VARCHAR(4000) NULL COMMENT '오류내용';

ALTER TABLE TB_AUDIT_LOG
    MODIFY COLUMN AUDIT_LOG_NO VARCHAR(20) NOT NULL COMMENT '감사로그번호',
    MODIFY COLUMN SITE_NO VARCHAR(20) NULL COMMENT '사이트번호',
    MODIFY COLUMN BIZ_NO VARCHAR(20) NULL COMMENT '사업번호',
    MODIFY COLUMN USER_NO VARCHAR(20) NULL COMMENT '사용자번호',
    MODIFY COLUMN TRGT_TBL_NM VARCHAR(100) NOT NULL COMMENT '대상테이블명',
    MODIFY COLUMN TRGT_PK_NO VARCHAR(50) NOT NULL COMMENT '대상PK번호',
    MODIFY COLUMN ACT_SE_CD VARCHAR(20) NOT NULL COMMENT '행위구분코드',
    MODIFY COLUMN CHG_CN JSON NULL COMMENT '변경내용(JSON)',
    MODIFY COLUMN REG_DT DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '생성일시';
