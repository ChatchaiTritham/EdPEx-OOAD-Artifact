-- DDL extracted from 112_student_digital_forms.sql (sha256 8c79c24e967d6c8d3eaf766fc3d14ffc4f3c64a0285c10f33731239ca94a2916)
CREATE TABLE IF NOT EXISTS ref_form_templates (
    id                   CHAR(36)     NOT NULL,
    form_code            VARCHAR(50)  NOT NULL COMMENT 'Unique form code identifier',
    form_name_th         VARCHAR(255) NOT NULL,
    form_name_en         VARCHAR(255) NOT NULL,
    category             VARCHAR(60)  NOT NULL COMMENT 'admission | immigration | leave | teaching | academics | internship | welfare | graduation | graduate_studies',
    document_format      VARCHAR(20)  NOT NULL DEFAULT 'PDF' COMMENT 'PDF | DOCX | Online Form',
    local_file_path      VARCHAR(255) NULL COMMENT 'relative path under assets/forms/',
    external_url         VARCHAR(500) NULL COMMENT 'official source URL',
    sla_days             INT          NOT NULL DEFAULT 7,
    requires_advisor     TINYINT(1)   NOT NULL DEFAULT 0,
    requires_dean        TINYINT(1)   NOT NULL DEFAULT 0,
    requires_registrar   TINYINT(1)   NOT NULL DEFAULT 1,
    is_active            TINYINT(1)   NOT NULL DEFAULT 1,
    field_schema         JSON         NULL COMMENT 'JSON array of form fields',
    created_at           DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at           DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_form_code (form_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS student_form_submissions (
    id                   CHAR(36)     NOT NULL,
    tenant_id            CHAR(36)     NOT NULL DEFAULT '00000000-0000-4000-a000-000000000001',
    ref_no               VARCHAR(50)  NOT NULL COMMENT 'e.g. ES-2569-XXXXXX',
    form_code            VARCHAR(50)  NOT NULL,
    student_id           CHAR(36)     NULL COMMENT 'FK students.id if registered student',
    student_code         VARCHAR(30)  NULL,
    applicant_name       VARCHAR(255) NOT NULL,
    applicant_email      VARCHAR(255) NULL,
    applicant_phone      VARCHAR(50)  NULL,
    faculty_name         VARCHAR(150) NULL DEFAULT 'วิทยาลัยนานาชาติ (International College)',
    program_name         VARCHAR(150) NULL,
    form_payload         JSON         NOT NULL COMMENT 'Submitted field key-values',
    uploaded_files       JSON         NULL COMMENT 'Array of stored evidence paths',
    student_signature    TEXT         NULL COMMENT 'Base64 digital signature or confirmation',
    signed_at            DATETIME     NULL,
    status               VARCHAR(30)  NOT NULL DEFAULT 'submitted' COMMENT 'submitted | in_review | approved | rejected | cancelled',
    current_step         VARCHAR(50)  NOT NULL DEFAULT 'staff_review' COMMENT 'advisor_review | dean_review | registrar_review | completed',
    sla_due_at           DATETIME     NULL,
    closed_at            DATETIME     NULL,
    rejection_reason     TEXT         NULL,
    created_at           DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at           DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_submission_ref (ref_no),
    KEY idx_sub_student (student_id),
    KEY idx_sub_status (tenant_id, status),
    KEY idx_sub_form (form_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS student_form_workflow_logs (
    id                   CHAR(36)     NOT NULL,
    submission_id        CHAR(36)     NOT NULL,
    step_name            VARCHAR(50)  NOT NULL,
    actor_user_id        CHAR(36)     NULL,
    actor_role           VARCHAR(50)  NOT NULL DEFAULT 'staff',
    action               VARCHAR(50)  NOT NULL COMMENT 'submit | forward | approve | return_info | reject',
    comment              TEXT         NULL,
    created_at           DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_wf_submission (submission_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
