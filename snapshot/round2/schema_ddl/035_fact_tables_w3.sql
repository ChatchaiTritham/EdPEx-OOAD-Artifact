-- DDL extracted from 035_fact_tables_w3.sql (sha256 0880530c4fe0a16f4d727669f6fd14b01b9efcfc2cfa4007a908045ae3976be7)
CREATE TABLE IF NOT EXISTS fact_curriculum_status (
    id               CHAR(36)        NOT NULL,
    tenant_id        CHAR(36)        NOT NULL,
    academic_year    SMALLINT        NOT NULL COMMENT 'Buddhist-era year e.g. 2567',
    program_key      VARCHAR(40)     NOT NULL COMMENT 'รหัสหลักสูตร/สาขา e.g. CS2566, IT, __faculty__',
    aunqa_score      DECIMAL(5,2)    NULL     DEFAULT NULL COMMENT 'คะแนน AUN-QA (0–9 scale or percent)',
    revised_on_time  TINYINT(1)      NOT NULL DEFAULT 0 COMMENT '1 = หลักสูตรปรับปรุงตามรอบเวลา (5-year cycle)',
    tqf2_submitted   TINYINT(1)      NOT NULL DEFAULT 0 COMMENT '1 = ส่ง TQF2 (มคอ.2) แล้วในปีนี้',
    tqf3_pct         DECIMAL(5,2)    NULL     DEFAULT NULL COMMENT '% รายวิชาที่มี มอค.3 ครบ (0–100)',
    created_at       DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at       DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_curriculum_year_program (tenant_id, academic_year, program_key),
    KEY idx_curr_tenant_year (tenant_id, academic_year),
    KEY idx_curr_program     (program_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Curriculum/program status per year — feeds 7-4-074, 7-4-075, TQF indicators';

CREATE TABLE IF NOT EXISTS fact_kpi_student_enrollment (
    id            CHAR(36)     NOT NULL,
    tenant_id     CHAR(36)     NOT NULL,
    academic_year SMALLINT     NOT NULL,
    program_key   VARCHAR(60)  NOT NULL,
    enrolled      INT          NULL,
    graduated     INT          NULL,
    dropout       INT          NULL,
    gpa_avg       DECIMAL(4,2) NULL,
    created_by    CHAR(36)     NULL,
    created_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_enroll_year_program (tenant_id, academic_year, program_key),
    KEY idx_enroll_year (tenant_id, academic_year)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='REGISTRAR enrollment per year per program (Arc) — feeds 7-1-017/018/019';

CREATE TABLE IF NOT EXISTS it_security_incidents (
    id            CHAR(36)     NOT NULL,
    tenant_id     CHAR(36)     NOT NULL,
    academic_year SMALLINT     NOT NULL,
    event_id      VARCHAR(80)  NOT NULL,
    event_type    VARCHAR(40)  NOT NULL,
    severity      VARCHAR(20)  NULL,
    resolved      TINYINT(1)   NULL,
    dl_test_pct   DECIMAL(5,2) NULL,
    created_by    CHAR(36)     NULL,
    created_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_it_event (tenant_id, event_id),
    KEY idx_it_year (tenant_id, academic_year)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='IT_DIGITAL security events (Arc) — feeds 7-1-031/033/034';
