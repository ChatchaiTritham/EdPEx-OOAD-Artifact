-- DDL extracted from 094_student_enrollment.sql (sha256 6b17dc9ae0bfd5b802174ad41f1b7a5edc3d30d48de149649ffb633af9a60b7f)
CREATE TABLE IF NOT EXISTS ic_student_enrollment (
    id                   CHAR(36)     NOT NULL,
    tenant_id            CHAR(36)     NOT NULL DEFAULT '00000000-0000-4000-a000-000000000001',
    person_id            CHAR(36)     NOT NULL COMMENT 'FK ic_person.id (app-level)',
    campus_id            CHAR(36)     NULL COMMENT 'FK ref_campus.id (app-level)',
    faculty_id           CHAR(36)     NULL COMMENT 'FK ref_faculty.id (app-level)',
    program              VARCHAR(190) NULL,
    level                VARCHAR(60)  NULL,
    level_section        VARCHAR(120) NULL,
    admit_year           SMALLINT     NULL COMMENT 'พ.ศ.',
    admit_semester       TINYINT      NULL,
    student_status_code  SMALLINT     NULL COMMENT 'FK ref_student_status.status_code (app-level)',
    g_code               VARCHAR(40)  NULL COMMENT 'registrar-assigned code, not always unique/present — indexed, not a hard key',
    created_at           DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at           DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_enrollment_person (tenant_id, person_id),
    KEY idx_enrollment_status (tenant_id, student_status_code),
    KEY idx_enrollment_gcode (tenant_id, g_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
