-- DDL extracted from 120_admission_visa_attendance_lifecycle.sql (sha256 6e257f3fd0e806746c34d97129117fdc8dec468d0da4a634e6e950de4544c669)
CREATE TABLE IF NOT EXISTS ic_student_attendance (
    id                  CHAR(36)       NOT NULL,
    tenant_id           CHAR(36)       NOT NULL DEFAULT '00000000-0000-4000-a000-000000000001',
    student_id          CHAR(36)       NOT NULL COMMENT 'FK ic_person.id or ic_admission_applications.id',
    student_code        VARCHAR(50)    NULL,
    academic_year       INT            NOT NULL DEFAULT 2569,
    semester            INT            NOT NULL DEFAULT 1,
    course_code         VARCHAR(50)    NOT NULL,
    course_name         VARCHAR(255)   NULL,
    session_date        DATE           NOT NULL,
    attendance_status   ENUM('present','absent','late','leave') NOT NULL DEFAULT 'present',
    verified_by         CHAR(36)       NULL COMMENT 'FK users.id (Instructor/Registrar)',
    notes               TEXT           NULL,
    created_at          DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_att_student (tenant_id, student_id),
    KEY idx_att_date (session_date),
    KEY idx_att_status (attendance_status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ic_student_visa_compliance (
    id                          CHAR(36)       NOT NULL,
    tenant_id                   CHAR(36)       NOT NULL DEFAULT '00000000-0000-4000-a000-000000000001',
    student_id                  CHAR(36)       NOT NULL COMMENT 'FK ic_person.id or ic_admission_applications.id',
    student_code                VARCHAR(50)    NULL,
    visa_type                   VARCHAR(30)    NOT NULL DEFAULT 'Non-ED',
    visa_number_enc             VARCHAR(255)   NULL COMMENT 'appEncryptPII()',
    visa_expiry_date            DATE           NOT NULL,
    ninety_day_report_due       DATE           NULL,
    attendance_rate_pct         DECIMAL(5,2)   NOT NULL DEFAULT 100.00,
    academic_status             ENUM('normal','probation','dropout_risk','withdrawn','dismissed') NOT NULL DEFAULT 'normal',
    immigration_alert_status    ENUM('compliant','warning_issued','reported_to_immigration','visa_cancelled') NOT NULL DEFAULT 'compliant',
    immigration_alert_date      DATETIME       NULL,
    immigration_report_ref      VARCHAR(100)   NULL COMMENT 'Official dispatch letter number to Immigration Bureau',
    alert_notes                 TEXT           NULL,
    created_at                  DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at                  DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_student_visa_comp (tenant_id, student_id),
    KEY idx_visa_expiry (visa_expiry_date),
    KEY idx_ninety_day (ninety_day_report_due),
    KEY idx_comp_status (immigration_alert_status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
