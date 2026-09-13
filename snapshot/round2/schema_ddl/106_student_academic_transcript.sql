-- DDL extracted from 106_student_academic_transcript.sql (sha256 a3b51a86c628c527af94aecd2643757cc61f9b6a620babb0c973bfd0d0c56f2e)
CREATE TABLE IF NOT EXISTS student_courses (
    id                CHAR(36)     NOT NULL,
    tenant_id         CHAR(36)     NOT NULL DEFAULT '00000000-0000-4000-a000-000000000001',
    person_id         CHAR(36)     NOT NULL COMMENT 'FK students.id (app-level)',
    academic_year     SMALLINT     NOT NULL COMMENT 'พ.ศ., e.g. 2567',
    semester          TINYINT      NOT NULL COMMENT '1, 2, or 3 (ภาคฤดูร้อน)',
    course_code       VARCHAR(20)  NOT NULL,
    course_name_th    VARCHAR(255) NULL,
    course_name_en    VARCHAR(255) NULL,
    credits           DECIMAL(3,1) NOT NULL DEFAULT 0.0,
    grade             VARCHAR(4)   NULL COMMENT 'A, B+, B, C+, C, D+, D, F, W, I, S, U, P — as printed by the registrar, not normalized',
    grade_point       DECIMAL(3,2) NULL COMMENT 'numeric point for this course if the registrar form prints one (4.00, 3.50, ...);

CREATE TABLE IF NOT EXISTS student_term_summaries (
    id                      CHAR(36)     NOT NULL,
    tenant_id               CHAR(36)     NOT NULL DEFAULT '00000000-0000-4000-a000-000000000001',
    person_id               CHAR(36)     NOT NULL COMMENT 'FK students.id (app-level)',
    academic_year           SMALLINT     NOT NULL,
    semester                TINYINT      NOT NULL,
    credits_registered_term SMALLINT     NULL,
    credits_earned_term     SMALLINT     NULL,
    gpa_term                DECIMAL(3,2) NULL COMMENT 'เกรดเฉลี่ยภาคการศึกษานี้ (GPAX เฉพาะภาค)',
    credits_earned_cumulative SMALLINT   NULL,
    gpa_cumulative          DECIMAL(3,2) NULL COMMENT 'เกรดเฉลี่ยสะสม (GPAX) ณ สิ้นภาคนี้',
    student_status_code     SMALLINT     NULL COMMENT 'FK ref_student_status.status_code (app-level) — status as of this term, not necessarily current',
    source_evidence_path    VARCHAR(255) NULL COMMENT 'storage/student_docs/<code>/... this row was transcribed from, if any',
    created_at              DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at              DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_student_term_summaries (tenant_id, person_id, academic_year, semester),
    KEY idx_student_term_summaries_person (person_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
