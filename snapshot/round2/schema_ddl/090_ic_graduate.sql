-- DDL extracted from 090_ic_graduate.sql (sha256 a3f289399b66458ea0f63f5a47294b02c3005779f1142407cd1fc3cf9e80083f)
CREATE TABLE IF NOT EXISTS ic_graduate (
    id                    CHAR(36)     NOT NULL,
    tenant_id             CHAR(36)     NOT NULL DEFAULT '00000000-0000-4000-a000-000000000001',
    student_code          VARCHAR(20)  NOT NULL,
    degree_level          ENUM('master','phd') NOT NULL,
    program               VARCHAR(120) NOT NULL,
    name_th               VARCHAR(190) NULL,
    name_en               VARCHAR(190) NOT NULL,
    entry_year            SMALLINT     NULL COMMENT 'ปีที่เข้าศึกษา พ.ศ.',
    nationality           VARCHAR(80)  NULL,
    gcode                 VARCHAR(20)  NULL,
    publication_title     VARCHAR(500) NULL,
    publication_citation  VARCHAR(500) NULL COMMENT 'authors · journal · vol(issue):pages · year',
    confidence            ENUM('high','medium','low','not_found','not_searched') NOT NULL DEFAULT 'not_searched',
    notes                 VARCHAR(300) NULL,
    created_at            DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at            DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_ic_graduate_student (tenant_id, student_code),
    KEY idx_ic_graduate_level (tenant_id, degree_level),
    KEY idx_ic_graduate_confidence (confidence)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
