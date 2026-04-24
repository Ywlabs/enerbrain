-- EnerBrain Database V2.1 (MariaDB, MVP 축소안)
-- 작성 목적:
-- 1) SITE > BIZ > ANALYSIS_ITEM 중심 오케스트레이션
-- 2) SAS(고객사 호출 API) + PAS(내부 운영 API) 인증 분리
-- 3) 불필요한 인력관리/복잡 MLOps 테이블 제외

CREATE DATABASE IF NOT EXISTS enerbrain
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_general_ci;
USE enerbrain;

-- =====================================================================
-- 00. 초기화 (재생성용)
-- =====================================================================

DROP TABLE IF EXISTS TB_AUDIT_LOG;
DROP TABLE IF EXISTS TB_API_REQ_LOG;
DROP TABLE IF EXISTS TB_API_SVC;
DROP TABLE IF EXISTS TB_BIZ_API_KEY;
DROP TABLE IF EXISTS TB_ANALYSIS_RUN;
DROP TABLE IF EXISTS TB_ANALYSIS_ITEM;
DROP TABLE IF EXISTS TB_BIZ;
DROP TABLE IF EXISTS TB_USER_SITE_ROLE;
DROP TABLE IF EXISTS TB_SITE;
DROP TABLE IF EXISTS TB_USER;
DROP TRIGGER IF EXISTS TRG_SET_TB_COMM_CD_MOD_DT;
DROP TABLE IF EXISTS TB_COMM_CD;

-- =====================================================================
-- 01. 공통 코드
-- =====================================================================

CREATE TABLE IF NOT EXISTS TB_COMM_CD (
    TYPE_CD             VARCHAR(40) NOT NULL COMMENT '물리테이블명 또는 COMM_CD',
    GRP_CD              VARCHAR(40) NOT NULL COMMENT '물리컬럼명 또는 코드그룹',
    CD_ID               VARCHAR(50) NOT NULL COMMENT '코드ID',
    CD_NM               VARCHAR(50) NOT NULL COMMENT '코드명',
    EXPLN               VARCHAR(200) NOT NULL COMMENT '설명',
    SORT_ORD            INT NOT NULL COMMENT '정렬순서',
    REG_DT              DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '생성일시',
    REG_USER_ID         VARCHAR(20) NOT NULL DEFAULT 'SYSTEM' COMMENT '생성자ID',
    MOD_DT              DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '수정일시',
    MOD_USER_ID         VARCHAR(20) NOT NULL DEFAULT 'SYSTEM' COMMENT '수정자ID',
    DEL_YN              CHAR(1) NOT NULL DEFAULT 'N' COMMENT '삭제여부',
    PRIMARY KEY (TYPE_CD, GRP_CD, CD_ID)
) ENGINE=InnoDB COMMENT='시스템 공통 코드';

CREATE INDEX IX_TB_COMM_CD_01 ON TB_COMM_CD (GRP_CD, SORT_ORD);

DELIMITER //
CREATE TRIGGER TRG_SET_TB_COMM_CD_MOD_DT
BEFORE UPDATE ON TB_COMM_CD
FOR EACH ROW
BEGIN
    SET NEW.MOD_DT = CURRENT_TIMESTAMP;
END//
DELIMITER ;

-- =====================================================================
-- 02. 사용자 / 인증 / 사이트 / 프로젝트
-- =====================================================================

CREATE TABLE IF NOT EXISTS TB_USER (
    USER_NO             VARCHAR(20) NOT NULL COMMENT '사용자번호',
    USER_ID             VARCHAR(100) NOT NULL COMMENT '로그인ID',
    USER_NM             VARCHAR(100) NOT NULL COMMENT '사용자명',
    GLOBAL_ROLE_CD      VARCHAR(30) NOT NULL DEFAULT 'OPS_ADMIN' COMMENT '전역역할코드(SUPER_ADMIN/OPS_ADMIN)',
    PW_HASH_CN          VARCHAR(255) NOT NULL COMMENT '비밀번호해시(평문저장금지)',
    PW_ALGO_CD          VARCHAR(20) NOT NULL DEFAULT 'ARGON2' COMMENT '해시알고리즘코드',
    FAIL_NOCS           INT NOT NULL DEFAULT 0 COMMENT '로그인실패횟수',
    LAST_LOGIN_DT       DATETIME NULL COMMENT '마지막로그인일시',
    PW_CHG_DT           DATETIME NULL COMMENT '비밀번호변경일시',
    LOCK_DT             DATETIME NULL COMMENT '잠금일시',
    EMAIL_ADDR          VARCHAR(200) NULL COMMENT '이메일',
    TELNO               VARCHAR(20) NULL COMMENT '전화번호',
    STTS_CD             VARCHAR(20) NOT NULL DEFAULT 'ACTIVE' COMMENT '상태코드',
    USE_YN              CHAR(1) NOT NULL DEFAULT 'Y' COMMENT '사용여부',
    DEL_YN              CHAR(1) NOT NULL DEFAULT 'N' COMMENT '삭제여부',
    REG_DT              DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '생성일시',
    UPD_DT              DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '수정일시',
    PRIMARY KEY (USER_NO),
    UNIQUE KEY UQ_TB_USER_01 (USER_ID)
) ENGINE=InnoDB COMMENT='운영 사용자(전역역할 포함)';

CREATE INDEX IX_TB_USER_01 ON TB_USER (GLOBAL_ROLE_CD, STTS_CD);

CREATE TABLE IF NOT EXISTS TB_SITE (
    SITE_NO             VARCHAR(20) NOT NULL COMMENT '사이트번호',
    SITE_NM             VARCHAR(100) NOT NULL COMMENT '업체명',
    CHRGR_NM            VARCHAR(100) NULL COMMENT '담당자명',
    CHRGR_EMAIL_ADDR    VARCHAR(200) NULL COMMENT '담당자이메일',
    CHRGR_TELNO         VARCHAR(20) NULL COMMENT '담당자전화번호',
    SITE_EXPLN          VARCHAR(1000) NULL COMMENT '사이트설명',
    STTS_CD             VARCHAR(20) NOT NULL DEFAULT 'ACTIVE' COMMENT '상태코드',
    USE_YN              CHAR(1) NOT NULL DEFAULT 'Y' COMMENT '사용여부',
    DEL_YN              CHAR(1) NOT NULL DEFAULT 'N' COMMENT '삭제여부',
    REG_DT              DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '생성일시',
    UPD_DT              DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '수정일시',
    PRIMARY KEY (SITE_NO)
) ENGINE=InnoDB COMMENT='고객사 사이트';

CREATE TABLE IF NOT EXISTS TB_USER_SITE_ROLE (
    USER_SITE_ROLE_NO   VARCHAR(20) NOT NULL COMMENT '사용자사이트역할번호',
    USER_NO             VARCHAR(20) NOT NULL COMMENT '사용자번호',
    SITE_NO             VARCHAR(20) NOT NULL COMMENT '사이트번호',
    ROLE_CD             VARCHAR(30) NOT NULL COMMENT '사이트역할코드(SITE_ADMIN/SITE_VIEWER)',
    USE_YN              CHAR(1) NOT NULL DEFAULT 'Y' COMMENT '사용여부',
    DEL_YN              CHAR(1) NOT NULL DEFAULT 'N' COMMENT '삭제여부',
    REG_DT              DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '생성일시',
    UPD_DT              DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '수정일시',
    PRIMARY KEY (USER_SITE_ROLE_NO),
    UNIQUE KEY UQ_TB_USER_SITE_ROLE_01 (USER_NO, SITE_NO, ROLE_CD)
) ENGINE=InnoDB COMMENT='사용자 사이트 범위 역할';

CREATE INDEX IX_TB_USER_SITE_ROLE_01 ON TB_USER_SITE_ROLE (SITE_NO, ROLE_CD);

CREATE TABLE IF NOT EXISTS TB_BIZ (
    BIZ_NO              VARCHAR(20) NOT NULL COMMENT '프로젝트번호',
    SITE_NO             VARCHAR(20) NOT NULL COMMENT '사이트번호',
    BIZ_NM              VARCHAR(200) NOT NULL COMMENT '프로젝트명',
    CHRGR_NM            VARCHAR(100) NULL COMMENT '프로젝트담당자명',
    CHRGR_EMAIL_ADDR    VARCHAR(200) NULL COMMENT '프로젝트담당자이메일',
    BIZ_CN              VARCHAR(2000) NULL COMMENT '프로젝트설명',
    STTS_CD             VARCHAR(20) NOT NULL DEFAULT 'ACTIVE' COMMENT '상태코드',
    USE_YN              CHAR(1) NOT NULL DEFAULT 'Y' COMMENT '사용여부',
    DEL_YN              CHAR(1) NOT NULL DEFAULT 'N' COMMENT '삭제여부',
    REG_DT              DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '생성일시',
    UPD_DT              DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '수정일시',
    PRIMARY KEY (BIZ_NO)
) ENGINE=InnoDB COMMENT='사이트 하위 프로젝트';

CREATE INDEX IX_TB_BIZ_01 ON TB_BIZ (SITE_NO, STTS_CD);

-- =====================================================================
-- 03. 분석 오케스트레이션
-- =====================================================================

CREATE TABLE IF NOT EXISTS TB_ANALYSIS_ITEM (
    ANALYSIS_ITEM_NO    VARCHAR(20) NOT NULL COMMENT '분석항목번호',
    BIZ_NO              VARCHAR(20) NOT NULL COMMENT '프로젝트번호',
    ITEM_NM             VARCHAR(200) NOT NULL COMMENT '분석항목명',
    ALGM_CD             VARCHAR(50) NOT NULL COMMENT '분석알고리즘코드',
    ITEM_EXPLN          VARCHAR(2000) NULL COMMENT '분석항목설명',
    STTS_CD             VARCHAR(20) NOT NULL DEFAULT 'ACTIVE' COMMENT '상태코드',
    CRON_EXPR_CN        VARCHAR(100) NULL COMMENT '배치주기(CRONTAB)',
    MODULE_PATH_CN      VARCHAR(500) NOT NULL COMMENT '실행파이썬파일경로',
    ENTRY_FUNC_NM       VARCHAR(100) NOT NULL DEFAULT 'run' COMMENT '실행함수명',
    MODEL_FILE_NM_CN    VARCHAR(200) NULL COMMENT '생성모델파일명(기준정보)',
    PARAMS_JSON         JSON NULL COMMENT '실행파라미터JSON',
    TIMEOUT_SEC         INT NOT NULL DEFAULT 600 COMMENT '실행타임아웃초',
    RETRY_CNT           INT NOT NULL DEFAULT 0 COMMENT '재시도횟수',
    USE_YN              CHAR(1) NOT NULL DEFAULT 'Y' COMMENT '사용여부',
    DEL_YN              CHAR(1) NOT NULL DEFAULT 'N' COMMENT '삭제여부',
    REG_DT              DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '생성일시',
    UPD_DT              DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '수정일시',
    PRIMARY KEY (ANALYSIS_ITEM_NO)
) ENGINE=InnoDB COMMENT='분석항목 설정';

CREATE INDEX IX_TB_ANALYSIS_ITEM_01 ON TB_ANALYSIS_ITEM (BIZ_NO, STTS_CD);
CREATE INDEX IX_TB_ANALYSIS_ITEM_02 ON TB_ANALYSIS_ITEM (CRON_EXPR_CN);

CREATE TABLE IF NOT EXISTS TB_ANALYSIS_RUN (
    ANALYSIS_RUN_NO     VARCHAR(20) NOT NULL COMMENT '분석실행번호',
    ANALYSIS_ITEM_NO    VARCHAR(20) NOT NULL COMMENT '분석항목번호',
    RUN_BGNG_DT         DATETIME NOT NULL COMMENT '실행시작일시',
    RUN_END_DT          DATETIME NULL COMMENT '실행종료일시',
    RUN_STTS_CD         VARCHAR(20) NOT NULL COMMENT '실행상태코드(RUN/DONE/FAIL)',
    PROC_MSEC           INT NULL COMMENT '분석처리밀리초',
    INPUT_NOCS          INT NULL COMMENT '입력데이터건수',
    OUTPUT_NOCS         INT NULL COMMENT '출력데이터건수',
    RUN_RSLT_JSON       JSON NULL COMMENT '실행결과요약JSON',
    RUN_MODEL_JSON      JSON NULL COMMENT '모델결과JSON(모델경로/버전/지표/대표여부)',
    ERR_CN              VARCHAR(4000) NULL COMMENT '오류내용',
    REG_DT              DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '생성일시',
    PRIMARY KEY (ANALYSIS_RUN_NO)
) ENGINE=InnoDB COMMENT='분석항목 실행이력';

CREATE INDEX IX_TB_ANALYSIS_RUN_01 ON TB_ANALYSIS_RUN (ANALYSIS_ITEM_NO, RUN_BGNG_DT);
CREATE INDEX IX_TB_ANALYSIS_RUN_02 ON TB_ANALYSIS_RUN (RUN_STTS_CD, RUN_BGNG_DT);

-- =====================================================================
-- 04. 서비스 API / 요청 로그
-- =====================================================================

CREATE TABLE IF NOT EXISTS TB_BIZ_API_KEY (
    BIZ_API_KEY_NO      VARCHAR(20) NOT NULL COMMENT '프로젝트API키번호',
    BIZ_NO              VARCHAR(20) NOT NULL COMMENT '프로젝트번호',
    KEY_NM              VARCHAR(100) NOT NULL COMMENT '키명',
    KEY_HASH_CN         VARCHAR(255) NOT NULL COMMENT '키해시값(평문저장금지)',
    KEY_PREFIX_CN       VARCHAR(30) NOT NULL COMMENT '키접두어(표시용)',
    KEY_STTS_CD         VARCHAR(20) NOT NULL DEFAULT 'ACTIVE' COMMENT '키상태코드',
    EXPR_DT             DATETIME NULL COMMENT '만료일시',
    RATE_LMT_PER_MIN    INT NULL COMMENT '분당호출제한건수',
    ISSUE_CN            VARCHAR(1000) NULL COMMENT '발급사유',
    LAST_USE_DT         DATETIME NULL COMMENT '마지막사용일시',
    REVOKE_DT           DATETIME NULL COMMENT '폐기일시',
    USE_YN              CHAR(1) NOT NULL DEFAULT 'Y' COMMENT '사용여부',
    DEL_YN              CHAR(1) NOT NULL DEFAULT 'N' COMMENT '삭제여부',
    REG_DT              DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '생성일시',
    UPD_DT              DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '수정일시',
    PRIMARY KEY (BIZ_API_KEY_NO)
) ENGINE=InnoDB COMMENT='프로젝트 API 키(SAS 인증용)';

CREATE INDEX IX_TB_BIZ_API_KEY_01 ON TB_BIZ_API_KEY (BIZ_NO, KEY_STTS_CD, EXPR_DT);
CREATE INDEX IX_TB_BIZ_API_KEY_02 ON TB_BIZ_API_KEY (KEY_HASH_CN);

CREATE TABLE IF NOT EXISTS TB_API_SVC (
    API_SVC_NO          VARCHAR(20) NOT NULL COMMENT 'API서비스번호',
    BIZ_NO              VARCHAR(20) NOT NULL COMMENT '프로젝트번호',
    API_NM              VARCHAR(200) NOT NULL COMMENT '서비스API명',
    API_PATH_CN         VARCHAR(500) NOT NULL COMMENT '서비스API경로',
    REQ_MTHD_CD         VARCHAR(10) NOT NULL COMMENT '요청메서드코드(GET/POST/PUT/DELETE)',
    API_EXPLN           VARCHAR(1000) NULL COMMENT '서비스API설명',
    TEST_REQ_JSON       JSON NULL COMMENT '테스트요청샘플JSON',
    TEST_RES_JSON       JSON NULL COMMENT '테스트응답샘플JSON',
    STTS_CD             VARCHAR(20) NOT NULL DEFAULT 'ACTIVE' COMMENT '상태코드',
    USE_YN              CHAR(1) NOT NULL DEFAULT 'Y' COMMENT '사용여부',
    DEL_YN              CHAR(1) NOT NULL DEFAULT 'N' COMMENT '삭제여부',
    REG_DT              DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '생성일시',
    UPD_DT              DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '수정일시',
    PRIMARY KEY (API_SVC_NO)
) ENGINE=InnoDB COMMENT='고객사 제공용 서비스 API 메타/테스트 정보';

CREATE INDEX IX_TB_API_SVC_01 ON TB_API_SVC (BIZ_NO, STTS_CD);
CREATE INDEX IX_TB_API_SVC_02 ON TB_API_SVC (API_PATH_CN, REQ_MTHD_CD);

CREATE TABLE IF NOT EXISTS TB_API_REQ_LOG (
    API_REQ_LOG_NO      VARCHAR(20) NOT NULL COMMENT 'API요청로그번호',
    API_SVC_NO          VARCHAR(20) NOT NULL COMMENT 'API서비스번호',
    BIZ_NO              VARCHAR(20) NULL COMMENT '프로젝트번호',
    USER_NO             VARCHAR(20) NULL COMMENT '사용자번호(PAS 호출 시)',
    BIZ_API_KEY_NO      VARCHAR(20) NULL COMMENT '프로젝트API키번호(SAS 호출 시)',
    REQ_DT              DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '요청일시',
    REQ_IP_ADDR         VARCHAR(45) NULL COMMENT '요청IP주소',
    REQ_MTHD_CD         VARCHAR(10) NULL COMMENT '요청메서드코드',
    REQ_PATH_CN         VARCHAR(1000) NULL COMMENT '요청경로',
    RES_STTS_CD         VARCHAR(10) NULL COMMENT '응답상태코드',
    PROC_MSEC           INT NULL COMMENT '처리밀리초',
    ERR_CN              VARCHAR(4000) NULL COMMENT '오류내용',
    PRIMARY KEY (API_REQ_LOG_NO)
) ENGINE=InnoDB COMMENT='API 요청 로그';

CREATE INDEX IX_TB_API_REQ_LOG_01 ON TB_API_REQ_LOG (API_SVC_NO, REQ_DT);
CREATE INDEX IX_TB_API_REQ_LOG_02 ON TB_API_REQ_LOG (BIZ_NO, REQ_DT);
CREATE INDEX IX_TB_API_REQ_LOG_03 ON TB_API_REQ_LOG (BIZ_API_KEY_NO, REQ_DT);

-- =====================================================================
-- 05. 감사 로그
-- =====================================================================

CREATE TABLE IF NOT EXISTS TB_AUDIT_LOG (
    AUDIT_LOG_NO        VARCHAR(20) NOT NULL COMMENT '감사로그번호',
    USER_NO             VARCHAR(20) NULL COMMENT '행위자사용자번호',
    SITE_NO             VARCHAR(20) NULL COMMENT '사이트번호',
    BIZ_NO              VARCHAR(20) NULL COMMENT '프로젝트번호',
    TRGT_TBL_NM         VARCHAR(100) NOT NULL COMMENT '대상테이블명',
    TRGT_PK_CN          VARCHAR(200) NOT NULL COMMENT '대상PK문자열',
    ACT_SE_CD           VARCHAR(20) NOT NULL COMMENT '행위구분코드(CREATE/UPDATE/DELETE)',
    CHG_JSON            JSON NULL COMMENT '변경내용JSON',
    REG_DT              DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '생성일시',
    PRIMARY KEY (AUDIT_LOG_NO)
) ENGINE=InnoDB COMMENT='감사 로그';

CREATE INDEX IX_TB_AUDIT_LOG_01 ON TB_AUDIT_LOG (REG_DT);
CREATE INDEX IX_TB_AUDIT_LOG_02 ON TB_AUDIT_LOG (USER_NO, REG_DT);

-- =====================================================================
-- 06. 초기 코드/샘플 운영계정 (선택)
-- =====================================================================

INSERT IGNORE INTO TB_COMM_CD
(TYPE_CD, GRP_CD, CD_ID, CD_NM, EXPLN, SORT_ORD, REG_USER_ID, MOD_USER_ID)
VALUES
('COMM_CD', 'STTS_CD', 'ACTIVE', '활성', '활성 상태', 1, 'SYSTEM', 'SYSTEM'),
('COMM_CD', 'STTS_CD', 'INACTIVE', '비활성', '비활성 상태', 2, 'SYSTEM', 'SYSTEM'),
('COMM_CD', 'RUN_STTS_CD', 'RUN', '실행중', '실행중 상태', 1, 'SYSTEM', 'SYSTEM'),
('COMM_CD', 'RUN_STTS_CD', 'DONE', '완료', '완료 상태', 2, 'SYSTEM', 'SYSTEM'),
('COMM_CD', 'RUN_STTS_CD', 'FAIL', '실패', '실패 상태', 3, 'SYSTEM', 'SYSTEM'),
('COMM_CD', 'GLOBAL_ROLE_CD', 'SUPER_ADMIN', '전체관리자', '모든 사이트/프로젝트 권한', 1, 'SYSTEM', 'SYSTEM'),
('COMM_CD', 'GLOBAL_ROLE_CD', 'OPS_ADMIN', '운영관리자', '운영 관리자 권한', 2, 'SYSTEM', 'SYSTEM'),
('COMM_CD', 'SITE_ROLE_CD', 'SITE_ADMIN', '사이트관리자', '사이트 단위 권한', 1, 'SYSTEM', 'SYSTEM'),
('COMM_CD', 'SITE_ROLE_CD', 'SITE_VIEWER', '사이트조회자', '사이트 조회 권한', 2, 'SYSTEM', 'SYSTEM'),
('TB_BIZ_API_KEY', 'KEY_STTS_CD', 'ACTIVE', '활성', '사용 가능 키', 1, 'SYSTEM', 'SYSTEM'),
('TB_BIZ_API_KEY', 'KEY_STTS_CD', 'REVOKED', '폐기', '폐기된 키', 2, 'SYSTEM', 'SYSTEM'),
('TB_BIZ_API_KEY', 'KEY_STTS_CD', 'EXPIRED', '만료', '만료된 키', 3, 'SYSTEM', 'SYSTEM');

INSERT IGNORE INTO TB_USER
(USER_NO, USER_ID, USER_NM, GLOBAL_ROLE_CD, PW_HASH_CN, PW_ALGO_CD, EMAIL_ADDR, STTS_CD, USE_YN, DEL_YN)
VALUES
(
    'USR0000001',
    'admin',
    '전체관리자',
    'SUPER_ADMIN',
    '$argon2id$v=19$m=65536,t=3,p=4$REPLACE_WITH_REAL_HASH',
    'ARGON2',
    'admin@enerbrain.ai',
    'ACTIVE',
    'Y',
    'N'
);

-- =====================================================================
-- 07. 샘플 데이터 (SITE / BIZ / ANALYSIS_ITEM)
-- =====================================================================

INSERT IGNORE INTO TB_SITE
(SITE_NO, SITE_NM, CHRGR_NM, CHRGR_EMAIL_ADDR, CHRGR_TELNO, SITE_EXPLN, STTS_CD, USE_YN, DEL_YN)
VALUES
(
    'SITE_CABINLAB01',
    '캐빈랩',
    '황정우',
    'hwangjw@cabinlab.co.kr',
    '01012341234',
    '에너브레인 고객사 캐빈랩',
    'ACTIVE',
    'Y',
    'N'
);

INSERT IGNORE INTO TB_BIZ
(BIZ_NO, SITE_NO, BIZ_NM, CHRGR_NM, CHRGR_EMAIL_ADDR, BIZ_CN, STTS_CD, USE_YN, DEL_YN)
VALUES
(
    'BIZ_GMSC_2026',
    'SITE_CABINLAB01',
    '광명스마트시티',
    '황정우',
    'hwangjw@cabinlab.co.kr',
    '광명 스마트시티 에너지 예측 분석 프로젝트',
    'ACTIVE',
    'Y',
    'N'
);

INSERT IGNORE INTO TB_ANALYSIS_ITEM
(
    ANALYSIS_ITEM_NO, BIZ_NO, ITEM_NM, ALGM_CD, ITEM_EXPLN, STTS_CD,
    CRON_EXPR_CN, MODULE_PATH_CN, ENTRY_FUNC_NM, MODEL_FILE_NM_CN, PARAMS_JSON, TIMEOUT_SEC, RETRY_CNT, USE_YN, DEL_YN
)
VALUES
(
    'AI_GMSC_D1_001',
    'BIZ_GMSC_2026',
    '광명 D+1 전력예측',
    'LGBM_REG',
    '일 단위(D+1) 발전량/소비량 예측',
    'ACTIVE',
    '0 2 * * *',
    'jobs/gmsc_d1_forecast.py',
    'run',
    'model_gmsc_d1.pkl',
    JSON_OBJECT(
        'target_metrics', JSON_ARRAY('PV_GEN_KW', 'LOAD_KW'),
        'lookback_days', 365,
        'timezone', 'Asia/Seoul'
    ),
    1200,
    1,
    'Y',
    'N'
),
(
    'AI_GMSC_MON_001',
    'BIZ_GMSC_2026',
    '광명 월간 리포트 집계',
    'RULE_BASED',
    '월간 집계/리포트 생성 작업',
    'ACTIVE',
    '30 3 1 * *',
    'jobs/gmsc_monthly_report.py',
    'run',
    'model_gmsc_monthly.pkl',
    JSON_OBJECT(
        'report_type', 'MONTHLY',
        'output_format', 'json'
    ),
    900,
    0,
    'Y',
    'N'
);

-- =====================================================================
-- 08. 샘플 데이터 (TB_USER_SITE_ROLE)
-- =====================================================================

INSERT IGNORE INTO TB_USER
(
    USER_NO, USER_ID, USER_NM, GLOBAL_ROLE_CD, PW_HASH_CN, PW_ALGO_CD,
    EMAIL_ADDR, STTS_CD, USE_YN, DEL_YN
)
VALUES
(
    'USR0000002',
    'ops_gmsc',
    '광명운영자',
    'OPS_ADMIN',
    '$argon2id$v=19$m=65536,t=3,p=4$REPLACE_WITH_REAL_HASH',
    'ARGON2',
    'ops_gmsc@cabinlab.co.kr',
    'ACTIVE',
    'Y',
    'N'
);

INSERT IGNORE INTO TB_USER_SITE_ROLE
(
    USER_SITE_ROLE_NO, USER_NO, SITE_NO, ROLE_CD, USE_YN, DEL_YN
)
VALUES
(
    'USR_SITE_0001',
    'USR0000002',
    'SITE_CABINLAB01',
    'SITE_ADMIN',
    'Y',
    'N'
);
