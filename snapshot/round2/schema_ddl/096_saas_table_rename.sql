-- DDL extracted from 096_saas_table_rename.sql (sha256 656cd0790b7be60038f7a339d97c320672ef4ab8f3ff60c01d693f61820abd01)
CREATE TABLE IF NOT EXISTS students (
    id                       CHAR(36)     NOT NULL,
    tenant_id                CHAR(36)     NOT NULL DEFAULT '00000000-0000-4000-a000-000000000001',
    student_code             VARCHAR(20)  NULL,
    title                    VARCHAR(40)  NULL,
    name_th                  VARCHAR(190) NULL,
    name_en                  VARCHAR(190) NULL,
    nationality_code         CHAR(2)      NULL COMMENT 'FK ref_country.code (app-level)',
    date_of_birth            VARCHAR(255) NULL COMMENT 'appEncryptPII() at write time — L4',
    passport_no              VARCHAR(255) NULL COMMENT 'appEncryptPII() at write time — L4, display only, NOT lookupable',
    passport_no_bidx         CHAR(64)     NULL COMMENT 'HMAC-SHA256(normalize(passport_no), APP_PDPA_INDEX_KEY) — lookup/dedup',
    passport_issue_date      DATE         NULL,
    passport_expiry_date     DATE         NULL,
    address_line1            VARCHAR(190) NULL,
    address_line2            VARCHAR(190) NULL COMMENT 'เขต/อำเภอ',
    address_province         VARCHAR(120) NULL,
    address_postal_code      VARCHAR(20)  NULL,
    address_country_code     CHAR(2)      NULL COMMENT 'FK ref_country.code (app-level)',
    phone_mobile              VARCHAR(40)  NULL,
    work_status              ENUM('not_working','working') NULL,
    work_company              VARCHAR(190) NULL,
    work_position             VARCHAR(120) NULL,
    family_income_range      VARCHAR(60)  NULL COMMENT 'free-text range as printed by the registrar system, e.g. "150,000-300,000"',
    th_residence_evidence_id CHAR(36)     NULL COMMENT 'FK evidence_documents.id',
    deleted_at               DATETIME     NULL COMMENT 'PDPA retention/erasure — enforces ropa_register.retention_days',
    anonymized_at            DATETIME     NULL,
    created_at               DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at               DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_students_passport_bidx (tenant_id, passport_no_bidx),
    UNIQUE KEY uq_students_code (tenant_id, student_code),
    KEY idx_students_deleted (deleted_at),
    KEY idx_students_nationality (tenant_id, nationality_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS persons (
    id                       CHAR(36)     NOT NULL,
    tenant_id                CHAR(36)     NOT NULL DEFAULT '00000000-0000-4000-a000-000000000001',
    student_code             VARCHAR(20)  NULL,
    title                    VARCHAR(40)  NULL,
    name_th                  VARCHAR(190) NULL,
    name_en                  VARCHAR(190) NULL,
    nationality_code         CHAR(2)      NULL COMMENT 'FK ref_country.code (app-level)',
    date_of_birth            VARCHAR(255) NULL COMMENT 'appEncryptPII() at write time — L4',
    passport_no              VARCHAR(255) NULL COMMENT 'appEncryptPII() at write time — L4, display only, NOT lookupable',
    passport_no_bidx         CHAR(64)     NULL COMMENT 'HMAC-SHA256(normalize(passport_no), APP_PDPA_INDEX_KEY) — lookup/dedup',
    passport_issue_date      DATE         NULL,
    passport_expiry_date     DATE         NULL,
    address_line1            VARCHAR(190) NULL,
    address_line2            VARCHAR(190) NULL,
    address_province         VARCHAR(120) NULL,
    address_postal_code      VARCHAR(20)  NULL,
    address_country_code     CHAR(2)      NULL COMMENT 'FK ref_country.code (app-level)',
    phone_mobile              VARCHAR(40)  NULL,
    work_status              ENUM('not_working','working') NULL,
    work_company              VARCHAR(190) NULL,
    work_position             VARCHAR(120) NULL,
    family_income_range      VARCHAR(60)  NULL,
    th_residence_evidence_id CHAR(36)     NULL COMMENT 'FK evidence_documents.id',
    deleted_at               DATETIME     NULL,
    anonymized_at            DATETIME     NULL,
    created_at               DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at               DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_persons_passport_bidx (tenant_id, passport_no_bidx),
    KEY idx_persons_deleted (deleted_at),
    KEY idx_persons_nationality (tenant_id, nationality_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS visa_records (
    id                    CHAR(36)     NOT NULL,
    tenant_id             CHAR(36)     NOT NULL DEFAULT '00000000-0000-4000-a000-000000000001',
    person_id             CHAR(36)     NOT NULL COMMENT 'FK students.id',
    record_type           ENUM('visa','work_permit') NOT NULL,
    doc_number            VARCHAR(255) NOT NULL COMMENT 'appEncryptPII() at write time — L4, display only',
    doc_number_bidx       CHAR(64)     NOT NULL COMMENT 'HMAC-SHA256 blind index — lookup/dedup, see students',
    issue_date            DATE         NULL,
    expiry_date           DATE         NULL,
    evidence_document_id  CHAR(36)     NULL COMMENT 'FK evidence_documents.id',
    deleted_at            DATETIME     NULL COMMENT 'PDPA retention/erasure, same as students',
    created_at            DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_visa_records_bidx (record_type, doc_number_bidx),
    KEY idx_visa_records_person (person_id),
    KEY idx_visa_records_expiry (expiry_date),
    KEY idx_visa_records_deleted (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS evidence_documents (
    id              CHAR(36)     NOT NULL,
    tenant_id       CHAR(36)     NOT NULL DEFAULT '00000000-0000-4000-a000-000000000001',
    person_id       CHAR(36)     NOT NULL COMMENT 'FK students.id (app-level, no DB constraint)',
    doc_type        ENUM('passport_copy','visa_copy','work_permit','residence_proof','contract','transcript','publication_proof','registration_form','rector_letter','unclassified') NOT NULL,
    storage_path    VARCHAR(255) NOT NULL COMMENT 'outside web root, e.g. storage/admission_evidence/<id>.<ext>',
    file_sha256     CHAR(64)     NOT NULL COMMENT 'integrity + re-ingest dedup',
    import_job_id   CHAR(36)     NULL COMMENT 'FK import_job.id — which ETL batch produced this row',
    status          ENUM('pending','verified','rejected') NOT NULL DEFAULT 'pending',
    rejection_reason VARCHAR(255) NULL COMMENT 'e.g. expired passport, blurry scan',
    verified_by     CHAR(36)     NULL COMMENT 'users.id',
    verified_at     DATETIME     NULL,
    uploaded_by     CHAR(36)     NOT NULL COMMENT 'users.id',
    uploaded_at     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at      DATETIME     NULL COMMENT 'PDPA retention/erasure — consistent with students/visa_records',
    created_at      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_evidence_documents_sha (tenant_id, file_sha256),
    KEY idx_evidence_documents_person (person_id),
    KEY idx_evidence_documents_job (import_job_id),
    KEY idx_evidence_documents_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS graduates (
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
    UNIQUE KEY uq_graduates_student (tenant_id, student_code),
    KEY idx_graduates_level (tenant_id, degree_level),
    KEY idx_graduates_confidence (confidence)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS student_enrollments (
    id                   CHAR(36)     NOT NULL,
    tenant_id            CHAR(36)     NOT NULL DEFAULT '00000000-0000-4000-a000-000000000001',
    person_id            CHAR(36)     NOT NULL COMMENT 'FK students.id',
    campus_id            CHAR(36)     NULL COMMENT 'FK ref_campus.id (app-level)',
    faculty_id           CHAR(36)     NULL COMMENT 'FK ref_faculty.id (app-level)',
    program              VARCHAR(190) NULL,
    level                VARCHAR(60)  NULL,
    level_section        VARCHAR(120) NULL,
    admit_year           SMALLINT     NULL COMMENT 'พ.ศ.',
    admit_semester       TINYINT      NULL,
    student_status_code  SMALLINT     NULL COMMENT 'FK ref_student_status.status_code (app-level)',
    g_code               VARCHAR(40)  NULL COMMENT 'registrar-assigned code, not always unique/present — indexed, not a hard key',
    advisor_name         VARCHAR(190) NULL,
    prior_education_level VARCHAR(120) NULL,
    prior_school         VARCHAR(255) NULL,
    admit_date           DATE         NULL COMMENT 'exact registrar date, complements admit_year/admit_semester',
    credits_earned       SMALLINT     NULL,
    credits_registered   SMALLINT     NULL,
    gpa                  DECIMAL(3,2) NULL,
    created_at           DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at           DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_student_enrollments_person (tenant_id, person_id),
    KEY idx_student_enrollments_status (tenant_id, student_status_code),
    KEY idx_student_enrollments_gcode (tenant_id, g_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS family_contacts (
    id             CHAR(36)     NOT NULL,
    tenant_id      CHAR(36)     NOT NULL DEFAULT '00000000-0000-4000-a000-000000000001',
    person_id      CHAR(36)     NOT NULL COMMENT 'FK students.id — the STUDENT, not this contact',
    role           ENUM('father','mother','guardian','emergency_contact') NOT NULL,
    name           VARCHAR(190) NULL,
    occupation     VARCHAR(190) NULL,
    relationship   VARCHAR(60)  NULL COMMENT 'ความสัมพันธ์กับนักศึกษา ตามที่ระบบต้นทางระบุ (มักซ้ำกับ role)',
    is_deceased    TINYINT(1)   NOT NULL DEFAULT 0,
    phone          VARCHAR(40)  NULL,
    email          VARCHAR(190) NULL,
    address_line1  VARCHAR(190) NULL,
    address_line2  VARCHAR(190) NULL,
    address_province VARCHAR(120) NULL,
    address_postal_code VARCHAR(20) NULL,
    address_country_code CHAR(2) NULL COMMENT 'FK ref_country.code (app-level)',
    created_at     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_family_contacts_role (tenant_id, person_id, role),
    KEY idx_family_contacts_person (person_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS ic_person;

DROP TABLE IF EXISTS ic_visa_record;

DROP TABLE IF EXISTS ic_evidence_document;

DROP TABLE IF EXISTS ic_graduate;

DROP TABLE IF EXISTS ic_student_enrollment;

DROP TABLE IF EXISTS ic_family_contact;
