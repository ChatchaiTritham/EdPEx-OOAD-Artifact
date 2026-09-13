-- DDL extracted from 034_fact_tables_w2.sql (sha256 7adcac33792cd8edd05acc6d964656c473aa0679d71364cbd6418e1c100600f5)
CREATE TABLE IF NOT EXISTS fact_graduate_employment (
    id               CHAR(36)        NOT NULL,
    tenant_id        CHAR(36)        NOT NULL,
    academic_year    SMALLINT        NOT NULL COMMENT 'Buddhist-era year (พ.ศ.) of graduation cohort',
    respondent_token CHAR(64)        NOT NULL COMMENT 'SHA-256 hex pseudonym — no PII (class 2)',
    program_key      VARCHAR(40)     NOT NULL DEFAULT '__faculty__' COMMENT 'สาขา/หลักสูตร;

CREATE TABLE IF NOT EXISTS fact_satisfaction_responses (
    id               CHAR(36)        NOT NULL,
    tenant_id        CHAR(36)        NOT NULL,
    academic_year    SMALLINT        NOT NULL COMMENT 'Buddhist-era year (พ.ศ.) of the survey round',
    respondent_token CHAR(64)        NOT NULL COMMENT 'SHA-256 hex pseudonym — no PII (class 2)',
    respondent_type  ENUM('student','graduate','employer','faculty','staff','community')
                                     NOT NULL DEFAULT 'student',
    item_code        VARCHAR(80)     NOT NULL COMMENT 'survey item / dimension code (e.g. teaching_quality)',
    score            DECIMAL(5,2)    NOT NULL COMMENT 'raw score on this item',
    max_score        DECIMAL(5,2)    NULL     DEFAULT NULL COMMENT 'scale maximum (e.g. 5 or 100);

CREATE TABLE IF NOT EXISTS ref_standard_salary (
    id               CHAR(36)        NOT NULL,
    degree_level     ENUM('bachelor','master','doctoral')
                                     NOT NULL,
    academic_year    SMALLINT        NOT NULL COMMENT 'พ.ศ. this standard takes effect (use max year <= grad year)',
    base_salary      DECIMAL(10,2)   NOT NULL COMMENT 'เงินเดือนมาตรฐานแรกบรรจุ (บาท/เดือน)',
    threshold_multiplier DECIMAL(4,2) NOT NULL DEFAULT 1.50 COMMENT 'เกณฑ์ตัวคูณ — 1.5x default per EdPEx indicator',
    source_note      VARCHAR(300)    NULL     DEFAULT NULL,
    created_at       DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at       DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_salary_std (degree_level, academic_year)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Standard first-appointment salary reference — used for 7-1-002 threshold calculation';
