-- DDL extracted from 101_student_data_remarks.sql (sha256 8ea77aa47f9dc6d6809cdb1b92f6499f0619aaf112b82459e629a65d67322b9b)
CREATE TABLE IF NOT EXISTS student_data_remarks (
    id           CHAR(36)     NOT NULL,
    tenant_id    CHAR(36)     NOT NULL DEFAULT '00000000-0000-4000-a000-000000000001',
    person_id    CHAR(36)     NOT NULL COMMENT 'FK students.id',
    field_name   VARCHAR(60)  NOT NULL COMMENT 'students column this remark is about, e.g. date_of_birth, citizen_id_no',
    confidence   ENUM('confirmed','needs_review','other') NOT NULL DEFAULT 'needs_review',
    remark_text  VARCHAR(500) NOT NULL,
    source       VARCHAR(100) NULL COMMENT 'how the value was derived, e.g. ocr_mrz_partial, ocr_citizen_id_checksum',
    created_by   CHAR(36)     NULL,
    created_at   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at   DATETIME     NULL COMMENT 'set once staff has verified/resolved this remark against the source document',
    PRIMARY KEY (id),
    KEY idx_remarks_person (person_id, field_name),
    KEY idx_remarks_deleted (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
