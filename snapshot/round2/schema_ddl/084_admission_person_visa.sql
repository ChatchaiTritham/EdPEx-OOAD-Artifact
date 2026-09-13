-- DDL extracted from 084_admission_person_visa.sql (sha256 aa803a6d7c0e42e8a38d56f00b62e2ee3935fd940abe502cff4cecbdbea6b6ce)
CREATE TABLE IF NOT EXISTS ic_person (
    id                       CHAR(36)     NOT NULL,
    tenant_id                CHAR(36)     NOT NULL DEFAULT '00000000-0000-4000-a000-000000000001',
    person_type              ENUM('student','instructor') NOT NULL,
    title                    VARCHAR(40)  NULL,
    name_th                  VARCHAR(190) NULL,
    name_en                  VARCHAR(190) NULL,
    nationality              VARCHAR(80)  NULL,
    date_of_birth            VARCHAR(255) NULL COMMENT 'appEncryptPII() at write time — L4',
    passport_no              VARCHAR(255) NULL COMMENT 'appEncryptPII() at write time — L4, display only, NOT lookupable',
    passport_no_bidx         CHAR(64)     NULL COMMENT 'HMAC-SHA256(normalize(passport_no), APP_PDPA_INDEX_KEY) — lookup/dedup',
    passport_issue_date      DATE         NULL,
    passport_expiry_date     DATE         NULL,
    th_residence_evidence_id CHAR(36)     NULL COMMENT 'FK ic_evidence_document.id (added in a later migration)',
    deleted_at               DATETIME     NULL COMMENT 'PDPA retention/erasure — enforces ropa_register.retention_days',
    anonymized_at            DATETIME     NULL,
    created_at               DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at               DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_person_passport_bidx (tenant_id, passport_no_bidx),
    KEY idx_person_type (tenant_id, person_type),
    KEY idx_person_deleted (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ic_visa_record (
    id                    CHAR(36)     NOT NULL,
    tenant_id             CHAR(36)     NOT NULL DEFAULT '00000000-0000-4000-a000-000000000001',
    person_id             CHAR(36)     NOT NULL COMMENT 'FK ic_person.id',
    record_type           ENUM('visa','work_permit') NOT NULL,
    doc_number            VARCHAR(255) NOT NULL COMMENT 'appEncryptPII() at write time — L4, display only',
    doc_number_bidx       CHAR(64)     NOT NULL COMMENT 'HMAC-SHA256 blind index — lookup/dedup, see ic_person',
    issue_date            DATE         NULL,
    expiry_date           DATE         NULL,
    evidence_document_id  CHAR(36)     NULL COMMENT 'FK ic_evidence_document.id (added in a later migration)',
    created_at            DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_visa_bidx (record_type, doc_number_bidx),
    KEY idx_visa_person (person_id),
    KEY idx_visa_expiry (expiry_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
