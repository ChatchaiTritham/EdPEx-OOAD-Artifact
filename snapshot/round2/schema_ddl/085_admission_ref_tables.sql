-- DDL extracted from 085_admission_ref_tables.sql (sha256 8eef9e1a78daa714e408842e6e4beac4ada55495733cc374a1cd260df93fffe6)
CREATE TABLE IF NOT EXISTS ref_country (
    code    CHAR(2)      NOT NULL COMMENT 'ISO 3166-1 alpha-2',
    name_th VARCHAR(120) NOT NULL,
    name_en VARCHAR(120) NOT NULL,
    PRIMARY KEY (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ref_campus (
    id      CHAR(36)     NOT NULL,
    code    VARCHAR(20)  NOT NULL,
    name_th VARCHAR(120) NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uq_campus_code (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ref_faculty (
    id        CHAR(36)     NOT NULL,
    tenant_id CHAR(36)     NOT NULL DEFAULT '00000000-0000-4000-a000-000000000001',
    code      VARCHAR(20)  NOT NULL,
    name_th   VARCHAR(190) NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uq_faculty_code (tenant_id, code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ref_student_status (
    status_code               VARCHAR(10)  NOT NULL COMMENT 'real registrar code, e.g. 10/12/40/60/70/80',
    status_name_th            VARCHAR(190) NOT NULL,
    maps_to_enrollment_status ENUM('studying','leave_of_absence','graduated','withdrawn','dismissed') NOT NULL,
    PRIMARY KEY (status_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ref_visa_type (
    code    VARCHAR(40)  NOT NULL COMMENT 'normalized bucket, e.g. ed / non_ed / ed_plus / student_visa / tourist_tr',
    name_en VARCHAR(120) NOT NULL,
    PRIMARY KEY (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ref_document_request_type (
    code    VARCHAR(40)  NOT NULL,
    name_en VARCHAR(120) NOT NULL,
    PRIMARY KEY (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ref_qa_body (
    code    VARCHAR(40)  NOT NULL,
    name_th VARCHAR(190) NOT NULL,
    PRIMARY KEY (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
