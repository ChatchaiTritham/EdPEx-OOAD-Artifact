-- DDL extracted from 128_curriculum_learning_outcomes.sql (sha256 a2a9275e6458fe53e7a817db8ff048ce45a08e45f20e1b0cd2b078181abf4db8)
CREATE TABLE IF NOT EXISTS obe_curriculum_plos (
    id                CHAR(36)      NOT NULL,
    tenant_id         VARCHAR(40)   NOT NULL DEFAULT 'utk_ic',
    program_code      VARCHAR(50)   NOT NULL COMMENT 'e.g. IC-BBA, IC-IT, IC-THM',
    curriculum_year   SMALLINT      NOT NULL DEFAULT 2565 COMMENT 'พ.ศ. e.g. 2565',
    plo_code          VARCHAR(20)   NOT NULL COMMENT 'e.g. PLO1, PLO2, PLO3',
    title_th          TEXT          NOT NULL,
    title_en          TEXT          NULL,
    domain            ENUM('knowledge','skill','ethics','social_emotional','digital_reasoning') NOT NULL DEFAULT 'knowledge',
    target_percentage DECIMAL(5,2)  NOT NULL DEFAULT 80.00 COMMENT 'เกณฑ์เป้าหมาย เช่น นศ. ไม่น้อยกว่า 80% บรรลุ',
    created_at        DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at        DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_obe_program_plo (tenant_id, program_code, curriculum_year, plo_code),
    KEY idx_obe_program (program_code, curriculum_year)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS obe_course_clo_mappings (
    id                CHAR(36)      NOT NULL,
    tenant_id         VARCHAR(40)   NOT NULL DEFAULT 'utk_ic',
    plo_id            CHAR(36)      NOT NULL COMMENT 'FK obe_curriculum_plos.id',
    course_code       VARCHAR(20)   NOT NULL,
    course_name_th    VARCHAR(255)  NULL,
    emphasis_level    ENUM('I','R','M','A') NOT NULL DEFAULT 'A' COMMENT 'I=Introduced, R=Reinforced, M=Mastered, A=Assessed',
    passing_grade_min VARCHAR(4)    NOT NULL DEFAULT 'C' COMMENT 'Min grade threshold to count as passing PLO benchmark',
    created_at        DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_obe_course_plo (plo_id, course_code),
    KEY idx_obe_mapping_course (course_code),
    CONSTRAINT fk_obe_mapping_plo FOREIGN KEY (plo_id) REFERENCES obe_curriculum_plos(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS obe_plo_evaluation_summaries (
    id                      CHAR(36)      NOT NULL,
    tenant_id               VARCHAR(40)   NOT NULL DEFAULT 'utk_ic',
    plo_id                  CHAR(36)      NOT NULL COMMENT 'FK obe_curriculum_plos.id',
    academic_year           SMALLINT      NOT NULL COMMENT 'พ.ศ.',
    total_students_assessed INT UNSIGNED  NOT NULL DEFAULT 0,
    passed_students_count   INT UNSIGNED  NOT NULL DEFAULT 0,
    attainment_rate         DECIMAL(5,2)  NOT NULL DEFAULT 0.00,
    target_met              TINYINT(1)    NOT NULL DEFAULT 0,
    cqi_plan                TEXT          NULL COMMENT 'Continuous Quality Improvement / Action plan',
    evaluated_by            CHAR(36)      NULL,
    created_at              DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at              DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_obe_summary_year (tenant_id, plo_id, academic_year),
    KEY idx_obe_summary_year (academic_year),
    CONSTRAINT fk_obe_summary_plo FOREIGN KEY (plo_id) REFERENCES obe_curriculum_plos(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
