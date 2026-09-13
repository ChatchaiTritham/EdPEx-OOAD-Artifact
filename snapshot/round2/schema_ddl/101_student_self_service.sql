-- DDL extracted from 101_student_self_service.sql (sha256 c66f338d9a315d430818b3e940f3b88a9e89f6c2f11afcd31f87b728434c0085)
CREATE TABLE IF NOT EXISTS student_access_tokens (
    student_code VARCHAR(20) NOT NULL,
    token_hash   CHAR(64)    NOT NULL,
    created_at   DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (student_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS student_update_requests (
    id              CHAR(36)     NOT NULL,
    tenant_id       CHAR(36)     NOT NULL DEFAULT '00000000-0000-4000-a000-000000000001',
    student_code    VARCHAR(20)  NOT NULL,
    submitted_fields TEXT        NOT NULL COMMENT 'JSON: {field: proposed_value} — only fields the submitter actually changed',
    status          ENUM('submitted','approved','rejected') NOT NULL DEFAULT 'submitted',
    submitted_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    reviewed_by     CHAR(36)     NULL COMMENT 'FK users.id (app-level)',
    reviewed_at     DATETIME     NULL,
    reject_reason   VARCHAR(500) NULL,
    PRIMARY KEY (id),
    KEY idx_sur_code (tenant_id, student_code),
    KEY idx_sur_status (tenant_id, status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS student_update_request_files (
    id           CHAR(36)    NOT NULL,
    request_id   CHAR(36)    NOT NULL COMMENT 'FK student_update_requests.id (app-level)',
    doc_type     ENUM('passport','tm30','visa','biblio','grade') NOT NULL,
    storage_path VARCHAR(255) NOT NULL COMMENT 'relative to storage/student_update_requests/<request_id>/',
    created_at   DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_surf_request (request_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
